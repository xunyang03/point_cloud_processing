
function A = v2t(v)
% V2T vector to homogeneous transformation
c = cos(v(3));
s = sin(v(3));
A = [c, -s, v(1);
     s,  c, v(2);
     0   0  1];

end