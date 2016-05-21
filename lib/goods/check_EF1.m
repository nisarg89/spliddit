function is_EF1 = check_EF1(valuation,divisibility,allocation)
% Is the given allocation EF1? 
% EF1: Envy even after removing each indivisible good or 0.01 fraction of
% each divisible good

TOL = 1e-6;

[n,~] = size(valuation);
for i=1:n
    for j=1:n
        if i==j
            continue;
        end
        v_i_j = sum(valuation(i,:).*allocation(j,:)); % v_i(A_j)
        v_i_i = sum(valuation(i,:).*allocation(i,:)); % v_i(A_i)

        % Value to be removed from v_i_j before checking envy
        % Reduce all divisible allocations to j to 0.01, then find the best thing to remove
        reduced_j_allocation = allocation(j,:);
        reduced_j_allocation(divisibility & (reduced_j_allocation > 0)) = 0.01; 
        remove_value = max(valuation(i,:).*reduced_j_allocation);
        if v_i_j - remove_value > v_i_i + TOL
            is_EF1 = false;
            return
        end
    end
end

is_EF1 = true;
return
        