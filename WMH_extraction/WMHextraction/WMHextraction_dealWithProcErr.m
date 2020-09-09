function WMHextraction_dealWithProcErr (ME, subj_dir, ID, err_mfile)

% write to a list of subj IDs failing processing
fid = fopen (fullfile(subj_dir,'failed_processing.list'), 'a+');
fprintf (fid, [ID '\n']);
fclose (fid);

% write detailed error message into subject's folder who fails processing.
fid = fopen (fullfile(subj_dir,ID,'failed_processing.errMsg'), 'a+');
fprintf (fid, 'Error occurred when calling:\n');
fprintf (fid, [err_mfile '\n']);
fprintf (fid, 'Error message:\n');
fprintf (fid, ME.message);
fprintf (fid, '\nError identifier:\n');
fprintf (fid, ME.identifier);
fprintf (fid, '\n');
fclose(fid);