-- Header to Source Scaffolder for C++
-- Generates .cpp implementation files from .h header files
-- This is a local plugin (no remote dependency).

local function get_declarations_from_header(bufnr)
  local source = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local declarations = {
    includes = {},
    namespaces = {},
    functions = {},
    classes = {},
  }

  local brace_depth = 0
  local namespace_stack = {}
  local current_class = nil

  for i, line in ipairs(source) do
    local ns_name = line:match('namespace%s+([%w_]+)%s*{')
    if ns_name then
      table.insert(namespace_stack, ns_name)
    end

    local class_name = line:match('class%s+([%w_]+)') or line:match('struct%s+([%w_]+)')
    if class_name and (line:match('{') or (source[i + 1] and source[i + 1]:match('^%s*{'))) then
      if not line:match(';%s*$') then
        current_class = {
          name = class_name,
          namespace = #namespace_stack > 0 and table.concat(namespace_stack, '::') or nil,
          methods = {},
          start_line = i,
        }
        table.insert(declarations.classes, current_class)
      end
    end

    local open_braces = select(2, line:gsub('{', ''))
    local close_braces = select(2, line:gsub('}', ''))
    brace_depth = brace_depth + open_braces - close_braces

    if close_braces > 0 and #namespace_stack > 0 then
      if brace_depth < #namespace_stack then
        table.remove(namespace_stack)
      end
    end
  end

  local function parse_methods_simple(lines, class_name)
    local methods = {}
    local in_class = false
    local brace_count = 0
    local current_access = 'private'

    for _, line in ipairs(lines) do
      local class_match = line:match('class%s+' .. class_name .. '%s*[:{]')
        or line:match('struct%s+' .. class_name .. '%s*[:{]')
      if class_match then
        in_class = true
      end

      if in_class then
        for _ in line:gmatch('{') do brace_count = brace_count + 1 end
        for _ in line:gmatch('}') do brace_count = brace_count - 1 end

        if line:match('^%s*public%s*:') then
          current_access = 'public'
        elseif line:match('^%s*protected%s*:') then
          current_access = 'protected'
        elseif line:match('^%s*private%s*:') then
          current_access = 'private'
        end

        local method_pattern = '^%s*([%w_:%s%*&<>]+)%s+([%w_~]+)%s*(%b())%s*([const%s]*)%s*[;=]'
        local return_type, method_name, params, qualifiers = line:match(method_pattern)

        if return_type and method_name and params then
          local is_declaration = line:match(';%s*$') ~= nil
          local is_pure_virtual = line:match('=%s*0%s*;') ~= nil
          local is_deleted = line:match('=%s*delete%s*;') ~= nil
          local is_defaulted = line:match('=%s*default%s*;') ~= nil

          if is_declaration and not is_pure_virtual and not is_deleted and not is_defaulted then
            return_type = return_type:gsub('^%s+', ''):gsub('%s+$', '')
            return_type = return_type:gsub('virtual%s+', '')
            return_type = return_type:gsub('static%s+', '')
            return_type = return_type:gsub('inline%s+', '')
            return_type = return_type:gsub('explicit%s+', '')

            qualifiers = (qualifiers or ''):gsub('^%s+', ''):gsub('%s+$', '')

            table.insert(methods, {
              return_type = return_type,
              name = method_name,
              params = params,
              qualifiers = qualifiers,
              access = current_access,
              is_constructor = (method_name == class_name),
              is_destructor = (method_name == '~' .. class_name or method_name:match('^~')),
            })
          end
        end

        if brace_count == 0 and in_class then
          in_class = false
        end
      end
    end

    return methods
  end

  local function parse_free_functions(lines)
    local functions = {}
    local in_class = false
    local brace_count = 0
    local ns_stack = {}

    for i, line in ipairs(lines) do
      local ns_name = line:match('namespace%s+([%w_]+)%s*{')
      if ns_name then
        table.insert(ns_stack, ns_name)
      end

      if line:match('class%s+[%w_]+') or line:match('struct%s+[%w_]+') then
        if line:match('{') or (lines[i + 1] and lines[i + 1]:match('^%s*{')) then
          in_class = true
        end
      end

      if in_class then
        for _ in line:gmatch('{') do brace_count = brace_count + 1 end
        for _ in line:gmatch('}') do brace_count = brace_count - 1 end
        if brace_count == 0 then in_class = false end
      elseif not in_class then
        local func_pattern = '^([%w_:%s%*&<>]+)%s+([%w_]+)%s*(%b())%s*;'
        local return_type, func_name, params = line:match(func_pattern)

        if return_type and func_name and params then
          if not return_type:match('typedef') and not return_type:match('using') then
            return_type = return_type:gsub('^%s+', ''):gsub('%s+$', '')
            return_type = return_type:gsub('extern%s+', '')

            table.insert(functions, {
              return_type = return_type,
              name = func_name,
              params = params,
              namespace = #ns_stack > 0 and table.concat(ns_stack, '::') or nil,
            })
          end
        end

        if line:match('^}') then
          if #ns_stack > 0 then
            table.remove(ns_stack)
          end
        end
      end
    end

    return functions
  end

  for _, class_info in ipairs(declarations.classes) do
    class_info.methods = parse_methods_simple(source, class_info.name)
  end

  declarations.functions = parse_free_functions(source)
  declarations.header_filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')

  return declarations
end

local function generate_cpp_content(declarations, header_path)
  local lines = {}
  local header_filename = vim.fn.fnamemodify(header_path, ':t')

  table.insert(lines, '#include "' .. header_filename .. '"')
  table.insert(lines, '')

  local has_implementations = false
  local active_namespaces = {}

  for _, class_info in ipairs(declarations.classes) do
    if #class_info.methods > 0 then
      if class_info.namespace and not vim.tbl_contains(active_namespaces, class_info.namespace) then
        table.insert(lines, 'namespace ' .. class_info.namespace .. ' {')
        table.insert(lines, '')
        table.insert(active_namespaces, class_info.namespace)
      end

      for _, method in ipairs(class_info.methods) do
        has_implementations = true
        local sig = ''
        if not method.is_constructor and not method.is_destructor then
          sig = method.return_type .. ' '
        end
        sig = sig .. class_info.name .. '::' .. method.name .. method.params
        if method.qualifiers and method.qualifiers ~= '' then
          sig = sig .. ' ' .. method.qualifiers
        end
        table.insert(lines, sig .. ' {')
        table.insert(lines, '    // TODO: implement')
        table.insert(lines, '}')
        table.insert(lines, '')
      end
    end
  end

  local current_ns = nil
  for _, func in ipairs(declarations.functions) do
    has_implementations = true
    if func.namespace ~= current_ns then
      if current_ns then
        table.insert(lines, '} // namespace ' .. current_ns)
        table.insert(lines, '')
      end
      if func.namespace then
        table.insert(lines, 'namespace ' .. func.namespace .. ' {')
        table.insert(lines, '')
      end
      current_ns = func.namespace
    end
    local sig = func.return_type .. ' ' .. func.name .. func.params
    table.insert(lines, sig .. ' {')
    table.insert(lines, '    // TODO: implement')
    table.insert(lines, '}')
    table.insert(lines, '')
  end

  if current_ns then
    table.insert(lines, '} // namespace ' .. current_ns)
    table.insert(lines, '')
  end

  for i = #active_namespaces, 1, -1 do
    table.insert(lines, '} // namespace ' .. active_namespaces[i])
  end

  if not has_implementations then return nil end
  return lines
end

local function get_source_path(header_path)
  local dir = vim.fn.fnamemodify(header_path, ':h')
  local name = vim.fn.fnamemodify(header_path, ':t:r')
  local ext = vim.fn.fnamemodify(header_path, ':e')

  local source_ext = 'cpp'
  if ext == 'hpp' then source_ext = 'cpp'
  elseif ext == 'hxx' then source_ext = 'cxx'
  elseif ext == 'hh' then source_ext = 'cc'
  elseif ext == 'h' then source_ext = 'cpp'
  end

  local possible_dirs = {
    dir,
    dir:gsub('/include/', '/src/'),
    dir:gsub('/include$', '/src'),
    dir:gsub('/headers/', '/source/'),
    dir:gsub('/h/', '/cpp/'),
  }

  local project_root = vim.fn.getcwd()
  local relative_path = header_path:gsub('^' .. project_root .. '/', '')
  if relative_path:match('^include/') then
    local src_relative = relative_path:gsub('^include/', 'src/')
    table.insert(possible_dirs, 2, project_root .. '/' .. vim.fn.fnamemodify(src_relative, ':h'))
  end

  for _, try_dir in ipairs(possible_dirs) do
    local source_path = try_dir .. '/' .. name .. '.' .. source_ext
    if vim.fn.filereadable(source_path) == 1 then
      return source_path, true
    end
  end

  local target_dir = possible_dirs[1]
  for _, try_dir in ipairs(possible_dirs) do
    if vim.fn.isdirectory(try_dir) == 1 then
      target_dir = try_dir
      break
    end
  end

  return target_dir .. '/' .. name .. '.' .. source_ext, false
end

local function scaffold_from_header()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local ext = vim.fn.fnamemodify(filepath, ':e')

  if not vim.tbl_contains({ 'h', 'hpp', 'hxx', 'hh' }, ext) then
    vim.notify('Not a header file! Open a .h/.hpp file first.', vim.log.levels.WARN)
    return
  end

  local declarations = get_declarations_from_header(bufnr)
  if not declarations then
    vim.notify('Failed to parse header file', vim.log.levels.ERROR)
    return
  end

  local has_content = false
  for _, class in ipairs(declarations.classes) do
    if #class.methods > 0 then
      has_content = true
      break
    end
  end
  if not has_content and #declarations.functions == 0 then
    vim.notify('No function declarations found to implement', vim.log.levels.INFO)
    return
  end

  local cpp_content = generate_cpp_content(declarations, filepath)
  if not cpp_content then
    vim.notify('No implementations to generate', vim.log.levels.INFO)
    return
  end

  local source_path, exists = get_source_path(filepath)

  if exists then
    vim.ui.select({ 'Append to existing file', 'Replace existing file', 'Cancel' }, {
      prompt = 'Source file already exists: ' .. source_path,
    }, function(choice)
      if choice == 'Append to existing file' then
        local existing = vim.fn.readfile(source_path)
        table.insert(existing, '')
        table.insert(existing, '// === Scaffolded implementations ===')
        for _, line in ipairs(cpp_content) do
          if not (line:match('^#include') and vim.tbl_contains(existing, line)) then
            table.insert(existing, line)
          end
        end
        vim.fn.writefile(existing, source_path)
        vim.cmd('edit ' .. source_path)
        vim.notify('Appended implementations to ' .. source_path, vim.log.levels.INFO)
      elseif choice == 'Replace existing file' then
        vim.fn.writefile(cpp_content, source_path)
        vim.cmd('edit ' .. source_path)
        vim.notify('Created ' .. source_path, vim.log.levels.INFO)
      end
    end)
  else
    local dir = vim.fn.fnamemodify(source_path, ':h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
    vim.fn.writefile(cpp_content, source_path)
    vim.cmd('edit ' .. source_path)
    vim.notify('Created ' .. source_path, vim.log.levels.INFO)
  end
end

local function preview_scaffold()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local ext = vim.fn.fnamemodify(filepath, ':e')

  if not vim.tbl_contains({ 'h', 'hpp', 'hxx', 'hh' }, ext) then
    vim.notify('Not a header file!', vim.log.levels.WARN)
    return
  end

  local declarations = get_declarations_from_header(bufnr)
  if not declarations then
    vim.notify('Failed to parse header file', vim.log.levels.ERROR)
    return
  end

  local cpp_content = generate_cpp_content(declarations, filepath)
  if not cpp_content then
    vim.notify('No implementations to generate', vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, cpp_content)
  vim.api.nvim_set_option_value('filetype', 'cpp', { buf = buf })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Preview: Generated .cpp ',
    title_pos = 'center',
  })

  vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set('n', '<Esc>', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

-- Return as a proper local plugin spec (no external dependency needed)
return {
  dir = vim.fn.stdpath('config'),
  name = 'cpp-scaffolder',
  ft = { 'c', 'cpp' },
  config = function()
    vim.keymap.set('n', '<leader>cs', scaffold_from_header, { desc = '[C]pp [S]caffold .cpp from header' })
    vim.keymap.set('n', '<leader>cp', preview_scaffold, { desc = '[C]pp [P]review scaffold' })

    vim.api.nvim_create_user_command('CppScaffold', scaffold_from_header, {
      desc = 'Generate .cpp implementation file from current header',
    })
    vim.api.nvim_create_user_command('CppScaffoldPreview', preview_scaffold, {
      desc = 'Preview generated .cpp implementation',
    })
  end,
}
