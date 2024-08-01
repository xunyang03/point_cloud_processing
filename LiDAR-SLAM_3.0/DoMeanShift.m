% Mean Shift Clustering
function Clust = DoMeanShift(Line_decision,radius,alpha)
% Input:
%   Line_decision: Line segment with decision(center,slope)
%   radius: radius of classes
%   alpha: bandwidth of direction
% Output:
%   Clust: class oder for each line

%-------------------- Initialize --------------------
Imax = 1000;                % maximum iteration
Dth = 0.02;                 % distance threshold for mean value
Ath = 0.1;                   % angle threshold for mean value
P = Line_decision(1:3,:);   % fixed - oringinal points
P(3,:) = atand(P(3,:));      % slope -> direction(deg) [-90,90]
k = size(P,2);              % total number of line
T = P;                      % iterative - copied points
Clust = zeros(1,k);         % class number

%-------------------- First level --------------------
for i = 1 : k               % currunt position in T
    copy = T(:,i); 
    iter1 = 1;
    while (iter1 < Imax)
        oldcopy = copy;
        copy = Shift(oldcopy,P,radius,alpha); % do Mean-shift if not converge        
        dm = copy - oldcopy;
        if norm(dm(1:2)) < Dth
            break
        end
        iter1 = iter1 + 1;        
    end
    T(:,i) = copy;
    % Test
%     fprintf('iter: %d ',iter1);
%     fprintf('dm: %f\n',max(dm(1:2)));
end

%-------------------- Clustering --------------------
Clust(1) = 1;
for i = 2 : k                       % currunt position
    class = Clust(i-1);             % fixed - the last class
    for j = i-1 : -1 : 1            % compare with previous
        if (abs(T(1,i) - T(1,j)) < Dth && abs(T(2,i) - T(2,j)) < Dth) ...
                && abs(T(3,i) - T(3,j)) < Ath
            Clust(i) = Clust(j);
            break
        elseif j == 1 
            Clust(i) = class + 1;
        end    
    end
end

return


% shift once
function newT = Shift(T,P,h1,h2)
% Input
%   P: oringal points
%   T: copied points
%   h_: bandwidth
% Output
%   newT: after shifted
shift = zeros(3,1);     % delta mean store here
factor = 0;
for j = 1 : size(P,2)       % curr in P  
    temp = P(:,j) - T;
    dist = norm(temp(1:2));
    dist_dir = abs(temp(3));
    if (dist < h1)&&(dist_dir < h2)
        shift = shift + temp; 
        factor = factor + 1;
    end
end
newT = T + shift./factor;
% newT = shift./factor;
return


% Gauss Kernel
function K = GaussKernel( center , direct , h)
% Input:
%   center: center point
%   direct: direction. (for level-2 direction is fixed)
%   h: bandwidth
% Output:
%   value of Gauss Kernel

sigma = 0.75;        % default
return