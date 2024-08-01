% Create an occupancy grid map from points
function gridmap = OccuGrid(pts, pixelSize)
% pts:localMap [x1 y1;x2 y2;...]
% pixelSize:the side length of a cell in a grid map

%---------- Grid size ----------
minXY = min(pts) - 3 * pixelSize;
maxXY = max(pts) + 3 * pixelSize;
Sgrid = round((maxXY - minXY) / pixelSize) + 1; % number of Grid

%-------------------- Assignment --------------------
N = size(pts, 1);
% The coordinates of the occupied grid
hits = round((pts-repmat(minXY, N, 1)) / pixelSize) + 1; % map.point 所占的格子
idx = (hits(:,1)-1)*Sgrid(2) + hits(:,2);  % 转为一维坐标

grid  = false(Sgrid(2), Sgrid(1));      % logical zero
grid(idx) = true;                           % true = there is a scan point

gridmap.occGrid = grid;                     % OccuGrid Map
gridmap.metricMap = min(bwdist(grid),10);   % distance from the nearest non-zero pixel
gridmap.pixelSize = pixelSize;
gridmap.topLeftCorner = minXY;