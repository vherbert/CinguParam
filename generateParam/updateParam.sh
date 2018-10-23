
    #(C) Copyright 2018 CEA LIST. All Rights Reserved.
    #Contributor(s): Cingulata team (formerly Armadillo team)
 
    #This software is governed by the CeCILL-C license under French law and
    #abiding by the rules of distribution of free software.  You can  use,
    #modify and/ or redistribute the software under the terms of the CeCILL-C
    #license as circulated by CEA, CNRS and INRIA at the following URL
    #"http://www.cecill.info".
 
    #As a counterpart to the access to the source code and  rights to copy,
    #modify and redistribute granted by the license, users are provided only
    #with a limited warranty  and the software's author,  the holder of the
    #economic rights,  and the successive licensors  have only  limited
    #liability.
 
    #The fact that you are presently reading this means that you have had
    #knowledge of the CeCILL-C license and that you accept its terms.


# Goal: generate xml files containing parameter set when HEAD of lwe-estimator is updated.
# Usage : 
#DIR_NAME=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7)
#parallel  --header : --results ../storeParam/$DIR_NAME bash updateParam.sh {1} {2} {3} {4} $DIR_NAME ::: mult_depth $(seq 20) ::: min_secu 80 128 192 ::: model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" ::: gen_method "wordsizeinc" "bitsizeinc"

#Estimation of secure parameter against primal-uSVP using lwe-estimator HEAD
#These parameters are stored in xml files stored in the directory storeParam
#The filename is determined by input parameters : <multiplicative depth>, <BKZ reduction model cost>, <minimal security>, <generation method>

MULT_DEPTH=$1
REQUIRED_SECU=$2
COST_MODEL=$3
GEN_METHOD=$4 
DIR_NAME=$5

PARAM_SET="../storeParam/$DIR_NAME/${MULT_DEPTH}_${COST_MODEL}_${REQUIRED_SECU}_${GEN_METHOD}"
sage ../generateParam/genParam.sage --output_xml ${PARAM_SET} --mult_depth  $MULT_DEPTH  --lambda_p $REQUIRED_SECU --model $COST_MODEL  --gen_method $GEN_METHOD 

#From now, we modify filename by replacing required minimal security by approximated security (80,128,192,256).
#It is preferable because a gap exist between required minimum security and estimated minimum security.
# estimated secu can be much greater than required minimal security.
# approximated_secu is the highest multiple of 64 lower than (estimated secu + 8)
# example : 128 is the minimum required, 203 is estimated with lwe-estimator, 192 is the approximation on estimated secu in xml filename
# approximation 64 for estimation in interval [56 120], 128 for [120 184], 192 for [184 248], 256 for [248 312]


TOLERANCE=8 # example: if the security estimation is 120 bits (resp. 119) and the tolerance is 8 bits, then our approximation is 128 bits (resp. 80).

cd ../storeParam/$DIR_NAME/
for file in *$REQUIRED_SECU*
do
        ESTIMATED_SECU=$(xmllint --xpath 'fhe_params/extra/estimated_secu_level/text()' $file)
        APPROXIMATED_SECU=$(((ESTIMATED_SECU+TOLERANCE)/64*64)) 
        echo $APPROXIMATED_SECU
        mv "$file" "${file/$REQUIRED_SECU/$APPROXIMATED_SECU}"
done


# to remove gen_method from xml filename
mmv -d \*_wordsizeinc "#1"
mmv -d \*_bitsizeinc "#1" # the flag -d serves to force overwrite. Indeed, we do not favour a generation method.

# to replace approximated secu 64 by 80 in filename when it is relevant
if [ $REQUIRED_SECU -ge 80 -a  $REQUIRED_SECU -lt $((128-TOLERANCE)) ]
then
        mmv -d \*_64 "#1_80"
fi

# to remove most unpractical parameter sets
rm -f  *320* *384* *448* *512* *576* *640* *704* *768*