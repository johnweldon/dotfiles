require("string")

--[[]x]
local function dump(o, i)
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
      s = s .. prefix .. k .. ": " .. dump(v, i + 1) .. ",\n"
    end

    return s .. finalprefix .. "}"
  else
    return tostring(o)
  end
end
--[[]]

return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    --[[
     default sources:
      1: lsp,
      2: path,
      3: snippets,
      4: buffer,
      5: lazydev,
      6: dadbod,
    ]]
    opts.sources.per_filetype = { markdown = { "lsp", "path", "snippets", "lazydev", "dadbod" } }
    opts.sources.min_keyword_length = 4
  end,
}
