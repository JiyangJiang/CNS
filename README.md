# CHeBA NiL Software (CNS)
This is the repository for CNS. The core of CNS is the pipeline for automated segmentation of WMH, UBO Detector. Below is the methodology paper published in Neuroimage:

*Jiyang Jiang, Tao Liu, Wanlin Zhu, Rebecca Koncz, Hao Liu, Teresa Lee, Perminder S. Sachdev, Wei Wen (2018). "UBO Detector - A cluster-based, fully automated pipeline for extracting white matter hyperintensities". Neuroimage 174:539-549*

Quick start manual can be found at https://cheba.unsw.edu.au/research-groups/neuroimaging/quick-start-manual, or by clicking <code>Manual -> CNS User Manual</code> in CNS GUI.

## Known issues
- Recent FSL versions (at least from 6.0.6.5) changed *cluster* command. This will lead to errors and the results of number of clusters being all zeros. A work-around is to replace ${FSLDIR} with /path/to/old/FSL in line 47 of /path/to/CNS/WMH_extraction/WMHextraction/WMHextraction_kNNdiscovery_Step3_5_Nol_count.sh, to force using *cluster* command in older FSL versions. FSL version 6.0.4 was tested.