function love.addtl(list, name, func)
  
  if callList[list][name] then
    log.record("Main",name.." entry was already added into "..list)
  else
    callList[list][name] = func
    log.record("Main","Added "..name.." entry into "..list)
  end
  
end

function love.remfl(list, name)
  
  if callList[list][name] then
    callList[list][name] = nil
    log.record("Main","Removed "..name.." entry into "..list)
  else
    log.record("Main","No such entry "..name.." in list "..list)
  end
  
end

callList = {
  
  update        = {},
  textinput     = {},
  keypressed    = {},
  mousemoved    = {},
  mousepressed  = {},
  mousereleased = {},
  focus         = {}
  
}

--[[
  
  Basically, for all of this; it's a queue list. You register yourself, you get updated, and/or get input forwarded to you.
  
--]]

function love.update(dt)
  
  local loopCount = 0
  
  log.subrecord("Main", "Memory usage: "..collectgarbage("count").." KB")
  if collectgarbage("count") > (1*(1024^2)) then love.lowmemory() end
  if dt > 30/conf.global.fpscap then log.record("Update","Can't keep up! System time changed or Game overloaded. Running below half of target framerate!"..dt) return end
  log.subrecord("Update",dt)
  
  for i,v in pairs(callList.update) do
    
    loopCount = loopCount + 1
    if conf.debug.strict then
      v(dt)
    else
      local s,msg = pcall(v,dt)
      if not s then log.record("Callbacks", ("love.update was unable to execute: %t - %t, error: %s"):format(i,v,msg), true, 1) end
    end
    
  end
  
  log.subrecord("Update",("Updated %d objects"):format(loopCount))
  
end

function love.textinput(t)
  
  for i,v in pairs(callList.textinput) do
    
    if conf.debug.strict then
      v(t)
    else
      local s,msg = pcall(v,t)
      if not s then log.record("Callbacks", ("love.textinput was unable to execute: %t - %t, error: %s"):format(i,v,msg), true, 1) end
    end
    
  end
  
end

function love.keypressed(key)
  
  if key == conf.global.screenshotkey then
    
    local screenshot = lg.newScreenshot(true)
    fileman.dir("screenshots",true,"Main")
    
    screenshot:encode('png', "screenshots/"..os.time() .. math.random(0,1000) .. '.png')
    
    log.record("Main","Screenshot taken and saved to: "..lf.getSaveDirectory().."/screenshots/"..os.time()..".png")
    notif.newnotif("Screenshot taken and saved to: "..lf.getSaveDirectory().."/screenshots/"..os.time()..".png")
    
  end
  
  for i,v in pairs(callList.keypressed) do
    if conf.debug.strict then
      v(key)
    else
      local s,msg = pcall(v,key)
      if not s then log.record("Callbacks", ("love.keypressed was unable to execute: %t - %t, error: %s"):format(i,v,msg), true, 1) end
    end
  end
  
end

function love.mousemoved(x, y, dx, dy)
  
  for i,v in pairs(callList.mousemoved) do
    if conf.debug.strict then
      v(x, y, dx, dy)
    else
      local s,msg = pcall(v, x, y, dx, dy)
      if not s then log.record("Callbacks", ("love.mousemoved was unable to execute: %t - %t, error: %s"):format(i,v,msg), true, 1) end
    end
  end
  
end

function love.mousepressed(x,y,button)
  
  for i,v in pairs(callList.mousepressed) do
    if conf.debug.strict then
      v(x, y, button)
    else
      local s,msg = pcall(v, x, y,button)
      if not s then log.record("Callbacks", ("love.mousepressed was unable to execute: %t - %t, error: %s"):format(i,v,msg), true, 1) end
    end
  end
  
end

function love.mousereleased(x,y,button)
  
  for i,v in pairs(callList.mousereleased) do
    if conf.debug.strict then
      v(x, y, dx, dy)
    else
      local s,msg = pcall(v, x, y, dx, dy)
      if not s then log.record("Callbacks", ("love.mousereleased was unable to execute: %t - %t, error: %s"):format(i,v,msg), true, 1) end
    end
  end
  
end

function love.focus(f)
  
  for i,v in pairs(callList.focus) do
    if conf.debug.strict then
      v(f)
    else
      local s,msg = pcall(f)
      if not s then log.record("Callbacks", ("love.focus was unable to execute: %t - %t, error: %s"):format(i,v,msg), true, 1) end
    end
  end
  
end

function love.threaderror(thread, errstr)
  
  -- [love.threaderror](https://love2d.org/wiki/love.threaderror)
  -- [Threads](https://love2d.org/wiki/Thread)
  
end