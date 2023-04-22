% 要求做到：
% 给的是时域特征，尝试频域特征
% 列出不同特征的正确率表格
% 分析究竟用何种特征和多大的K可以得到最佳识别正确率
%% 这段不用管
clear;clc;close all;dbstop  if  error
% 读取特征
load("Feature.mat")
% 实验次数
ExN=10;
% 动作数量
AcN=5;
% 每个动作中训练集样本的数量
AcTrNum=60;
% 每个动作中测试集样本的数量
AcTeNum=16;
% 每个实验中训练集样本的数量
ExTrNum=AcTrNum*AcN;
% 每个实验中测试集样本的数量
ExTeNum=AcTeNum*AcN;
% 每个动作中样本总数量
AcNum=AcTrNum+AcTeNum;
% 每次实验中样本总数量
ExNum=AcNum*AcN;
% 创建标签
label=1:AcN;
label=repelem(label,AcNum);
label=repmat(label,1,10);
% 将每个动作前AcTrNum个数据作为训练集
XTr=zeros(2,ExTrNum*ExN);
YTr=zeros(1,ExTrNum*ExN);
XTe=zeros(2,ExTeNum*ExN);
YTe=zeros(1,ExTeNum*ExN);
% 赋值
for ex=1:ExN
    for ac=1:AcN
        XTr(:,(ex-1)*ExTrNum+(ac-1)*AcTrNum+1:(ex-1)*ExTrNum+ac*AcTrNum)=...
            TDFeature(:,(ex-1)*ExNum+(ac-1)*AcNum+1:(ex-1)*ExNum+(ac-1)*AcNum+AcTrNum);
        % 时域改频域↑在这里
        YTr((ex-1)*ExTrNum+(ac-1)*AcTrNum+1:(ex-1)*ExTrNum+ac*AcTrNum)=...
            label(:,(ex-1)*ExNum+(ac-1)*AcNum+1:(ex-1)*ExNum+(ac-1)*AcNum+AcTrNum);
        XTe(:,(ex-1)*ExTeNum+(ac-1)*AcTeNum+1:(ex-1)*ExTeNum+ac*AcTeNum)=...
            TDFeature(:,(ex-1)*ExNum+(ac-1)*AcNum+61:(ex-1)*ExNum+(ac-1)*AcNum+AcNum);
        % 时域改频域↑在这里
        YTe((ex-1)*ExTeNum+(ac-1)*AcTeNum+1:(ex-1)*ExTeNum+ac*AcTeNum)=...
            label(:,(ex-1)*ExNum+(ac-1)*AcNum+61:(ex-1)*ExNum+(ac-1)*AcNum+AcNum);
    end
end
%% 画图
figure
title('所有数据')
hold on
for ex=1:ExN
    for ac=1:AcN
        % 通道1，特征1为X轴，通道2，特征1为Y轴
        % 时域改频域↓在这里（有两个）
        plot(TDFeature(1,(ex-1)*AcN*AcNum+(ac-1)*AcNum+1:(ex-1)*AcN*AcNum+ac*AcNum), ...
            TDFeature(2,(ex-1)*AcN*AcNum+(ac-1)*AcNum+1:(ex-1)*AcN*AcNum+ac*AcNum), ...
            '.','Color',[ac/5 (5-ac)/5 ac/5])
    end
end
axis([-1 1 -1 1])
figure
title('训练集')
hold on
for ex=1:ExN
    for ac=1:AcN
        % 通道1，特征1为X轴，通道2，特征1为Y轴
        plot(XTr(1,(ex-1)*AcN*AcTrNum+(ac-1)*AcTrNum+1:(ex-1)*AcN*AcTrNum+ac*AcTrNum), ...
            XTr(2,(ex-1)*AcN*AcTrNum+(ac-1)*AcTrNum+1:(ex-1)*AcN*AcTrNum+ac*AcTrNum), ...
            '.','Color',[ac/5 (5-ac)/5 ac/5])
    end
end
axis([-1 1 -1 1])
figure
title('测试集')
hold on
for ex=1:ExN
    for ac=1:AcN
        % 通道1，特征1为X轴，通道2，特征1为Y轴
        plot(XTe(1,(ex-1)*AcN*AcTeNum+(ac-1)*AcTeNum+1:(ex-1)*AcN*AcTeNum+ac*AcTeNum), ...
            XTe(2,(ex-1)*AcN*AcTeNum+(ac-1)*AcTeNum+1:(ex-1)*AcN*AcTeNum+ac*AcTeNum), ...
            '.','Color',[ac/5 (5-ac)/5 ac/5])
    end
end
axis([-1 1 -1 1])
XTr=XTr';
YTr=YTr';
XTe=XTe';
YTe=YTe';
%% 模型训练和测试
opts = statset('Display','off');
[idx,C] = kmeans(XTr,5,'Replicates',500,'Options',opts);
% 画图
figure;
hold on
for ac=1:5
    plot(XTr(idx==ac,1),XTr(idx==ac,2),'.','MarkerSize',12,'Color',[ac/5 (5-ac)/5 ac/5])
    plot(C(ac,1),C(ac,2),'kx','MarkerSize',15,'LineWidth',3) 
end
title '分布图'
hold off
% 模型测试
D=zeros(ExTeNum*ExN,1);
Y=zeros(ExTeNum*ExN,1);
for DataIndex=1:ExTeNum*ExN
    X=XTe(DataIndex,:);
    X1=[X;C];
    D=pdist(X1);
    Di=squareform(D);
    [~,Y(DataIndex)]=min(Di(1,2:end));
end
% 计算正确率
Acc=1-sum(Y~=YTe)/800