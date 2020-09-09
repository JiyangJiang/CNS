function failureIDcellArr = WMHextraction_readFailureList (subj_dir)

if isfile (fullfile(subj_dir,'failed_processing.list'))
	failure_list = fileread(fullfile(subj_dir,'failed_processing.list'));
	failureIDcellArr = strsplit (failure_list,'\n');
else
	failureIDcellArr = {};
end