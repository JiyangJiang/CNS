#!/bin/bash

UD_nii=$1
MT_nii=$2
FLAIRbrain_nii=$3

# UD_nii=70118044_WMH.nii.gz
# MT_nii=70118044_WMH_Jmod.nii.gz
# FLAIRbrain_nii=nonBrainRemoved_wr70118044_FLAIR.nii.gz

fslmaths $UD_nii -mul $MT_nii UDandMT
fslmaths $MT_nii -sub $UD_nii -thr 1 -bin FN

ud_and_mt=$(fslstats UDandMT -V | awk '{print $1}')
ud=$(fslstats $UD_nii -V | awk '{print $1}')
mt=$(fslstats $MT_nii -V | awk '{print $1}')
all=$(fslstats $FLAIRbrain_nii -V | awk '{print $1}')
fn=$(fslstats FN -V | awk '{print $1}')
id=$(basename $UD_nii | cut -d_ -f1)



si=$(bc -l <<< "2*$ud_and_mt/($ud+$mt)")  # similarity index (SI)

tpr=$(bc -l <<< "$ud_and_mt/$mt")  # true positive ratio (TPR)

fpr=$(bc -l <<< "($ud-$ud_and_mt)/$mt")  # false positive ratio (FPR)

specificity=$(bc -l <<< "1-($ud-$ud_and_mt)/($all-$mt)")  # specificity

accuracy=$(bc -l <<< "(2*$ud_and_mt+$all-$mt-$ud)/$all")  # accuracy

fnr=$(bc -l <<< "$fn/$mt") # false negative rate (FNR)

echo "$id,$si,$tpr,$fpr,$specificity,$accuracy,$fnr"

# extract group-level results
#
# while read i;do performance_metrics.sh ${i}_WMH.nii.gz ${i}_WMH_Jmod.nii.gz nonBrainRemoved_wr${i}_FLAIR.nii.gz;done < manLab.list > performance_metrics.csv