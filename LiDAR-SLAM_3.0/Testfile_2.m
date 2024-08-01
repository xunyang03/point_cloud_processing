close all;clear;clc;

load('point_map.mat');
point = map.points;

figure(1)
% plot(point(:,1),point(:,2),'k.','markersize',0.2);

% -------- compile line --------
k = length(map.line);
endpoint = [];
decision = [];
for i = 1 : k
    endpoint = [endpoint(:,:) map.line(i).point];
    decision = [decision(:,:) map.line(i).decision];
end

data = decision(1:2,:)';
distmat = zeros(size(data,1),size(data,1));

for i=1:size(data,1)
    for j=i:size(data,1)
        distmat(i,j)=sqrt((data(i,1:2)-data(j,1:2))*(data(i,1:2)-data(j,1:2))');
    end
end

for i=1:size(data,1)
    for j=i:size(data,1)
        distmat(j,i)=distmat(i,j);
    end
end

% ----- DBSCAN ------
% Eps=0.5; MinPts=1;
% Clust = DBSCAN(distmat,Eps,MinPts);
% disp(max(Clust));

% ----- MS -----
radius = 5;
% subClust = Clust';
Clust = ones(size(decision,2),1);
subClust = MeanShift(decision,endpoint,20,radius,Clust);
disp(max(subClust));
    
% plot different clusters
figure(2)
PlotLine(endpoint,subClust,4);

%**************************************************************************
% class = DoMeanShift(decision,radius,alpha);     % Do mean-shift
% class = DoHierClust(endpoint,decision,class,dth);
% figure(2)
% PlotLine(endpoint,class,4);
% *************************************************************************

% ----- Merge the same cluster -----
class = subClust';
newLine.point = endpoint;
newLine.decision = decision;
add = length(class);
for i = 1 : max(class)      % traverse and merge each class    
    toMerg = find(class==i); % segments belonging to the same class
    % no merging
    if length(toMerg) == 1        
        continue;
    end
    
    add = add + 1;
    newLine.decision(:,toMerg) = 0; % delete
    % compile endpoint
    toMergPts = zeros(2,2*length(toMerg));    
    for j = 1 : length(toMerg)
        k = toMerg(j);
        toMergPts(:,2*j-1:2*j) = endpoint(:,2*k-1:2*k);
        newLine.point(:,2*k-1:2*k) = 0;        
    end   
    
    % PCA Merging -> endpoint, decision
    tempMerg = PCAMerg(toMergPts);
    
    if isempty(tempMerg.point)      % 如果拟合失败，识别为噪音
        % 保留最长        
        i_max = tempMerg.decision;
        newLine.point(2,2*add) = 0; newLine.decision(4,add) = 0; % Expand
        newLine.point(:,2*add-1:2*add) = toMergPts(:,2*i_max-1:2*i_max);
        newLine.decision(:,add) = decision(:,toMerg(i_max));        
        continue;
        
    end
    newLine.point(2,2*add) = 0;  newLine.decision(4,add) = 0;
    newLine.point(:,2*add-1:2*add) = tempMerg.point;
    newLine.decision(:,add) = tempMerg.decision;
    
end
newLine.point(:,all(newLine.point==0)) = [];
newLine.decision(:,all(newLine.decision==0)) = [];
newLine = deleteShort(newLine,0.1);

figure(3)
PlotLine(newLine.point,size(newLine.decision,2),2);

function newLine = deleteShort(Line,minLen)
newLine = Line;
N = size(Line.decision,2);
for i = 1 : N
    tempL = norm(Line.point(1,2*i-1)-Line.point(2,2*i-1),Line.point(1,2*i)-Line.point(2,2*i));
    if tempL < minLen
        newLine.point(:,2*i) = 0; newLine.point(:,2*i-1) = 0; 
        newLine.decision(:,i) = 0;
    end
end
newLine.point(:,all(newLine.point==0)) = [];
newLine.decision(:,all(newLine.decision==0)) = [];
return
end
