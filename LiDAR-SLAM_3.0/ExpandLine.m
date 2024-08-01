function point = ExpandLine(endPoint)
% Inuput
%   line:slope and centrual points
%   map:first and end points
% Output
%   point:expanded line points with line feature

if isempty(endPoint)
    point = [];
    return
end

k = size(endPoint,2)/2;
point = zeros(1,2);
front = 0;

for i = 1 : k
    length = 100*ceil(norm([endPoint(1,2*i-1) endPoint(1,2*i)]-[endPoint(2,2*i-1) endPoint(2,2*i)]));
    point(front + 1:front + length,1) = linspace(endPoint(1,2*i-1),endPoint(2,2*i-1),length)';
    point(front + 1:front + length,2) = linspace(endPoint(1,2*i),endPoint(2,2*i),length)';
    front = size(point,1);
end

return