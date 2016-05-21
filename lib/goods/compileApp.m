PLATFORM = 'LIN64'; % or 'WIN64'

if isequal(PLATFORM,'LIN64')
    system('rm -f *.log *.txt goods *.sh *~');
    mcc -R -nodisplay -m goods.m -a ./* -a ./matlab_bgl/ -a ./cplex/x86-64_linux/
    
    % Unfortunately, on Linux, run_goods.sh produced outputs things that
    % can mess up the parsing. 
    % This code is specific to the run_goods.sh produced for MNW. Test
    % carefully before using it for another application.
    
    % First, remove all lines with "echo".
    f1 = fopen('run_goods.sh');
    f2 = fopen('test.sh','w');
    tline = fgetl(f1);
    while ischar(tline)
        if isempty(strfind(tline,'echo'))
            fprintf(f2,'%s\n',tline);
        end
        tline = fgetl(f1);
    end
    fclose('all');
    
    % Now, remove any empty if
    f1 = fopen('test.sh');
    f2 = fopen('run_goods.sh','w');
    tline = fgetl(f1);
    while ischar(tline)
        % Skip if, else, fi
        if (length(tline) < 3 || ~isequal(tline(1:3),'if ')) && (length(tline) < 4 || ~isequal(tline,'else')) && (length(tline) < 1 || ~isequal(tline,'fi'))
            fprintf(f2,'%s\n',tline);
        end
        tline = fgetl(f1);
    end
    fclose('all');
    system('rm -f test.sh');
else
    system('rm -f *.log *.txt *.exe *~');
    mcc -m goods.m -a ./* -a ./matlab_bgl -a ./cplex/x64_win64
end
system('rm -f mccExcludedFiles.log requiredMCRProducts.txt readme.txt ');
system('mv -f run_goods.sh goods ../../bin/');