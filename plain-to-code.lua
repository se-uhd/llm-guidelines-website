-- Convert plain environment (lstnewenvironment) to code blocks.
-- Pandoc wraps unknown environments in Div with the environment name as class.
function Div(el)
  if el.classes:includes("plain") then
    local doc = pandoc.Pandoc(el.content)
    local text = pandoc.write(doc, "plain")
    local trimmed = text:gsub("\n+$", "")
    return pandoc.CodeBlock(trimmed)
  end
end
