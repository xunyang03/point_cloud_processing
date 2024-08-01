function [line, map] = Initialize(scan, pose, map)

    % line detection
    scan_w = Transform(scan,pose);
    mclust = DoCluster1(scan_w,0.3);            % 1st-level cluster
    sclust = DoCorner(mclust);                  % Corner Detect
    line = PCALine(sclust); % PCA Line fitting
    tempPts = ExpandLine(line.point);
    
    % update map        
    map.points(:,1:2) = tempPts;
    
    k = length(map.keyscans)+1;
    map.line(k).point = line.point;
    map.line(k).decision = line.decision;
    map.keyscans(k).pose = pose;
    map.keyscans(k).iBegin = 1;
    map.keyscans(k).iEnd = size(tempPts,1);
    map.keyscans(k).loopClosed = true;
    map.keyscans(k).loopTried = false;
