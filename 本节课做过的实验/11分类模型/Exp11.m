% 提取时域和频域特征各三个。分别为：RMS，ZC和WL；平均功率频率MPF、功率谱最大值MPV、中值频率MF。
clear;close all;dbstop if error;
%% 参数定义
% feature_dimension，单个通道特征的维数
FeD=3;
% 肌电信号频率，由于后面单位是毫秒，这里除以1000
Frq=1500/1000;
% action_number，动作数量
AcN=5;
% action_length，每次实验中每个动作的长度，单位为毫秒
AcL=4000;
% 窗口长度
WL=250;
% sliding_length，肌电信号无重叠滑动的长度，单位是毫秒
St=50;
% channel，肌电信号的采集通道数量，即肌肉数量
ChN=2;
% 特征提取所需时间
FTime=zeros(2,1);
% 读取数据
load('Data.mat')
%% 训练和测试
[FTime(1),TDFeature,TDsep]=TDFeatureExtract(Data,AcN,AcL,Frq,WL,St,ChN,FeD);
[FTime(2),FDFeature,FDsep]=FDFeatureExtract(Data,AcN,AcL,Frq,WL,St,ChN,FeD);
save('Feature.mat','TDFeature','FDFeature')
%% 时域特征
function [FeatureTime,Feature,sep]=TDFeatureExtract(Data,AcN,AcL,Frq,WL,St,ChN,FeD)
% 变量预定义
AcL=AcL*Frq;
WL=WL*Frq;
St=St*Frq;
% windows_number_per_action，每个动作中信号窗口的数量
WNPA=(AcL-WL)/St+1;%76
% 过零点数的判断阈值
ZCThres=3;
Feature=zeros(ChN*FeD,AcN*WNPA);
% 聚合度
sep=zeros(3,1);
% 特征提取
tic
for ac=1:AcN % 对于每个动作
    for win=1:WNPA % 对于每个信号段
        for ch=1:ChN % 对于每个通道
            % 把数据赋给临时变量，方便操作
            Tmp=squeeze(Data(1,ch,(ac-1)*AcL+(win-1)*St+1:(ac-1)*AcL+(win-1)*St+WL));
            % 提取特征
            % Rms    第一个↓特征
            Feature((ch-1)*FeD+1,(ac-1)*WNPA+win)=log(rms(Tmp));
            ZCTmp=0;
            WLTmp=0;
            % 对于每个数据点
            for i=2:length(Tmp)
                if ((Tmp(i)*Tmp(i-1)<0)&&abs(Tmp(i)-Tmp(i-1))>=ZCThres)
                    % 过零点数第二个↓特征
                    ZCTmp=ZCTmp+1;
                end
                % WL          第3个↓特征
                WLTmp=WLTmp+abs(Tmp(i)-Tmp(i-1));
            end
            % 赋值
            Feature((ch-1)*FeD+2,(ac-1)*WNPA+win)=ZCTmp;
            Feature((ch-1)*FeD+3,(ac-1)*WNPA+win)=log(WLTmp);
        end
    end
end
FeatureTime=toc;
% 归一化

% 计算聚合度
MeanX=zeros(AcN,1);
MeanY=MeanX;
r=zeros(AcN,1);
R=zeros(AcN);
% 类内间距
for ac=1:AcN
    x=Feature(1,(ac-1)*WNPA+1:ac*WNPA);
    y=Feature(4,(ac-1)*WNPA+1:ac*WNPA);
    MeanX(ac)=mean(x);
    MeanY(ac)=mean(y);
    r(ac)=mean(sqrt((x-MeanX(ac)).^2+(y-MeanY(ac)).^2));
end
% 类间间距
for ac=1:AcN
    for ac2=1:AcN
        R(ac,ac2)=sqrt((MeanX(ac)-MeanX(ac2)).^2+(MeanY(ac)-MeanY(ac2)).^2);
    end
end
r=mean(r);
R=sum(R,"all")/(AcN*(AcN-1));
sep(1)=r/R;
% 画图
figure
title('RMS特征')
hold on
for ac=1:AcN
    % 通道1，特征1为X轴，通道2，特征1为Y轴
    plot(Feature(1,(ac-1)*WNPA+1:ac*WNPA),...
        Feature(4,(ac-1)*WNPA+1:ac*WNPA),...
        '.','Color',[ac/5 (5-ac)/5 ac/5],'MarkerSize',15)
end
end
%% 频域特征：平均功率频率MPF、功率谱最大值MPV、中值频率MF
function [FeatureTime,Feature,sep]=FDFeatureExtract(Data,AcN,AcL,Frq,WL,St,ChN,FeD)
% 变量预定义
AcL=AcL*Frq;
WL=WL*Frq;
St=St*Frq;
% windows_number_per_action，每个动作中信号窗口的数量
WNPA=(AcL-WL)/St+1;%76
Feature=zeros(ChN*FeD,AcN*WNPA);
% 聚合度
sep=zeros(3,1);
% 特征提取
tic
    for ac=1:AcN % 对于每个动作
        for win=1:WNPA % 对于每个信号段
            for ch=1:ChN % 对于每个通道
                % 把数据赋给临时变量，方便操作
                Tmp=squeeze(Data(1,ch,(ac-1)*AcL+(win-1)*St+1:(ac-1)*AcL+(win-1)*St+WL));
                % 使用Welch方法获取sEMG的功率谱
                % [Psd,f]=pwelch(Tmp,[],[],500,Frq*1000);
                [Psd,f]=pwelch(Tmp,[],[],500,Frq*1000);
                % MPF        第一个↓特征
                Feature((ch-1)*FeD+1,(ac-1)*WNPA+win)=sum(f.*Psd)/sum(Psd);
                % MPV        第二个↓特征
                Feature((ch-1)*FeD+2,(ac-1)*WNPA+win)=log(max(Psd));
                % MF         第三个↓特征
                IndexVector=1:length(f);
                CumAmp=cumtrapz(f,abs(Psd(IndexVector))); % 计算Psd的积分
		        Feature((ch-1)*FeD+3,(ac-1)*WNPA+win)=...
                    interp1(CumAmp,f,CumAmp(end)/2); % 插值方法寻找MF
            end
        end
    end
FeatureTime=toc;
% 归一化

% 计算聚合度

% 画图

end