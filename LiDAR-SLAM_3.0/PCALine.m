% PCA-based line fitting w/ deleting & merging
function Line = PCALine(clust) 
% Input
%   scan: points (x, y)
%   number: number of expected line (number of cluster)
% Output
%   Line:information of lines after fitting

if isempty(clust)
    Line.point = [];
    Line.decision = [];
    return
end

scan = clust.point;
number = clust.number;
    
%-------------------- Initialize --------------------
Eth = 30;                       % threshold determine a line segment
alpha = 0.5;                    % merging threshold (degree)
m = zeros(1,number); n = m;     % slope & deviation
cent = zeros(2,number);         % centroid
endPoint = zeros(2,2*number);   % endpoints
del = 0;
%-------------------- Line fitting --------------------
% traverse each cluster
for i = 1:number
    scanx = scan(:,2*i-1);  scany = scan(:,2*i);
    x = scanx(scanx~=0);    y = scany(scany~=0);
    xc = mean(x);           yc = mean(y);
    len = length(x);        % number of points in one cluster   

    % covariance matrix
     Q = [sum((x-xc).^2) sum((x-xc).*(y-yc));...
         sum((x-xc).*(y-yc)) sum((y-yc).^2)]./len;
    [eigvect, eigval] = eig(Q);     % solve the cov matrix
    lamda = diag(eigval);
    if lamda(2) > lamda(1)
        lamda = wrev(lamda);        % sort from largest to smallest
        eigvect = fliplr(eigvect);
    end
    
    % Not a line segment, DELETE    
    idx = lamda(1)/lamda(2);
    if idx < Eth 
        m(i) = 0; n(i) = 0; cent(:,i) = 0; 
        endPoint(:,2*i-1) = 0; endPoint(:,2*i) = 0;
        del = del + 1;
        continue
    end
    
    % y = m * x + n
    m(i) = eigvect(2,1)/eigvect(1,1);
    n(i) = yc - m(i) * xc;    
    % projection - find the endpoints    
    projx = DoProject(x,y,m(i),n(i));
    projx = unique(projx);  % from small to large
    x1 = projx(1);          x2 = projx(end);
    y1 = m(i)*x1 + n(i);    y2 = m(i)*x2 + n(i);    
    % update
    cent(1,i) = xc; cent(2,i) = yc;
    endPoint(1,2*i-1) = x1; endPoint(1,2*i) = y1;
    endPoint(2,2*i-1) = x2; endPoint(2,2*i) = y2;
end  
number = number - del;              % don't forget the deleted points

%-------------------- Merging step --------------------
if number == 0
    Line.point = [];  Line.decision = [];  Line.number = 0; return
elseif number > 1
    a = atand(m);                   % orientation ∈ [-90,90] m=tan(a)
    mc = zeros(1,number-1);
    for j = 1:number-1
    % line connecting two centroids
    mc(j) = (cent(2,j+1)-cent(2,j))/(cent(1,j+1)-cent(1,j));     
    ac = atand(mc(j));
    if abs(a(j)-a(j+1))<alpha && abs(a(j)-ac)<alpha...
            && abs(a(j+1)-ac)<alpha
         tempm = mc(j);
         % calculate n iteratively
         tempn = (n(j) + n(j+1))/2;
         while true  % projection
             projx = DoProject([endPoint(:,2*j-1);endPoint(:,2*j+1)],...
                 [endPoint(:,2*j);endPoint(:,2*j+2)],tempm,tempn);
            minx = min(projx);maxx = max(projx);
            b1 = tempm * minx + tempn; b2 = tempm * maxx + tempn;
            cx = 0.5*(minx+maxx); cy = 0.5*(b1+b2);
            Er = cy - tempm*cx - tempn;
             if abs(Er) < 0.01
                 break
             else
                 tempn = tempn + Er;
             end         
         end
         
         % update and be ready for the next iter
        endPoint(:,2*j+1) = [minx;maxx];
        endPoint(:,2*j+2) = [b1; b2];
        cent(:,j+1) = [cx; cy];
        m(j+1) = tempm;         n(j+1) = tempn;
        endPoint(:,2*j-1) = 0;  endPoint(:,2*j) = 0;
        cent(:,j) = 0;
    end
    end
end        
endPoint(:,all(endPoint==0)) = [];
n(all(cent==0)) = [];m(all(cent==0)) = [];
cent(:,all(cent==0)) = [];

Line.point = endPoint;
Line.decision = [cent;m;n];
Line.number = 0.5 * size(endPoint,2);
return