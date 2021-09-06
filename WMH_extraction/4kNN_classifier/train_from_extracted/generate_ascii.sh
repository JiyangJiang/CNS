#!/bin/bash

subjDIR=$1
id=$2

for s in seg0 seg1 seg2
do
	fslmaths ${subjDIR}/${id}/mri/extractedWMH/temp/${id}_${s} \
			 -mas ${subjDIR}/${id}/mri/extractedWMH/${id}_WMH \
			 ${subjDIR}/${id}/mri/extractedWMH/temp/${id}_${s}_WMHmasked

	fsl2ascii ${subjDIR}/${id}/mri/extractedWMH/temp/${id}_${s}_WMHmasked \
			  ${subjDIR}/${id}/mri/extractedWMH/temp/${id}_${s}_WMHmasked_ascii
done