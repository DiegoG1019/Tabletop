conf = 0
configure = {
  
  save = function()
    
    local dat = table.write(conf)
    fileman.write("options", dat, "w", "conf", false, "sys")
    
  end,
  
  change = function(menu, option, value)
    
    conf[menu][option] = value
    
    log.record("Config", string.format("Changed %s/%s to %t",menu,option,value))
    return true
    
  end,
  
  language = function(value)
    
    if fileman.exists(("resources/lang/%s.lang"):format(value)) then
      conf.global.language = value
      lf.load(("resources/lang/%s.lang"):format(conf.global.language))()
      log.record("Config", "Changed the game's language to "..value)
      return true
    else
      return false
    end
    
  end,
  
  load = function()
    
    if not lf.exists("sys/options") or true then
      --Comment this "or true" when not necessary, this is to ensure the default values are loaded for debug purposes
      
      conf = lf.load("default.conf")()
      print("Configurations file does not exist; loaded default values")
      
    else
      
      local confstr = fileman.read("sys/options")
      local success
      success,conf = pcall(loadstring,confstr)
      
      if not success then
        print("Configurations file is corrupted; loaded default values")
        conf = lf.load("default.conf")()
      end
      
      print("Loaded confurations")
      
    end
    
    lf.load(("resources/lang/%s.lang"):format(conf.global.language))()
    
  end
  
}