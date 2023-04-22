clc;clear;
%% 手动实现
% 定义样本
Z=[5.4 -2.6 -3.6 2.4 -1.6;4.4 -1.6 -2.6 1.9 -2.1];
% 计算协方差矩阵
Q=Z*Z';
% 计算特征值D和特征向量V
[V,D]=eig(Q);
% 得到最大的特征值
maxD=max(D,[],'all');
% 寻找最大特征值所在的列号
[maxx,maxy]=find(D==maxD);
% 计算第一主成分
First1=V(:,maxy)'*Z
%% 自带函数
[~,First2]=pca(Z');
