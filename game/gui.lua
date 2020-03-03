local rollval = 0
local alips = 1


function game.loadGUI()
  
  love.addtl("keypressed","SUIT",suit.keypressed)
  love.addtl("textinput","SUIT",suit.textinput)
  
  local gr, gg, gb, ga = unpack(conf.game.gridcolor)
  local glr, glg, glb, gla = unpack(conf.game.gridlabelcolor)
  
  suit.theme.color = {
    normal  = {bg = { 66, 66, 66}, fg = {188,188,188}},
    hovered = {bg = { 50,153,187}, fg = {255,255,255}},
    active  = {bg = {255,153,  0}, fg = {225,225,225}}
  }
  game.gui = {
    alloff = function()
      game.gui.mapmenu.active = false
      game.gui.charactermenu.active = false
      game.gui.config.active = false
      game.gui.dmmenu.active = true
      game.gui.mainmenu.active = true
      game.gui.encounterlist.active = false
      game.gui.turnorder.active = false
    end,
    menu = {
      mainmenu = suit.new(),
      timekeeping = suit.new(),
      charactermenu = suit.new(),
      mapmenu = suit.new(),
      encounterlist = suit.new(),
      config = suit.new(),
      turnorder = suit.new(),
      dmmenu = suit.new()
    },
    charactermenu = {
      list = {player = {},ally = {},enemy = {}},
      scroll = {value = 10, min = -18, max = 10},
      active = false
      --buttoncanvas = lg.newCanvas(win.dmw-252,win.h)
    },
    mapmenu = {
      list = {},
      scroll = {value = 0, min = 0, max = 0},
      active = false
      --buttoncanvas = lg.newCanvas(win.dmw-252,win.h)
    },
    encounterlist = {
      list = {
        
        "Encuentros de Puntacolmillo",
        "Bandidos de los Caminos",
        "Gitanos Viajeros",
        "Encuentros de Dungeon: Guardianes de lo Profanado",
        "Encuentros de Dungeon: Lo Profanado",
        "El Nigromante",
        "Mercaderes e Injusticias"
        
      },
      scroll = {value = 0, min = 0, max = 0},
      active = false
      --buttoncanvas = lg.newCanvas(win.dmw-252,win.h)
    },
    dmmenu = {
      active = true
    },
    mainmenu = {
      active = true
    },
    config = {
      list = {},
      scroll = {value = 10, min = 10, max = 10},
      colors = {
        n = {"R","G","B","A"},
        grid = {
          {value = gr, min = 0, max = 255},
          {value = gg, min = 0, max = 255},
          {value = gb, min = 0, max = 255},
          {value = ga, min = 0, max = 255}
        },
        gridlabels = {
          {value = glr, min = 0, max = 255},
          {value = glg, min = 0, max = 255},
          {value = glb, min = 0, max = 255},
          {value = gla, min = 0, max = 255}
        }
      },
      active = false
      --buttoncanvas = lg.newCanvas(win.dmw-252,win.h)
    }
  }
  for i,v in ipairs(fileman.list("resources/entities")) do
    for i1,v1 in ipairs(fileman.list("resources/entities/"..v)) do
      table.insert(game.gui.charactermenu.list[v],({entities.loadsprite(v.."/"..v1:sub(1,-5)),v1:sub(1,-5)}))
    end
  end
  --23 because (x/3)(64+5) -- items, three per row, vertical cellsize and padding -- = 69(x/3) = 23x
  
  for i,v in ipairs(fileman.list("resources/assets/images/maps")) do
    if v ~= "nomap.png" then 
      game.gui.mapmenu.list[v] = {}
      for i1,v1 in ipairs(fileman.list("resources/assets/images/maps/"..v)) do
        local c = lg.newCanvas(60,52)
        local mn = v1:sub(1,-5)
        local fmn = "maps/"..v.."/"..mn
        local iw,ih = assets.image(fmn):getDimensions()
        c:renderTo(
          function()
            lg.draw(assets.image(fmn),0,0,0,math.resize(iw,ih,60,52))
          end
        )
        table.insert(game.gui.mapmenu.list[v],({c,mn,fmn}))
      end
    end
  end
  
end

function game.GUI()
  
  assets.font("copperplate gothic light",16)
  lg.setColor(255,255,255)
  
  --Main Menu
  -------------------------------
  if game.gui.mainmenu.active then
    game.gui.menu.mainmenu.layout:reset(win.w+5,160,15,15)
    if game.gui.menu.mainmenu:Button(lang.game.menu.charsb,game.gui.menu.mainmenu.layout:row(70,52)).hit then
      if game.gui.charactermenu.active then
        game.gui.alloff()
      else
        game.gui.alloff()
        game.gui.charactermenu.active = true
        game.gui.dmmenu.active = false
        game.gui.mainmenu.active = false
      end
    end
    if game.gui.menu.mainmenu:Button(lang.game.menu.mapsb,game.gui.menu.mainmenu.layout:row(70,52)).hit then
      if game.gui.mapmenu.active then
        game.gui.alloff()
      else
        game.gui.alloff()
        game.gui.mapmenu.active = true
        game.gui.dmmenu.active = false
        game.gui.mainmenu.active = false
      end
    end
    if game.gui.menu.mainmenu:Button(lang.game.menu.conf,game.gui.menu.mainmenu.layout:row(70,52)).hit then
      if game.gui.config.active then
        game.gui.alloff()
      else
        game.gui.alloff()
        game.gui.config.active = true
        game.gui.dmmenu.active = false
        game.gui.mainmenu.active = false
        game.gui.mainmenu.active = false
      end
    end
    if game.gui.menu.mainmenu:Button(lang.game.menu.enc,game.gui.menu.mainmenu.layout:row(70,52)).hit then
      if game.gui.mapmenu.active then
        game.gui.alloff()
      else
        game.gui.alloff()
        game.gui.encounterlist.active = true
        game.gui.dmmenu.active = false
        game.gui.mainmenu.active = false
      end
    end
    if game.gui.menu.mainmenu:Button(lang.game.menu.camlock,game.gui.menu.mainmenu.layout:row(70,52)).hit then
      if game.camlock then
        game.camlock = false
      else
        game.camlock = true
      end
    end
    if game.gui.menu.mainmenu:Button(lang.game.menu.roll.."\n"..rollval,game.gui.menu.mainmenu.layout:row(70,52)).hit then
      rollval = math.random(1,20)
    end
    if game.gui.menu.mainmenu:Button(lang.game.characters.alipstate[1].."\n"..lang.game.characters.alipstate[alips],game.gui.menu.mainmenu.layout:row(70,52)).hit then
      alips = math.random(2,3)
    end
    if game.gui.menu.mainmenu:Button(lang.game.menu.timecycle..": "..lang.game.menu.time[game.time],win.dmw-125,win.h-74,120,44).hit then
      game.time = game.time+1
      if game.time > 4 then
        game.time = 1
      end
    end
    game.gui.menu.mainmenu:draw()
  end
  --Character Menu
  -------------------------------
  if game.gui.charactermenu.active then
    
    assets.font("copperplate gothic light",16)
    local cmx,cmy,cmw,cmh
    local rowcount = 0
    local rowy
    
    lg.setColor(0,0,0,200)
    lg.draw(assets.image("dot"),win.dmw-252,0,0,math.resize(1,1,win.dmw-252,win.h))
    lg.setColor(255,255,255,255)
    
    game.gui.menu.charactermenu:draw()
    
    if game.gui.menu.charactermenu:Button("X",win.dmw-36,5,32,32).hit then
      game.gui.alloff()
    end
    
    game.gui.menu.charactermenu.layout:reset(win.dmw-252,game.gui.charactermenu.scroll.value*4)
    game.gui.menu.charactermenu.layout:padding(5,5)
    game.gui.menu.charactermenu:Slider(game.gui.charactermenu.scroll,{vertical = true},win.dmw-264,0,16,win.h)
    game.gui.menu.charactermenu:Label(lang.game.menu.plchar,game.gui.menu.charactermenu.layout:row(252,32))
    
    --print(table.write(game.gui.charactermenu.list.player))
    game.gui.menu.charactermenu.layout:reset(win.dmw-316,game.gui.charactermenu.scroll.value*4,15,15)
    game.gui.menu.charactermenu.layout:row(64,64)
    game.gui.menu.charactermenu.layout:row(64,16)
    
    for i,v in pairs(game.gui.charactermenu.list.player) do
      assets.font("copperplate gothic light",11)
      --print(v[2])
      if rowcount > 2 then
        _,rowy = game.gui.menu.charactermenu.layout:nextRow()
        game.gui.menu.charactermenu.layout:reset(win.dmw-237,rowy,15,15)
        cmx,cmy,cmw,cmh = game.gui.menu.charactermenu.layout:row(64,64)
        rowcount = 0
      else
        cmx,cmy,cmw,cmh = game.gui.menu.charactermenu.layout:col(64,64)
      end
      if game.gui.menu.charactermenu:Button(v[2],{align = "left",id = v[2].."player",valign = "bottom"},cmx,cmy,cmw,cmh).hit then
        local cx,cy = camera.getPos()
        cx,cy = math.floor(cx/32),math.floor(cy/32)
        console.execute("spawnentity","player/"..v[2],cx,cy)
      end
      
      do
        local i,q = assets.texture(v[1][1],v[1][2])
        lg.draw(i,q,cmx-4,cmy-4,0,2,2)
      end
      
      rowcount = rowcount+1
    end
    
    assets.font("copperplate gothic light",16)
    game.gui.menu.charactermenu.layout:reset(win.dmw-237,rowy+64,15,15)
    game.gui.menu.charactermenu:Label(lang.game.menu.enchar,game.gui.menu.charactermenu.layout:row(252,32))
    for i,v in pairs(game.gui.charactermenu.list.enemy) do
      assets.font("copperplate gothic light",11)
      --print(v[2])
      if rowcount > 2 then
        _,rowy = game.gui.menu.charactermenu.layout:nextRow()
        game.gui.menu.charactermenu.layout:reset(win.dmw-237,rowy,15,15)
        cmx,cmy,cmw,cmh = game.gui.menu.charactermenu.layout:row(64,64)
        rowcount = 0
      else
        cmx,cmy,cmw,cmh = game.gui.menu.charactermenu.layout:col(64,64)
      end
      if game.gui.menu.charactermenu:Button(v[2],{align = "left",id = v[2].."enemy",valign = "bottom"},cmx,cmy,cmw,cmh).hit then
        local cx,cy = camera.getPos()
        cx,cy = math.floor(cx/32),math.floor(cy/32)
        console.execute("spawnentity","enemy/"..v[2],cx,cy)
      end
      
      do
        local i,q = assets.texture(v[1][1],v[1][2])
        lg.draw(i,q,cmx-4,cmy-4,0,2,2)
      end
      
      rowcount = rowcount+1
    end
    
    assets.font("copperplate gothic light",16)
    game.gui.menu.charactermenu.layout:reset(win.dmw-237,rowy+64,15,15)
    game.gui.menu.charactermenu:Label(lang.game.menu.alchar,game.gui.menu.charactermenu.layout:row(252,32))
    game.gui.menu.charactermenu.layout:reset(win.dmw-237,rowy+96,15,15)
    for i,v in pairs(game.gui.charactermenu.list.ally) do
      assets.font("copperplate gothic light",11)
      --print(v[2])
      if rowcount > 2 then
        _,rowy = game.gui.menu.charactermenu.layout:nextRow()
        game.gui.menu.charactermenu.layout:reset(win.dmw-237,rowy,15,15)
        cmx,cmy,cmw,cmh = game.gui.menu.charactermenu.layout:row(64,64)
        rowcount = 0
      else
        cmx,cmy,cmw,cmh = game.gui.menu.charactermenu.layout:col(64,64)
      end
      if game.gui.menu.charactermenu:Button(v[2],{align = "left",id = v[2].."ally",valign = "bottom"},cmx,cmy,cmw,cmh).hit then
        local cx,cy = camera.getPos()
        cx,cy = math.floor(cx/32),math.floor(cy/32)
        console.execute("spawnentity","ally/"..v[2],cx,cy)
      end
      
      do
        local i,q = assets.texture(v[1][1],v[1][2])
        lg.draw(i,q,cmx-4,cmy-4,0,2,2)
      end
      
      rowcount = rowcount+1
    end
  end
  
  --Map Menu
  -------------------------------
  if game.gui.mapmenu.active then
    assets.font("copperplate gothic light",16)
    local cmx,cmy,cmw,cmh
    local rowcount = 0
    local rowy
    
    lg.setColor(0,0,0,200)
    lg.draw(assets.image("dot"),win.dmw-252,0,0,math.resize(1,1,win.dmw-252,win.h))
    lg.setColor(255,255,255,255)
    
    game.gui.menu.mapmenu:draw()
    
    if game.gui.menu.mapmenu:Button("X",win.dmw-36,5,32,32).hit then
      game.gui.alloff()
    end
    
    game.gui.menu.mapmenu.layout:reset(win.dmw-252,10)
    game.gui.menu.mapmenu.layout:padding(5,5)
    game.gui.menu.mapmenu:Slider(game.gui.mapmenu.scroll,{vertical = true},win.dmw-264,0,16,win.h)
    game.gui.menu.mapmenu:Label(lang.game.menu.avmaps,game.gui.menu.mapmenu.layout:row(252,32))
    if game.gui.menu.mapmenu:Button(lang.game.menu.nomaps,game.gui.menu.mapmenu.layout:row(252,32)).hit then
      game.loadmap("maps/nomap")
    end
    
    --print(table.write(game.gui.mapmenu.list.player))
    game.gui.menu.mapmenu.layout:reset(win.dmw-316,game.gui.mapmenu.scroll.value+96,15,15)
    
    for i,v in pairs(game.gui.mapmenu.list) do
      assets.font("copperplate gothic light",16)
      _,rowy = game.gui.menu.mapmenu.layout:row(252,32)
      game.gui.menu.mapmenu.layout:reset(win.dmw-316,game.gui.mapmenu.scroll.value+rowy,15,0)
      game.gui.menu.mapmenu:Label("                  "..i,{align = "left"},game.gui.menu.mapmenu.layout:row(252,32))
      game.gui.menu.mapmenu.layout:row(252,32);game.gui.menu.mapmenu.layout:row(64,0)
      for i1,v1 in pairs(v) do
        assets.font("copperplate gothic light",11)
        --print(v[2])
        if rowcount > 2 then
          _,rowy = game.gui.menu.mapmenu.layout:nextRow()
          game.gui.menu.mapmenu.layout:reset(win.dmw-237,game.gui.mapmenu.scroll.value+rowy,15,15)
          cmx,cmy,cmw,cmh = game.gui.menu.mapmenu.layout:row(64,64)
          rowcount = 0
        else
          cmx,cmy,cmw,cmh = game.gui.menu.mapmenu.layout:col(64,64)
        end
        if game.gui.menu.mapmenu:Button(v1[2],{align = "left",valign = "bottom"},cmx,cmy,cmw,cmh).hit then
          if v[3] ~= game.map then
            game.loadmap(v1[3])
          end
        end
        
        do
          lg.draw(v1[1],cmx+2,cmy+2,0)
        end
        
        rowcount = rowcount+1
      end
    end
  end
  
  if game.gui.encounterlist.active then
    assets.font("copperplate gothic light",16)
    lg.setColor(0,0,0,200)
    lg.draw(assets.image("dot"),win.dmw-252,0,0,math.resize(1,1,win.dmw-252,win.h))
    lg.setColor(255,255,255,255)
    
    game.gui.menu.encounterlist:draw()
    
    if game.gui.menu.encounterlist:Button("X",win.dmw-36,5,32,32).hit then
      game.gui.alloff()
    end
    
    game.gui.menu.encounterlist.layout:reset(win.dmw-252,10)
    game.gui.menu.encounterlist.layout:padding(5,5)
    game.gui.menu.encounterlist:Slider(game.gui.encounterlist.scroll,{vertical = true},win.dmw-264,0,16,win.h)
    game.gui.menu.encounterlist:Label(lang.game.menu.enc,game.gui.menu.encounterlist.layout:row(252,32))
    
    --print(table.write(game.gui.mapmenu.list.player))
    game.gui.menu.mapmenu.layout:reset(win.dmw-316,game.gui.encounterlist.scroll.value+96,15,15)
    
    for i,v in pairs(game.gui.encounterlist.list) do
      assets.font("copperplate gothic light",16)
      if game.gui.menu.encounterlist:Button(v,game.gui.menu.encounterlist.layout:row(252,32)).hit then
        notif.newnotif(lang.game.menu.encs.." #"..i-1,1)
        notif.newnotif(v,3)
      end
    end
  end
  
  --Configurations Menu
  -----------------------
  if game.gui.config.active then
    
    assets.font("copperplate gothic light",16)
    local cmx,cmy,cmw,cmh
    local rowcount = 0
    local rowy
    
    lg.setColor(0,0,0,200)
    lg.draw(assets.image("dot"),win.dmw-252,0,0,math.resize(1,1,win.dmw-252,win.h))
    lg.setColor(255,255,255,255)
    
    game.gui.menu.config:draw()
    
    if game.gui.menu.config:Button("X",win.dmw-36,5,32,32).hit then
      game.gui.alloff()
    end
    
    game.gui.menu.config.layout:reset(win.dmw-252,game.gui.config.scroll.value*4,5,5)
    game.gui.menu.config:Slider(game.gui.config.scroll,{vertical = true},win.dmw-264,0,16,win.h)
    game.gui.menu.config:Label(lang.game.menu.confbig,game.gui.menu.config.layout:row(252,32))
    
    game.gui.menu.config.layout:reset(win.dmw-232,game.gui.config.scroll.value*4,15,15)
    game.gui.menu.config.layout:row(64,64)
    game.gui.menu.config.layout:row(64,16)
    
    if game.gui.menu.config:Button(lang.game.menu.optco,game.gui.menu.config.layout:row(200,32)).hit then
      configure.change("game","showgridlabels",toggle(conf.game.showgridlabels))
    end
    
    if game.gui.menu.config:Button(lang.game.menu.optsn,game.gui.menu.config.layout:row(200,32)).hit then
      configure.change("game","showgridnumbering",toggle(conf.game.showgridnumbering))
    end
    if game.gui.menu.config:Button(lang.game.menu.optsg,game.gui.menu.config.layout:row(200,32)).hit then
      configure.change("game","showgrid",toggle(conf.game.showgrid))
    end
    
    --
    assets.font("copperplate gothic light",11)
    game.gui.menu.config.layout:row(252,16)
    game.gui.menu.config:Label(lang.game.menu.confgc,game.gui.menu.config.layout:row(252,32))
    local x,y
    for i,v in ipairs(game.gui.config.colors.grid) do
      game.gui.menu.config:Slider(game.gui.config.colors.grid[i],game.gui.menu.config.layout:row(162,16))
      x,y = game.gui.menu.config.layout:nextRow()
      game.gui.menu.config:Label(game.gui.config.colors.n[i].." "..math.floor(v.value),game.gui.menu.config.layout:col(64,14))
      game.gui.menu.config.layout:reset(x,y,5,5)
    end
    --
    
    game.gui.menu.config:Label(lang.game.menu.confglc,game.gui.menu.config.layout:row(252,32))
    for i,v in ipairs(game.gui.config.colors.gridlabels) do
      game.gui.menu.config:Slider(game.gui.config.colors.gridlabels[i],game.gui.menu.config.layout:row(162,16))
      x,y = game.gui.menu.config.layout:nextRow()
      game.gui.menu.config:Label(game.gui.config.colors.n[i].." "..math.floor(v.value),game.gui.menu.config.layout:col(64,14))
      game.gui.menu.config.layout:reset(x,y,5,5)
    end
    
    --Make 4 sliders for each color R G B A and a label saying what its for
    
    
  end
  --camera.gui(function()game.gui.menu.timekeeping:draw()end,3)
  
end

local pos = win.w+5
local time12 = {"AM","PM"}
local bw,bh = 34,16
local pm = 1
local year,month,day,hour,minute,second,days,weekday
function game.dmGUI()
  if game.gui.dmmenu.active then
    lg.setColor(255,255,255,255)
    year,month,day,hour,minute,second,days,weekday = game.calendar:retrieve()
    if hour > 12 then hour = hour-12;pm = 2 else pm = 1 end
    
    
    game.gui.menu.dmmenu:draw()
    
    assets.font("copperplate gothic light",16)
    game.gui.menu.dmmenu.layout:reset(pos,15,2,5)
    game.gui.menu.dmmenu:Label(("%d; (%d) %s, %d"):format(year,month,lang.game.calendar[month],day),game.gui.menu.dmmenu.layout:row(300,24))
    game.gui.menu.dmmenu:Label(("%d:%02d:%02d %s."):format(hour,minute,second,time12[pm]),game.gui.menu.dmmenu.layout:row(300,24))
    game.gui.menu.dmmenu:Label(("%d %s, %d %s, %s"):format(days,lang.game.watch[1],math.floor(days/7),lang.game.watch[2],lang.game.week[weekday]),game.gui.menu.dmmenu.layout:row(300,24))
    
    assets.font("copperplate gothic light",11)
    
    if game.gui.menu.dmmenu:Button("+1Y",game.gui.menu.dmmenu.layout:row(bw,bh)).hit then
      game.calendar.year(1,false,true)
    end
    if game.gui.menu.dmmenu:Button("+1M",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.month(1,false,true)
    end
    if game.gui.menu.dmmenu:Button("+1D",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.day(1)
    end
    if game.gui.menu.dmmenu:Button("+1h",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.hours(1)
    end
    if game.gui.menu.dmmenu:Button("+5m",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.minutes(5)
    end
    if game.gui.menu.dmmenu:Button("+1m",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.minutes(1)
    end
    if game.gui.menu.dmmenu:Button("+30s",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.seconds(30)
    end
    if game.gui.menu.dmmenu:Button("+6s",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.seconds(6)
    end
    
    game.gui.menu.dmmenu.layout:reset(pos,125,2,5)
    
    if game.gui.menu.dmmenu:Button("-1Y",game.gui.menu.dmmenu.layout:row(bw,bh)).hit then
      game.calendar.year(-1,false,true)
    end
    if game.gui.menu.dmmenu:Button("-1M",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.month(-1,false,true)
    end
    if game.gui.menu.dmmenu:Button("-1D",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.day(-1)
    end
    if game.gui.menu.dmmenu:Button("-1h",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.hours(-1)
    end
    if game.gui.menu.dmmenu:Button("-5m",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.minutes(-5)
    end
    if game.gui.menu.dmmenu:Button("-1m",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.minutes(-1)
    end
    if game.gui.menu.dmmenu:Button("-30s",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.seconds(-30)
    end
    if game.gui.menu.dmmenu:Button("-6s",game.gui.menu.dmmenu.layout:col(bw,bh)).hit then
      game.calendar.seconds(-6)
    end
    
    game.gui.menu.dmmenu.layout:reset(pos,win.h-60,2,5)
    
    if game.gui.menu.dmmenu:Button(lang.game.menu.repwin,game.gui.menu.dmmenu.layout:row(120,30)).hit then
      lw.setPosition(-1000,0)
      lw.setPosition(unpack(win.realpos))
    end
  end
end