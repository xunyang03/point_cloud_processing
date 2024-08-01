function [map, matchScan] = DetectLoopClosure(map, scan, hits, Tmax, Rmax, pixelSize)
% Input:
%   scan: scan in lidar frame
%   rest: rest of the line

k = length(map.keyscans);  % current total number of key scan
pose = map.keyscans(end).pose; % current pose (need modification)

%---------- Condition 1: Distance > 50 ----------
S = 0;
while k > 1 && S < 20
    k = k-1;
    dT = DiffPose(map.keyscans(k).pose, map.keyscans(k+1).pose);
    S  = S + norm(dT(1:2)); 
end

%---------- Condition 2: Displacement < Tmax ----------
L = 0;
for i = k : -1 : 1
    dp = DiffPose(map.keyscans(i).pose, pose);
    if norm(dp(1:2)) < Tmax + 1
        L = i;
        matchScan = L;
        break;
    end
end
if L < 1 
    matchScan = 0;
    return;
end

disp('Loop detected');

% =============== Loop Closure Detection ===============
% Extract a refrence map around current scan
ndear = map.keyscans(matchScan).iEnd;
dearPoints = map.points(1:ndear, :);
refMap  = ExtractLocalMap(dearPoints, scan, pose, Tmax+4);
% refMap  = ExtractLocalMap(map.points, scan, pose, Tmax+4);

scoreThresh = sum(hits) * 0.8;
countThresh = sum(hits==0) * 0.6;       % 等于0有几项，即被占用的栅格数

% Brute force scan matching
refGrid = OccuGrid(refMap, pixelSize);
resol = [0.05, 0.05, deg2rad(0.5)];
[bestPose, bestHits] = BruteMatch(refGrid, scan, pose, resol, Tmax/Tmax, Rmax);

if sum(bestHits<4) > countThresh && sum(bestHits) < scoreThresh
    disp('Loop closure');
    pose = bestPose;
    hits = bestHits;
    pause(1);
end

scan_w = Transform(scan,pose);
mclust = DoCluster1(scan_w,0.3);             % 1st-level cluster    
sclust = DoCorner(mclust);                      % Corner Detect    
myline = PCALine(sclust);  % PCA Line fitting
tempPts = ExpandLine(myline.point); npts = size(tempPts,1);

%-------------------- Update Map --------------------
a = map.keyscans(end).iBegin;
b = map.keyscans(end).iEnd;
front = map.keyscans(end-1).iEnd;
map.points(a:b,:) = []; 
map.line(end) = [];

% Update
k = length(map.keyscans);
map.points(front+1:front+npts,1:2) = tempPts;
map.line(k).point = myline.point;
map.line(k).decision = myline.decision;
map.keyscans(end).pose = pose;
map.keyscans(end).iBegin = front + 1;
map.keyscans(end).iEnd = front + npts;
map.keyscans(end).loopClosed = true;



        
    
    
    
    
    
    
    
    
    