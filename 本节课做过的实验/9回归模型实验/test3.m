x=[1 2 3];
y=[1 3 4];
% 散点图
plot(x,y,'r.','MarkerSize',10)
% 坐标轴标题
xlabel('x')
ylabel('y')
% 最小二乘法
syms b0 b1
% 求偏导
pdb0=y-b0-b1.*x;
pdb1=(y-b0-b1.*x).*x;
% 求和
sumpdb0=sum(pdb0);
sumpdb1=sum(pdb1);
% 解方程
[beta0,beta1]=solve(sumpdb0,sumpdb1,b0,b1);
beta0=double(beta0);
beta1=double(beta1);
% 画图
x1=0:0.05:4;
y1=beta1*x1+beta0;
hold on
plot(x1,y1)
%% matlab自带函数
beta=polyfit(x,y,1);
