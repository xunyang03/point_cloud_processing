% BRUTE PCA-based line fitting w/o deleting/merging
function Line = PCALine2(scan,number) 
% Input
%   scan:point
%   number:number of expected line
% Output
%   Line:information of lines after fitting

%--------------- Initialize ---------------
Eth = 20;
m = zeros(1,number); n = m;     % m - slope, n - deviation
cent = zeros(2,number);         % centroid
endPoint = zeros(2,2*number);   % endpoints

%--------------- Line fitting ---------------
for i = 1:number
    scanx = scan(:,2*i-1);  scany = scan(:,2*i);
    x = scanx(scanx~=0);  y = scany(scany~=0);
    len = length(x);
    xc = mean(x); yc = mean(y);
    
    % covariance matrix
     Q = [sum((x-xc).^2) sum((x-xc).*(y-yc));...
         sum((x-xc).*(y-yc)) sum((y-yc).^2)]./len;
    [eigvect, eigval] = eig(Q);
    lamda = diag(eigval);
    if lamda(2) > lamda(1)
        lamda = wrev(lamda);
        eigvect = fliplr(eigvect);
    end
    
    % Not a line segment, BRUTE fit
    idx = lamda(1)/lamda(2);
    if idx < Eth         
        endPoint(:,2*i-1) = scan([1 len],2*i-1); 
        endPoint(:,2*i) = scan([1 len],2*i);
        cent(:,i) = 0.5*([endPoint(2,2*i-1)+endPoint(1,2*i-1);...
            endPoint(2,2*i)+endPoint(1,2*i)]); 
        m(i) = (endPoint(2,2*i)-endPoint(1,2*i))/...
            (endPoint(2,2*i-1)-endPoint(1,2*i-1)); 
        n(i) = cent(2,i) - m(i) * cent(1,i); 
        continue
    end    
    
    % y = m * x + n
    m(i) = eigvect(2,1)/eigvect(1,1);
    n(i) = yc - m(i) * xc;    
    % projection    
    projx = DoProject(x,y,m(i),n(i));
    projx = unique(projx);
    x1 = projx(1);  x2 = projx(end);
    y1 = m(i)*x1 + n(i); y2 = m(i)*x2 + n(i);    
    % update
    cent(1,i) = xc; cent(2,i) = yc;
    endPoint(1,2*i-1) = x1; endPoint(1,2*i) = y1;
    endPoint(2,2*i-1) = x2; endPoint(2,2*i) = y2;
end  
endPoint(all(endPoint==0,2),:) = [];        % delete rows with all 0

Line.point = endPoint;                      % endpoint of line segment
Line.decision = [cent;m;n];
Line.number = size(endPoint,2)/2;