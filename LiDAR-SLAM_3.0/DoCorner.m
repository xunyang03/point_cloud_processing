% Second Level Clusterization
function subClust = DoCorner(mainClust)
% Input
%   scan:points after 1st-level clusterization
%   number:number of main clusters
% Output
%   subClust:sub cluster

if isempty(mainClust)
    subClust = [];
	return
end

scan = mainClust.point;
number = mainClust.number;

%--------- Parameter ---------
num = ones(1,number);       % number of sub clust in each main class
max = size(scan,1);         % max number of points in a clust
clsPoint = zeros(max,1);    % point in typical classes

% traverse each main cluster
for i = 1 : number
    %--------- Discern ---------
    xline = scan(:,2*i-1);
    yline = scan(:,2*i);
    sclust = FindCorner([xline yline]);  % subClust for a SINGLE mainClust
    
    %--------- Compile ---------
    num(i) = sclust.num;
    [row, col] = size(sclust.point);     
    front = size(clsPoint,2);           % column in front of current 
    clsPoint(max,front+col) = 0;        % expand the matrix
    clsPoint(1:row,front+1:front+col) = sclust.point;    
end
clsPoint(all(clsPoint==0,2),:) = [];clsPoint(:,all(clsPoint==0)) = [];
class = sum(num);                       % cluster number

subClust.point = clsPoint;
subClust.number = class;
return

% Corner detector for a SINGLE main cluster
function subClust = FindCorner(scan)
% Input
%   scan:points in Cartesian coordinate (x,y)
% Output
%   subClust:sub cluster

%---------- Parameter ----------
imax = 5;                   % max iteration
dth = 0.1;                  % distance threshold
min = 10;                   % avoid tinny cluster
%---------- Initialize ----------
num = 1;                    % previous number of subclust
newnum = 1;                 % updated number of subclust
iter = 1;

%========== Iterative corner searching ==========
while iter <= imax
    tempLine = PCALine2(scan,num);     % brute line fitting
    tempPoint = tempLine.point;
    brkPos = zeros(1,num);                % position of break point
    
    for i = 1:num
        scanx = scan(:,2*i-1); scany = scan(:,2*i);
        scanx = scanx(scanx~=0); scany = scany(scany~=0);
        len = size(scanx,1);        % number of points in this subclust 
        dist = zeros(len,1);        % distance from scan points to tempLine
        %---------- Comparison point2line distance ----------
        for j = 1:len
            P = [scanx(j) scany(j)];
            Q1 = [tempPoint(1,2*i-1) tempPoint(1,2*i)];
            Q2 = [tempPoint(2,2*i-1) tempPoint(2,2*i)];
            dist(j) = abs(det([Q2-Q1;P-Q1]))/norm(Q2-Q1);    
        end
        % record the location of corner
        refind = true;
        while refind == 1
        [val,loc] = max(dist);
        if val > dth && (loc < min || loc > len-min)
            dist(loc) = 0;  % do refind if the subcluster is too tinny
        elseif val >= dth
            newnum = newnum + 1;
            brkPos(i) = loc;
            refind = false;
        elseif val < dth
            refind = false;
        end
        end
    end
    
    %---------- Update scan & num ----------
    newscn = zeros(size(scan,1),2*newnum);  % initialize new scan
    front = 0;
    for m = 1 : num
        la = scan(:,2*m-1); lb = scan(:,2*m);
        la(la==0) = []; lb(lb==0) = []; 
        l = length(la);     % number of points in the previous clust        
        tempPos = brkPos(m); 
        if tempPos == 0     % there is no corner, stay the same            
            newscn(1:l,front+1) = la(:);
            newscn(1:l,front+2) = lb(:);
            front = front + 2;
        else
            id = 1;
            for n = 1 : l                
                newscn(id,front+1) = la(n);
                newscn(id,front+2) = lb(n);
                id = id + 1;
                if n == tempPos  % meet the corner -> new subcluster
                    id = 1; front = front + 2;
                end
            end
            front = front + 2;
        end
    end
    newscn(all(newscn==0,2),:) = [];  % delete rows with all 0
    % update for the next iteration
    scan = newscn; num = newnum;
    iter = iter + 1;   
end
subClust.num = num;
subClust.point = scan;
return
