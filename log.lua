log = {records = {}, fullrecords = {},logsaved = false}
do
  local game = ("%s %d.%d.%d - %s"):format(getGameVer())
  log.title = os.time() .. game
end

local logsaved = false

function log.record(source, data, iserror, gravity, catchCall)
  
  gravity = gravity or 1
  iserror = iserror or false
  catchCall = catchCall or 3
  if data then data = tostring(data) else data = "No info available." end
  local debugInf = debug.getinfo(catchCall).name or "Catch Call unavailable."
  
  if iserror then
    
    assert(gravity <= 1,("[%s](%s)"):format(source,data))
    assert(not conf.debug.strict, ("{%d:%d:%d}[%s](%s) ||ERROR"):format(os.date("%H"),os.date("%M"),os.date("%S"),source,data))
    
    local str = ("{%d:%d:%d}[%s](%s) ||ERROR"):format(os.date("%H"),os.date("%M"),os.date("%S"),source,data)
    
    table.insert(log.records,str)
    print(str)
    if conf.debug.otc then
      table.insert(console.output,1,str)
    end
    
  else
    
    local str = ("{%d:%d:%d}[%s](%s)"):format(os.date("%H"),os.date("%M"),os.date("%S"),source,data)
    
    table.insert(log.records,1,str)
    print(str)
    if conf.debug.otc then
      table.insert(console.output,1,str)
    end
    
  end
  
  return data
  
end

function log.subrecord(source,data)
  if conf.debug.strict and conf.debug.sublog then
    local str = ("///{%d:%d:%d}[%s](%s)"):format(os.date("%H"),os.date("%M"),os.date("%S"),source,data)
    table.insert(log.fullrecords, str)
    print(str)
  end
end

if conf.debug.profile then
  log.record("Log","Running in strict mode, non-release version.")
  log.profile = require 'profile'
  log.profile.hookall("Lua")
end

function log.savelog(crash)
  
  local startTime = love.timer.getTime()
  local header
  
  do
    local game = ("Game: %s: %d.%d.%d - %s"):format(getGameVer())
    header = game
  end
  
  local body    = "\n---------------------------\n"
  local subbody = "\n---------------------------\n"
  
  local mode
  if logsaved then mode = "a" else mode = "w"; logsaved = true end
  
  for i,v in pairs(log.records) do
    
    body = body.."\n"..v
    
  end
  body    = body    .."\n\n---------------------------\n"
  
  local footer    = string.format("Dumped %d items in %d miliseconds", #log.records, ((love.timer.getTime()*1000)-(startTime*1000)))
  
  if crash then
    
    return {log.title,string.format("%s%s%s",header,body,footer)}
    
  else
    
    fileman.write(log.title..".log",string.format("%s%s%s",header,body,footer),mode,"log",false,"logs",true)
    
  end
  
end

if not conf.debug.loveerrorhand then
  
  function love.errhand(msg)
    
    love.audio.stop()
    
    local trace,os,battery,processor , state, percent, seconds , graphic , cores , und , separ , name , version , vendor , device
    und = "Undefined"
    separ = "\n--------------------------------\n"
    
    trace = debug.traceback()
    
    local crashreport = "crash.log"
    local crashreportdir = "logs/crash/"
    
    state, percent, seconds = love.system.getPowerInfo()
    state = state or und
    percent = percent or und
    seconds = seconds or und
    name, version, vendor, device = lg.getRendererInfo() or und, und, und, und
    
    cores = love.system.getProcessorCount()
    
    os = "OS: "..love.system.getOS()
    battery = string.format("Battery info: State = %s; Charge = %d%; Battery life left = %d",state,percent,seconds)
    processor = "Processor info: Cores = "..cores
    graphic = string.format([[Renderer:
  Software: %s
  Version: %s
  Vendor: %s
  Hardware: %s]],name,version,vendor,device)
    
    local header = ("%s %d.%d.%d - %s"):format(getGameVer())
    
    local a = "LÖVE Graphics state in last frame:\n    "
    local stats = lg.getStats()
    a = a.."Drawcalls: "..stats.drawcalls.."\n    Canvas Switches: "..stats.canvasswitches.."\n    Texture Memory: "..stats.texturememory.." bytes\n    Loaded images: "..stats.images.."\n    Loaded canvases: "..stats.canvases.."\n    Loaded fonts: "..stats.fonts.."\n    Shader Switches: "..stats.shaderswitches
    
    local b = "LÖVE window state:\n    "
    
    local isFs, fst = love.window.getFullscreen()
    
    local ww,wh,flags = love.window.getMode()
    
    lg.setColor(3,3,131,120)
    lg.rectangle("fill",0,0,ww,wh)
    lg.present()
    
    local w,h = love.window.getDesktopDimensions(flags.display)
    
    local deskdm = "w"..w.."*h"..h
    
    local windmode = "w"..ww.."*h"..wh.."\n"
    
    for i,v in pairs(flags) do
      
      windmode = windmode.."    "..i..":"..tostring(v).."\n    "
      
    end
    
    b=b.."Is Visible: "..tostring(love.window.isVisible())..
    "\n    Fullscreen: "..tostring(isFs)..
    ", Type: "..
    fst..
    "\n    Display: "..
    love.window.getDisplayName(flags.display)..
    ", Count: "..
    love.window.getDisplayCount()..
    "\n    Is Focused: "..
    tostring(love.window.hasFocus())..
    "\n    Desktop Dimensions: "..
    deskdm..
    "\n    Window Mode: "..
    windmode
    
    local c = "Game State\n    Common: "..gamestate.common
    local e = header..separ..os..separ..battery..separ..processor..separ..graphic..separ..a..separ..b..separ.."Keyboard: TextInput: "..tostring(lk.hasTextInput())..separ..c..separ
    
    fileman.write(crashreport, e.."\n"..msg.."\n"..trace.."\n\n"..log.savelog(true), "w", "log", false, crashreportdir)
    love.window.showMessageBox("FATAL ERROR (Not really)", love.window.getTitle().." has crashed. We've collected relevant data and stored it in \""..crashreport.."\"\nWe have also attempted to make an emergency backup of your save.\nPlease contact us at \""..author.contact.."\"\nClose this message box to continue.", "error", false)
    love.event.quit()
    
  end
  
end