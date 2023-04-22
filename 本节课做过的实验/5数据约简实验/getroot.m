a=1;
b=2;
c=0.5;
% 判断是否可以计算
if b^2 - 4*a*c>=0
    % 如果可以
    [x1,x2]=mygetroot(a,b,c)
else
    disp('无实数根！')
end

function [x1,x2] = mygetroot(a,b,c)
%该函数返回一元二次方程的根
%它需要3个输入参数a,b,c，%它返回2个根
d = b24ac(a,b,c); 
x1 = (-b + d) / (2*a);
x2 = (-b - d) / (2*a);
end
function b24ac = b24ac(a,b,c) 
    %函数计算判别式
    b24ac = sqrt(b^2 - 4*a*c);
end