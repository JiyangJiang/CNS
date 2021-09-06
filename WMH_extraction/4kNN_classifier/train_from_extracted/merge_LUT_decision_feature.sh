#!/bin/bash

subjDIR=$1
id=$2

lut=${subjDIR}/${id}/mri/extractedWMH/temp/${id}_clusterLookUp_4prediction.txt
feature=${subjDIR}/${id}/mri/extractedWMH/temp/${id}_feature_4prediction.txt

[ -f "${subjDIR}/${id}/mri/extractedWMH/temp/${id}_allSeg_decision.txt" ] && \
	rm -f ${subjDIR}/${id}/mri/extractedWMH/temp/${id}_allSeg_decision.txt
for i in seg0 seg1 seg2
do
	cat ${subjDIR}/${id}/mri/extractedWMH/temp/${id}_${i}_decision.txt >> \
		${subjDIR}/${id}/mri/extractedWMH/temp/${id}_allSeg_decision.txt
done

decision=${subjDIR}/${id}/mri/extractedWMH/temp/${id}_allSeg_decision.txt

paste ${lut} ${decision} ${feature} | sed 's/ /,/g' | sed 's/\t/,/g' > \
		${subjDIR}/${id}/mri/extractedWMH/temp/${id}_lut_decicion_feature.csv