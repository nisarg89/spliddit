function [MMS_apx] = MMSApx(valuation,divisibility,allocation)

[n,~] = size(valuation);
MMS_values = arrayfun(@(player) compute_maximin(valuation(player,:),divisibility,n),1:n);
utilities = sum(allocation.*valuation,2);

MMS_apx = 1;
for player=1:length(MMS_values)
    if MMS_values(player) <= utilities(player)
        ratio = 1;
    else
        ratio = utilities(player)/MMS_values(player);
    end
    MMS_apx = max(MMS_apx,ratio);
end

end