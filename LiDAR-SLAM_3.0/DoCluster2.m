% Second Level clusterization after Mean shift
% Based on distance between centerpoints and distance between endpoints
function Clust2 = DoCluster2(endpoint,decision,Clust1,dth)
% Input:
%   Line: Line segment with endpoints and decision(center,slope)
%   Clust1: classes after doing mean-shift
%   dth: distance threshold
% Output:
%   Clust2: class oder for each line

Clust2 = Clust1;
add = 0;
for i = 1 : max(Clust1)
    toClust = find(Clust1 == i);
    if length(toClust)==1
        continue;
    end
    cent = decision(1:2,toClust);
    Z = squareform(pdist(cent'));    % distance square matrix
%     disp(Z);
%     disp(toClust);
%     disp(cent);    
    
    for j = 2: length(toClust)
        l1 = norm([endpoint(1,2*j-1:2*j) endpoint(2,2*j-1:2*j)]);
        for k = j-1 : -1 : 1
            l2 = norm([endpoint(1,2*k-1:2*k) endpoint(2,2*k-1:2*k)]);
            if Z(k,j) < 0.5*(l1 + l2) 
%             if endPointCheck(endpoint(:,2*j-1:2*j),endpoint(:,2*k-1:2*k))...
%                    || endPointCheck(endpoint(:,2*k-1:2*k),endpoint(:,2*j-1:2*j))
%             if Z(k,j) < dth || ...
%                     endPointCheck(endpoint(:,2*j-1:2*j),endpoint(:,2*k-1:2*k))
                Clust2(toClust(j)) = Clust2(toClust(k));  % same cluster
                break;
            
            elseif k == 1
                add = add + 1;
                Clust2(toClust(j)) = max(Clust1)+add;
            end            
        end
        
    end
end

function flag = endPointCheck(end_1,end_2)
% endpoint: end_1[x1 y1;x2 y2] end_2[x1' y1';x2' y2']
x1x1p = end_1(1,1) - end_2(1,1);
x1x2p = end_1(1,1) - end_2(2,1);
x2x1p = end_1(2,1) - end_2(1,1);
x2x2p = end_1(2,1) - end_2(2,1);
check_x1 = x1x1p * x1x2p;
check_x2 = x2x1p * x2x2p;
check_xd = max(abs([x1x1p x1x2p x2x1p x2x2p]));
y1y1p = end_1(1,2) - end_2(1,2);
y1y2p = end_1(1,2) - end_2(2,2);
y2y1p = end_1(2,2) - end_2(1,2);
y2y2p = end_1(2,2) - end_2(2,2);
check_y1 = y1y1p * y1y2p;
check_y2 = y2y1p * y2y2p;
check_yd = max(abs([y1y1p y1y2p y2y1p y2y2p]));

if (check_x1 < 0 || check_x2 < 0) && (check_yd < 1) 
    flag = true;
elseif (check_y1 < 0 || check_y2 < 0) && (check_xd < 1)
    flag = true;
else
    flag = false;
end
return
