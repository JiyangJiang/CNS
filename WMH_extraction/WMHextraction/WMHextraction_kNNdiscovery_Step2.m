

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% WMHextraction_kNNdiscovery_Step2: kNN calculation %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function WMHextraction_kNNdiscovery_Step2 (k, ID, CNSP_path, studyFolder, classifier, dartelTemplate, ageRange, probThr, trainingFeatures1, trainingFeatures2, varargin)

switch classifier
    case 'built-in'
        feature4training = strcat (CNSP_path, '/WMH_extraction/4kNN_classifier/feature_forTraining.txt');
        decision4training = strcat (CNSP_path, '/WMH_extraction/4kNN_classifier/decision_forTraining.txt');
    case 'customised'
        feature4training = [studyFolder '/customiseClassifier/textfiles/feature_forTraining.txt'];
        decision4training = [studyFolder '/customiseClassifier/textfiles/decision_forTraining.txt'];
end

if exist (decision4training, 'file') == 2
    if exist (feature4training, 'file') == 2
        
        %% generate features for prediction
        if nargin == 10
            generateFeatures_forPrediction (ID, [studyFolder '/subjects'], CNSP_path, dartelTemplate, ageRange);
        elseif (nargin >= 11) && strcmp(varargin{1},'noGenF')
            % no need to generate features
        elseif (nargin >= 11) && ~strcmp(varargin{1},'noGenF')
            generateFeatures_forPrediction (ID, [studyFolder '/subjects'], CNSP_path, dartelTemplate, ageRange);
        end


        %% build kNN model
        if (nargin == 10) || ((nargin == 11) && strcmp(varargin{1},'noGenF'))
            int_kNN_mdl = build_kNN_classifier (k,feature4training, decision4training, trainingFeatures1);
        elseif nargin > 11 && strcmp(varargin{1},'noGenF')
            int_kNN_mdl = build_kNN_classifier (k,feature4training, decision4training, trainingFeatures1, varargin{2:end});
        elseif nargin > 10 && ~strcmp(varargin{1},'noGenF')
            int_kNN_mdl = build_kNN_classifier (k,feature4training, decision4training, trainingFeatures1, varargin{:});
        end

        
        %% examine the quality of the kNN model
        rloss = resubLoss(int_kNN_mdl); % Examine the resubstitution loss, which, by default, is the fraction of misclassifications from the predictions of Mdl.
        CVMdl = crossval(int_kNN_mdl); % Construct a cross-validated classifier from the model.
        kloss = kfoldLoss(CVMdl); % Examine the cross-validation loss, which is the average loss of each cross-validation model when predicting on data that is not used for training.
        
        fprintf('UBO Detector: resubstitution loss of the kNN model is %1.4f\n',rloss);
        fprintf('UBO Detector: cross-validation loss of the kNN model is %1.4f\n',kloss);

        %% predict
        predictionTBL_path = [studyFolder '/subjects/' ID '/mri/extractedWMH/temp/' ID '_feature_4prediction.txt'];
        predictionTBL = importdata(predictionTBL_path, ' ');
%         [label, score, cost] = predict (kNN_mdl, predictionTBL);
        [label, score, cost] = predict (int_kNN_mdl, predictionTBL(:,trainingFeatures1));
        

        %% saved seg012 clusters with label ID
        seg0_lablID_struct = load_nii ([studyFolder '/subjects/' ID '/mri/extractedWMH/temp/' ID '_seg0.nii']);
        seg1_lablID_struct = load_nii ([studyFolder '/subjects/' ID '/mri/extractedWMH/temp/' ID '_seg1.nii']);
        seg2_lablID_struct = load_nii ([studyFolder '/subjects/' ID '/mri/extractedWMH/temp/' ID '_seg2.nii']);
        
        seg0_lablID = seg0_lablID_struct.img;
        seg1_lablID = seg1_lablID_struct.img;
        seg2_lablID = seg2_lablID_struct.img;
        
        clear seg0_lablID_struct;
        clear seg1_lablID_struct;
        clear seg2_lablID_struct;
        
        seg0_max = max(max(max(seg0_lablID)));
        seg1_max = max(max(max(seg1_lablID)));
        seg2_max = max(max(max(seg2_lablID)));
        
        seg012_max = cat (2, seg0_max, seg1_max, seg2_max);
        seg012_combined4D = cat (4, seg0_lablID, seg1_lablID, seg2_lablID);
        
        clear seg0_lablID;
        clear seg1_lablID;
        clear seg2_lablID;
        
        
%         seg012_combined4D_label = seg012_combined4D; % duplicate for assigning different values
        seg012_combined4D_score = seg012_combined4D;
        
        clear seg012_combined4D;
                       
                        
        %% probability map
        fprintf (['UBO Detector: generating WMH score map (i.e. WMH probability map) for ' ID ' ...\n']);
        score_cell {1} = score (1:seg0_max,2);
        score_cell {2} = score ((seg0_max+1):(seg0_max+seg1_max),2);
        score_cell {3} = score ((seg0_max+seg1_max+1):(seg0_max+seg1_max+seg2_max),2);
        
        for p = 1:3
            for m = 1:seg012_max(1,p)
                [r,c,v] = ind2sub(size(seg012_combined4D_score(:,:,:,p)),find(seg012_combined4D_score(:,:,:,p) == m)); % find index in 3D array
                [r_Nrow,~] = size(r);
               
                for q = 1: r_Nrow
                    seg012_combined4D_score(r(q),c(q),v(q),p) = score_cell{p}(m);
                end
            end
        end     
        
        seg012_score_img = seg012_combined4D_score(:,:,:,1) + seg012_combined4D_score(:,:,:,2) + seg012_combined4D_score(:,:,:,3);
        save_nii(make_nii (seg012_score_img), [studyFolder '/subjects/' ID '/mri/extractedWMH/' ID '_WMH_ProbMap.nii']);
        
        clear seg012_combined4D_score;
        
        %% thresholded probability map
        fprintf (['UBO Detector: generating WMH map with probability threshold applied (probability threshold = ' num2str(probThr) ') for ' ID ' ...\n']);
        thresholded_probMap = seg012_score_img;
        
        clear seg012_score_img;
        
        thresholded_probMap (thresholded_probMap <= probThr) = 0;
        thresholded_probMap (thresholded_probMap > probThr) = 1;
        probThr = sprintf ('%1.2f', probThr); % two decimals
        probThr_parts = strsplit (probThr, '.');
        save_nii (make_nii (thresholded_probMap), [studyFolder '/subjects/' ID '/mri/extractedWMH/' ID '_WMH_Prob' probThr_parts{1} '_' probThr_parts{2} '.nii']);
        


        clear thresholded_probMap;          
        
        
    else
        fprintf ('%s\n', 'ERROR: no feature_forTraining.txt');
    end
else
    fprintf ('%s\n', 'ERROR: no decision_forTraining.txt');
end


    
    
    
    
    