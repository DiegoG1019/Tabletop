local c = {}

---Dev Utilities

local help = {
  
  help            = lang.cmds.help,
  clear           = lang.cmds.clear,
  fotc            = lang.cmds.fotc,
  lua             = lang.cmds.lua,
  sys             = lang.cmds.sys,
  getlist         = lang.cmds.get,
  conf            = lang.cmds.conf,
  profile         = lang.cmds.profile,
  getentityinfo   = lang.cmds.getentityinfo,
  entitycount     = lang.cmds.entitycount,
  getcamerapos    = lang.cmds.getcamerapos,
  getvers         = lang.cmds.getvers,
  movecamera      = lang.cmds.movecamera,
  setcamera       = lang.cmds.movecamera,
  setcamera       = lang.cmds.movecamera,
  forcemovecamera = lang.cmds.movecamera
  
}

function c.getvers()
  return getGameVer()
end

function c.profile(a,...)
  
  if conf.debug.strict then
    
    return select(2,pcall(log.profile[a],...))
    
  else
    
    return lang.cmds.disabled
    
  end
  
end

function c.movecamera(x,y)
  local cx,cy = camera.getPos()
  if not x then x = cx end
  if not y then y = cy end
  return true
end

function c.forcesetrotation(r)
  local _,_,cr,_ = camera.getPos()
  if not r then r = cr end
  camera.forcesetrotation(r)
  return true
end

function c.setrotation(r)
  local _,_,cr,_ = camera.getPos()
  if not r then r = cr end
  camera.setrotation(r)
  return true
end

function c.rotate(r)
  local _,_,cr,_ = camera.getPos()
  if not r then r = cr end
  camera.rotate(r)
  return true
end

function c.forcerotate(r)
  local _,_,cr,_ = camera.getPos()
  if not r then r = cr end
  camera.forcerotate(r)
  return true
end

function c.zoom(z)
  local _,_,_,cz = camera.getPos()
  if not z then z = cz end
  camera.zoom(z)
  return true
end

function c.forcezoom(z)
  local _,_,_,cz = camera.getPos()
  if not z then z = cz end
  camera.forcezoom(z)
  return true
end

function c.setzoom(z)
  local _,_,_,cz = camera.getPos()
  if not z then z = cz end
  camera.setzoom(z)
  return true
end

function c.forcesetzoom(z)
  local _,_,_,cz = camera.getPos()
  if not z then z = cz end
  camera.forcesetzoom(z)
  return true
end

function c.setcamera(x,y)
  local cx,cy = camera.getPos()
  if not x then x = cx end
  if not y then y = cy end
  camera.move(x,y)
  return true
end

function c.forcemovecamera(x,y)
  local cx,cy = camera.getPos()
  if not x then x = cx end
  if not y then y = cy end
  camera.forcemove(x,y)
  return true
end

function c.forcesetcamera(x,y)
  local cx,cy = camera.getPos()
  if not x then x = cx end
  if not y then y = cy end
  camera.forceset(x,y)
  return true
end

function c.help(f)
  
  if f then
    
    return help[f]
    
  else
    
    local a = ""
    for i,v in pairs(help) do
      a = a.."; "..i
    end
    return a
    
  end
  
end

function c.clear()
  
  console.command = ""
  console.report = ""
  console.input = ""
  console.output={}
  
end

function c.fotc()
  if conf.debug.otc then
    config.change("debug","otc",false)
  else
    config.change("debug","otc",true)
  end
end

function c.lua(...)
  
  return loadstring(tostring(...))() or lang.cmds.luachunk
  
end

function c.sys(func)
  
  if func == "quit" then
    love.event.quit()
  elseif func == "restart" then
    love.event.quit(func)
  else
    return "sys::available = quit, restart"
  end
  
end

function c.mode()
  
  if console.big then console.big = false return lang.cmds.consmall else console.big = true return lang.cmds.conbig end
  
end

local debug_data = false

function c.conf(menu,option,value)
  
  return configure.change(menu,option,value)
  
end

local getlist = {
  
  gui = function() return table.write(camerapast.guiList,true) end,
  draw = function() return table.write(camerapast.drawList,true) end,
  fx   = function() return table.write(camerapast.fxList,true) end,
  update = function() return table.write(callList.update,true) end
  
}

entities = require 'game.entities'
function c.spawnentity(name,x,y)
  table.insert(game.entities,{entities.load(name,x,y),0,0})
  local id
  id = #game.entities+1
  for i,v in ipairs(game.entities) do
    if not pcall(game.entities[i]:getName()) then id = i break end
  end
  game.entities[id]:setid(id)
  c.fixentids()
  return id
end

function c.fixentids()
  for i,v in ipairs(game.entities) do
    if v:getid() ~= i then
      game.entities[i]:setid(i)
      if game.entities.selected > 1 then game.entities.selected = game.entities.selected-1 end
    end
  end
end

function c.killentity(id)
  table.remove(game.entities,id)
  game.entities.selected = 0
  c.fixentids()
end

function c.getentityinfo(id)
  if not id then id = game.entities.selected else id=tonumber(id) end
  local name  = game.entities[id]:getName()
  local x,y   = game.entities[id]:getPosition()
  local xt,yt = game.entities[id]:getTruePosition()
  local dir   = game.entities[id]:getDirection()
  local w,h   = game.entities[id]:getDimensions()
  local m     = game.entities[id].allowmove
  return ("ENT: N:%s Pos:%d,%d TPos:%d,%d Dir:%s Dim:%d,%d Mov:%s, ID:%d"):format(name,x,y,xt,yt,dir,w,h,m,id)
end

function c.clearassetcache()
  assets.loaded.image       = {}
  assets.loaded.font        = {default = {}}
  assets.loaded.sound       = {}
  assets.loaded.texture     = {}
  entities.loadedclasses    = {}
  for i,_ in ipairs(game.entities) do
    game.entities[i]:clearassetcache()
  end
  return true
end

function c.reloadconfig()
  configure.load()
  return true
end

function c.setlang(val)
  return configure.language(val)
end

function c.reloadgamegui()
  game.loadGUI()
end

c.gametimeoptions = {"dawn","day","dusk","night"}
function c.setgametime(i)
  i = tonumber(i)
  print(c.gametimeoptions[i])
  if c.gametimeoptions[i] then
    game.time = c.gametimeoptions[i]
  else
    return "invalid gametime: 1,2,3 and 4"
  end
  
end

function c.reloadobjects()
  entities.loadedclasses = {}
  for i,_ in ipairs(game.entities) do
    game.entities[i]:reloadself()
  end
  game.loadmap(game.map)
end

function c.clearcache()
  c.clearassetcache()
  c.reloadconfig()
  c.reloadgamegui()
  c.reloadobjects()
end

function c.loadmap()
  
end

function c.entitycount()
  return #game.entities
end

function c.getcamerapos()
  return ("x:%f y:%f r:%f z:%f"):format(camera.getPos())
end

return c