function subClust = MeanShift(Line_decision,Line_endpoint,alpha,radius,Clust)
%Input
% alpha: weight function
% radius: searching circle radius
Line_endpoint = reshape(Line_endpoint,[4,size(Line_decision,2)]);% [x1 x2 y1 y2]'
Clust_copy = Clust;
subClust = zeros(1,size(Line_decision,2));
for i = 1:max(Clust_copy)
    toClust = find(Clust_copy == i);    
    subClust(toClust) = max(subClust) + 1;    
    if length(toClust) == 1
        continue;
    end    
    temp_decision = Line_decision(:,toClust);
    temp_endpoint = Line_endpoint(:,toClust);
    temp_clust = DoMeanShift1(temp_decision,radius,[1 alpha]);
    temp_clust_copy = temp_clust;
    for j = 1 : max(temp_clust_copy) % refine the clust        
        reClust = find(temp_clust_copy == j);
        if length(reClust) == 1
            continue;
        end
        re_temp_decision = temp_decision(:,reClust);
        re_temp_endpoint = temp_endpoint(:,reClust);
        re_temp_endpoint = reshape(re_temp_endpoint,[2,2*length(reClust)]);
        fitTry = PCALine2(ExpandLine(re_temp_endpoint),1);
        if abs(atand(fitTry.decision(3)) - ...
                mean(atand(re_temp_decision(3,:)))) > 20 
        re_temp_clust = DoMeanShift1(re_temp_decision,radius,[5 1]);
        addVect = mergeClust(temp_clust_copy,re_temp_clust,j);
        temp_clust = temp_clust + addVect;
        end
    end
%     disp('**********************************');
    subClust(toClust) = subClust(toClust) + temp_clust - 1;
end % for loop
return

%*************************************************************************
function Clust = DoMeanShift1(decision,Radius,Alpha)
%采用基础MeanShift算法，单位均匀核函数
% Alpha: weight function
data = decision(1:3,:)';
data(:,1:2) = Alpha(1) .* data(:,1:2);
data(:,3) = Alpha(2) .* data(:,3);
% angle = atand(decision(:,3)); % slope -> direction(deg) [-90,90]

StopThresh = 0.1;%MeanShift迭代结束阈值
N = size(data,1);
Visited = zeros(N,1);%访问与否标记
PointChosen = 1; %每次迭代初始点
CenterNumTh = zeros(N,1);
NumTh = 0;%编号
IDX = zeros(N,1);
AllCenter = zeros(N,3);
Weight = [];

while 1
    WeightTemp=zeros(1,N);
	NewCenter=data(PointChosen,:); % 以初始点为中心
    while 1
        PreCenter=NewCenter;
	    Dis2Cen=sqrt(sum((data-repmat(NewCenter,N,1)).^2,2)); % 距离
	    PointIn=find(Dis2Cen<Radius);%寻找圈内点
		Visited(PointIn)=1;%将访问过的点值置1
	    WeightTemp(PointIn)=WeightTemp(PointIn)+1;%更新权重
		NewCenter=mean(data(PointIn,:),1);%求均值，获得新中心
	    
        if(sum((NewCenter-PreCenter).^2,2)<StopThresh)%趋于收敛，MeanShift停止后处理模块
            RealCenter=0;
            for i=1:NumTh
                if(sum((NewCenter-AllCenter(i,:)).^2,2)<Radius) % 与已有中点重复
				    RealCenter=i;
                end
            end
            if RealCenter>0 %合并
		        AllCenter(RealCenter,:)=(AllCenter(RealCenter,:)+NewCenter)/2;
			    Weight(RealCenter,:)=Weight(RealCenter,:)+WeightTemp;
			else
			    NumTh=NumTh+1;%添加新中心
				Weight(NumTh,:)=WeightTemp;
				AllCenter(NumTh,:)=NewCenter;   
            end
            break; % 收敛，退出当前循环
        end
    end
    PointsNVisited=find(Visited==0);
    if(isempty(PointsNVisited))
         break;
    end
    PointChosen=PointsNVisited(1); % 设置新的初始中心
    
end%最外侧循环

[~,IDX]=max(Weight,[],1);

maxIDX = max(IDX);
Clust = zeros(1,size(decision,2));
front = 0;
for i = 1:maxIDX
    isIn = find(IDX==i);
    if ~isempty(isIn)
        front = front + 1;
        Clust(isIn) = front;
    else
        continue
    end
end

return

function addVector = mergeClust(Clust1_copy,Clust2,valInClust1)
addVector = zeros(size(Clust1_copy));
maxClass = max(Clust2);
addVector(Clust1_copy == valInClust1) = Clust2 - 1;
addVector(Clust1_copy > valInClust1) = maxClass - 1;
return