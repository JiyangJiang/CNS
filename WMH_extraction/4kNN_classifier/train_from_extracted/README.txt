+++++++++++++++++++++++++++++++
README for train_from_extracted
+++++++++++++++++++++++++++++++

GENERAL COMMENTS
----------------

+ This should work for both native and standard space


AIM
---

+ To create a new training set from UBOD-processed WMH


METHODS
-------

+ (SHELL) call train_from_extracted.sh </path/to/subjects> <ID> </path/to/train_from_extracted>
		  This will run the following 3 commands:
		  
	+ (SHELL) generate_ascii.sh </path/to/subjects> <ID>
		
		- map UBOD-generated WMH mask to index maps (i.e. seg0-2 in temp folder).
		- convert these WMH-masked index maps to ascii text files

	+ (MATLAB) generate_decision ('</path/to/subjects>','<ID>')

		- create .../mri/extractedWMH/temp/<ID>_seg<0-2>_decision.txt, according
		  to the ascii text files

	+ (SHELL) merge_LUT_decision_feature.sh </path/to/subjects> <ID>

		- combine lookup table, decision, and feature into a single csv file.

+ Visualise WMH mask (ID/mri/extracted/ID_WMH.nii.gz) superimposing onto FLAIR (ID/mri/orig/ID_FLAIR.nii or
  ID/kNN_intermediateOutput/wrFLAIR), with seg0-2 index maps (ID/mri/extractedWMH/temp/ID_seg?.nii.gz), and 
  correct the csv file.