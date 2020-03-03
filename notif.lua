notif = {
  
  regular = {
    
    --[[
    
    message = {msg, color, 5}
    
    ]]--
    
  },
  
  important = {
    
    --Will show at just like regular messages, but twice as big
    --On-screen duration: 10
    
  },
  
  header = {
    
    --Will show up at the center of the screen, 5 times the size of a regular message
    --On-screen: 5
    
  }
  
}

local msgproc = {
  
  function() return "regular",5 end,
  function() return "important",10 end,
  function() return "header",5 end
  
}

function notif.newnotif(msg, level, color)
  
  local typ,time
  level = tonumber(level) or 1
  typ,time = msgproc[level]()
  
  if not type(color) == "table" or not color then
    color = {255,255,255}
  else
    local r,g,b = unpack(color)
    color = {r or 255 , g or 255 , b or 255}
  end
  
  typ = typ or 1
  time = time or 5
  
  table.insert(notif[typ], #notif[typ]+1, {msg,color,time})
  
  log.record("Notification System", msg.."~"..typ)
  
end

local dt = 0.03 --Dirty save; this whole module needs to be done from scratch.
local function draw()
  
  assets.font("lucida console",16)
  for i,v in ipairs(notif.regular) do --Each of these loop through the tables and draws all the messages
    lg.setColor(v[2])
    lg.printf(tostring(v[1]), 5,20*i,win.w,"left")
    v[3] = v[3] - dt
    if v[3] <= 0 then
      table.remove(notif.regular,i)
    end
  end
  
  assets.font("lucida console",26)
  for i,v in ipairs(notif.important) do
    lg.setColor(v[2])
    lg.printf(v[1], 5,30*i,win.w,"right")
    v[3] = v[3] - dt
    if v[3] <= 0 then
      table.remove(notif.important,i)
    end
  end
  
  assets.font("lucida console",32)
  for i,v in ipairs(notif.header) do
    lg.setColor(v[2])
    lg.printf(v[1], 0,100*i,win.w,"center")
    v[3] = v[3] - dt
    if v[3] <= 0 then
      table.remove(notif.header,i)
    end
  end
  
end

function notif.update(dt)
  
  camera.gui(draw,5)
  
end
  
love.addtl("update","notif",notif.update) --Registers itself onto update

--DELETE AND WRITE FROM SCRATCH, DT NOT COOL