#!/bin/bash

# This is the main command to perform 'train from extracted (TFE)'

subjDIR=$1
id=$2

# subjDIR='/data4/jiyang/temp2'
# id='1239362'

TFEdir=dirname $(which $0)
export PATH=$TFEdir:$PATH

set -x

# generate ascii from WMH-masked index maps
generate_ascii.sh $subjDIR $id

# generate files with decisions
matlab -nodisplay -nosplash -nodesktop -r \
		"addpath('${TFEdir}');\
		 generate_decision('${subjDIR}','${id}');\
		 exit"

# merge LUT, decision, feature
merge_LUT_decision_feature.sh $subjDIR $id

set +x

echo "TFE done - $id"