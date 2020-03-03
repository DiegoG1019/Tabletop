camera = {}
local camx,camy,camr,camz = 0,0,0,2
local goalx,goaly,goalr,goalz = 0,0,0,2
local drawlist  = {}
local guilist   = {}
local dmguilist = {}

local camr2 = 0

local preRender  = lg.newCanvas()
local postRender = lg.newCanvas(win.w,win.h)
-- x  -left +right
-- y  -up +down
-- r  camera rotation in radians (INPUT IN DEGREES, CONVERSION DONE INTERNALLY)
-- zo zoom, -smaller +bigger (Default is 1)
-- r2 SCREEN rotation in radians

local color = {255,255,255}
local font = {"lucida console",12}

local sortPgui = function(a,b) if a[2] < b[2] then return true end return false end

--2x 3y 4p
local function sortdraw(a,b)
  if a[4] < b[4] then
    return true
  elseif a[4] > b[4] then
    return false
  elseif a[3] < b[3] then
    return true
  elseif a[3] > b[3] then
    return false
  elseif a[2] < b[2] then
    return true
  elseif a[2] > b[2] then
    return false
  end
end

local function clear()
  drawlist  = {}
  guilist   = {}
  dmguilist = {}
end
  
function camera.draw(func,x,y,priority,sx,sy) -- highest number = last to draw; 1 is lowest priority
  if not priority then priority = 1 end
  if not sx then sx = 1 end
  if not sy then sy = 1 end
  table.insert(drawlist,{func,x,y,priority,sx,sy})
end

function camera.gui(func,priority,x,y) -- This is only to help organize GUI placing
  x = x or 0
  y = y or 0
  table.insert(guilist,{func,priority,x,y})
end

function camera.dmGUI(func,priority,x,y) -- This is only to help organize GUI placing
  x = x or 0
  y = y or 0
  table.insert(dmguilist,{func,priority,x,y})
end

function love.draw()
  
  lg.push()
  lg.origin()
  
  preRender:renderTo(function()
    lg.clear()
    local bgw,bgh = math.resize(156,156,win.w,win.h)
    lg.draw(assets.image("menu/background"),0,0,0,bgw,bgh)
  end)
  
  lg.setScissor(0,0,win.w+conf.window.extraw,win.h)
  lg.scale(camz,camz)
  lg.translate(win.mw/camz,win.mh/camz)
  lg.rotate(-camr2)
  lg.translate(-camx, -camy)
  
  table.sort(drawlist,sortdraw)
  
  --bg

  preRender:renderTo(function()
    for i,v in ipairs(drawlist) do
      drawlist[i][1]()
      assets.font(unpack(font))
      lg.setColor(color)
      lg.setBlendMode("alpha","alphamultiply")
    end
  end)

  lg.origin()
  lg.setCanvas()
  lg.clear()
  lg.draw(preRender,0,0)
  lg.pop()
  
  table.sort(guilist,sortPgui)
  for i,v in ipairs(guilist) do
    lg.translate(v[3],v[4])
    guilist[i][1]()
    assets.font(unpack(font))
    lg.setColor(color)
    lg.origin()
    lg.setBlendMode("alpha","alphamultiply")
  end
  
  clear()
  
end

function camera.setColor(r,g,b)
  color = {r,g,b}
end

function camera.set(x,y)
  goalx = x; goaly = y
end

function camera.move(x,y)
  goalx = goalx+x; goaly = goaly+y
end

function camera.forcemove(x,y)
  camx = camx+x; camy = camy+y
  camera.move(x,y)
end

function camera.forceset(x,y)
  camx = x; camy = y
  camera.set(x,y)
end

function camera.setrotation(r)
  goalr = math.rad(r)
end

function camera.forcesetrotation(r)
  goalr = math.rad(r)
  camr = math.rad(r)
end

function camera.rotate(r)
  goalr = goalr + math.rad(r)
end

function camera.forcerotate(r)
  camr = math.rad(r)
  goalr = math.rad(r)
end

function camera.forcezoom(z)
  camz = z
  goalz = z
end

function camera.zoom(z)
  goalz = z+goalz
end

function camera.setzoom(z)
  goalz = z
end

function camera.forcesetzoom(z)
  goalz = z
  camz = z
end

function camera.getPos()
  return camx,camy,camr,camz
end

function camera.getGoal()
  return goalx,goaly,goalr,goalz
end

function camera.normalize()
  camr2 = 0
end

function camera.update(dt)
  
  camx = camx - ( ( ( camx - goalx ) ) * 10 * dt )
  camy = camy - ( ( ( camy - goaly ) ) * 10 * dt )
  camr = camr - ( ( ( camr - goalr ) ) * 10 * dt )
  camz = camz - ( ( ( camz - goalz ) ) * 10 * dt )
  if camz <= 0.1 then camz = 0.1;goalz = 0.1 elseif camz >= 4 then camz = 4;goalz = 4 end
  
end

love.addtl("update","camupdate",camera.update)

return camera