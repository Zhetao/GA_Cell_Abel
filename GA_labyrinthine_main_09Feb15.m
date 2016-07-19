% cga
%
% This is a typical GA that works with continuous variables
% Uses - single point crossover
%      - roulette wheel selection
%
clear 
%cd M:\GA_labyrinthine_09Feb15
global funcount
funcount = 0;
warning off %#ok<WNOFF>
% Defining cost function
nvar = 8*4;
ff = 'GA_labyrinthine_COMSOL_09Feb15';

% GA parameters
npop = 8;           % population size
mutrate = 0.5;      % mutation rate
natsel = npop/2;    % # chromosomes kept
M = npop-natsel;    % # chromosomes discarded
el = 1;             % # chromosomes not mutated
Nmut = ceil(mutrate*((npop-el)*nvar));  % # mutations
parents = 1:natsel; % indicies of parents
prob = parents/sum(parents);    % prob assigned to parents
odds = [0 cumsum(prob)];    Nodds = length(odds);   % cum prob
% stopping criteria
maxgen = 500;       % max # generations
maxfun = 2000;      % max function calls
mincost = -50;      % acceptable cost

% initial population
D = 0.05;
P = zeros(npop,nvar);
cost = zeros(npop,nvar);
% Param = D/2*(rand(2,4)-0.5);

% cost function
nGoal = 2;
plotFlag = 'n';
for pop = 1:npop
    Param = D/2*(rand(1,nvar)-0.5);     % [x1a,y1a,x1b,y1b,x2a,y2a,x2b,y2b]
    Param(2) = 0.0248; Param(6) = -0.0248;
    nCal = feval(ff,Param,plotFlag);
    P(pop,:) = Param;
    cost(pop) = abs(nGoal-nCal)^2;
    disp(['Cost is ' num2str(cost(pop))])
    disp(['Initial guess, # chromosome = ' num2str(pop)])
end

% Natural selection
[cost,ind] = sort(cost);
P = P(ind(1:natsel),:);
cost = cost(1:natsel);

minc(1) = min(cost);    % best cost in each generation

for gen = 1:maxgen
    disp(['# generation ' num2str(gen)])
    % Create mating pool
    for ic = 1:2:M
        r = rand;   ma = max(find(odds<r)); % indicies of mother
        r = rand;   pa = max(find(odds<r)); % indicies of father
        xp = ceil(rand*nvar);               % crossover point
        r = rand;                           % mixing parameter
        xy = P(ma,xp)-P(pa,xp);             % mix from ma and pa
        % generate masks
        mask1 = [ones(1,xp) zeros(1,nvar-xp)];
        mask2 = not(mask1);
        % crossover
        P(natsel+ic,:) = mask1.*P(ma,:)+mask2.*P(pa,:);
        P(natsel+ic+1,:) = mask2.*P(ma,:)+mask1.*P(pa,:);
        % create single point crossover variable
        P(natsel+ic,xp) = P(natsel+ic,xp)-r*xy;
        P(natsel+ic+1,xp) = P(natsel+ic+1,xp)-r*xy;
    end
    
    % Mutation
    elP = P(el+1:npop,:);
    elP(ceil((npop-el)*nvar*rand(1,Nmut))) = rand(1,Nmut);
    P(el+1:npop,:) = elP;
    
    % Cost function
%     cost = feval(ff,P);
    for pop = 1:npop
        Param = P(pop,:);     % [x1a,y1a,x1b,y1b,x2a,y2a,x2b,y2b]
        nCal = feval(ff,Param,plotFlag);
        cost(pop) = abs(nGoal-nCal)^2;
        disp(['# chromosome = ' num2str(pop)])
        disp(['Cost is ' num2str(cost(pop))])
        % Plot geometry
        Param = reshape(Param,2,4);
        x1a = Param(1,1); y1a = Param(2,1); x1b = Param(1,2); y1b = Param(2,2);
        x2a = Param(1,3); y2a = Param(2,3); x2b = Param(1,4); y2b = Param(2,4);
        close all
        figure(11); xlim([-D/2,D/2]); ylim([-D/2,D/2])
        line([x1a x1b],[y1a y1b]); hold on;
        line([x2a x2b],[y2a y2b])
        title(['# generation ' num2str(gen) ' and # chromosome = ' num2str(pop)])
        drawnow
    end

    % Natural selection
    [cost,ind] = sort(cost);
    P = P(ind(1:natsel),:);
    cost = cost(1:natsel);
    
    minc(gen+1) = cost(1);
%     [gen cost(1)]
    % convergence check
    if funcount>maxfun ||gen>maxgen || minc(gen+1)<mincost
        mincost
        break
    end
    
end

% Present results
day = clock;
disp(datestr(datenum(day(1),day(2),day(3),day(4),day(5),day(6)),0))
disp(['optimized function is ' ff])
format short g
disp(['# par = ' num2str(nvar)])
disp(['min cost = ' num2str(mincost)])
disp(['best chromosome = ' num2str(P(1,:))])

figure(1)
plot([0:gen],minc)
xlabel('generation'); ylabel('cost')










