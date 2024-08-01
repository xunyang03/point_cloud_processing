% Second Level clusterization after Mean shift
% Based on distance between centerpoints and distance between endpoints
function subClust = DoHierClust(endpoint,decision,Clust1,dth)
% Input:
%   Line: Line segment with endpoints and decision(center,slope)
%   Clust1: classes after doing mean-shift
%   dth: distance threshold
% Output:
%   Clust: class oder for each line

%-------------------- Initialize --------------------
k = size(decision,2);  % Total number of lines
subClust = zeros(1,k); 
Clust2 = zeros(1,k);
C = zeros(1,max(Clust1)); % Break point for each cluster_1

%-------------------- Hierarchical Clustering --------------------
for i = 1 : max(Clust1)                 % Traverse each cluster_1
    toClust = find(Clust1 == i);
    subClust(toClust) = max(subClust) + 1;     % Cumulative class number
    if length(toClust)==1
        continue;
    end
    cent = decision(1:2,toClust);
    Y = pdist(cent');            % distance square matrix of centerpoint
    Z = linkage(Y,'complete');              % Hierarchical Clustering
    
    for j = 1 : size(Z,1) 
        if Z(j,3) > dth          % distance beyond threshold
            C(i) = (length(cent)-j) + 1;  % how much sub-cluster it has
            break
        else
            C(i) = 1;           % sub-cluster stays the same
        end
    end
%-------------------- Compilation --------------------
    T = cluster(Z,'maxclust',C(i)); % subscript
    Clust2(toClust) = T'-1;
    subClust(toClust) = subClust(toClust) + Clust2(toClust);

end

return