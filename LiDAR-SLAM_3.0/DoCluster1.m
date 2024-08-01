% Firt (high) level clusterization
function mainClust = DoCluster1(scan,dth)
% Input
%   scan:points in world frame
%   dth:distance threshold
% Output
%   mainClust:main cluster

if isempty(scan)
    mainClust = [];
    return
end

%---------- Setting parameter ----------
min = 10;                       % avoid tinny cluster 
del = 0;                        % number of deleted cluster
class = 1;                      % cluster number
k = size(scan,1);               % number of points in this scan
tempPos = zeros(k,class);       % oder of points in classes
clsPoint = zeros(k,class);      % point in typical classes

Z = squareform(pdist(scan));    % distance square matrix

%---------- Discern break point ----------
for i = 1:k-1
    if Z(i,i+1) <= dth
        tempPos(i,class) = i;
        tempPos(i+1,class) = i+1;
    else                        % change column at the break point
        class = class+1;
        tempPos(i+1,class) = i+1;
    end
end

%---------- Compilation ----------

for n = 1:class
    line = tempPos(:,n);        % line record the location in a scan
    line(line(:)==0) = [];
    % delete noise point
    if length(line) < min
        del = del + 1;
        continue;
    end
    for m = 1:length(line)
        clsPoint(m,2*n-1) = scan(line(m),1);     % x   
        clsPoint(m,2*n) = scan(line(m),2);       % y
    end
end
clsPoint(:,all(clsPoint==0)) = [];
clsPoint(all(clsPoint==0,2),:) = []; 
class = class - del;

mainClust.point = clsPoint;
mainClust.number = class;
return
