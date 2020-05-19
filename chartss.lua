-- ChartSS.lua
-- Deltas from the boilerplate pandoc filter file are Copyright Andrew Marble, 2020
--
-- Invoke with: pandoc -t ChartSS.lua
--
-- Note:  you need not have lua installed on your system to use this
-- custom writer.  However, if you do have lua installed, you can
-- use it to test changes to the script.  'lua sample.lua' will
-- produce informative error messages if your code contains
-- syntax errors.

local pipe = pandoc.pipe
local stringify = (require "pandoc.utils").stringify

-- The global variable PANDOC_DOCUMENT contains the full AST of
-- the document which is going to be written. It can be used to
-- configure the writer.
local meta = PANDOC_DOCUMENT.meta

-- Chose the image format based on the value of the
-- `image_format` meta value.
local image_format = meta.image_format
  and stringify(meta.image_format)
  or "png"
local image_mime_type = ({
    jpeg = "image/jpeg",
    jpg = "image/jpeg",
    gif = "image/gif",
    png = "image/png",
    svg = "image/svg+xml",
  })[image_format]
  or error("unsupported image format `" .. img_format .. "`")

-- Character escaping
local function escape(s, in_attribute)
  return s:gsub("[<>&\"']",
    function(x)
      if x == '<' then
        return '&lt;'
      elseif x == '>' then
        return '&gt;'
      elseif x == '&' then
        return '&amp;'
      elseif x == '"' then
        return '&quot;'
      elseif x == "'" then
        return '&#39;'
      else
        return x
      end
    end)
end

-- Helper function to convert an attributes table into
-- a string that can be put into HTML tags.
local function attributes(attr)
  local attr_table = {}
  for x,y in pairs(attr) do
    if y and y ~= "" then
      table.insert(attr_table, ' ' .. x .. '="' .. escape(y,true) .. '"')
    end
  end
  return table.concat(attr_table)
end

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- This gives you a fragment.  You could use the metadata table to
-- fill variables in a custom lua template.  Or, pass `--template=...`
-- to pandoc, and pandoc will add do the template processing as
-- usual.
function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add('<!DOCTYPE html>')
  add('<html>')
  add('<head>')
  add('<link rel="stylesheet" href="ChartSS.css" />')
  -- a default good style
  add('<link rel="stylesheet" href="https://unpkg.com/mvp.css" />')
  add('</head>')
  add('<body style="margin:3%">')
  add(body)
  if #notes > 0 then
    add('<ol class="footnotes">')
    for _,note in pairs(notes) do
      add(note)
    end
    add('</ol>')
  end
  add('</body>')
  add('</html>')
  return table.concat(buffer,'\n') .. '\n'
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Str(s)
  return escape(s)
end

function Space()
  return " "
end

function SoftBreak()
  return "\n"
end

function LineBreak()
  return "<br/>"
end

function Emph(s)
  return "<em>" .. s .. "</em>"
end

function Strong(s)
  return "<strong>" .. s .. "</strong>"
end

function Subscript(s)
  return "<sub>" .. s .. "</sub>"
end

function Superscript(s)
  return "<sup>" .. s .. "</sup>"
end

function SmallCaps(s)
  return '<span style="font-variant: small-caps;">' .. s .. '</span>'
end

function Strikeout(s)
  return '<del>' .. s .. '</del>'
end

function Link(s, src, tit, attr)
  return "<a href='" .. escape(src,true) .. "' title='" ..
         escape(tit,true) .. "'>" .. s .. "</a>"
end

function Image(s, src, tit, attr)
  return "<img src='" .. escape(src,true) .. "' title='" ..
         escape(tit,true) .. "'/>"
end

function Code(s, attr)
  return "<code" .. attributes(attr) .. ">" .. escape(s) .. "</code>"
end

function InlineMath(s)
  return "\\(" .. escape(s) .. "\\)"
end

function DisplayMath(s)
  return "\\[" .. escape(s) .. "\\]"
end

function SingleQuoted(s)
  return "&lsquo;" .. s .. "&rsquo;"
end

function DoubleQuoted(s)
  return "&ldquo;" .. s .. "&rdquo;"
end

function Note(s)
  local num = #notes + 1
  -- insert the back reference right before the final closing tag.
  s = string.gsub(s,
          '(.*)</', '%1 <a href="#fnref' .. num ..  '">&#8617;</a></')
  -- add a list item with the note to the note table.
  table.insert(notes, '<li id="fn' .. num .. '">' .. s .. '</li>')
  -- return the footnote reference, linked to the note.
  return '<a id="fnref' .. num .. '" href="#fn' .. num ..
            '"><sup>' .. num .. '</sup></a>'
end

function Span(s, attr)
  return "<span" .. attributes(attr) .. ">" .. s .. "</span>"
end

function RawInline(format, str)
  if format == "html" then
    return str
  else
    return ''
  end
end

function Cite(s, cs)
  local ids = {}
  for _,cit in ipairs(cs) do
    table.insert(ids, cit.citationId)
  end
  return "<span class=\"cite\" data-citation-ids=\"" .. table.concat(ids, ",") ..
    "\">" .. s .. "</span>"
end

function Plain(s)
  return s
end

function Para(s)
  return "<p>" .. s .. "</p>"
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  return "<h" .. lev .. attributes(attr) ..  ">" .. s .. "</h" .. lev .. ">"
end

function BlockQuote(s)
  return "<blockquote>\n" .. s .. "\n</blockquote>"
end

function HorizontalRule()
  return "<hr/>"
end

function LineBlock(ls)
  return '<div style="white-space: pre-line;">' .. table.concat(ls, '\n') ..
         '</div>'
end

function CodeBlock(s, attr)
  -- If code block has class 'dot', pipe the contents through dot
  -- and base64, and include the base64-encoded png as a data: URL.
  if attr.class and string.match(' ' .. attr.class .. ' ',' dot ') then
    local img = pipe("base64", {}, pipe("dot", {"-T" .. image_format}, s))
    return '<img src="data:' .. image_mime_type .. ';base64,' .. img .. '"/>'
  -- otherwise treat as code (one could pipe through a highlighter)
  else
    return "<pre><code" .. attributes(attr) .. ">" .. escape(s) ..
           "</code></pre>"
  end
end

function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function trim5(s)
   return s:match'^%s*(.*%S)' or ''
end

function BarChart(items)

  local buffer2 = {}
  local nums = {}
  for _, item in pairs(items) do
      local o = mysplit(item,":")

      if # o == 2 then
        if tonumber(o[2]) ~= nil then
          table.insert(nums,tonumber(o[2]))
        else
          return nil
        end
      else
        return nil
      end
  end

  table.sort(nums)
  local m = nums[#nums]

  for _, item in pairs(items) do
    local o = mysplit(item,":")

    table.insert(buffer2, "<li class=\"BarLi\"><span class=\"ChartLabel\">" .. trim5(o[1]) .. "</span><span class=\"BarSep\"> : </span><span class=\"BarValue\" style=\"--bar-length:" .. (math.floor(tonumber(o[2])*90/m)) .. "%\">" .. trim5(o[2]) .. "</span></li>")
    end

    table.insert(buffer2, "<li class=\"BarLi\"> <span class=\"XTicks\">")

    -- for loop from 0 to m/0.9 in five steps:
    for step=0,4 do
     table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:\'" .. string.format("%.1f",step*m/.9/4) ..  "\'\"></span>")
    end

    return "<ul class=\"BarList\">\n" .. table.concat(buffer2, "\n") .. "\n</ul>"

end

function LineChart(items)

  local buffer2 = {}
  local nx = {}
  local ny = {}
  local sx = {}
  local sy = {}

  for _, item in pairs(items) do
      local o = mysplit(item,":")

      if # o == 2 then
        if tonumber(o[2]) ~= nil and tonumber (o[1]) ~= nil then
           -- print (o[1],o[2])
           table.insert(nx,tonumber(o[1]))
           table.insert(ny,tonumber(o[2]))
           table.insert(sx,tonumber(o[1]))
           table.insert(sy,tonumber(o[2]))
        else
          return nil
        end
      else
        return nil
      end
  end
  
  -- only works for a constant gap
  
  if #nx < 2 then 
     return nil
   end

  local gap = nx[2]-nx[1]
  for t=2,#nx do
     if (nx[t]-nx[t-1] ) ~= gap then
         return nil
     end
  end

  table.sort(sx)
  table.sort(sy)

  local maxx = sx[#sx]
  local minx = sx[1]
  local maxy = sy[#sy]
  local miny = sy[1]

  -- pad a bit
  local padx = (maxx-minx)*.05
  local pady = (maxy-miny)*.05

  maxx = maxx + padx
  minx = minx -padx
  maxy = maxy + padx
  miny = miny -padx

  -- now draw it

  table.insert(buffer2,"<div class=\"PlotOuterContainer\">")

  -- add y ticks in descending order

  table.insert(buffer2,"<div class=\"YTicks\">")

  if maxy==miny then
    table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",maxy) .. "'\"></span>")
  else

    for i=1,6 do
      local t = maxy - (i-1)*(maxy-miny)/5
    table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",t) .. "'\"></span>")
    end
  end

  table.insert(buffer2,"</div>")

  table.insert(buffer2,"<div class=\"FlexColumn\"> <div class=\"LineOuterContainer\">")

  table.insert(buffer2,"<li class=\"InvisibleListItem\">" .. nx[1] .. " : " .. ny[1] .. "</li>")

  for i = 2,#nx do

    local yf = string.format("%.1f",(ny[i-1]-miny)/(maxy-miny)*100)
    local yt = string.format("%.1f",(ny[i]-miny)/(maxy-miny)*100)

    -- has to start at the lowest
    local dir = "to top left"
    if (ny[i-1]>ny[i]) then
      local tmep = yt
      yt=yf
      yf=tmep
      dir="to top right"
    end

    if yf==yt then
      table.insert(buffer2,"<div class=\"SegmentContainer\"  style=\"--line-y-from:".. yf .."%;--line-y-to:"..yt.."%;--line-slope:"..dir.."\"> <li class=\"LineSegment\" style=\"border-top-style:solid\">" .. nx[i] .. " : " .. ny[i] .. "</li> <div class=\"LineBlock\"></div> </div>")
  
    else

      table.insert(buffer2,"<div class=\"SegmentContainer\"  style=\"--line-y-from:".. yf .."%;--line-y-to:"..yt.."%;--line-slope:"..dir.."\"> <li class=\"LineSegment\">" .. nx[i] .. " : " .. ny[i] .. "</li> <div class=\"LineBlock\"></div> </div>")
    end

  end 

  -- add x ticks, inside the flex-column

  table.insert(buffer2,"</div><div class=\"BarLi\"> <span class=\"XTicks\">")

  if maxx==minx then
    table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",maxx) .. "'\"></span>")
  else

    for i=1,6 do
      local t = minx+(i-1)*(maxx-minx)/5
      table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",t) .. "'\"></span>")
    end
  end


  table.insert(buffer2,"</span></div></div></div>")

  return table.concat(buffer2,"\n")

end


function ScatterPlot(items)

  local buffer2 = {}
  local nx = {}
  local ny = {}
  local sx = {}
  local sy = {}
  for _, item in pairs(items) do
      local o,p = item:gmatch "([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)"()
      
      if tonumber(o)==nil or tonumber(p)==nil then
        return nil
      end
      
      table.insert(nx,tonumber(o))
      table.insert(sx,tonumber(o))
      table.insert(ny,tonumber(p))
      table.insert(sy,tonumber(p)) 
  end

  table.sort(sx)
  table.sort(sy)

  local maxx = sx[#sx]
  local minx = sx[1]
  local maxy = sy[#sy]
  local miny = sy[1]

  -- pad a bit
  local padx = (maxx-minx)*.05
  local pady = (maxy-miny)*.05

  maxx = maxx + padx
  minx = minx -padx
  maxy = maxy + padx
  miny = miny -padx

  table.insert(buffer2,"<div class=\"PlotOuterContainer\">")

  -- add y ticks in descending order

  table.insert(buffer2,"<div class=\"YTicks\">")

  if maxy==miny then
    table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",maxy) .. "'\"></span>")
  else

    for i=1,6 do
      local t = maxy - (i-1)*(maxy-miny)/5
      table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",t) .. "'\"></span>")
    end
  end

  table.insert(buffer2,"</div>")

  table.insert(buffer2,"<div class=\"FlexColumn\"> <div class=\"ScatterMainContainer\">")

  for i=1,#nx do
    local xp=nil
    local yp

    if maxx==minx then
      xp=50
    else
      xp = string.format("%.0f",(nx[i]-minx)/(maxx-minx)*100)
    end

    if maxy==miny then
      yp=50
    else
      yp= string.format("%.0f",(ny[i]-miny)/(maxy-miny)*100)
    end

    table.insert(buffer2,"<div class=\"ScatterPoint\" style=\"--pixel-x-percent:" .. xp .. "%;--pixel-y-percent:" .. yp .. "%\"><li class=\"ScatterValue\">(" .. nx[i] .. "," .. ny[i] .. ")</li></div>" )
  end

  -- add x ticks, inside the flex-column

  table.insert(buffer2,"</div><div class=\"BarLi\"> <span class=\"XTicks\">")

  if maxx==minx then
    table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",maxx) .. "'\"></span>")
  else

    for i=1,6 do
      local t = minx+(i-1)*(maxx-minx)/5
      table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",t) .. "'\"></span>")
    end
  end


  table.insert(buffer2,"</span></div></div></div>")

  return table.concat(buffer2,"\n")
end

function StackedBar (items)

  local buffer2 = {}
  local nums = {}
  for _, item in pairs(items) do
    if item:sub(#item,#item) == '+' then
      item = item:sub(1,#item-1)
    else
      return nil
    end 

    
    local o = mysplit(item,":")

    if # o == 2 then
      if tonumber(o[2]) ~= nil then
        table.insert(nums,tonumber(o[2]))
      else
        return nil
      end
    else
      return nil
    end
  end

  local maxy=0
  for _,ba in ipairs(nums) do
    maxy=maxy+ba
  end

  local maxy = maxy*1.05 -- shouldnt hard code

  table.insert(buffer2,"<div class=\"PlotOuterContainer\">")


  -- add y ticks in descending order

  table.insert(buffer2,"<div class=\"YTicks\">")

  if maxy==0 then
    return nil
  else

    for i=1,6 do
      local t = maxy - (i-1)*(maxy)/5
      table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",t) .. "'\"></span>")
    end
  end

  table.insert(buffer2,"</div>\n<div class=\"FlexColumn StackFlexColumn\">")



  for _, item in pairs(items) do
    item = item:sub(1,#item-1)
    local o = mysplit(item,":")
    table.insert(buffer2,"<li class=\"BarBlock\" style=\"--stack-height:"..string.format("%.1f",tonumber(o[2])/maxy*100) .."%\">" .. trim5(o[1]) .. ": " .. trim5(o[2]) .. "</li>")    
  end


  table.insert(buffer2,"</div></div>")

  return "<ul class=\"BarList\">\n" .. table.concat(buffer2, "\n") .. "\n</ul>"

end

function Waterfall(items)
  local buffer2 = {}
  local nums = {}
  for i =2,#items do
  local item=items[i]
  if item:sub(#item,#item) == '+' then
     item = item:sub(1,#item-1)
  else
    return nil
  end

  local o = mysplit(item,":")

    if # o == 2 then
      if tonumber(o[2]) ~= nil then
        table.insert(nums,tonumber(o[2]))
      else
        return nil
      end
    else
      return nil
    end
  end

  local item=items[1]
  item = item:sub(1,#item-1)
  local maxy = mysplit(item,":")[2]
  if tonumber(maxy) == nil then
    return nil
  end

  maxy = maxy*1.05 -- shouldnt hard code

  -- now draw it

  table.insert(buffer2,"<div class=\"PlotOuterContainer\">")

  -- add y ticks in descending order

  table.insert(buffer2,"<div class=\"YTicks\">")

  if maxy==0 then
    return nil
  else

    for i=1,6 do
      local t = maxy - (i-1)*(maxy)/5
      table.insert(buffer2,"<span class=\"TickLabel\" style=\"--tick-label:'" .. string.format("%.1f",t) .. "'\"></span>")
    end
  end

  table.insert(buffer2,"</div>")

  table.insert(buffer2,"<div class=\"FlexColumn\"> <div class=\"LineOuterContainer\">")

  local last_hp=1/1.05*100

  for _,item in pairs(items) do
    local item = item:sub(1,#item-1)
    local label = trim5(mysplit(item,":")[1])
    local value = tonumber(mysplit(item,":")[2])

    local height_percent = string.format("%.1f",value/maxy*100)
    local yf = string.format("%.1f",last_hp-(value/maxy)*100) -- hard code
    if _ > 1 then 
      last_hp =last_hp - value/maxy*100 
    end

    table.insert(buffer2,"<div class=\"WaterfallContainer\"> <li class=\"BarBlock\" style=\"--stack-height:" .. height_percent .. "%;width:100%\">" .. item .. "</li> <div class=\"LineBlock\" style=\"--line-y-from:" .. yf .. "%\"></div> </div>")

  end

  -- add x ticks, inside the flex-column

  table.insert(buffer2,"</div><div class=\"BarLi\"> <span class=\"XTicks\">")



  table.insert(buffer2,"</span></div></div></div>")

  return table.concat(buffer2,"\n")



end

function DefaultBulletList(items)

  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "<li>" .. item .. "</li>")
   end
    
   return "<ul>\n" .. table.concat(buffer, "\n") .. "\n</ul>"

end

function BulletList(items)
  -- Check and see if it is a list that can be parsed into <Category>:<Number>

  local l1 = trim5(items[1])
  local la=nil

  local lb=nil
  la,lb= l1:gmatch "([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)"()
  -- see if items[1] matches one of the data point formats
  local buffer = nil
  if # mysplit(l1,":")==2 and tonumber(mysplit(l1,":")[2]) ~= nil then

      if tonumber(mysplit(l1,":")[1]) ~= nil then
         buffer = LineChart(items)
      end

      if buffer==nil then

       buffer = BarChart(items)
      end
  
  elseif l1:sub(#l1,#l1)=='+' then
       -- try to parse it like a stacked bar
       buffer = StackedBar(items)

  elseif l1:sub(#l1,#l1)=='=' then
       -- try to parse it like a waterfall
       buffer = Waterfall(items)

  elseif tonumber(la)~=nil and tonumber(lb)~=nil then
       buffer = ScatterPlot(items) 
   end

  if buffer ~= nil then
         return buffer
  else 
         return DefaultBulletList(items)
  end

end

function OrderedList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "<li>" .. item .. "</li>")
  end
  return "<ol>\n" .. table.concat(buffer, "\n") .. "\n</ol>"
end

function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    local k, v = next(item)
    table.insert(buffer, "<dt>" .. k .. "</dt>\n<dd>" ..
                   table.concat(v, "</dd>\n<dd>") .. "</dd>")
  end
  return "<dl>\n" .. table.concat(buffer, "\n") .. "\n</dl>"
end

-- Convert pandoc alignment to something HTML can use.
-- align is AlignLeft, AlignRight, AlignCenter, or AlignDefault.
function html_align(align)
  if align == 'AlignLeft' then
    return 'left'
  elseif align == 'AlignRight' then
    return 'right'
  elseif align == 'AlignCenter' then
    return 'center'
  else
    return 'left'
  end
end

function CaptionedImage(src, tit, caption, attr)
   return '<div class="figure">\n<img src="' .. escape(src,true) ..
      '" title="' .. escape(tit,true) .. '"/>\n' ..
      '<p class="caption">' .. caption .. '</p>\n</div>'
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add("<table>")
  if caption ~= "" then
    add("<caption>" .. caption .. "</caption>")
  end
  if widths and widths[1] ~= 0 then
    for _, w in pairs(widths) do
      add('<col width="' .. string.format("%.0f%%", w * 100) .. '" />')
    end
  end
  local header_row = {}
  local empty_header = true
  for i, h in pairs(headers) do
    local align = html_align(aligns[i])
    table.insert(header_row,'<th align="' .. align .. '">' .. h .. '</th>')
    empty_header = empty_header and h == ""
  end
  if empty_header then
    head = ""
  else
    add('<tr class="header">')
    for _,h in pairs(header_row) do
      add(h)
    end
    add('</tr>')
  end
  local class = "even"
  for _, row in pairs(rows) do
    class = (class == "even" and "odd") or "even"
    add('<tr class="' .. class .. '">')
    for i,c in pairs(row) do
      add('<td align="' .. html_align(aligns[i]) .. '">' .. c .. '</td>')
    end
    add('</tr>')
  end
  add('</table>')
  return table.concat(buffer,'\n')
end

function RawBlock(format, str)
  if format == "html" then
    return str
  else
    return ''
  end
end

function Div(s, attr)
  return "<div" .. attributes(attr) .. ">\n" .. s .. "</div>"
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)

