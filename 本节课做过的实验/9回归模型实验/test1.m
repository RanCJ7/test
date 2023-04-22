clc;clear;close all
dbstop if error
%% 自行实现
% 定义点
x=[1 2 3];
y=[1 3 4];
% 散点图
plot(x,y,'r.','MarkerSize',10) 
% 横坐标标题
xlabel('x','fontsize',12)
% 纵坐标标题
ylabel('y','fontsize',12)
% 采用最小二乘拟合
% 定义符号变量
syms b1 b0
% 求偏导数
pdb0=y-b0-b1.*x;
pdb1=(y-b0-b1.*x).*x;
% 求偏导数的和
sumpdb1=sum(pdb0);
sumpdb2=sum(pdb1);
% 求解含有符号变量的方程
[b0,b1]=solve(sumpdb1,sumpdb2,b0,b1);
b0=double(b0);
b1=double(b1);
% 计算预测的y值
y1=b1*x+b0;
hold on
% 画线
plot(x,y1,'linewidth',2,'Color',[0 0 0]);
disp(['手动实现拟合的曲线是：y=' num2str(b1) 'x+' num2str(b0)])
%% Matlab实现
beta=polyfit(x,y,1);%线性回归，结果按照次数从大到小排列
disp(['Matlab实现拟合的曲线是：y=' num2str(beta(1)) 'x+' num2str(beta(2))])