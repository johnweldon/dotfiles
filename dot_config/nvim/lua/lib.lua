require("os")
require("string")

function DebugDump(o, i)
  local dbg = os.getenv("NVIM_DEBUG") or "false"
  if dbg == "false" then
    return
  end

  if type(o) == "table" then
    if i == nil or i < 1 then
      i = 1
    end

    local indent = "  "
    local prefix = string.rep(indent, i)
    local finalprefix = string.rep(indent, i - 1)

    local s = "{\n"
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. prefix .. k .. ": " .. DebugDump(v, i + 1) .. ",\n"
    end

    return s .. finalprefix .. "}"
  else
    return tostring(o)
  end
end

-- example disable autoformat per filetype, in a .nvim.lua file for example
if false then
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "c", "cpp" },
    callback = function()
      vim.b.autoformat = false
    end,
  })
end
