local ts = tostring
function tostring(...) --Replaces te default tostring function for one that can concatenate and print multiple values
  
  local a = {...}
  if #a <= 1 then
    
    return ts(a[1])
    
  else
    
    local b = ""
    
    for i,v in ipairs(a) do
      b = b.." "..ts(v)
    end
    
    return b
    
  end
  
end

function newCalendar(y,m,d,h,mi,s,days)
  if not y then y = 0 end
  if not m then m = 0 end
  if not d then d = 0 end
  if not h then h = 0 end
  if not mi then mi = 0 end
  if not s then s = 0 end
  if not days then days = 0 end
  local weekday = days+1
  while weekday > 7 do
    weekday = weekday-7
  end
  local calendar = {}
  calendar.time = {y,m,d,h,mi,s,days,weekday}
  function calendar.seconds(n,f)
    calendar.time[6] = calendar.time[6]+n
    if not f then calendar.clock() end
  end
  function calendar.minutes(n,f)
    calendar.time[5] = calendar.time[5]+n
    if not f then calendar.clock() end
  end
  function calendar.hours(n,f)
    calendar.time[4] = calendar.time[4]+n
    if not f then calendar.clock() end
  end
  function calendar.day(n,f)
    calendar.time[3] = calendar.time[3]+n
    calendar.time[7] = calendar.time[7]+n
    calendar.time[8] = calendar.time[8]+n
    if not f then calendar.clock() end
  end
  function calendar.month(n,f,a)
    calendar.time[2] = calendar.time[2]+n
    if a then
      calendar.time[7] = calendar.time[7]+(n*30)
      calendar.time[8] = calendar.time[8]+(n*30)
    end
    if not f then calendar.clock() end
  end
  function calendar.year(n,f,a)
    calendar.time[1] = calendar.time[1]+n
    if a then
      calendar.time[7] = calendar.time[7]+(n*360)
      calendar.time[8] = calendar.time[8]+(n*360)
    end
    if not f then calendar.clock() end
  end
  function calendar.clock()
    calendar.time[8] = calendar.time[7]
    while calendar.time[6] > 59 do
      calendar.minutes(1,true)
      calendar.time[6] = calendar.time[6]-60
    end
    while calendar.time[5] > 59 do
      calendar.hours(1,true)
      calendar.time[5] = calendar.time[5]-60
    end
    while calendar.time[4] > 23 do
      calendar.day(1,true)
      calendar.time[4] = calendar.time[4]-24
    end
    while calendar.time[3] > 30 do
      calendar.month(1,true)
      calendar.time[3] = calendar.time[3]-30
    end
    while calendar.time[2] > 12 do
      calendar.year(1,true)
      calendar.time[2] = calendar.time[2]-12
    end
    while calendar.time[8] > 7 do
      calendar.time[8] = calendar.time[8]-7
    end
    while calendar.time[6] < 0 do
      calendar.minutes(-1,true)
      calendar.time[6] = 60+calendar.time[6]
    end
    while calendar.time[5] < 0 do
      calendar.hours(-1,true)
      calendar.time[5] = 60+calendar.time[5]
    end
    while calendar.time[4] < 0 do
      calendar.day(-1,true)
      calendar.time[4] = 24+calendar.time[4]
    end
    while calendar.time[3] < 1 do
      calendar.month(-1,true)
      calendar.time[3] = 30+calendar.time[3]
    end
    while calendar.time[2] < 1 do
      calendar.year(-1,true)
      calendar.time[2] = calendar.time[2]+12
    end
    while calendar.time[8] > 7 do
      calendar.time[8] = calendar.time[8]-7
    end
  end
  
  function calendar.retrieve()
    return unpack(calendar.time)
  end
  
  return calendar
end

function toggle(bool)
  if bool then return false else return true end
end

local lmgp = love.mouse.getPosition
function love.mouse.getPosition()
  local mx,my = lmgp()
  mx = mx-win.mw
  my = my-win.mh
  return mx,my
end

function love.mouse.getRelativePosition()
  local mx,my = love.mouse.getPosition()
  local camx,camy,camr,camz = camera.getPos()
  mx = (mx/camz)+camx
  my = (my/camz)+camy
  return mx,my
end

local ___type = type
function type(v)
  
  local t = ___type(v)
  
  if t == "userdata" then
    if t == "table" and t.type then
      return t:type()
    else
      return t
    end 
  else
    return t
  end
  
end

function strexplode(str,level)
  level = level or 1
  if level < 1 then level = 1 elseif level > 2 then level = 2 end
  if type(str) == "string" then
    local b = {}
    if level == 1 then
      for string in str:gmatch("%S+") do
        table.insert(b,string)
      end
      return b
    elseif level == 2 then
      for string in str:gmatch("%S") do
        table.insert(b,string)
      end
      return b
    end
  end
end

function setReadOnly(t)
  return setmetatable(
    {},
    {
      __index = t,
      __newindex = function(t,k,v)
        log.record("Lua","Attempt to update a read-only table", true, 2)
      end,
      __metatable = nil
    }
  )
end

local strformat = string.format
function string.format(format, ...)
  local args = {...}
  local match_no = 1
  for pos, type in string.gmatch(format, "()%%.-(%a)") do
    if type == 't' then
      args[match_no] = tostring(args[match_no])
    end
    match_no = match_no + 1
  end
  return strformat(string.gsub(format, '%%t', '%%s'),
         unpack(args,1,select('#',...)))
end

local tn = tonumber
function tonumber(...)
  
  local str = {...}
  local num = {}
  
  if #str < 1 then return nil end
  
  for i,v in ipairs(str) do
    
    table.insert(num, tn(v))
    
  end
  
  return unpack(num)

end

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