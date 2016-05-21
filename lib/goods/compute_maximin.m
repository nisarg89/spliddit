function v = compute_maximin(values,divisibility,k)
% Given values and divisibilities of goods, what is the way to partition the goods into k bundles?
% In our case, k will be n (the number of players). 
% We want to maximize the minimum value in any bundle.

m = length(values);

% Program: Maximize M
% \sum_i A_(i,p) * v(i) >= M
% \sum_p A_(i,p) = 1
% A_(i,p) \in {0,1} for indivisible good
% A_(i,p) \in [0,1] for divisible good

nVar = m*k+1;
nIneq = k;
nEq = m;
varInd_A = @(good,partition) (good-1)*k+partition;

f = zeros(nVar,1);
Aineq = zeros(nIneq,nVar);
bineq = zeros(nIneq,1);
Aeq = zeros(nEq,nVar);
beq = zeros(nEq,1);

% Objective Function
f(end) = -1; % M is at the end

% Inequality Constraints
ineqCnt = 1;
for partition=1:k
    for good=1:m
        Aineq(ineqCnt,varInd_A(good,partition)) = -values(good);
    end
    Aineq(ineqCnt,nVar) = 1;
    ineqCnt = ineqCnt+1;
end

% Eq
eqCnt = 1;
for good=1:m
    Aeq(eqCnt,varInd_A(good,1):varInd_A(good,k)) = 1;
    beq(eqCnt) = 1;
    eqCnt = eqCnt+1;
end

ctype = repmat('B',1,nVar);
for good=1:m
    if divisibility(good)
        ctype(varInd_A(good,1):varInd_A(good,k)) = 'C';
    end
end
ctype(end) = 'C';

options=cplexoptimset('Display', 'off');
options.output.clonelog = -1; 
[~,fval,exitflag] = cplexmilp(f,Aineq,bineq,Aeq,beq,[],[],[],[],[],ctype);
assert(exitflag >= 0);

v = -fval;

end