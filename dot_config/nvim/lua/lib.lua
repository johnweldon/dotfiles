local M = {}

function M.debug_dump(o, i)
  local dbg = os.getenv("NVIM_DEBUG") or "false"
  if dbg == "false" then
    return ""
  end

  if type(o) == "table" then
    i = i or 1
    local indent = "  "
    local prefix = string.rep(indent, i)
    local finalprefix = string.rep(indent, i - 1)

    local s = "{\n"
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. prefix .. k .. ": " .. M.debug_dump(v, i + 1) .. ",\n"
    end
    return s .. finalprefix .. "}"
  else
    return tostring(o)
  end
end

-- Global function for backwards compatibility
function DebugDump(o, i)
  return M.debug_dump(o, i)
end

return M
