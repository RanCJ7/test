clc;close all;clear
% 在出现错误时暂停
dbstop if error
% 定义符号变量
syms x;
% 求解精度
e=0.01;
% 初始值
x0=16*rand-8;
% 想要求解的函数
f=x^2+2*x+2;
% 调用函数
[k,ender,value]=GD(f,x0,e);
disp(['迭代' num2str(k) '次，解得最小值点为：(' num2str(ender) ',' num2str(value) ')'])

function [k,ender,value]=GD(f,x1,e)
% 定义符号变量
syms x
% 学习率
m=0.1;
%循环标志 
flag=1;  
%迭代次数
k=0; 
%画出函数图像
ezplot(f,[-9,9])
xlim([-10,10])
hold on
plot(x1,x1^2+2*x1+2,'.',MarkerSize=10);
while(flag)
    % 求x1的梯度
    d=-[diff(f,x)];
    %将起始点代入，求得当次下降x1梯度值
    d_temp=subs(d,x,x1);
    % 向量的长度
    nor=norm(d_temp); 
    % 如果向量的长度大于等于精确度，证明仍然需要迭代
    if(nor>=e)
        % 更新起始点x
        x1=x1+m*d_temp; 
        % 画图
        plot(x1,x1^2+2*x1+2,'r.',MarkerSize=10);
        % 立即更新图像
        drawnow;
        % 暂停0.1秒
        pause(0.1);
        k=k+1;
    else
        flag=0;
    end
end
% 终点
ender=double(x1);
% 输出在终点的函数值
x=ender(1,1);
value=x^2+2*x+2;
end