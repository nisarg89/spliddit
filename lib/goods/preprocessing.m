function [feasible_values] =  preprocessing(values,divisibility)
% Find all possible sums of subsets in data
% Uses dynamic programming

new_values = values*100;
SUMVAL = sum(new_values);
n = length(new_values);

% feasible: can we find sum = i using first j elements of data?
feasible = false(SUMVAL,n);

% Initialize
if new_values(1) > 0
    if divisibility(1)
        feasible(new_values(1)/100:new_values(1)/100:new_values(1),1) = true;
    else
        feasible(new_values(1),1) = true; % Cannot generate anything else
    end
end

for g = 2:n
    if divisibility(g)
        if new_values(g) > 0
            % Don't use g at all
            feasible(:,g) = feasible(:,g) | feasible(:,g-1);
            
            % Use g
            if new_values(g) > 0
                % Use x parts of g, x >= 1
                for x = 1:100 
                    VAL = new_values(g)*x/100;

                    % Only using x parts of g
                    feasible(VAL,g) = true; 

                    % Using x parts of g along with at least one previous good
                    feasible(VAL+1:SUMVAL,g) = feasible(VAL+1:SUMVAL,g) | feasible(1:SUMVAL-VAL,g-1);
                end
            end
        else
            feasible(:,g) = feasible(:,g-1);
        end
    else
        feasible(1:new_values(g)-1,g) = feasible(1:new_values(g)-1,g-1);
        if new_values(g) > 0
            feasible(new_values(g),g) = true;
        end
        feasible(new_values(g)+1:SUMVAL,g) = feasible(1:SUMVAL-new_values(g),g-1) | feasible(new_values(g)+1:SUMVAL,g-1);
    end
end

feasible_values = find(feasible(:,n))/100;

end