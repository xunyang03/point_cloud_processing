clear;clc;
bag = rosbag('MIT.bag');%读取所有数据

%读取水平雷达topic 数据
 laser = select(bag, 'Time', ...
            [bag.StartTime bag.EndTime], 'Topic', '/tf');

% 从文件中查找数据的大小 
N = laser.NumMessages;%雷达数据条数

for i = 1:N
    temp = readMessages(laser,i);
    tf_temp = temp{1,1}.Transforms;
    
    if ~isempty(tf_temp)
        disp(i);
    end
end
disp("FINISH");

%%
% x = readMessages(laser,1);
% [M,~] = size(x{1,1}.Ranges);
% times = zeros(N,1);%时间参数
% ranges = zeros(N,M);%距离参数
% 
% % 循环读取数据 ：整体读取时会出现内存不足的情况
% for i=1:N
%     temp = readMessages(laser,i);
%     times(i) = temp{1,1}.Header.Stamp.Sec;%时间
%     ranges_temp = temp{1,1}.Ranges;%雷达测量（1079维数据）
%     
% %     for j = 1:M %不知道如何整体读取，所以加了循环
% %         laser_echo = ranges_temp(j,1).Echoes;
% %         [xx,yy] = size(laser_echo);
% %         if xx*yy<1 %当laser_echo为空时，跳出当前循环
% %             continue
% %         end
% %         ranges(i,j) = laser_echo(1);%雷达测量的距离数据
% %     end
%     ranges(i,1:M) = ranges_temp;
% 
%     %显示进度
%     if mod(i,100)==0
%         disp(['处理进度%：', num2str(i/N*100)]);
%     end
% end
% 
% %
% %数据保存为mat文件
% % save tf_data times ranges