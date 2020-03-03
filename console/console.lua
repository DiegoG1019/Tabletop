console = {
  
  active = false,
  callList_id = {},
  command = "",
  report = "",
  input = "",
  output={},
  avns=nil, --Arbitrary Variable Name Space
  big = false,
  debug = false,
  manualinput = {""},
  miid = 1,
  
  cmds = require 'console.cmds'
  
}

--To-do: Make it scrollable

local function draw()
  
  assets.font("lucida console",16)
  
  if console.big then
    
    local x,w,h,y = 2, conf.window.width-4, conf.window.height-70
    y = win.h-h
    
    lg.setColor(35, 35, 35, 120)
    lg.rectangle("fill", x,y,w,h)
    
    lg.setColor(220, 220, 220, 120)
    lg.rectangle("line", x,y,w,h)
    
    lg.setColor(35, 35, 120, 120)
    
    lg.rectangle("fill", 2, win.h-200, w,win.h-25)
    
    lg.rectangle("fill", 0, win.h-555, win.w, 25)
    
    lg.setColor(220, 255, 220, 120)
    lg.printf(console.report, -10, win.h-550, win.w, "right")
    lg.printf(console.input, 5, win.h-190, win.w, "left")
    
    for i,v in pairs(console.output) do
      lg.printf(tostring(v), 5, win.h-((30*i)+190), win.w, "left")
    end
    
  else
    
    local x,w,h,y = 2, win.w-4, win.h/2.5
    y = win.h-h
    
    lg.setColor(35, 35, 35, 120)
    
    lg.rectangle("fill", x,y,w,h)
    
    lg.setColor(220, 220, 220, 120)
    lg.rectangle("line", x,y,w,h)
    
    lg.setColor(35, 35, 120, 120)
    
    lg.rectangle("fill", 2, win.h-25, w,win.h-25)
    
    lg.setColor(35, 35, 120, 120)
    lg.rectangle("fill", win.w-(150), win.h/1.8, 150, 25)
    
    lg.setColor(220, 255, 220, 120)
    lg.printf(console.report, -10, win.h/1.78, win.w, "right")
    lg.printf(console.input, 5, win.h-20, win.w, "left")
    
    for i,v in pairs(console.output) do
      lg.printf(tostring(v), 5, win.h-((30*i)+15), win.w, "left")
    end
    
  end
  
  while #console.output > 15 do table.remove(console.output, #console.output) end

end

function console.load()
  
  love.addtl("update", "console",console.update)
  love.addtl("keypressed", "console", console.keypressed)
  love.addtl("textinput", "console", console.textinput)
  log.record("Console","Successfully registered in update and input, activation key: "..conf.console.keyAct)
  
end

function console.textinput(t)
  
  if console.active then
    
    if t ~= "`" then
      console.input = string.format("%s%s",console.input,t)
    end
    
  end
  
end

function console.keypressed(key)
  
  if console.active then
    
    if key == "backspace" then
      local byteoffset = utf8.offset(console.input, -1)
      
      if byteoffset then
        console.input = string.sub(console.input, 1, byteoffset - 1)
      end
      
    end
    
    if key == "return" then
      
      if console.big then
        
        if lk.isDown("lshift") or lk.isDown("rshift") then
          
          console.input = console.input.."\n"
          
        else
          
          local c = strexplode(console.input,1)
          table.insert(console.manualinput,console.input)
          console.miid = #console.manualinput
          console.execute(unpack(c))
          console.input = ""
          
        end
        
      else
        
        local c = strexplode(console.input,1)
        table.insert(console.manualinput,console.input)
        console.miid = #console.manualinput
        console.execute(unpack(c))
        console.input = ""
        
      end
      
    end
    
  end
  
  if key == conf.console.keyAct then
    
    if console.active then
      console.active = false
      game.truepause(false)
    else
      console.active = true
      game.truepause(true)
    end
    
  end
  
  if key == "up" then
    if console.miid < 1 then console.miid = 1 end
    console.input = console.manualinput[console.miid]
    console.miid = console.miid - 1
  end
  
  if key == "down" then
    console.miid = console.miid + 1
    if console.miid > #console.manualinput then console.miid = #console.manualinput end
    console.input = console.manualinput[console.miid]
  end
  
end

function console.execute(command,...)
  
  local b
  if conf.debug.consolestrict then
    b = {true,console.cmds[command](...)}
  else
    b = {pcall(console.cmds[command],...)}
  end
  
  if not conf.debug.otc then
    
    if unpack(b,2) then
      local a = {unpack(b,2)}
      for i,v in pairs(a) do
        if type(v) == type({}) then
          for i1,v1 in pairs(v) do
            table.insert(console.output,1, v1)
          end
        else
          table.insert(console.output,1, v)
        end
      end
    end
    
  end
  
  console.report = string.format("%t::%t", command,b[1])
  
  log.record("Console",string.format("Executed: %s and returned: %s", console.report, tostring(unpack(b,2))))
  
  return unpack(b,2)
  
end

function console.update()
  
  if console.active then --Need to be able to pause/block all other input when this is active. Don't worry about game.lua, it'll take care of itself.
    camera.gui(draw,5)
  end
  
end