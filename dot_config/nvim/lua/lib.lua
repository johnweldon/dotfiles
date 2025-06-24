local M = {}

-- Check if debug mode is enabled
function M.is_debug_enabled()
  local dbg = os.getenv("NVIM_DEBUG") or "false"
  return dbg ~= "false"
end

-- Standardized debug logging
function M.debug_log(plugin_name, message, data)
  if not M.is_debug_enabled() then
    return
  end

  local timestamp = os.date("%H:%M:%S")
  local log_msg = string.format("[%s] %s: %s", timestamp, plugin_name, message)

  if data then
    log_msg = log_msg .. "\n" .. M.debug_dump(data, 1)
  end

  print(log_msg)
end

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

-- Create a debug logger for a specific plugin
function M.create_logger(plugin_name)
  return {
    log = function(message, data)
      M.debug_log(plugin_name, message, data)
    end,
    dump = function(data)
      return M.debug_dump(data)
    end,
    is_enabled = M.is_debug_enabled,
  }
end

return M
