clc;close all;clear;
%% Test
lidar = SetLidarParameters(1);
lidar_data = load('dataset\new_laser_data2.mat');

pose = [0.5; 0; 1];
idx = 15560;
scan = ReadAScan(lidar_data, idx, lidar, 24);
scan_w = Transform(scan,pose); % 世界坐标
minx = min(scan_w(:,1));
miny = min(scan_w(:,2));
maxx = max(scan_w(:,1));
maxy = max(scan_w(:,2));

mclust = DoCluster1(scan_w,0.3);
point_m = mclust.point;
number_m = mclust.number;
    
sclust = DoCorner(mclust);
point_s = sclust.point;
number_s = sclust.number;
% 
% yuline = PCALine2(point_m,number_m);
% point_y = yuline.point;
% number_y = yuline.number;
% 
myline = PCALine(sclust);
point_l = myline.point;
number_l = myline.number;

figure(1)
subplot(2,2,1)
plot(scan_w(:,1),scan_w(:,2),'k.')
axis([minx,maxx,miny,maxy]);
title('Original Data')
subplot(2,2,2)
PlotLine(point_m,number_m,1);
axis([minx,maxx,miny,maxy]);title('Interval Detection');
subplot(2,2,3)
PlotLine(point_s,number_s,1);
axis([minx,maxx,miny,maxy]);title('Corner Detection');
subplot(2,2,4)
PlotLine(point_l,number_l,3);
axis([minx,maxx,miny,maxy]);title('Line fitting');
% hold on
% plot(scan_w(:,1),scan_w(:,2),'g.','markersize',1);

%% Test 2
% Map = load('LineMap.mat');
% Rest = Map.myrest;
% class = DoMeanShift(Rest.decision,5,5);
% % class = DoCluster2(Rest.point,Rest.decision,class,1);
% class = DoHierClust(Rest.point,Rest.decision,class,1);
% % class = ones(1,size(Rest.decision,2));
% % class = DoCluster2(Rest.point,Rest.decision,class,1);
% figure(1)
% PlotLine(Rest.point,size(Rest.decision,2),2);title('Origin');
% figure(2)
% PlotLine(Rest,class,4);title('Clustering');
% % figure(4)
% % PlotLine(Rest,class2,4);title('Clustering2');
% 
% restpts = zeros(2,2*max(class));
% restslp = zeros(4,max(class));
% add = 0;
% for i = 1 : max(class)      % traverse and merge each class
%     add = add + 1;
%     toMerg = find(class==i); % segments belonging to the same class
%     % compile endpoint
%     toMergPts = zeros(2,2*length(toMerg));
%     for j = 1 : length(toMerg)
%         k = toMerg(j);
%         toMergPts(:,2*j-1:2*j) = Rest.point(:,2*k-1:2*k);
%     end
%     if length(toMerg) == 1
%         restpts(:,2*add-1:2*add) = toMergPts;
%         restslp(:,add) = Rest.decision(:,toMerg(1));
%         continue;
%     end
%     
% %     tempExp = ExpandLine();
%     tempMerg = PCAMerg(toMergPts);
%     if isempty(tempMerg.point) % 如果拟合失败，识别为噪音
% %         restpts(:,2*add-1:2*add) = toMergPts(:,1:2);
% %         restslp(:,add) = Rest.decision(:,toMerg(1));
%         continue;
%     end
%     restpts(:,2*add-1:2*add) = tempMerg.point;
%     restslp(:,add) = tempMerg.decision;
% end
% figure(3)
% PlotLine(restpts,size(restslp,2),2);title('Line fitting');
%% Test 3
% N = 20;
% dth = 0.6;
% x = randn(N,2);
% % x = [0.0781888950833453,0.279784956482345;2.10662965570578,0.0512203118444502;-0.715847393133824,-0.774466243939416;-0.280515661741481,0.786781710402895;1.16647500451602,1.40890695099350;1.21282141876426,-0.534098583791872;0.485540987057964,1.92775842981169;1.02601648619598,-0.176247547257615;0.870726021083679,-0.243750362486459;-0.381757878508905,-0.897600658709959;0.428893027102996,-0.792336865107050;-0.299130520022908,-0.952974690953379;-0.899868519999532,0.353905454236426;0.634745461257071,1.59702632391116;0.0674535908285647,0.527470251141925;-0.187120544841388,0.854202301151847;0.291727455002394,1.34184652204595;0.987694691911684,-2.49953344192971;0.392934569877554,-0.167559322169704;0.194551374026050,0.353015314527152];
% Y = pdist(x);
% % disp(squareform(Y));
% % Z = linkage(Y);
% method = 'average';
% Z = linkage(Y,method);
% for i = 1 : size(Z,1)
%     if Z(i,3) > dth
%         C = (N-i)+1;
%         break
%     end
% end
% 
% figure(1)
% plot(x(:,1),x(:,2),'bo');
% 
% figure(2)
% dendrogram(Z);
% T = cluster(Z,'maxclust',C);
% color = rand(max(T),3);
% 
% figure(3)
% for i = 1 : max(T)
%     toPlot = find(T==i);
%     plot(x(toPlot,1),x(toPlot,2),'.','markersize',10,'color',color(i,:)); 
%     hold on
%     plot(mean(x(toPlot,1)),mean(x(toPlot,2)),'o','markersize',15,'color',color(i,:));
% end