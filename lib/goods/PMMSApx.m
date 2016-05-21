function PMMS_apx = PMMSApx(valuation,divisibility,allocation)

[n,~] = size(valuation);

PMMS_values = zeros(1,n);
for i=1:n
    for j=1:n
        if i==j
            continue;
        end
        
        % Partition values of items allocated to i & j into 2 bundles.
        combined_allocation = allocation(i,:)+allocation(j,:); % What i & j have
        reduced_values = valuation(i,:).*combined_allocation; % i's values for that
        items = reduced_values > 0; % Nonzero valued items
        values = reduced_values(items); % Values of nonzero valued items
        div = divisibility(items); % Divisibility of nonzero valued items
        PMMS_i_j = compute_maximin(values,div,2); 
        PMMS_values(i) = max(PMMS_values(i),PMMS_i_j);
    end
end

utilities = sum(allocation.*valuation,2);
PMMS_apx = 1;

for player=1:length(utilities)
    if PMMS_values(player) <= utilities(player)
        ratio = 1;
    else
        ratio = utilities(player)/PMMS_values(player);
    end
    PMMS_apx = max(PMMS_apx,ratio);
end

end