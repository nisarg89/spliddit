function [allocation] = MNW(valuation,divisibility)
% Run MNW
% Uses: Matlab_bgl (matching)

% Step 1: Find the maximal set of players to which we can give a positive utility. 
% To do that, make 100 copies of each divisible good. Then do max-cardinality matching.

% Step 2: Run MNW on that set. Multiply all values by 100. 
% For a divisible good g, use \sum_i A_{i,g} = 100 with general integer variables.

warning off;
global TOL;
global DIVISIBLE_NUMPARTS;

[n,m] = size(valuation);

divisible_indices = find(divisibility==1); num_divisible = length(divisible_indices);
indivisible_indices = find(divisibility==0); num_indivisible = length(indivisible_indices);
assert(num_divisible+num_indivisible == m);
new_m = num_indivisible + DIVISIBLE_NUMPARTS*num_divisible;

% Sanity check
SUM_VAL = 1000; assert(all(sum(valuation,2)==SUM_VAL));

%% Step 1: Max cardinality matching
positive_value_graph = zeros(n+new_m,n+new_m);
for player=1:n
    positive_value_graph(player,n+1:n+num_indivisible) = (valuation(player,indivisible_indices)>TOL);
    positive_value_graph(player,n+num_indivisible+1:n+new_m) = repmat(valuation(player,divisible_indices)>TOL,1,DIVISIBLE_NUMPARTS);
end

% Make it symmetric
positive_value_graph = positive_value_graph + transpose(positive_value_graph);
[match,is_max_card] = matching(sparse(positive_value_graph));
assert(is_max_card==1);
reduced_players = sort(find(match(1:n)>0))';

reduced_allocation = MNW_nonzero(valuation(reduced_players,:),divisibility);

% Convert to an allocation of the original problem
allocation = zeros(n,m);
allocation(reduced_players,:) = reduced_allocation;
end