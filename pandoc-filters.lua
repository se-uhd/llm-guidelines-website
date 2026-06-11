-- Pandoc Lua filters for LaTeX → Markdown conversion.
-- Pandoc wraps unknown environments in Div with the environment name as class.

-- Convert plain environment (lstnewenvironment) to code blocks.
-- Convert enumerate* environment to OrderedList.
-- Preserve display math for MathJax. markdown_strict otherwise tries to
-- down-convert TeX math to plain Markdown and warns on fractions/binomials.
function Para(el)
  if #el.content >= 1 and el.content[1].t == "Math" and el.content[1].mathtype == "DisplayMath" then
    local blocks = {pandoc.RawBlock("markdown", "$$" .. el.content[1].text .. "$$")}
    local rest = {}
    local start = 2
    if el.content[start] and el.content[start].t == "SoftBreak" then
      start = start + 1
    end
    for i = start, #el.content do
      table.insert(rest, el.content[i])
    end
    if #rest > 0 then
      table.insert(blocks, pandoc.Para(rest))
    end
    return blocks
  end
end

function Div(el)
  if el.classes:includes("plain") then
    local doc = pandoc.Pandoc(el.content)
    local text = pandoc.write(doc, "plain")
    local trimmed = text:gsub("\n+$", "")
    return pandoc.CodeBlock(trimmed)
  end

  if el.classes:includes("enumerate*") then
    local items = {}
    for _, block in ipairs(el.content) do
      if block.t == "Para" or block.t == "Plain" then
        table.insert(items, {pandoc.Plain(block.content)})
      end
    end
    if #items > 0 then
      return pandoc.OrderedList(items)
    end
  end
end

-- Tighten lists: convert single-Para items to Plain (removes <p> wrapping).
-- Only applies when ALL items in the list are single-paragraph.
local function tighten(items)
  for _, item in ipairs(items) do
    if #item ~= 1 or item[1].t ~= "Para" then
      return nil
    end
  end
  local tight = {}
  for _, item in ipairs(items) do
    table.insert(tight, {pandoc.Plain(item[1].content)})
  end
  return tight
end

function OrderedList(el)
  local tight = tighten(el.content)
  if tight then
    el.content = tight
  end
  return el
end

function BulletList(el)
  local tight = tighten(el.content)
  if tight then
    el.content = tight
  end
  return el
end
