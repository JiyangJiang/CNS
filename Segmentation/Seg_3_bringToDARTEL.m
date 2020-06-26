


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Step 4:  bring T1, FLAIR, GM, WM, and CSF to DARTEL space  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function Seg_3_bringToDARTEL (imgFolder, dartelTemplate, segExcldList)

    excldIDs = strsplit (segExcldList, ' ');

    imgs = dir (strcat (imgFolder,'/*.nii'));
    [Nsubj,n] = size (imgs);


    %% SPM segmentation

    spm('defaults', 'fmri');

    parfor i = 1:Nsubj

        imgNames = strsplit (imgs(i).name, '_');   % split T1 image name, delimiter is underscore
        imgFileNames = strsplit (imgs(i).name, '.');
        ID = imgNames{1};   % first section is ID
        imgFileName = imgFileNames{1};

        if ismember(ID, excldIDs) == 0

            matlabbatch = [];   % preallocate to enable parfor
            spm_jobman('initcfg');

            switch dartelTemplate
                case 'existing'
                    flowMap = strcat (imgFolder, '/spmoutput/u_rc1', imgs(i).name);
                case 'creating'
                    flowMap = [imgFolder '/spmoutput/u_rc1' imgFileName '_Template.nii'];

            end
%             
            
            

            cGM = strcat (imgFolder, '/spmoutput/c1', imgs(i).name);
            cWM = strcat (imgFolder, '/spmoutput/c2', imgs(i).name);
            cCSF = strcat (imgFolder, '/spmoutput/c3', imgs(i).name);

            matlabbatch{1}.spm.tools.dartel.crt_warped.flowfields = {flowMap};
            matlabbatch{1}.spm.tools.dartel.crt_warped.images = {
                                                                 {cGM}
                                                                 {cWM}
                                                                 {cCSF}
                                                                 }';
            matlabbatch{1}.spm.tools.dartel.crt_warped.jactransf = 0;
            matlabbatch{1}.spm.tools.dartel.crt_warped.K = 6;
            matlabbatch{1}.spm.tools.dartel.crt_warped.interp = 1;

            output = spm_jobman ('run',matlabbatch);
            
            copyfile ([imgFolder '/spmoutput/wc1' imgFileName '.nii'],[imgFolder '/segmentation/GM/' ID '_GM_DARTEL.nii']);
            copyfile ([imgFolder '/spmoutput/wc2' imgFileName '.nii'],[imgFolder '/segmentation/WM/' ID '_WM_DARTEL.nii']);
            copyfile ([imgFolder '/spmoutput/wc3' imgFileName '.nii'],[imgFolder '/segmentation/CSF/' ID '_CSF_DARTEL.nii']);
        end
    end
 