clc;clear;close all
dbstop if error
%% 自行实现
% 定义点
x=[1 2 4 6 8];
v=x;
w=x.^2;
y=[1 -1 -4 -2 1];
% 散点图
plot(x,y,'r.','MarkerSize',10) 
% 横坐标标题
xlabel('x','fontsize',12)
% 纵坐标标题
ylabel('y','fontsize',12)
% 采用最小二乘拟合
% y=b2x2+b1x+b0
% 定义符号变量
syms b2 b1 b0
% 求偏导数
pdb0=y-b0-b1.*v-b2.*w;
pdb1=(y-b0-b1.*v-b2.*w).*v;
pdb2=(y-b0-b1.*v-b2.*w).*w;
% 求偏导数的和
sumpdb0=sum(pdb0);
sumpdb1=sum(pdb1);
sumpdb2=sum(pdb2);
% 求解含有符号变量的方程
[b0,b1,b2]=solve(sumpdb0,sumpdb1,sumpdb2,b0,b1,b2);
% 将结果强制转换为double类型
b0=double(b0);
b1=double(b1);
b2=double(b2);
% 计算预测的y值
xxx=-1:0.01:9;
yyy=b2*xxx.^2+b1*xxx+b0;
hold on
% 画线
plot(xxx,yyy,'linewidth',2,'Color',[0 0 0]);
disp(['手动实现拟合的曲线是：y=' num2str(b2) 'x^2+' num2str(b1) 'x+' num2str(b0)])
%% Matlab实现
beta=polyfit(x,y,2);%线性回归，结果按照次数从大到小排列
disp(['Matlab实现拟合的曲线是：y=' num2str(beta(1)) 'x^2+' num2str(beta(2)) 'x+' num2str(beta(3))])