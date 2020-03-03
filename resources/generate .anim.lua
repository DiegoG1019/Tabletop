function table.write(t,mode)
  
  local dat,content,index,closure = nil, 0,0
  if not mode then
    dat = "local t={"
    closure = "} return t"
  else
    dat = "{"
    closure = "}"
  end
  
  for i,v in pairs(t) do
    content = content + 1
  end
  
  for i,v in pairs(t) do
    index = index +1
    if type(i) == "number" then
      if type(v) == "table" then
        if index < content then
          dat = dat .. table.write(v,true) .. ","
        else
          dat = dat .. table.write(v,true)
        end
      elseif type(v) == "string" then
        if index < content then
          dat = dat .. "\""..v.."\"" .. ","
        else
          dat = dat .. "\""..v.."\""
        end
      else
        if index < content then
          dat = dat .. tostring(v) .. ","
        else
          dat = dat .. tostring(v)
        end
      end
    else
      if type(v) == "table" then
        if index < content then
          dat = dat .. i .. "=" .. table.write(v,true) .. ","
        else
          dat = dat .. i .. "=" .. table.write(v,true)
        end
      elseif type(v) == "string" then
        if index < content then
          dat = dat .. i .. "=" .. "\"" .. v .. "\"" .. ","
        else
          dat = dat .. i .. "=" .. "\"" .. v .. "\""
        end
      else
        if index < content then
          dat = dat .. i .. "=" .. tostring(v) .. ","
        else
          dat = dat .. i .. "=" .. tostring(v)
        end
      end
    end
  end
  
  return dat..closure
  
end

