% Projection
function projx = DoProject(x,y,m,n)
% Input
%   x,y: point
%   m,n: slope & deviation
% Output
%   projx: Abscissa after projection
len = length(x);
if len == 0
    return
elseif len == 1
    projx = (x+m*(y-n))/(m^2+1);
else
    projx = (x(1:len)+m*(y(1:len)-n))/(m^2+1);
end
return