%
clear 
cd M:\GA_labyrinthine_09Feb15
warning off %#ok<WNOFF>
% Parameters
nvar = 8*4;
ff = 'GA_labyrinthine_COMSOL_09Feb15';
D = 0.05;   % m
maxgen = 100;
%
plotFlag = 'y';
s21Vec = zeros(maxgen,1);
for gen = 1:maxgen
    figure; 
    Param = D*0.95*(rand(1,nvar)-0.5);   
    Param = reshape(Param,[],4);
    [nrTmp, zrTmp, s21Tmp] = feval(ff,Param,plotFlag); 
    annotation('textbox', [0.2,0.1,0.4,0.1],'LineStyle','none',...
           'String', ['nr = ' num2str(nrTmp) '\newlinezr = ' num2str(zrTmp)]);
    fn = ['retrieved_gen' num2str(gen)];
    saveas(gcf,['random_8lines\' fn '.jpg'])
    close;
    disp(['Complete generation ' num2str(gen)])
    s21Vec(gen) = s21Tmp;
end
figure; scatter(angle(s21Vec),abs(s21Vec)); 
xlabel('Elapsed phase'); ylabel('Amplitude of Transmission');









