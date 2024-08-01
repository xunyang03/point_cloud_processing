% Extract a local map according to current scan
function localMap = ExtractLocalMap(point,scan,pose,borderSize)
% Input
%   point:existing map points
%   scan:current scan in RF
%   borderSize:size
% Output
%   localMap:local map around current pose

scan_w = Transform(scan,pose);
% Set top-left & bottom-right corner
minX = min(scan_w(:,1) - borderSize); % left
minY = min(scan_w(:,2) - borderSize); % bottom
maxX = max(scan_w(:,1) + borderSize); % right
maxY = max(scan_w(:,2) + borderSize); % top

% Extract
isAround = point(:,1) > minX...
         & point(:,1) < maxX...
         & point(:,2) > minY...
         & point(:,2) < maxY;

localMap = point(isAround, :);