game = {}
require 'game.entities'
require 'game.gui'
local movedThisFrame = false

--[[
  The FPS starts to flop at around 313 entities, and drops from 30 to 26---27-28--29 (Also set on the largest map, but doesn't seem to affect at all; even if constantly changing maps)
  Clearing the asset cache drops it to 24 in these conditions
  Reloading all objects takes ~1.5865512 seconds
  Clearing the assets bumps up used memory by ~4mb
  But they get cleared up quickly. Sometimes it tones it down by 1 whole mb
  Reloading doesn't seem to have an effect.
  
  At about 444 Entities, the FPS drops below an average of 20, over to 18-19---20
  Reloading objects takes 3 full seconds
  Memory usage rises by about 10mb (Likely due to animations)
  
  At roughly 933 entities, the FPS is now at an average of 12--13-14-15
  Memory is now 15mb more
  Reloading objects takes 4 seconds
  Clearing asset cache takes like 1.7 seconds, and ups memory usage by 20mb
  
  Past the 999 mark
  7 seconds to reload everything.
  
  1200
  FPS Average at 13-15
  Memory usage is high
  7.4 seconds to reload objects
  
  3505
  FPS is just 5.
  Memory usage is 152MB
  22 seconds to reload all objects, damn.
  
]]--

function game.loadmap(name)
  game.map = name
  local w,h = (assets.image(game.map)):getDimensions()
  game.mapsize = {w,h}
  w,h = w+32,h+32
  
  assets.font("copperplate gothic bold",16)
  game.grid = lg.newCanvas(w,h)
  game.grid:renderTo(
    function()
      lg.push()
      lg.origin()
      lg.setScissor()
      lg.setColor(255,255,255,255)
      lg.rectangle("line",32,32,w-32,h-32)
      for a = math.floor(w/32), 0, -1 do
        for b = math.floor(h/32), 0, -1 do
          lg.setColor(255,255,255,255)
          lg.rectangle("line",(a+1)*32,(b+1)*32,32,32)
        end
      end
      lg.pop()
    end
  )--;print(game.grid:getDimensions())
  game.gridN = lg.newCanvas(w,h)
  game.gridN:renderTo(
    function()
      for a = math.floor(w/32), 0, -1 do
        for b = math.floor(h/32), 0, -1 do
          lg.setColor(255,255,255,255)
          lg.print(b+1,16,(b*32)+32)
        end
        lg.setColor(255,255,255,255)
        lg.print(a+1,(a*32)+32,16)
      end
    end
  )
  assets.font("lucida console",8)
  game.gridL = lg.newCanvas(w,h)
  game.gridL:renderTo(
    function()
      for a = math.floor(w/32), 0, -1 do
        for b = math.floor(h/32), 0, -1 do
          lg.setColor(255,255,255,255)
          lg.print("x"..a+1 .."y"..b+1,((a+1)*32),((b+1)*32)+24)
        end
      end
    end
  )
  log.record("Game",("Built grid map with dimensions X:%d Y:%d"):format(w,h))
  
end

function game.load()
  
  if fileman.exists("dates") then
    game.calendar = newCalendar(unpack(loadstring(fileman.read("dates"))()))
    log.record("Game","Loaded previously recorded date")
  else
    game.calendar = newCalendar(576,2,28,0,0,0,0)
    log.record("Game","Loaded default date")
  end
  
  game.directions = {
    move_up = {0,-1,0,1},
    move_down = {0,1,180,1},
    move_left = {-1,0,-90,1},
    move_right = {1,0,90,1},
    move_upleft = {-1,-1,-45,1.5},
    move_upright = {1,-1,45,1.5},
    move_downleft = {-1,1,-140,1.5},
    move_downright = {1,1,140,1.5},
    idle = {0,0,0,0}
  }
  
  game.entities = {}
  game.bigpause = false
  
  game.timecode = 0
  game.time = 1 --1dawn,2day,3dusk,4night
  game.timecolor = {
    {200,255,255,5},
    {0,0,0,0},
    {100,62,0,65},
    {3,0,31,230}
  }
  
  game.camlock = false
  
  control:bind("w","ent_move_up")
  control:bind("s","ent_move_down")
  control:bind("a","ent_move_left")
  control:bind("d","ent_move_right")
  control:bind("q","ent_move_upleft")
  control:bind("e","ent_move_upright")
  control:bind("z","ent_move_downleft")
  control:bind("c","ent_move_downright")
  control:bind("x","ent_idle")
  control:bind("lshift","ent_nomove")
  control:bind("escape","ent_deselect")
  control:bind("backspace","ent_kill")
  control:bind("space","ent_clearsteps")
  
  control:bind("up","cam_up")
  control:bind("down","cam_down")
  control:bind("left","cam_left")
  control:bind("right","cam_right")
  control:bind("kp0","cam_zoomi")
  control:bind("kp.","cam_zoomo")
  
  control:bind("lctrl","camGoToselected")
  
  game.loadGUI()
  game.loadmap("maps/nomap")
  
end

function game.start()
  
  log.record("Game","Starting game",nil,nil,2)
  
  game.entities.selected = 0
  
  love.addtl("update", "game", game.update)
  
  log.record("Game","Started game",nil,nil,2)
  
end

function game.truepause(bool)
  game.bigpause = bool
end

function game.update(dt)
  
  if not game.bigpause then
    
    movedThisFrame = false
    if game.entities.selected > 0 then
      if control:down("ent_clearsteps") then
        game.entities[game.entities.selected]:clearsteps()
      end
      for i,v in pairs(game.directions) do
        if control:down("ent_"..i) then
          game.entities[game.entities.selected]:move(i)
          game.entities[game.entities.selected]:movelock()
          movedThisFrame = true
        end
      end
      if control:down("ent_nomove") then
        game.entities[game.entities.selected]:togglemove()
          game.entities[game.entities.selected]:movelock()
        movedThisFrame = true
      end
      if not movedThisFrame then 
        game.entities[game.entities.selected]:moveunlock()
      end
      if control:down("camGoToselected") or game.camlock then
        if game.entities.selected > 0 then
          local x,y = game.entities[game.entities.selected]:getdirarrowpos()
          camera.set(x,y-12)
        else
          camera.set(0,0)
        end
      end
    end
    if control:down("ent_deselect") then
      game.entities.selected = 0
    end
    if control:down("ent_kill") and game.entities.selected > 0 then
      console.execute("killentity",game.entities[game.entities.selected]:getid())
    end
    
    if not game.camlock then
      if control:down("cam_up") then
        camera.move(0,-10)
      end
      if control:down("cam_down") then
        camera.move(0,10)
      end
      if control:down("cam_left") then
        camera.move(-10,0)
      end
      if control:down("cam_right") then
        camera.move(10,0)
      end
      if control:down("cam_zoomi") then
        camera.zoom(.05)
      end
      if control:down("cam_zoomo") then
        camera.zoom(-.05)
      end
    end
    
    for i,_ in ipairs(game.entities) do
      game.entities[i]:update(dt)
      game.entities[i]:draw(0,0)
    end
    
    camera.gui(game.GUI,2)
    camera.gui(game.dmGUI,1)
    
  end
  camera.draw(
    function()
      lg.draw(assets.image(game.map),0,0)
      lg.setColor(game.timecolor[game.time])
      lg.draw(assets.image("dot"),0,0,0,math.resize(1,1,game.mapsize[1],game.mapsize[2]))
    end,
    0,0,1)
  local gr,gg,gb,ga,glr,glb,glg,glb,gla
  if conf.game.showgrid then
    gr,gg,gb,ga = game.gui.config.colors.grid[1].value,game.gui.config.colors.grid[2].value,game.gui.config.colors.grid[3].value,game.gui.config.colors.grid[4].value
    camera.draw(function()lg.setColor(gr,gg,gb,ga);lg.draw(game.grid,-32,-32) end,0,0,2)
  end
  if conf.game.showgridnumbering then
    camera.draw(function()lg.setColor(conf.game.gridtextcolor);lg.draw(game.gridN,-32,-32) end,0,0,3)
  end
  if conf.game.showgridlabels then
    glr,glg,glb,gla = game.gui.config.colors.gridlabels[1].value,game.gui.config.colors.gridlabels[2].value,game.gui.config.colors.gridlabels[3].value,game.gui.config.colors.gridlabels[4].value
    camera.draw(function()lg.setColor(glr,glg,glb,gla);lg.draw(game.gridL,-32,-32) end,0,0,3)
  end
  
end

function game.quit()
  fileman.write("dates", table.write(game.calendar.time), "w", "Game")
end