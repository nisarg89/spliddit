function goods(filename)

global TOL; TOL = 1e-6;
global DIVISIBLE_NUMPARTS;DIVISIBLE_NUMPARTS = 100; 
global use_preprocessing; use_preprocessing = 1;

agents_id_map = containers.Map('KeyType','char','ValueType','int32');
goods_id_map = containers.Map('KeyType','char','ValueType','int32');
agents_name_map = containers.Map('KeyType','int32','ValueType','char');
goods_name_map = containers.Map('KeyType','int32','ValueType','char');
allocation = 0;
n = 0;
m = 0;

try 
    fid = fopen(filename);
    n = str2double(fgetl(fid));
    m = str2double(fgetl(fid));
    
    valuation = zeros(n,m);
    divisibility = false(1,m);

    num_agents_initialized = 0;
    num_goods_initialized = 0;
   
    % Get divisibilities
    for g = 1:m
        ln = strsplit(fgetl(fid));
        if ~goods_id_map.isKey(ln{1})
            num_goods_initialized = num_goods_initialized+1;
            goods_id_map(ln{1}) = num_goods_initialized;
            goods_name_map(num_goods_initialized) = ln{1};
        end
        divisibility(goods_id_map(ln{1})) = isequal(ln{2},'divisible');
    end

    % Get valuations
    for id = 1:n*m
        ln = strsplit(fgetl(fid));
        if ~agents_id_map.isKey(ln{1})
            num_agents_initialized = num_agents_initialized+1;
            agents_id_map(ln{1}) = num_agents_initialized;
            agents_name_map(num_agents_initialized) = ln{1};
        end
        if ~goods_id_map.isKey(ln{2})
            num_goods_initialized = num_goods_initialized+1;
            goods_id_map(ln{2}) = num_goods_initialized;
            goods_name_map(num_goods_initialized) = ln{2};
        end
        valuation(agents_id_map(ln{1}),goods_id_map(ln{2})) = str2double(ln{3});
    end

    allocation = MNW(valuation,divisibility);
    assert(isequal(size(allocation),size(valuation)));
    assert(check_EF1(valuation,divisibility,allocation));

    for player = 1:n
        for good = 1:m
            if allocation(player,good) > TOL
                val = round(allocation(player,good)*DIVISIBLE_NUMPARTS)/DIVISIBLE_NUMPARTS;
                fprintf([agents_name_map(player) ' ' goods_name_map(good) ' ' num2str(val) '\n']);
            end
        end
    end
	
	system('rm -f *.log');
catch
    fprintf('failure');
end


end