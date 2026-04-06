local M = {}

function M.setup()
  -- WSL clipboard: requires clip.exe (copy) and powershell.exe (paste) from Windows interop.
  if vim.fn.executable("clip.exe") ~= 1 or vim.fn.executable("powershell.exe") ~= 1 then
    return
  end

  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

return M
