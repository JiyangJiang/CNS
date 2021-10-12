#!/bin/bash

UD_nii=$1
MT_nii=$2

# similarity index (SI)
fslmaths $UD_nii -mul $MT_nii UDandMT
fslmaths $UD_nii -add $MT_nii -bin UDorMT
si=$((2*$(fslstats UDandMT -V | awk '{print $1}')/$(fslstats UDorMT -V | awk '{print $1}')))