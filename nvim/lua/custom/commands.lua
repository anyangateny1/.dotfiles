vim.api.nvim_create_user_command('ClangFormatWhich', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local ft = vim.bo.filetype

  if ft ~= 'c' and ft ~= 'cpp' then
    vim.notify('ClangFormatWhich: not a C/C++ buffer (ft=' .. ft .. ')', vim.log.levels.INFO)
    return
  end

  local style_file = vim.fs.find({ 'clang-format.yaml', '.clang-format', '_clang-format' }, { path = bufname, upward = true })[1]

  if style_file then
    vim.notify('clang-format will use: ' .. style_file, vim.log.levels.INFO)
  else
    vim.notify('clang-format: no style file found', vim.log.levels.WARN)
  end
end, {
  desc = 'Show which clang-format config is used',
})
