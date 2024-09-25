function width=Width(angle)
global x y
xn=sin(-angle)*x-cos(-angle)*y;
width=max(xn)-min(xn);