%
clear 
cd M:\GA_labyrinthine_16Feb15
warning off %#ok<WNOFF>
% Parameters
NbLines = 120;
Param = zeros(NbLines,4);
ff = 'LotsSmallLines_RandomUC_COMSOL_13Feb15';
D = 0.05;   % m
maxgen = 1000;
%
plotFlag = 'y';
s21Vec = zeros(maxgen,1);
rng(0)
freq = 1500; 
for gen = 1:maxgen
    figure; 
    for line = 1:NbLines
        Param(line,1) = D*0.98*(rand-0.5);   
        Param(line,2) = D*0.98*(rand-0.5);   
        lengthTmp = D/32+D/8*abs(randn);    % Single side normal distribution
        angleTmp = 2*pi*rand;
        Param(line,3) = Param(line,1)+lengthTmp*cos(angleTmp);   
        if Param(line,3)<-D/2*0.98, Param(line,3) = -D/2*0.98;
        elseif Param(line,3)>D/2*0.98, Param(line,3) = D/2*0.98;
        end
        Param(line,4) = Param(line,2)+lengthTmp*sin(angleTmp);   
        if Param(line,4)<-D/2*0.98, Param(line,4) = -D/2*0.98;
        elseif Param(line,4)>D/2*0.98, Param(line,4) = D/2*0.98;
        end
    end
    [nrTmp, zrTmp, s21Tmp] = feval(ff,Param,plotFlag,NbLines,freq); 
    annotation('textbox', [0.2,0.1,0.4,0.1],'LineStyle','none',...
           'String', ['nr = ' num2str(nrTmp) '\newlinezr = ' num2str(zrTmp)]);
    fn = ['retrieved_gen' num2str(gen)];
    saveas(gcf,['random_LotsSmallLines\' fn '.jpg'])
    pause(1); close;
    disp(['Complete generation ' num2str(gen)])
    s21Vec(gen) = s21Tmp;
end
%%
figure; scatter(angle(s21Vec),abs(s21Vec)); xlim([-pi pi]); ylim([0 1.1])
xlabel('Elapsed phase'); ylabel('Amplitude of Transmission');









