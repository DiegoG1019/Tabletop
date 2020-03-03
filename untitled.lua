a = 5
b = 95
c = "= V4 + "
str = "IF(AB%d > 0;V%d-U%d;-U%d) + "

for x=a,b,1 do
  c = c..str:format(x,x,x,x)
end
print(c)