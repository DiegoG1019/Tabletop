function lg.texturedPolygon(polygon,texture, x ,y ,r ,sx,sy,ox,oy, smooth) --return array of images. If drawn all, they represent textured polygon
  
  if type(polygon)~="table" or #polygon%2~=0 then return nil end  --polygon must be a table of x1,y1,x2,y2...
  if #polygon<6 then return nil end --for line return nil: nothing to draw here
  
  --load texture if needed
  if type(texture)=="string" then
    texture=love.image.newImageData(texture)
  end
  
  --default values for texture position parameters
  x  = x  or 0
  y  = y  or 0
  r  = r  or 0
  sx = sx or 1
  sy = sy or 1
  ox = ox or 0
  oy = oy or 0
  
  r = math.rad(r) --convert degrees to radians
  
  if smooth==nil then smooth=true end --we draw beautiful things on default
  
  local bb=lg.polygonBoundBox(polygon) --bounding box of polygon
  
  --simple==0 means no simplicity, 1 means we don't transform texture, 2 means we don't even need to round x,y values
  local simple=0
  if x ==0 and y ==0 and r ==0 and sx==1 and sy==1 and ox==0 and oy==0 then
    simple=1
    if bb.x==math.floor(bb.x) and bb.y==math.floor(bb.y) then
      simple=2
    end
  end
  --additionally, simple==3 means we need to transform our texture but user don't want to smooth the image
  if simple==0 and not smooth then 
    simple=3
  end
  
  --calculate some oftenly used numbers once to optimize our lovely code
  local cr,sr=math.cos(r ), math.sin(r )
  local tw,th=texture:getWidth(), texture:getHeight()
  
  --triangles is array of triangles (what a concidence!)
  local triangles
  if #polygon==6 then
    triangles={polygon}
  else
    triangles=love.math.triangulate(polygon)
  end
  
  local imageData=love.image.newImageData(math.ceil(bb.w),math.ceil(bb.h)) --empty ImageData for drawing. "empty" means every pixel has value 0,0,0,0
  
  for i,triangle in ipairs(triangles) do --for every tirangle...
    
    --we need three criteria to check whether pixel is within our triangle
    --we define three linear functions y=a#+b#*(x-c#) or x=a#+b#*(y-c#) (depend on side's inclination)
    --m# is mode: above (1), below (2), right (3) or left (4)
    --e#: whether this line is the edge of original polygon: nil(false) or range of x or y(true)
    local a0={}
    local b0={}
    local c0={}
    local m0={}
    local e0={}
    
    --I'd love to make a cycle over pair of points of triangle, but 3rd pair is (1,3) points, not (3,4)
    
    --for 1st pair of points    --we keep in mind that triangle[1]->x1,[2]->y1, [3]->x2,[4]->y2, [5]->x3,[6]->y3
    if triangle[1]==triangle[3] or math.abs( (triangle[4]-triangle[2])/(triangle[3]-triangle[1]) ) > 1 then --inclination is close to vertical
      m0[1]=2
    else
      m0[1]=1
    end
    if m0[1]==1 then --horizontal criterion
      a0[1],b0[1],c0[1] = triangle[2], (triangle[4]-triangle[2])/(triangle[3]-triangle[1]), triangle[1]
      if triangle[6] > a0[1] + b0[1]*(triangle[5]-c0[1]) then --check how another point of triangle pass this criteron
        m0[1]=1 --above criterion
      else
        m0[1]=2 --under criterion
      end
    else --vertial criterion
      a0[1],b0[1],c0[1] = triangle[1], (triangle[3]-triangle[1])/(triangle[4]-triangle[2]), triangle[2]
      if triangle[5] > a0[1] + b0[1]*(triangle[6]-c0[1]) then --check how another point of triangle pass this criteron
        m0[1]=3 --right criterion
      else
        m0[1]=4 --left  criterion
      end
    end
    if polygonEdgeLine(polygon, triangle[1],triangle[2],triangle[3],triangle[4]) then --check whether this line is the edge of polygon
      if m0[1]==1 or m0[1]==2 or m0[1]==5 or m0[1]==6 then
        e0[1]={math.min(triangle[1],triangle[3]), math.max(triangle[1],triangle[3])} --range of x where it is true
      else
        e0[1]={math.min(triangle[2],triangle[4]), math.max(triangle[2],triangle[4])} --range of y where it is true
      end
    else
      e0[1]=nil --no, it's internal splitting line
    end
    --and so on...
    
    --for 2nd pair of points
    if triangle[3]==triangle[5] or math.abs( (triangle[6]-triangle[4])/(triangle[5]-triangle[3]) ) > 1 then --inclination is close to vertical
      m0[2]=2
    else
      m0[2]=1
    end
    if m0[2]==1 then --horizontal criterion
      a0[2],b0[2],c0[2] = triangle[4], (triangle[6]-triangle[4])/(triangle[5]-triangle[3]), triangle[3]
      if triangle[2] > a0[2] + b0[2]*(triangle[1]-c0[2]) then
        m0[2]=1 --above criterion
      else          
        m0[2]=2
      end
    else --vertial criterion
      a0[2],b0[2],c0[2] = triangle[3], (triangle[5]-triangle[3])/(triangle[6]-triangle[4]), triangle[4]
      if triangle[1] > a0[2] + b0[2]*(triangle[2]-c0[2]) then
        m0[2]=3
      else
        m0[2]=4
      end
    end
    if polygonEdgeLine(polygon, triangle[3],triangle[4],triangle[5],triangle[6]) then
      if m0[2]==1 or m0[2]==2 or m0[2]==5 or m0[2]==6 then
        e0[2]={math.min(triangle[3],triangle[5]), math.max(triangle[3],triangle[5])}
      else
        e0[2]={math.min(triangle[4],triangle[6]), math.max(triangle[4],triangle[6])}
      end
    else
      e0[2]=nil
    end
    
    --for 3rd pair of points
    if triangle[1]==triangle[5] or math.abs( (triangle[6]-triangle[2])/(triangle[5]-triangle[1]) ) > 1 then --inclination is close to vertical
      m0[3]=2
    else
      m0[3]=1
    end
    if m0[3]==1 then --horizontal criterion
      a0[3],b0[3],c0[3] = triangle[2], (triangle[6]-triangle[2])/(triangle[5]-triangle[1]), triangle[1]
      if triangle[4] > a0[3] + b0[3]*(triangle[3]-c0[3]) then
        m0[3]=1
      else
        m0[3]=2
      end
    else --vertial criterion
      a0[3],b0[3],c0[3] = triangle[1], (triangle[5]-triangle[1])/(triangle[6]-triangle[2]), triangle[2]
      if triangle[3] > a0[3] + b0[3]*(triangle[4]-c0[3]) then
        m0[3]=3
      else
        m0[3]=4
      end
    end
    if polygonEdgeLine(polygon, triangle[1],triangle[2],triangle[5],triangle[6]) then
      if m0[3]==1 or m0[3]==2 or m0[3]==5 or m0[3]==6 then
        e0[3]={math.min(triangle[1],triangle[5]), math.max(triangle[1],triangle[5])}
      else
        e0[3]={math.min(triangle[2],triangle[6]), math.max(triangle[2],triangle[6])}
      end
    else
      e0[3]=nil
    end
    
    local function func(x,y,r,g,b,a) --function to apply to mapPixel method of ImageData polygon
      if r~=0 or g~=0 or b~=0 or a~=0 then return r,g,b,a end --pixel was already drawn, skip
      
      x=x+bb.x --go from resulting image coordinates to internal texture coordinates
      y=y+bb.y
      
      local alpha=1 --transparency to smooth edge (only used if smooth==true)
      
      --check all three criteria
      for j=1,3 do
        if m0[j]==1 then
          local y0=a0[j]+b0[j]*(x-c0[j]) --what to compare with
          if smooth and e0[j]~=nil and x>=e0[j][1] and x<e0[j][2] then --whether we need to smooth edge
            local z=y0-y --how far we are from ideal position of edge
              if z>1 then --we are too far
                return 0,0,0,0
              elseif z>0 then --we are within one-pixel edge area of smoothing
                alpha=alpha*(1-z)
              end
          elseif y<y0 then --we are outside of the triangle
            return 0,0,0,0
          end
          --and so on...
        elseif m0[j]==2 then
          local y0=a0[j]+b0[j]*(x-c0[j])
          if smooth and e0[j]~=nil and x>=e0[j][1] and x<e0[j][2] then
            local z=y0-y
            if z<0 then
              return 0,0,0,0
            elseif z<1 then
              alpha=alpha*z
            end
        elseif y>=y0 then
          return 0,0,0,0
        end
      elseif m0[j]==3 then
        local x0=a0[j]+b0[j]*(y-c0[j])
        if smooth and e0[j]~=nil and y>=e0[j][1] and y<e0[j][2] then
          local z=x0-x
          if z>1 then
            return 0,0,0,0
          elseif z>0 then
            alpha=alpha*(1-z)
          end
        elseif x<x0 then
          return 0,0,0,0
        end
      elseif m0[j]==4 then
        local x0=a0[j]+b0[j]*(y-c0[j])
        if smooth and e0[j]~=nil and y>=e0[j][1] and y<e0[j][2] then
          local z=x0-x
          if z<0 then
            return 0,0,0,0
          elseif z<1 then
            alpha=alpha*z
          end
        elseif x>=x0 then
          return 0,0,0,0
        end
      end
    end
    
    if simple==0 then --complicated case
      r,g,b,a=lg.getAveragePixel(texture, ((x+0.5-x )*cr+(y+0.5-y )*sr)/sx+ox, ((y+0.5-y )*cr-(x+0.5-x )*sr)/sy+oy, tw,th)
    elseif simple==1 then --simpler case
      r,g,b,a=texture:getPixel( math.floor(x)%tw, math.floor(y)%th)
    elseif simple==2 then --simplest case
      r,g,b,a=texture:getPixel( x%tw, y%th)
    else--if simple==3 then --ugly but fast case
      r,g,b,a=texture:getPixel( math.floor(((x-x )*cr+(y-y )*sr)/sx+ox)%tw, math.floor(((y-y )*cr-(x-x )*sr)/sy+oy)%th)
    end
    
    if smooth then a=a*alpha end --make edge as beautiful as we can
    --return texture:getPixel( (x)%texture:getWidth(), (y)%texture:getHeight())
    return r,g,b,a
  end
  
  imageData:mapPixel(func) --applying will draw one more triangle on the imageData
  end
  
  local image=love.graphics.newImage(imageData) --creating drawable object
  
  return {img=image, x=bb.x,y=bb.y,w=bb.w,h=bb.h, imgData=imageData}
  
end

function lg.polygonBoundBox(polygon) --simple function that find max and min x,y coordinates of a polygon and return them in a form of BoundingBox object: {x,y,w,h}
  if type(polygon)~="table" or #polygon<2 or #polygon%2~=0 then return nil end
  
  local minX=polygon[1]
  local maxX=polygon[1]
  local minY=polygon[2]
  local maxY=polygon[2]
  
  for i=1,#polygon,2 do
    if polygon[i]<minX then minX=polygon[i] end
    if polygon[i]>maxX then maxX=polygon[i] end
    if polygon[i+1]<minY then minY=polygon[i+1] end
    if polygon[i+1]>maxY then maxY=polygon[i+1] end
  end
  
  return {x=minX,y=minY,w=maxX-minX,h=maxY-minY}
end
 
function lg.polygonEdgeLine(polygon, x1,y1,x2,y2) --specific function that checks whether given pair of points belongs to one edge of a polygon
  local length=#polygon
  if type(polygon)~="table" or length<4 or length%2~=0 then return nil end
  
  local buf={} --comparison of non-integer values may be safe only if these values are rounded (to two digits, for example)
  for i,v in ipairs(polygon) do
    buf[i]=math.floor(v*100)/100
  end
  
  x1=math.floor(x1*100)/100
  y1=math.floor(y1*100)/100
  x2=math.floor(x2*100)/100
  y2=math.floor(y2*100)/100
  
  for i=1,length-2,2 do --compare all but the last line
    if buf[i]==x1 and buf[i+1]==y1 and buf[i+2]==x2 and buf[i+3]==y2 then
      return true
    elseif buf[i]==x2 and buf[i+1]==y2 and buf[i+2]==x1 and buf[i+3]==y1 then
      return true
    end
  end
  
  --compare last line separately
  if buf[1]==x1 and buf[2]==y1 and buf[length-1]==x2 and buf[length]==y2 then
    return true
  elseif buf[1]==x2 and buf[2]==y2 and buf[length-1]==x1 and buf[length]==y1 then
    return true
  end
  
  --if we have passed all previous checks, we fail:
  return false
end
 
function lg.getAveragePixel(texture, x,y,w,h) --return a pixel which color is averaged over neighbour pixels of a texture around x,y coordinates. w,h calculated previously to speed up the code
  local x1,x2,y1,y2 = math.floor(x), math.ceil(x), math.floor(y), math.ceil(y) --find neighbour integer-indexed pixels
  if x2==x1 then x2=x2+1 end
  if y2==y1 then y2=y2+1 end
  
  local d1,d2,d3,d4 = (x2-x)*(y2-y), (x-x1)*(y2-y), (x2-x)*(y-y1), (x-x1)*(y-y1) --find fraction of each pixel in a result
  
  x1=x1%w --ensure we are within texture (wrapped around)
  x2=x2%w
  y1=y1%h
  y2=y2%h
  
  local r1,g1,b1,a1 = texture:getPixel(x1,y1) --obtain four raw colors
  local r2,g2,b2,a2 = texture:getPixel(x2,y1)
  local r3,g3,b3,a3 = texture:getPixel(x1,y2)
  local r4,g4,b4,a4 = texture:getPixel(x2,y2)
  
  --...and average it all
  return d1*r1+d2*r2+d3*r3+d4*r4, d1*g1+d2*g2+d3*g3+d4*g4, d1*b1+d2*b2+d3*b3+d4*b4, d1*a1+d2*a2+d3*a3+d4*a4
end

function lg.roundRectangle(x, y, w, h, r)
  
  local right = 0
  local left = math.pi
  local bottom = math.pi * 0.5
  local top = math.pi * 1.5
  r = r or 15
  lg.rectangle("fill", x, y+r, w, h-r*2)
  lg.rectangle("fill", x+r, y, w-r*2, r)
  lg.rectangle("fill", x+r, y+h-r, w-r*2, r)
  lg.arc("fill", x+r, y+r, r, left, top)
  lg.arc("fill", x + w-r, y+r, r, -bottom, right)
  lg.arc("fill", x + w-r, y + h-r, r, right, bottom)
  lg.arc("fill", x+r, y + h-r, r, bottom, left)

end