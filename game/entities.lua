local entities = {
  
  loadedclasses = {}
  
}

function entities.loadclass(name)
  
  if entities.loadedclasses[name] then
    log.subrecord("Entity Handler","Returning previously loaded entity class: "..name)
    return entities.loadedclasses[name]
  else
    log.record("Entity Handler","Loading entity class: "..name)
    entities.loadedclasses[name] = lf.load(("resources/entities/%s.ent"):format(name))()
    return entities.loadedclasses[name]
  end
  
end

function entities.loadsprite(name)
  
  log.record("Entity Handler","Loading sprite of entity class: "..name)
  local ent_ = entities.loadclass(name)
  return ent_.sprite,ent_.name
  
end

function entities.load(name,x,y,id)
  
  local ent_ = entities.loadclass(name)
  local ent = {}
  if not id then ent.id = -1 else ent.id = id end
  if not x then x = 0 end
  if not y then y = 0 end
  
  log.record("Entity Handler",("Spawning entity: %s at X:%d Y:%d of ID %s"):format(name,x,y,(id or "Not yet defined")))
  
  ent.name = ent_.name
  --
  ent.dimensions = ent_.size
  ent.position = {x,y}
  ent.anim = assets.animation(unpack(ent_.anim))
  ent.anim:setState("idle")
  ent.direction = "idle"
  ent.directionalarrow = "icons/arrow2"
  ent.sprite = ent_.sprite
  ent.lock = "icons/lock"
  ent.movelocked = false
  ent.selected = false
  ent.color = ent_.color
  ent.allowmove = true
  ent.meta = ent_
  ent.dirarrowpos = {0,0}
  ent.steps = 0
  
  function ent:getDirection()
    return self.direction
  end
  
  function ent:clearsteps()
    self.steps = 0
  end
  
  function ent:setDirection(direction)
    self.direction = direction
  end
  
  function ent:move(direction)
    
    if not self.movelocked then
      self.anim:setState(direction)
      self.direction = direction
      if self.allowmove then
        local x,y,_,m = unpack(game.directions[direction])
        self.position[1] = self.position[1]+x
        self.position[2] = self.position[2]+y
        self.steps = self.steps+m
      end
    end
    
  end
  
  function ent:movelock()
    self.movelocked = true
  end
  
  function ent:moveunlock()
    self.movelocked = false
  end
  
  function ent:togglemove()
    if not self.movelocked then
      if self.allowmove then
        self.allowmove = false
      else
        self.allowmove = true
      end
    end
  end
  
  function ent:ismovelocked()
    return self.movelocked
  end
  
  function ent:setPosition(x,y)
    self.position = {x,y}
  end
  
  function ent:getPosition()
    return unpack(self.position)
  end
  
  function ent:getTruePosition()
    local x,y = self:getPosition()
    return x*32,y*32
  end
  
  function ent:getDimensions()
    return unpack(self.dimensions)
  end
  
  function ent:update(dt)
    self.anim:update(dt)
    local mx,my = lm.getRelativePosition()
    local sw,sh = self:getDimensions()
    local sx,sy = self:getTruePosition()
    sx,sy,sw,sh = math.getarea(sx,sy,sw,sh)
    if mx > sx and mx < sw and my > sy and my < sh and lm.isDown(1) then
      game.entities.selected = self.id
    end
  end
  
  function ent:setid(id)
    if type(id) == "number" and id > 0 then
      log.record("Entity Handler","Changed the ID of "..self.name.." from "..self.id.." to "..id)
      self.id = id
    else
      log.record("Entity Handler",("Attempted to change %s of ID: %d 's ID to an invalid form"):format(self.name,self.id),1,1)
      return false
    end
  end
  
  function ent:getid()
    return self.id
  end
  
  function ent:setname(n)
    self.name = n
  end
  
  function ent:getname()
    return self.name
  end
  
  function ent:getdirarrowpos()
    return unpack(self.dirarrowpos)
  end
  
  function ent:draw(cx,cy)
    
    local  x, y = self:getPosition()
    local aw,ah = self.anim:getDimensions()
    local aw2,ah2 = aw/2,ah/2
    
    x = (x*32)+cx
    y = (y*32)+cy
    
    local function draw()
      
      if conf.debug.entityframe then
        lg.setColor(0,255,255,255)
        lg.rectangle("line",x,y,aw,ah)
        lg.setColor(255,255,255,255)
      end
      
      if game.entities.selected == self.id then
        local r,g,b,a = unpack(self.color,1,3)
        a = 200
        lg.setColor(r,g,b,a)
        self.anim:draw(x-((aw2/1.75)+3),y-((ah2/1.75)+10),0,1.75,1.75)
      end
      lg.setColor(255,255,255)
      self.anim:draw(x-((aw2/1.5)-2),y-((ah2/1.5)+4),0,1.5,1.5)
      
      if conf.debug.entityspritebounds then
        lg.setColor(255,0,0)
        lg.circle("fill",x,y,2)
        lg.setColor(0,255,0)
        lg.circle("fill",x+aw,y+ah,2)
        lg.setColor(0,0,255)
        lg.circle("fill",x+(aw2),y+(ah2),2)
        lg.setColor(255,0,255)
        lg.circle("fill",x,y+ah,2)
        lg.setColor(255,255,0)
        lg.circle("fill",x+aw,y,2)
        lg.setColor(255,255,255)
      end
      
      if not self.allowmove then
        lg.draw(assets.image(self.lock),x+4,y+5)
      end
      lg.setColor(0,0,0)
      assets.font("lucida console",8)
      lg.print(math.floor(self.steps),x+5,y+13)
      lg.setColor(255,255,255)
      lg.print(math.floor(self.steps),x+4,y+12)
      
      if conf.game.showentnames then
        assets.font("lucida console",11)
        lg.setColor(0,0,0)
        lg.printf(self.name,x-31,y+36,96,"center")
        lg.setColor(255,255,255)
        lg.printf(self.name,x-32,y+35,96,"center")
      end
      
      if conf.game.showentids then
        assets.font("lucida console",8)
        lg.setColor(0,0,0)
        lg.printf(self.id,x-31,y+31,96,"center")
        lg.setColor(255,255,255)
        lg.printf(self.id,x-32,y+30,96,"center")
      end
      
      self.dirarrowpos = {x+(aw2),y+ah-4}
      lg.draw(assets.image(self.directionalarrow),self.dirarrowpos[1],self.dirarrowpos[2],math.rad(game.directions[self.direction][3]),1,1,7/2,5/2)
      
    end
    camera.draw(draw,x,y+(ah)-5,3)
    
  end
  
  function ent:getName()
    return self.name
  end
  
  function ent:clearassetcache()
    ent.anim = assets.animation(unpack(self.meta.anim))
    ent.anim:setState(self.direction)
  end
  
  function ent:reloadself()
    local x,y,dir = unpack(self.position)
    dir = self.direction
    game.entities[self.id] = entities.load(self.name,x,y,self.id)
    game.entities[self.id]:setDirection(self.direction)
    game.entities[self.id].anim:setState(self.direction)
    game.entities[self.id].allowmove = self.allowmove
  end
  
  log.record("Entity Handler",("Spawned entity: %s at X:%d Y:%d of ID %s"):format(name,x,y,(id or "Not yet defined")))
  
  return ent
  
end

return entities