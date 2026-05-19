# Debugging with nvim-dap

Debug configs live in your **project**, not in this dotfiles repo. nvim-dap reads
`.vscode/launch.json` (VS Code format) automatically when you press `<F5>`.

## Quick start

1. Copy the template into your project:

   ```bash
   mkdir -p .vscode
   cp ~/.config/nvim/launch.json.example .vscode/launch.json
   ```

2. Edit `.vscode/launch.json` — set `program`, `args`, `cwd` for your binary or package.

3. Install adapters (once per machine, via Mason):

   ```
   :MasonInstall codelldb delve debugpy
   ```

4. Open a source file, set breakpoints (`<leader>b`), press `<F5>`.

## Keymaps

| Key | Action |
|-----|--------|
| `<F5>` | Start / continue |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle DAP UI |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>dd` | Pick launch configuration |

## `launch.json` fields (common)

| Field | Meaning |
|-------|---------|
| `name` | Label shown when picking a config |
| `type` | Adapter: `codelldb`, `go`, `debugpy` |
| `request` | `launch` (start program) or `attach` (existing PID) |
| `program` | Executable or entry file |
| `cwd` | Working directory |
| `args` | Command-line arguments (array of strings) |
| `env` | Environment variables object |
| `stopOnEntry` | Pause on first line |

### Variables

| Variable | Expands to |
|----------|------------|
| `${workspaceFolder}` | Project root (where `.vscode/` lives) |
| `${file}` | Current buffer path |
| `${fileDirname}` | Directory of current file |

## Examples

### C++ (CMake, binary in `build/`)

```json
{
  "name": "My app",
  "type": "codelldb",
  "request": "launch",
  "program": "${workspaceFolder}/build/my_app",
  "cwd": "${workspaceFolder}",
  "args": ["--config", "config.json"]
}
```

### C++ attach to running process

```json
{
  "name": "Attach",
  "type": "codelldb",
  "request": "attach",
  "pid": "${command:pickProcess}"
}
```

`pickProcess` opens a picker (Telescope if available).

### Go

```json
{
  "name": "Debug package",
  "type": "go",
  "request": "launch",
  "mode": "debug",
  "program": "${workspaceFolder}/cmd/myapp"
}
```

### Python

```json
{
  "name": "Debug script",
  "type": "debugpy",
  "request": "launch",
  "program": "${file}",
  "cwd": "${workspaceFolder}"
}
```

## Multiple configs

Put several objects in `configurations`. `<F5>` uses the last selected config; to pick one:

```vim
:lua require('dap').select_config_to_run()
```

Use `<leader>dd` to pick a configuration before starting.

## Troubleshooting

- **No configurations found** — create `.vscode/launch.json` in the project root (same level as `.git`).
- **Adapter not found** — `:MasonInstall codelldb` (or `delve` / `debugpy`).
- **Program not found** — check `program` path; use absolute path or `${workspaceFolder}/...`.
- **Config not loading** — `:lua print(vim.inspect(require('dap').configurations))` after `<F5>` once.

See also: [nvim-dap wiki](https://github.com/mfussenegger/nvim-dap/wiki/Troubleshooting).
