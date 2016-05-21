function [allocation] = MNW_nonzero(valuation,divisibility)
% Runs MNW assuming Nash product > 0 is feasible. 
% Version of MIP: one that has segments on the log curve
% Preprocessing: Find possible values of v_i(A_i)

%MIP:
% Maximize \sum_{i=1}^n LV_i
% For all i and all v, 
%   LV_i <= Log(vLeft)+ (Log(vRight)-Log(vLeft))/(vRight-vLeft)*(\sum_g A_{i,g}*v_i(g)-vLeft). 
%   If g is divisible, use A_{i,g}*v_i(g)/100
% For all indivisible j: \sum_{i=1}^n A_{i,j} = 1 AND for all i, A_{i,j} \in {0,1}
% For all divisible j: \sum_{i=1}^n A_{i,j} = 100 AND A_{i,g} \in Integers && A_{i,g} >= 0
% For all i, LV_i is continuous
% For all i, v_i(A_i) >= 1

global use_preprocessing;

[n,m] = size(valuation);
SUM_OF_VALS = sum(valuation(1,:));

% Preprocessing
if use_preprocessing
    num_segment_constraints = 0;
    feasible_values = cell(1,n);
    for player=1:n
        % Find feasible values of v_i(A_i). Don't mark 0 feasible.
        feasible_values{player} = preprocessing(valuation(player,:),divisibility);
        
        % #segment constraints is roughly half of these in number
        num_segment_constraints = num_segment_constraints + ceil(length(feasible_values{player})/2);
    end
else
    if any(divisibility)
        default_segment_points = 0.01:0.01:SUM_OF_VALS;
    else
        default_segment_points = 1:SUM_OF_VALS;
    end
    num_segment_constraints = n*ceil(length(default_segment_points)/2);
end

% Divide valuation by 100 if the good is divisible. Helps because our
% A_{i,g} sum to 100 rather than 1 in that case. 
divisible_indices = find(divisibility);
new_valuation = valuation;
new_valuation(:,divisible_indices) = new_valuation(:,divisible_indices)/100;

% Number of equations and variables
nEq = m; % #Equality constraints: For all j, \sum_i A_{i,j} = 1
nIneq = num_segment_constraints+n; % #Inequality constraints: segments, v_i(A_i) >= 1
nVar = n+n*m; % #Variables: Log(v_i) and A_{i,g}

% Index of variables in the list
% varInd_LOGVAL = @(i) i; % Index of the variable Log(v_i)
varInd_ALLOC = @(i,g) n+(i-1)*m+g; % Index of the variable A_{i,g}

% Constraint matrices
Aineq = zeros(nIneq,nVar); % Inequality LHS
bineq = zeros(nIneq,1); % Inequality RHS
Aeq = zeros(nEq,nVar); % Equality LHS
beq = zeros(nEq,1); % Equality RHS
f = zeros(1,nVar); % Objective function

% Current index of the respective constraint
ineqCount = 1;
eqCount = 1;

%% Let's start building the constraints now.
% Segments Constraints
for player=1:n
    if use_preprocessing
        segment_points = feasible_values{player};
    else
        segment_points = default_segment_points;
    end
    
    % This assumes varInd_ALLOC(player,good) to be contiguous in good. Else, use a loop.
    varInd_ALLOC_range = varInd_ALLOC(player,1):varInd_ALLOC(player,m);
    
    for leftPt=1:2:length(segment_points)
        % Value at the left and right endpoints of the segment
        vLeft = segment_points(leftPt);
        if leftPt == length(segment_points) % Last, odd point. 
            vRight = vLeft+1;
        else
            vRight = segment_points(leftPt+1);
        end
        
        % Log(v_i) <= Log(vLeft)+ (Log(vRight)-Log(vLeft))/(vRight-vLeft)*(\sum_g A_{i,g}*v_i(g)-vLeft)

        % Small optimization: varInd_LOGVAL(player) = player
        % Aineq(ineqCount,varInd_LOGVAL(player)) = 1;
        Aineq(ineqCount,player) = 1;
        
        slope = ((log(vRight)-log(vLeft))/(vRight-vLeft));
        Aineq(ineqCount,varInd_ALLOC_range) = -slope*new_valuation(player,:);
        bineq(ineqCount) = log(vLeft)-slope*vLeft;
        ineqCount = ineqCount + 1;
    end
    
    % Non-zero values: For all i, \sum_g A_{i,g}*v_{i,g} >= 0.01
    Aineq(ineqCount,varInd_ALLOC_range) = -new_valuation(player,:);
    bineq(ineqCount) = -0.0001;
    ineqCount = ineqCount+1;
end
assert(ineqCount == nIneq+1);

% Allocation feasibility: Each item goes to a single player, divisible
% parts sum to 100.
for good=1:m
    for player=1:n
        Aeq(eqCount,varInd_ALLOC(player,good)) = 1;
    end
    if divisibility(good)
        beq(eqCount) = 100;
    else
        beq(eqCount) = 1;
    end
    eqCount = eqCount + 1;
end
assert(eqCount == nEq+1);

% Objective Function: Maximize \sum_i Log(v_i)
% Optimization: varInd_LOGVAL(player) = player
f(1:n) = -1;
% for player=1:n
%     f(varInd_LOGVAL(player)) = -1;
% end

ctype = repmat('B',1,nVar);
ctype(1:n) = 'C';
% for player=1:n
%     ctype(varInd_LOGVAL(player)) = 'C';
% end

lb = -Inf(1,nVar);
ub = log(1000)*ones(1,nVar);

for good=1:m
    for player=1:n
        lb(varInd_ALLOC(player,good)) = 0;
        if divisibility(good)
            ctype(varInd_ALLOC(player,good)) = 'I';
            ub(varInd_ALLOC(player,good)) = 100;
        else
            ub(varInd_ALLOC(player,good)) = 1;
        end
    end
end

options=cplexoptimset('Display', 'off');
options.output.clonelog = -1; 
%Cplex.Param.mip.tolerances.mipgap = TOL;
%options.lpmethod = 2;
%options.preprocessing.dual = 1;
%options.simplex.perturbation.indicator = 1;

[x,~,exitflag,~] = cplexmilp(f,Aineq,bineq,Aeq,beq,[],[],[],lb,ub,ctype);

% Error
if exitflag <0
    error('Error: Negative exitflag!\n');
end

allocation = zeros(n,m);
for player = 1:n
    for good = 1:m
        if divisibility(good)
            allocation(player,good) = round(x(varInd_ALLOC(player,good)))/100;
        else
            allocation(player,good) = (x(varInd_ALLOC(player,good)) > 0.5);
        end
    end
end
end