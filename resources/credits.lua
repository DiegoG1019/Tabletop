credits = {
  
  dg = {lang.credits.dg,"Diego García"},
  lb = {lang.credits.lb, "Lenin Briceño"},
  tpm = {lang.credits.tpm, {
    {lang.credits.TEsound, "'Ensayia', 'Taehl' love2d.org/wiki/TEsound"},
		{"Shine", "'Matthias Richter' github.com/vrld/"},
    {lang.credits.rich, "'Robin Wellner', 'Florian Fischer' https://github.com/gvx/richtext"},
    {lang.credits.lovox, "'Tjakka5' https://github.com/tjakka5/Lovox"},
    {lang.credits.boipushy, "'SSYGEN' https://github.com/SSYGEN/boipushy"},
    {lang.credits.windfield, "'SSYGEN' https://github.com/SSYGEN/windfield"}
    }
  },
  framework = lang.credits.engine
}

function loopCredits(t)
  
  log.record("Credits","Rolling...")
  
  for i,v in pairs(t) do
    
    if type(v[2]) == "table" then
      
      loopCredits(v[2])
      
    else
      
      print(v[1],v[2])
      
    end
    
  end

end