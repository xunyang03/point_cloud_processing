%% Modified V3.0
% Date: 2021/7/12
% Update:
% 1. Add Graph data structure
%% Code
clear; close all; clc;
%--------------------------- Setting variable --------------------------
lidar = SetLidarParameters(2);
cfig = figure(1);
lidar_data = load('dataset/new_laser_data4.mat');
N = size(lidar_data.times, 1);

% Map parameters 
borderSize    = 1;            
pixelSize     = 0.2;          
miniUpdated   = false;         
miniUpdateDT  = 0.1;         
miniUpdateDR  = deg2rad(5);   

% Scan matching parameters
fastResolution  = [0.05; 0.05; deg2rad(0.5)]; 
bruteResolution = [0.01; 0.01; deg2rad(0.1)];

% Create an empty map
map.points = [];
map.keyscans = [];    % 关键帧 
pose = [0; 0; 0];
path = pose;
poseGraph = PoseGraph();

%============================== SLAM Part ==============================
tic;
for scanIdx = 1 : 1 : 1200
    
    disp(['scan ', num2str(scanIdx)]);
    scan = ReadAScan(lidar_data, scanIdx, lidar, 24);
 %------------------------ Initialize ------------------------   
    if scanIdx == 1
        [myrest, map] = Initialize(scan,pose,map);
        poseGraph.insertNode(1,pose);
        miniUpdated = true;  continue;
    end
        
 %------------------------ Pose initial guess ------------------------   
    if scanIdx > 2
        pose_guess = pose + DiffPose(path(:,end-1), pose);
    else
        pose_guess = pose;
    end
    
%------------------------ Matching scan2submap ------------------------
    if miniUpdated
        localMap = ExtractLocalMap(map.points,scan,pose,borderSize); 
        if isempty(localMap)
            error("Too much error !");
        end
        gridMap1 = OccuGrid(localMap, pixelSize);
        gridMap2 = OccuGrid(localMap, pixelSize/2);
    % match current pose with the last keyscan's submap
        [pose, ~] = FastMatch(gridMap1, scan, pose_guess, fastResolution);
    else
        [pose, ~] = FastMatch(gridMap2, scan, pose_guess, fastResolution);
    end
    % Refine the pose using smaller pixels
%     [pose, hits] = FastMatch(gridMap2, scan, pose, fastResolution/2);
    [pose, hits] = BruteMatch(gridMap2, scan, pose, bruteResolution,0.1,deg2rad(0.5));
   
%------------------------ Update Map & Pose------------------------
    dp = abs(DiffPose(map.keyscans(end).pose, pose));
    ds = DiffPose(map.keyscans(end).pose, pose);
    if dp(1)>miniUpdateDT || dp(2)>miniUpdateDT || dp(3)>miniUpdateDR
        miniUpdated = true;        
        [map, myline] = AddKeyScan(map, scan, pose, hits);
        %
        nkey = length(map.keyscans);
        nedge = poseGraph.n_edge;
        nedge = nedge+1;
        poseGraph.insertNode(nkey,pose);
        poseGraph.insertEdge(nedge,nkey, nkey-1,ds,eye(3));
        
        if TryLoopOrNot(map)
            map.keyscans(end).loopTried = true;
            [map, myline, matchScan] = DetectLoopClosure(map, scan, myline, hits, 4, pi/6, pixelSize);
            pose = map.keyscans(end).pose;
            %
            poseGraph.insertNode(nkey,pose);
            if matchScan ~= 0
                ds = DiffPose(map.keyscans(matchScan).pose, pose);
                poseGraph.insertEdge(nedge+1,nkey,matchScan,ds,eye(3));
                poseGraph.optimize(5, true);
            end            
            pose = poseGraph.pose(:,end);
            
        end
        
        myrest = Line2Map(myrest, myline);              % merging
        map.points = ExpandLine(myrest.point);
    else
        miniUpdated = false;
    end
   
    path = [path  pose];
%----------------------------- Plot -----------------------------
    if mod(scanIdx, 30) == 0        % scanIdx是30的整数倍
%         PlotMap(cfig, map, path, scan, scanIdx);
    end
end    

mytime = toc;
disp(['Total time: ',num2str(toc)]);
 
figure(2)
PlotLine(myrest.point,size(myrest.decision,2),2);