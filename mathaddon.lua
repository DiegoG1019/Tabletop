local mathDat = {randomCalls = 0}
math.vector = {}
math.roman = {}
math.marioplex = 10^12431
math.randomseed(love.timer.getTime())

function math.factorial(n)
  
  local a = os.clock()
  
  for i=1,n-1 do
    n=n*i
  end
  
  local b = os.clock()

  return n, b-a

end

function math.permutation(n,r)

  --Where n is group size and r is total available

  if n < r then error("Group Size is greater than total available") return 0 end

  local n1, r1, a

  n1 = math.factorial(n)
  r1 = math.factorial(n-r)

  a = n1/r1

  return a

end

function math.percent(a,b)
  return a*(b/100)
end

function math.percentageOf(n,per)
  return (n*100)/per
end

function math.resize(oW,oH , nW,nH) --oW = oldWidth, oH = oldHeight; nW = newWidth, nH = newHeight
  --[[
  oW = oW or 1
  oH = oH or 1
  
  if not nW and not nH then
    return math.percentageOf(oH,oW)
  end
  return math.percentageOf(nW,oW), math.percentageOf(nH,oH)
  ]]
  
  oW = oW or 1
  oH = oH or 1
  
  if not nW and not nH then
    return oH/oW
  end
  return nW/oW, nH/oH
  
end

function math.getarea(x,y,w,h)
  return x,y,x+w,y+h
  --right, top, left, bottom
end

local hex = "0123456789ABCDEF"
function math.tohex(dec) --This function only returns strings; if you want a hex /number/, then concat a '0x' at the start and use tonumber()
  local s = ""
  while dec > 0 do
    local mod = math.fmod(dec,16)
    s = string.sub(hex, mod+1, mod+1) .. s
    dec = math.floor(dec / 16)
  end
  if s == '' then s = '0' end
  return s
end

function math.isInt(n)
  return n==math.floor(n)
end

function math.vector.str(x,y)
	return ("(%n,%n)"):format(tonumber(x),tonumber(y))
end

function math.vector.mul(s, x,y)
	return s*x, s*y
end

function math.vector.div(s, x,y)
	return x/s, y/s
end

function math.vector.add(x1,y1, x2,y2)
	return x1+x2, y1+y2
end

function math.vector.sub(x1,y1, x2,y2)
	return x1-x2, y1-y2
end

function math.vector.permul(x1,y1, x2,y2)
	return x1*x2, y1*y2
end

function math.vector.dot(x1,y1, x2,y2)
	return x1*x2 + y1*y2
end

function math.vector.det(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end

function math.vector.eq(x1,y1, x2,y2)
	return x1 == x2 and y1 == y2
end

function math.vector.lt(x1,y1, x2,y2)
	return x1 < x2 or (x1 == x2 and y1 < y2)
end

function math.vector.le(x1,y1, x2,y2)
	return x1 <= x2 and y1 <= y2
end

function math.vector.len2(x,y)
	return x*x + y*y
end

function math.vector.len(x,y)
	return math.sqrt(x*x + y*y)
end

function math.vector.dist(x1,y1, x2,y2)
	return len(x1-x2, y1-y2)
end

function math.vector.normalize(x,y)
	local l = len(x,y)
	return x/l, y/l
end

function math.vector.rotate(phi, x,y)
	local c, s = math.cos(phi), math.sin(phi)
	return c*x - s*y, s*x + c*y
end

function math.vector.perpendicular(x,y)
	return -y, x
end

function math.vector.project(x,y, u,v)
	local s = (x*u + y*v) / (u*u + v*v)
	return s*u, s*v
end

function math.vector.mirror(x,y, u,v)
	local s = 2 * (x*u + y*v) / (u*u + v*v)
	return s*u - x, s*v - y
end

local map = { 
  I = 1,
  V = 5,
  X = 10,
  L = 50,
  C = 100,
  D = 500,
  M = 1000,
}

local numbers = { 1, 5, 10, 50, 100, 500, 1000 }
local chars = { "I", "V", "X", "L", "C", "D", "M" }

function math.roman.toRoman(s)
    --s = tostring(s)
    s = tonumber(s)
    if not s or s ~= s then error"Unable to convert to number" end
    if s == math.huge then error"Unable to convert infinity" end
    s = math.floor(s)
    if s <= 0 then return s end
	local ret = ""
        for i = #numbers, 1, -1 do
        local num = numbers[i]
        while s - num >= 0 and s > 0 do
            ret = ret .. chars[i]
            s = s - num
        end
        --for j = i - 1, 1, -1 do
        for j = 1, i - 1 do
            local n2 = numbers[j]
            if s - (num - n2) >= 0 and s < num and s > 0 and num - n2 ~= n2 then
                ret = ret .. chars[j] .. chars[i]
                s = s - (num - n2)
                break
            end
        end
    end
    return ret
end

function math.roman.toNumber(s)
    s = s:upper()
    local ret = 0
    local i = 1
    while i <= s:len() do
--  for i = 1, s:len() do
        local c = s:sub(i, i)
        if c ~= " " then -- allow spaces
            local m = map[c] or error("Unknown Roman Numeral '" .. c .. "'")
            
            local next = s:sub(i + 1, i + 1)
            local nextm = map[next]
            
            if next and nextm then
                if nextm > m then 
                -- if string[i] < string[i + 1] then result += string[i + 1] - string[i]
                -- This is used instead of programming in IV = 4, IX = 9, etc, because it is
                -- more flexible and possibly more efficient
                    ret = ret + (nextm - m)
                    i = i + 1
                else
                    ret = ret + m
                end
            else
                ret = ret + m
            end
        end
        i = i + 1
    end
    return ret
end