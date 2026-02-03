local M = {}

-- Standard 16-color ANSI palette
M.cterm = {
  black = 0,
  red = 1,
  green = 2,
  yellow = 3,
  blue = 4,
  magenta = 5,
  cyan = 6,
  white = 7,
  bright_black = 8,
  bright_red = 9,
  bright_green = 10,
  bright_yellow = 11,
  bright_blue = 12,
  bright_magenta = 13,
  bright_cyan = 14,
  bright_white = 15,
}

-- Check if running in a 16-color terminal
function M.is_16color_terminal()
  local term_prog = os.getenv("TERM_PROGRAM") or os.getenv("LC_TERMINAL")
  if term_prog == "Apple_Terminal" then
    return true
  end
  local term = os.getenv("TERM") or ""
  local colorterm = os.getenv("COLORTERM") or ""
  if colorterm == "truecolor" or colorterm == "24bit" then
    return false
  end
  if not term:match("256color") and not term:match("truecolor") and not term:match("24bit") then
    return true
  end
  return false
end

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
