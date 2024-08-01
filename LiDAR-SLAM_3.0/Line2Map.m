%  Update new lines into the map
function restMap = Line2Map(exLine, newLine)
% Input
%   newLine:new line with points & decisions
%   exLine:exist lines with points & decisions
% Output
%   Rest:the rest part taken as the map

if isempty(newLine.decision)
    restMap = exLine;  return
end
if isempty(exLine.decision)
    restMap = newLine; return
end
%--------------  Threshold -------------- 
alpha = 5; radius = 5; dth = 1;

%-------------- Initialize --------------
newline = newLine.decision; newpoint = newLine.point;
exline = exLine.decision;   expoint = exLine.point;
k1 = size(newline,2);   % number of new lines
k2 = size(exline,2);    % number of existed lines
restpts = expoint;
restslp = exline;

%-------------- isAround --------------
minX = min(newline(1,:) - 2); % left
minY = min(newline(2,:) - 2); % bottom
maxX = max(newline(1,:) + 2); % right
maxY = max(newline(2,:) + 2); % top
isAround = exline(1,:) > minX...  % isAround is logical value [0/1]
         & exline(1,:) < maxX...
         & exline(2,:) > minY...
         & exline(2,:) < maxY;     
locline = exline(:,isAround);       % local exsited lines

if isempty(locline)
    restMap.point = [expoint newpoint];
    restMap.decision = [exline newline];
    return;
end

%============================== Line to Map ==============================
k3 = size(locline,2);       % number of local exist lines
restslp(:,isAround) = 0;    % Delete
locpoint = zeros(2,2*k3);   % construct local endpoint
n = 1;
for m = 1 : length(isAround)
    if isAround(m)
        locpoint(:,2*n-1:2*n) = expoint(:,2*m-1:2*m);
        restpts(:,2*m-1:2*m) = 0;
        n = n + 1;
    end
end

%-------------------- Mean Shift Cluster --------------------
templine = [locline newline];
temppoint = [locpoint newpoint];
class = DoMeanShift(templine,radius,alpha);  % Do mean-shift
% class = ones(1,size(templine,2));           % W/o mean-shift
% class = DoCluster2(temppoint,templine,class,dth);
class = DoHierClust(temppoint,templine,class,dth);

%-------------------- Merge --------------------
add = k2;
for i = 1 : max(class)      % traverse and merge each class
    add = add + 1;
    toMerg = find(class==i); % segments belonging to the same class
    % compile endpoint
    toMergPts = zeros(2,2*length(toMerg));
    for j = 1 : length(toMerg)
        k = toMerg(j);
        toMergPts(:,2*j-1:2*j) = temppoint(:,2*k-1:2*k);
    end
    % no merging
    if length(toMerg) == 1        
        restpts(2,2*add) = 0;  restslp(4,add) = 0;
        restpts(:,2*add-1:2*add) = toMergPts;
        restslp(:,add) = templine(:,toMerg(1));
        continue;
    end
    % PCA Merging -> endpoint, decision
    tempMerg = PCAMerg(toMergPts);
    
    if isempty(tempMerg.point)      % 如果拟合失败，识别为噪音
        % 保留最长
        restpts(2,2*add) = 0;  restslp(4,add) = 0;
        i_max = tempMerg.decision;
        restpts(:,2*add-1:2*add) = toMergPts(:,2*i_max-1:2*i_max);
        restslp(:,add) = templine(:,toMerg(i_max));
        % 直接加上后续
%         back = length(toMerg)-1;
%         restpts(2,2*add-1:2*(add+back)) = 0;
%         restslp(4,add:add+back) = 0;
%         restpts(:,2*add-1:2*(add+back)) = toMergPts;
%         restslp(:,add:add+back) = templine(:,toMerg);
%         add = add + back;
        continue;
    end
    restpts(2,2*add) = 0;  restslp(4,add) = 0;
    restpts(:,2*add-1:2*add) = tempMerg.point;
    restslp(:,add) = tempMerg.decision;
end
restpts(:,all(restpts==0)) = [];
restslp(:,all(restslp==0)) = [];

restMap.point = restpts;
restMap.decision = restslp;
return