% Laser sensor's parameters
function lidar = SetLidarParameters(type)
switch type
% type 1
    case 1
    lidar.angle_min = -2.351831;
    lidar.angle_max =  2.351831;
    lidar.angle_increment = 0.004363;
    lidar.npoints   = 1079;
    lidar.range_min = 0.023;
    lidar.range_max = 60;
    lidar.scan_time = 0.025;
    lidar.time_increment  = 1.736112e-05;

% type 2
    case 2
    lidar.angle_min = -1.570796370506287;
    lidar.angle_max =  1.570796370506287;
    lidar.angle_increment = 0.017453292384744;
    lidar.npoints   = 181;
    lidar.range_min = 0.001000000047497;
    lidar.range_max = 50;
    lidar.scan_time = 0.200000002980232;
    lidar.time_increment  = 5.555555690079927e-04;
end

lidar.angles = (lidar.angle_min : lidar.angle_increment : lidar.angle_max)';