% Read a laser scan 机器人坐标系
function scan = ReadAScan(lidar_data, idx, lidar, usableRange)
% idx: 读取当前帧
% lidar: 传感器自身参数
% usableRange: 规定最大距离
    
angles = lidar.angles;
ranges = lidar_data.ranges(idx, :)';

% Remove points whose range is not so trustworthy
maxRange = min(lidar.range_max, usableRange);
isBad = (ranges < lidar.range_min) | (ranges > maxRange);
angles(isBad) = [];
ranges(isBad) = [];

% Convert from polar coordinates to cartesian coordinates
[xs, ys] = pol2cart(angles, ranges);
scan = [xs, ys]; 
end