% 分别为清除命令行窗口、清除所有变量、关闭所有窗口
clc;clear;close all;
% 读取数据
load('data.mat');
%% 数据截取与可视化
% 新建一个绘图窗口
figure
% 画出数据的函数图像
plot(data)
% 命名标题
title('原信号')
% 本次只分析前200个数据
NewData=data(1:200);
figure
% plot的用法很复杂，这里只用最简单的
plot(NewData)
% 命名标题
title('截取信号')
%% 噪声值的处理
% 复制一份数据，为了防止把原始数据修改掉
DeNoiseData=NewData;
% 对比图。此处先不写figure，引出figure的用法
figure
% 此处先用单独的图，然后引出如何使用subplot
subplot(2,1,1)
plot(NewData)
% 调整y轴。此处先不调整y轴，然后引出ylim的用法
ylim([-200,1000])
% 此处先不用title，引出title的用法
title('截取信号')
% 寻找第一个噪声值。此处需要先看噪声值是多少
x1=find(NewData==1000);
% 将噪声值左右两边的值的均值赋给噪声值所在的位置。重点，需要逐步讲解
DeNoiseData(x1)=mean(NewData((x1-1):2:(x1+1)));
x2=find(NewData==-60);
DeNoiseData(x2)=mean(NewData((x2-1):2:(x2+1)));
subplot(2,1,2)
plot(DeNoiseData)
ylim([-200,1000])
title('处理噪声值后的信号')
%% 缺失值的处理
DeMissingData=NewData;
figure
subplot(2,1,1)
plot(NewData)
ylim([-200,1000])
title('截取信号')
% 寻找缺失值。此处先用x3,x4,x5，然后觉得非常麻烦，引出for循环
x3=find(NewData==inf);
for i=1:3
    % 将噪声值左右两边的值的均值赋给噪声值所在的位置
    DeMissingData(x3(i))=mean(NewData((x3(i)-1):2:(x3(i)+1)));
end
subplot(2,1,2)
plot(DeMissingData)
ylim([-200,1000])
title('处理缺失值后的信号')
%% 数据规范化
% 寻找第一个噪声值
x1=find(NewData==1000);
% 将噪声值左右两边的值的均值赋给噪声值所在的位置
DeMissingData(x1)=mean(NewData((x1-1):2:(x1+1)));
x2=find(NewData==-60);
DeMissingData(x2)=mean(NewData((x2-1):2:(x2+1)));
figure
subplot(2,1,1)
plot(DeMissingData)
ylim([-200,1000])
title('截取信号')
% 此处先不用0,1参数，引出参数的用法。同时，注意这里用了转置
StandardData=mapminmax(DeMissingData',0,1);
subplot(2,1,2)
plot(StandardData)
ylim([0,1])
title('规范化后的信号')