assets = {
  
  dirs = {
    
    image     = "resources/assets/images/",
    font      = "resources/assets/fonts/",
    sound     = "resources/assets/sounds/",
    texture   = "resources/assets/images/",
    particle  = "resources/assets/particles/",
    animation = "resources/assets/animations/"
    
  },
  
  loaded = {
    
    image       = {},
    font        = {default = {}},
    sound       = {},
    texture     = {},
    canvas      = {},
    spriteBatch = {},
    animation   = {}
    
  }
  
}
--All of the functions here work the following way:
--If it's loaded it simply returns it, and if it isn't it loads it and then returns it.
--Loaded assets are stored locally in a weak table, meaning that they will be deleted as soon as they are no longer being used

function assets.image(name)
  
  if assets.loaded.image[name] then
    
    log.subrecord("Assets",("Returned image %s"):format(name))
    return assets.loaded.image[name]
    
  else
    
    --assets.loaded.image[name] = {}
    local img = lg.newImage(string.format("%s%s.png",assets.dirs.image,name))
    if img then 
      assets.loaded.image[name] = img
      log.record("Asset Manager","Loaded image asset: "..name)
      return img
    else
      log.record("Asset Manager","Failed to load image asset: "..name,1,1)
      return false
    end
    
  end
  
end

function assets.imagex(name)
  
  if assets.loaded.image[name] then
    
    log.subrecord("Assets",("Returned image %s"):format(name))
    return assets.loaded.image[name]
    
  else
    
    --assets.loaded.image[name] = {}
    local img = lg.newImage(name)
    if img then 
      assets.loaded.image[name] = img
      log.record("Asset Manager","Loaded image asset: "..name)
      return img
    else
      log.record("Asset Manager","Failed to load image asset: "..name,1,1)
      return false
    end
    
  end
  
end

function assets.reloadimage(name)
  
  local a = assets.loaded.image[name]
  assets.loaded.image[name] = nil
  local b = assets.image(name)
  
end

function assets.font(name,size)
  
  if type(name) == "table" then
    name,size = unpack(name)
  end
  size = size or 16
  name = name or "default"
  
  if name == "default" then
    
    local fnt = assets.loaded.font.default[size]
    if fnt then lg.setFont(fnt) else assets.loaded.font.default[size] = lg.newFont(size); lg.setFont(assets.loaded.font.default[size]) end
    return
    
  end
  
  if not assets.loaded.font[name] then assets.loaded.font[name] = {} end
  
  if assets.loaded.font[name][size] then
    
    log.subrecord("Assets",("Set font %s %d"):format(name,size))
    lg.setFont(assets.loaded.font[name][size])
    
  else
    
    local fntloc = string.format("%s%s.ttf",assets.dirs.font,name)
    assets.loaded.font[name][size] = lg.newFont(fntloc,size)
    
    log.record("Asset Manager","Loaded font asset: "..name.." "..size)
    lg.setFont(assets.loaded.font[name][size])
    
  end
  
end

function assets.reloadfont(name,size)
  
  assets.loaded.font[name][size] = nil
  return assets.font(name,size)
  
end

function assets.texture(name,sprite,data) --A texture returns the image and the queried quad. [Quad Wiki Page](https://love2d.org/wiki/Quad)
  
  --Every *single* texture (or atlas) MUST have a '.sprite' file with the same name that specifies it's quad dimensions and the name of each sprite
  
  if assets.loaded.texture[name] then
    
    log.subrecord("Assets",("Returned texture %s"):format(name))
    return assets.loaded.texture[name].img, assets.loaded.texture[name].sprites[sprite], #assets.loaded.texture[name].sprites
    
  else
    
    assets.loaded.texture[name] = {} 
    local spriteinfo = data or lf.load(string.format("%s%s.sprite",assets.dirs.texture,name))()
    assets.loaded.texture[name].img = lg.newImage(string.format("%s%s.png",assets.dirs.texture,name))
    local w,h = assets.loaded.texture[name].img:getDimensions()
    assets.loaded.texture[name].sprites = {}
   
    for i,v in pairs(spriteinfo) do
      local x, y,ws,hs  = unpack(v)
      assets.loaded.texture[name].sprites[i] = lg.newQuad(x,y,ws,hs,w,h)
    end
    
    log.record("Asset Manager","Loaded texture asset: "..name)
    
    return assets.loaded.texture[name].img, assets.loaded.texture[name].sprites[sprite], #assets.loaded.texture[name].sprites
    
  end

end

function assets.reloadtexture(name,sprite,data)
  
  assets.loaded.texture[name] = nil
  return assets.texture(name,sprite,data)
  
end

function assets.canvas(name, data) --Basically this is a regular image just that it's actually a bunch of them merged into a single image (Images used to draw it can then be discarded) [Canvas Wiki Page](https://love2d.org/wiki/Canvas)
  
  if type(name) == "table" then
    name,data = unpack(name)
  end
  if assets.loaded.canvas[name] then
    
    log.subrecord("Assets",("Returned canvas %s"):format(name))
    return assets.loaded.canvas[name]
    
  else
    
    local canvas = lg.newCanvas(unpack(data[1]))
    local prevCanvas = lg.getCanvas()
    lg.setCanvas(canvas)
    
    local success = pcall(data[2])
    if not success then canvas = nil; lg.setCanvas(prevCanvas); return success end
    
    lg.setCanvas(prevCanvas)
    
    assets.loaded.canvas[name] = canvas
    return assets.loaded.canvas[name]
    
  end
  
end

function assets.reloadcanvas(name,data)
  
  assets.loaded.canvas[name] = nil
  return assets.canvas(name,data)
  
end

function assets.spriteBatch(name, quad, amount, size) --Amount = {x,y}
  
  if type(name) == "table" then
    name,quad,amount,size = unpack(name)
  end
  if quad and (not amount or not size) then
    quad,amount,size = nil,quad,amount
  end
  
  if assets.loaded.spriteBatch[name] then
    
    log.subrecord("Assets",("Returned batch %s"):format(name))
    return assets.loaded.spriteBatch[name]
    
  else
    
    assets.loaded.spriteBatch[name] = {}
    
    local max = amount[1] * amount[2]
    
    if quad then
      
      local a,b = assets.texture(name,quad,2/60)
      local spriteBatch = lg.newSpriteBatch(a,max,"static")
      local x, y, w, h = b:getViewport()
      
      if size and type(size) == "table" then
        w,h = unpack(size)
      end
      
      local ind = 1
      
      while ind <= amount[1] do
        
        spriteBatch:add(b,(w*ind)-w,0)
        ind = ind+1
        
      end
      
      ind = 1
      
      while ind <= amount[2] do
        
        spriteBatch:add(b,0,(h*ind)-h)
        ind = ind+1
        
      end
      
      assets.loaded.spriteBatch[name] = spriteBatch
      return assets.loaded.spriteBatch[name]
      
    else
      
      local a = assets.image(name,2/60)
      local spriteBatch = lg.newSpriteBatch(a,max,"static")
      
      local w,h
      
      if size and type(size) == "table" then
        w,h = unpack(size)
      else
        w,h = a:getDimensions()
      end
      
      local ind = 0
      
      while ind <= amount[1] do
        
        spriteBatch:add((w*ind),0)
        ind = ind+1
        
      end
      
      ind = 0
      
      while ind <= amount[2] do
        
        spriteBatch:add(0,(h*ind))
        ind = ind+1
        
      end
      
      spriteBatch:flush()
      assets.loaded.spriteBatch[name] = spriteBatch
      return assets.loaded.spriteBatch[name]
      
    end
    
  end
  
end

function assets.reloadspriteBatch(name, quad, amount, size)
  
  assets.loaded.spriteBatch[name] = nil
  return assets.spriteBatch(name, quad, amount, size)

end

function assets.particle(name) --This uses .particle files
  
  local psystem = lf.load(string.format("%s%s.particle",assets.dirs.particle,name))()
  log.record("Assets",("Created particle object: %s"):format(name))
  return psystem
  
end

function assets.animation(file,name,data) 
  
  local animObj = {}
  local animObj_
  if not data then animObj_ = lf.load(("%s%s.anim"):format(assets.dirs.animation,file))() else animObj_ = data end
  
  animObj.framerate = tonumber(animObj_.framerate)
  animObj.__framerate = animObj_.framerate
  animObj.stage = 1
  animObj.texture = animObj_.texture
  --
  local states = {}
  local x,y,w,h
  for i,v in pairs(animObj_[name]) do
    states[i] = {}
    for i1,v1 in ipairs(v) do
      x,y,w,h = unpack(v1)
      table.insert(states[i],lg.newQuad(x,y,w,h,(assets.imagex(string.format("%s%s.png",assets.dirs.animation,animObj.texture))):getDimensions()))
    end
    states[i].rewind = v.rewind
  end
  
  animObj.name = name
  animObj.states = states
  animObj.stateChanged = false
  animObj.lastState = "normal"
  animObj.state = "normal"
  animObj.stage = 1
  animObj.sprites = 1
  animObj.rewindGlobal = animObj_.rewind
  animObj.rewind = animObj.rewindGlobal
  animObj.inRewind = false
  
  function animObj:update(dt)
    self.framerate = self.framerate - dt
    
    if self.framerate <= 0 then
      if self.inRewind then
        self.stage = self.stage - 1
        self.framerate = self.__framerate
      else
        self.stage = self.stage + 1
        self.framerate = self.__framerate
      end
    end
    
    if self.stage > self.sprites then
      if self.rewind then
        self.inRewind = true
        self.stage = self.stage - 1
      else
        self.stage = 1
      end
    end
    
    if self.stage < 1 and self.inRewind then
      self.stage = 1
      self.inRewind = false
    end
    
    if self.state ~= self.lastState then
      self.stage = 1
      self.framerate = self.__framerate
    end
    self.lastState = self.state
    
  end
  
  function animObj:draw(x,y,sx,sy,ox,oy,kx,ky)
    lg.draw((assets.imagex(string.format("%s%s.png",assets.dirs.animation,animObj.texture))), self.states[self.state][self.stage],x,y,sx,sy,ox,oy,kx,ky)
  end
  
  function animObj:getImage()
    return (assets.imagex(string.format("%s%s.png",assets.dirs.animation,animObj.texture)))
  end
  
  function animObj:getDimensions()
    local x,y,w,h = self.states[self.state][self.stage]:getViewport()
    return w,h
  end
  
  function animObj:setState(state)
    self.state = state
    self.sprites = #self.states[state]
    if self.states[state].rewind then
      self.rewind = true
    elseif self.states[state].rewind == false then
      self.rewind = false
    elseif self.states[state].rewind == nil then
      self.rewind = self.rewindGlobal
    end
  end
  
  animObj:setState("normal")
  
  return animObj
  
end