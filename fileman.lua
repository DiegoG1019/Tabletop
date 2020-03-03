fileman = {}

function fileman.write(file, data, mode, user, isSilent, dir, noComp)
  
  if not noComp then data = love.math.compress(data,"zlib") end
  
  if mode then
  elseif lf.exists(file) and not mode then
    mode = "a"
  elseif not mode then
    mode = "w"
  elseif not mode == "a" or not mode == "w" then
    mode = "w"
  elseif not mode == "a" or not mode == "w" and lf.exists(file) then
    mode = "a"
  end
  
  if dir then 
    fileman.dir(dir,isSilent,user) --Creates the directory
    file=dir.."/"..file --Concatenates the file and directory so the directory will be used
  end
  

  if file then
    
    local file_, errorstr = lf.newFile(file, mode)
    
    if errorstr then
      log.record("File Manager", "Invalid file received for: "..user.." - error: "..errorstr, true, 1)
      return
    end
    
    if type(data) == "table" then
      
      local index = 1
      
      for i,v in pairs(data) do
        
        file_:write(data[index])
        index = index + 1
        
      end
      
      file_:close()
      
      if not isSilent then
        
        if mode == "a" then 
          log.record("File Manager", "Successfully appended data into: "..file..", for: "..user, false)
        elseif mode == "w" then
          log.record("File Manager", "Successfully wrote data into: "..file..", for: "..user, false)
        else
          log.record("File Manager", "Successfully did something into: "..file..", for: "..user, false)
        end
        
      end
      
      return true
      
    else
      
      file_:write(data)
      file_:close()
      
      if not isSilent then
        
        if mode == "a" then 
          log.record("File Manager", "Successfully appended data into \""..file.."\" for: "..user, false)
        elseif mode == "w" then
          log.record("File Manager", "Successfully wrote data into \""..file.."\" for: "..user, false)
        else
          log.record("File Manager", "Successfully did something into \""..file.."\" for: "..user, false)
        end
        
      end
      
    end
    
  end
  
end

function fileman.dir(dir,isSilent,user)
  
  dir = dir.."/"
  local success = lf.createDirectory(dir)
  if not success then
    if not isSilent then log.record("File Manager", "Couldn't create the specified directory for: "..user, true, 1) end
    return
  else
    if not isSilent then log.record("File Manager", "Successfully created the specified directory for: "..user) end
    return true
  end
  
end

function fileman.list(dir)
  return lf.getDirectoryItems(dir)
end

function fileman.read(file, noComp)
  
  if lf.exists(file) then
    
    local output = lf.read(file)
    if not noComp then output = select(2,pcall(love.math.decompress,output,"zlib")) end
    return output
    
  else
    
    log.record("File Manager", "Error reading '"..file..". File does not exist.", true)
    
    return false
    
  end

end

function fileman.exists(file)
  return lf.exists(file)
end

return fileman