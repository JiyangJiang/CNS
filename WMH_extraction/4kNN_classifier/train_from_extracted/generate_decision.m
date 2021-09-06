function generate_decision (path,id)

% path='/data4/jiyang/temp2';
% id='1239362';

temp_dir=fullfile(path,id,'mri','extractedWMH','temp');

for i = 0:2
% for i = 0:0
	seg = fullfile(temp_dir, [id '_seg' num2str(i)]);
	ascii = [seg '_WMHmasked_ascii00000'];
	dec = [seg '_decision.txt'];

	% index range of seg's
	[~,seg_range] = system (['fslstats ' seg ' -R']);
	tmp=strsplit(seg_range,' ');
	r=str2num(tmp{2});

	% get index for Yes
	m = dlmread (ascii);
	u = unique(nonzeros(m));

	% generate decision matrix for the seg
	d = cell(r,1); % cell array for decisions
	d(:)={'No'}; % initialise decision as 'No'
	for j = 1:size(u,1)
		d(u(j))={'Yes'}; % indices in u are assigned with 'Yes'
	end

	% write decision to txt
	t=cell2table(d);
	writetable(t,dec,...
				'WriteVariableNames',false,'WriteRowNames',false);
end