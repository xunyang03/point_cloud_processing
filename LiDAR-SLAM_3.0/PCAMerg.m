% PCA line fitting in the Line2Map process
% Endpoint prediction based on average length
function Line = PCAMerg(endPoint)
% Input:
%   endPoint: x1 y1 x3 y3
%             x2 y2 x4 y4

%-------------------- Initialize --------------------
Eth = 20;                  % threshold determine a line segment
cent = zeros(2,1);         % centroid
endPoint_l = zeros(2,2);   % endpoints of line

%-------------------- Expand --------------------
if isempty(endPoint)
    
    return
end

k = size(endPoint,2)/2; % total number of line
tempExp = ExpandLine(endPoint); % expand the endpoints
% average length
len = 0;
len_max = 0;
i_max = 0;
for i = 1 : k
    len_temp =  norm([endPoint(1,2*i-1) endPoint(1,2*i)]...
        -[endPoint(2,2*i-1) endPoint(2,2*i)]);
    len = len + len_temp;
    if len_temp > len_max
        len_max = len_temp;
        i_max = i;
    end
end
% len_mean = len/k; 
% if 2*len_mean < len_max
%     len_mean = 0.9 * len_max;
% end
len_mean = len_max;

%-------------------- Line fitting --------------------
% traverse each cluster
Exp_x = tempExp(:,1);  Exp_y = tempExp(:,2);
x = Exp_x(Exp_x~=0);    y = Exp_y(Exp_y~=0);
xc = mean(x);           yc = mean(y);

% covariance matrix
 Q = [sum((x-xc).^2) sum((x-xc).*(y-yc));...
     sum((x-xc).*(y-yc)) sum((y-yc).^2)]./length(x);
[eigvect, eigval] = eig(Q);     % solve the cov matrix
lamda = diag(eigval);
if lamda(2) > lamda(1)
    lamda = wrev(lamda);        % sort from largest to smallest
    eigvect = fliplr(eigvect);
end

% Not a line segment, DELETE    
% idx = lamda(1)/lamda(2);
% if idx < Eth 
%     Line.point = [];
%     Line.decision = [];
%     return;
% end

% Not a line segment, return the longest one
idx = lamda(1)/lamda(2);
if idx < Eth 
    Line.point = [];
    Line.decision = i_max;
    return;
end

% y = m * x + n
m = eigvect(2,1)/eigvect(1,1);
n = yc - m * xc; 

%-------------------- Find the endpoints --------------------
% projection
projx = DoProject(x,y,m,n);
projx = unique(projx);  % from small to large

% method of bisection
% for j = 0 : 1 : length(projx)-1
%     x1 = projx(1+j); x2 = projx(end-j);
%     y1 = m*x1 + n; y2 = m*x2 + n;
%     if norm([x2-x1;y2-y1])-len_mean < 0        
%         break
%     else
%         x1_old = x1; x2_old = x2;
%     end
% end
% if x1 ~= projx(1)
%     iter = 0;
%     while max(abs([x1-x1_old,x2-x2_old])) > 0.1 && iter < 100
%         x1_m = 0.5*(x1_old + x1);
%         x2_m = 0.5*(x2_old + x2);
%         y1_m = m*x1_m + n; y2_m = m*x2_m + n;
%         if norm([x2_m-x1_m;y2_m-y1_m]) > len_mean                
%             x1_old = x1_m; x2_old = x2_m;
%         else
%             x1 = x1_m; x2 = x2_m;
%         end
%         iter = iter + 1;
%     end
% end

% 直接拟合
x1 = projx(1); x2 = projx(end);

y1 = m*x1 + n; y2 = m*x2 + n;
xc = 0.5 * (x1 + x2);
yc = m * xc + n;

% update
cent(1) = xc; cent(2) = yc;
endPoint_l(1,1) = x1; endPoint_l(1,2) = y1;
endPoint_l(2,1) = x2; endPoint_l(2,2) = y2;
 
Line.point = endPoint_l;
Line.decision = [cent;m;n];
return
