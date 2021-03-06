#!/bin/bash

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

#Estimation of secure parameter against primal-uSVP using lwe-estimator HEAD
#These parameters are stored in xml files stored in the directory storeParam
#The filename is determined by input parameters : <multiplicative depth>, <BKZ reduction model cost>, <minimal security>, <generation method>

MULT_DEPTH=$1
REQUIRED_SECU=$2
COST_MODEL=$3
GEN_METHOD=$4 
DIR_NAME=$5

FILE_NAME="../storeParam/$DIR_NAME/${MULT_DEPTH}_${COST_MODEL}_${REQUIRED_SECU}_${GEN_METHOD}"
sage ../generateParam/genParam.sage --output_xml "${FILE_NAME}" --mult_depth  "$MULT_DEPTH"  --lambda_p "$REQUIRED_SECU" --model "$COST_MODEL"  --gen_method "$GEN_METHOD"

