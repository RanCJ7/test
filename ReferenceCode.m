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
% 实验次数
ExN=10;
%% 读取数据
load('Data.mat')
%% 画数据图，需要补全
subplot(2,1,1)
plot(squeeze(Data(1,1,:)),'r')
% 此处需要手动添加图题、x和y轴标题以及修改坐标系范围

%% 提取特征
TDFeature=TDFeatureExtract(Data,ExN,AcN,AcL,Frq,WL,St,ChN,FeD);
save('Feature.mat','TDFeature')
%% 生成标签，需要补全
% 对于BPNN
% 第一步，生成1~AcN个独热数据标签
BPNNLabel=eye(5);
% 第二步，利用repelem函数，在行方向重复(AcL-WL)/St+1次，在列方向重复1次，得到每次实验的标签
% 语法：repelem(被重复的数组,行方向重复次数,列方向重复次数)

% 第三步，利用repmat，将该数组在行方向重复ExN次，在列方向重复1次，得到所有实验的标签

% 第四步，将BPNNLabel转置以适应特征

% 第五步，保存
save('BPNNLabel.mat','BPNNLabel')
% 对于其他分类器
% 第一步，生成1~AcN个数据标签
Label=1:AcN;
% 第二步，利用repelem函数，每个元素重复(AcL-WL)/St+1次，得到每次实验的标签
% 语法：repelem(被重复的数组,重复次数)

% 第三步，利用repmat，将该数组在行方向重复1次，在列方向重复ExN次，得到所有实验的标签

% 第四步，保存
save('Label.mat','Label')
%% 时域特征，需要补全画图部分
function Feature=TDFeatureExtract(Data,ExN,AcN,AcL,Frq,WL,St,ChN,FeD)
% 变量预定义
AcL=AcL*Frq;
WL=WL*Frq;
St=St*Frq;
% windows_number_per_action，每个动作中信号窗口的数量
WNPA=(AcL-WL)/St+1;%76
% 过零点数的判断阈值
ZCThres=3;
Feature=zeros(ChN*FeD,AcN*WNPA);
% 特征提取
for ex=1:ExN % 对于每次实验
    for ac=1:AcN % 对于每个动作
        for win=1:WNPA % 对于每个信号段
            for ch=1:ChN % 对于每个通道
                % 把数据赋给临时变量，方便操作
                Tmp=squeeze(Data(ex,ch,(ac-1)*AcL+(win-1)*St+1:(ac-1)*AcL+(win-1)*St+WL));
                % 提取特征
                % Rms    第一个↓特征
                Feature((ch-1)*FeD+1,(ex-1)*WNPA*AcN+(ac-1)*WNPA+win)=log(rms(Tmp));
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
                Feature((ch-1)*FeD+2,(ex-1)*WNPA*AcN+(ac-1)*WNPA+win)=ZCTmp;
                Feature((ch-1)*FeD+3,(ex-1)*WNPA*AcN+(ac-1)*WNPA+win)=log(WLTmp);
            end
        end
    end
end
% 归一化
Feature=mapminmax(Feature);
% 画图

end