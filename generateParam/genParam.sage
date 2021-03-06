# -*- coding: utf-8 -*-
#
#    (C) Copyright 2017 CEA LIST. All Rights Reserved.
#    Contributor(s): Cingulata team (formerly Armadillo team)
#
#    This software is governed by the CeCILL-C license under French law and
#    abiding by the rules of distribution of free software.  You can  use,
#    modify and/ or redistribute the software under the terms of the CeCILL-C
#    license as circulated by CEA, CNRS and INRIA at the following URL
#    "http://www.cecill.info".
#
#    As a counterpart to the access to the source code and  rights to copy,
#    modify and redistribute granted by the license, users are provided only
#    with a limited warranty  and the software's author,  the holder of the
#    economic rights,  and the successive licensors  have only  limited
#    liability.
#
#    The fact that you are presently reading this means that you have had
#    knowledge of the CeCILL-C license and that you accept its terms.
#

  
"""@package genParam

[Disclaimer]
This script generates parameters for the Fan-Vercauteren cryptosystem following our variant of an algorithm described in G. Bonnoron PhD Thesis (algorithm 5.9, page 76). It employs HEAD commit of lwe-estimator (https://bitbucket.org/malb/lwe-estimator) . It is provided on an AS IS basis. If you need up-to-date security levels you should consider more recent complexity estimates for known attacks on RLWE.

[Short description]
This script is used to generate parameters for Fan-Vercauteren (FV for short) leveled homomorphic encryption following lwe-estimator (https://bitbucket.org/malb/lwe-estimator).

[First use] 
To use this script properly, type:
sage genParam.sage -h

This command describes input parameters and how to use them. It also gives default parameters

[Toy example] 
To use this script with default values, type:
sage genParam.sage

[Input/Output]
Input parameters are displayed on the standard output.
Generated parameters describes probability distributions and indicates moduli bitsize.
Output is a xml file in which generated parameters and input parameters are written.

[Additional info]
The script define two parameters sets. 
The first parameter set is used during key generation, encryption.
The second one is used during relinearisation (version 2).

Sources (chronological order): 

        [LP11] LINDNER, Richard et PEIKERT, Chris. Better key sizes (and attacks) for LWE-based encryption. In : Cryptographers’ Track at the RSA Conference. Springer, Berlin, Heidelberg, 2011. p. 319-339.

        [FV12] Fan, Junfeng, and Frederik Vercauteren. "Somewhat Practical Fully Homomorphic Encryption." IACR Cryptology ePrint Archive 2012 (2012): 144.
        URL: https://eprint.iacr.org/2012/144.pdf

        [APS15] Martin R. Albrecht, Rachel Player and Sam Scott. On the concrete hardness of Learning with Errors.
        Journal of Mathematical Cryptology. Volume 9, Issue 3, Pages 169–203, ISSN (Online) 1862-2984,
        ISSN (Print) 1862-2976 DOI: 10.1515/jmc-2015-0016, October 2015

        [P16] PEIKERT, Chris. How (not) to instantiate ring-lwe. In : International Conference on Security and Cryptography for Networks. Springer, Cham, 2016. p. 411-430.

        [B18] G Bonnoron A journey towards practical Fully Homomorphic Encryption (PhD thesis, 2018)

        [AC+18] Martin R. Albrecht and Benjamin R. Curtis and Amit Deo and Alex Davidson and Rachel Player and Eamonn W. Postlethwaite and Fernando Virdia and Thomas Wunderer
        Estimate all the {LWE, NTRU} schemes!


\author CEA-List, Embedded Real-Time System foundations Lab (DACLE/LaSTRE)
"""


load('https://bitbucket.org/malb/lwe-estimator/raw/HEAD/estimator.py')

import sys
import os
import argparse
import mpmath as mpm
from mpmath import mpf
from xml.dom import minidom
import numpy as np


#######
# Read config file with name=value pairs, ConfigParse module

class _Parameters:
        def __init__(self):
                None
    
        def __getitem__(self, key):
                return self.__dict__[key]

        def updateParams(self, params_dict):
                self.__dict__.update(params_dict)

        def _parse_param(self, xmldoc, paramName):
                a = xmldoc.getElementsByTagName(paramName)
                if len(a) > 0:
                        self.__dict__[paramName] = float(a[0].firstChild.data)
      
        def parseXml(self, xmlStr):
                xmldoc = minidom.parseString(xmlStr)
                for key in self._params_defaults.keys():
                        self._parse_param(xmldoc, key)
    
        def write(self):
                print ("FHE scheme parameters:")
                for key,val in self.__dict__.items():
                        print ('\t{0}: {1}'.format(key, val))

class _ParametersGenerator:
        def __init__(self, params):
                self._eps_exp = params['eps_exp'] # Exponent of adversary's advantage (i.e. success probability) in distinguishing attack on decision-LWE described in [LP11].
                self._h = params['sk_hamm'] # Hamming weight of the secret key
                self._lambda_p = params['lambda_p'] # Security level
                # Estimated security _lambda_p is greater than desired/minimal/required security level given in CLI.   
                self.t = params['pt_base'] # Maximum plaintext coefficient
                self.L = params['mult_depth'] # Circuit multiplicative depth
                self.k = params['relin_k']
                self.cyclotomic_poly_index = params['cyclotomic_poly_index']  # Is equal to 2*n where n is the polynomial degree, a power of two.
                self.poly_degree_log2 = int(np.log2(self.cyclotomic_poly_index)) - 1 
                self.omega=params['omega']
                self.word_size=params['word_size']
                self.model=params['model']
                self.gen_method=params['gen_method']

                mpm.mp.prec = 128
                self.comp_init_params()


        def write_all(self):
                print ("FHE scheme parameters:")
                for key,val in self.__dict__.items():
                        print ('\t{0}: {1}'.format(key, val))

        def write(self):
                print colors.YELLOW + "Attack cost computed with lwe-estimator \nHEAD commit ID =",os.popen("git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7").read().rstrip('\n') + colors.DEFAULT  
                order = ['model', '_lambda_p', 'L','n', 'log2_q' , 'sigma', 'nb_64_bit_words_q'] #'sigma_k','log2_sigma_k','nb_lwe_estimator_calls'
                for flag in order:
                        for key,val in self.__dict__.items():
                                if (flag == key):        
                                        if (key in ['model','nb_64_bit_words_q','_lambda_p','L','sigma','log2_q']): #'sigma_k','log2_sigma_k','nb_lwe_estimator_calls'
                                                print ('\t{0} = {1}'.format(Describe(key), val))  
                                        elif (key in ['n','L']):
                                                print ('\t{0} = {1}'.format(key, val))
        
        def comp_init_params(self):
                self._alfa = self._comp_alfa(self._eps_exp)
                self._beta = self._comp_beta(self._eps_exp)

        def _round_up(self, a, dps):
                m = mpm.power(10, dps)
                return mpm.ceil(a * m) / m

        def _comp_alfa(self, eps_exp):
                eps = mpm.power(2, eps_exp)
                alfa = mpm.sqrt(mpm.ln(1 / eps) / mpm.pi)
                alfa = self._round_up(alfa, 3)
                return alfa

        def _comp_beta(self, eps_exp):
                eps = mpm.power(2, eps_exp)
                beta = mpm.erfinv(1-eps) * mpm.sqrt(2)
                return beta

        def _comp_error_bound(self, beta, sigma):
                return mpm.ceil(beta * sigma)

        def _comp_sigma_k(self, sigma, q, k):
                sigma_k = mpm.power(self._alfa, 1-mpm.sqrt(k))
                sigma_k *= mpm.power(q, k-mpm.sqrt(k))
                sigma_k *= mpm.power(sigma, mpm.sqrt(k))
                sigma_k = mpm.ceil(sigma_k)
                return sigma_k

        def __getitem__(self, key):
                return self.__dict__[key]
    
        def comp_params(self): 
                n=int(2 * 2 ** self.poly_degree_log2) # ciphertext polynomial degree
                min_security_level=self._lambda_p
                mult_depth=self.L
                #time param_set=ChooseParam(n,min_security_level,mult_depth,model=self.model,omega=self.omega,word_size=self.word_size,gen_method=self.gen_method) 
                param_set=ChooseParam(n,min_security_level,mult_depth,model=self.model,omega=self.omega,word_size=self.word_size,gen_method=self.gen_method) 

                self.n=param_set[0]
                self.poly_degree_log2 = int(np.log2(param_set[0]))
                self.cyclotomic_poly_index = param_set[0]*2
                self._lambda_p=param_set[1][0]   
                self.log2_q= param_set[1][1]
                self.nb_lwe_estimator_calls=param_set[2]
                self.nb_64_bit_words_q= param_set[3]*64/self.word_size
                self.q=param_set[4]
                self.sigma=mpf(2*sqrt(self.n)/sqrt(2*pi)) #error/noise standard deviation = width/sqrt(2*pi)            width aka Gaussian width parameter
                self.error_bound = self._comp_error_bound(self._beta, self.sigma)
                self._comp_relin_v2_params()
                self.alpha=param_set[5]


        def out_mpf_C_str(self, mpf):
                prec = int(mpm.nstr(mpf, 0).split('e')[-1]) + 1
                mpf_str = mpm.nstr(mpf, prec)
                mpf_int_str = mpf_str.split('.')[0]

                r = range(0, len(mpf_int_str), 76) + [len(mpf_int_str)]
                res = '  "'

                for i in xrange(0, len(mpf_int_str), 76):
                        res += mpf_int_str[i:(i+76)]
                        if i+78 < len(mpf_int_str):
                                res += '\\\n  '
                res += '"'
                return res

        def _comp_relin_v2_params(self):
                self.log2_p = int(self.log2_q) * (self.k-1)
                self.log2_pq = int(self.log2_q) * self.k
                q=mpm.power(2,self.log2_q)
                self.sigma_k = mpf(self._comp_sigma_k(self.sigma, q, self.k))
                self.log2_sigma_k=ceil(log(self.sigma_k)/log(2))
                self.B_k = self._comp_error_bound(self._beta, self.sigma_k)
    
    

        def substitute_params(self, tempStr):
                tempStr = tempStr.replace("@FHE_PARAM_T@", "{0}".format(int(self.t)))
                tempStr = tempStr.replace("@FHE_PARAM_SIZE_T@", "{0}".format(int(self.size_t)))
                tempStr = tempStr.replace("@FHE_PARAM_LOG2_Q@", "{0}".format(int(self.log2_q)))
                tempStr = tempStr.replace("@FHE_PARAM_LOG2_P@", "{0}".format(int(self.log2_p)))
                tempStr = tempStr.replace("@FHE_PARAM_LOG2_PQ@", "{0}".format(int(self.log2_pq)))
                tempStr = tempStr.replace("@FHE_PARAM_LOG2_D@", "{0}".format(int(self.poly_degree_log2)))
                tempStr = tempStr.replace("@FHE_PARAM_D@", "{0}".format(int(2 ** self.poly_degree_log2)))
                tempStr = tempStr.replace("@FHE_PARAM_SIGMA_STR@", "{0}".format(self.out_mpf_C_str(self.sigma)))
                tempStr = tempStr.replace("@FHE_PARAM_B_STR@", "{0}".format(self.out_mpf_C_str(self.error_bound)))
                tempStr = tempStr.replace("@FHE_PARAM_SIGMA_K_STR@", "{0}".format(self.out_mpf_C_str(self.sigma_k)))
                tempStr = tempStr.replace("@FHE_PARAM_B_K_STR@", "{0}".format(self.out_mpf_C_str(self.B_k)))
                tempStr = tempStr.replace("@FHE_PARAM_SK_H@", "{0}".format(int(self._h)))
                tempStr = tempStr.replace("@FHE_PARAM_L@", "{0}".format(int(self.L)))

                return tempStr


        def mpf2str(self, mpf):
                prec = int(mpm.nstr(mpf, 0).split('e')[-1]) + 1
                mpf_str = mpm.nstr(mpf, prec)
                mpf_int_str = mpf_str.split('.')[0]
                return mpf_int_str


        def createPolynomialRingNode(self, doc):
                def createCoeffNode(doc, value, degree):
                        coeff = doc.createElement("coeff")

                        v = doc.createElement("value")
                        v.appendChild(doc.createTextNode(str(int(value))))
                          
                        d = doc.createElement("degree")
                        d.appendChild(doc.createTextNode(str(int(degree))))

                        coeff.appendChild(v)
                        coeff.appendChild(d)

                        return coeff

                def createPolyNode(doc, poly):
                        cfs = doc.createElement("coeffs")
                        for degree, coeff in poly.dict().items():
                                cfs.appendChild(createCoeffNode(doc, coeff, degree))
                        return cfs    

                def createFactorsNode(doc, poly_factors):
                        fsn = doc.createElement("factors")
              
                        for order in xrange(len(poly_factors)):        
                                factor, exponent = poly_factors[order]
                                assert(exponent == 1)

                                fn = doc.createElement("factor")

                                #fn.setAttribute("order", str(order))
                                on = doc.createElement("order")
                                on.appendChild(doc.createTextNode(str(order)))
                                fn.appendChild(on)       

                                #fn.setAttribute("exponent", str(exponent))
                                on = doc.createElement("exponent")
                                on.appendChild(doc.createTextNode(str(exponent)))
                                fn.appendChild(on)       

                                fn.appendChild(createPolyNode(doc, factor))

                                fsn.appendChild(fn)
                        return fsn
    
                pr = doc.createElement("polynomial_ring")
                mp = doc.createElement("cyclotomic_polynomial")

                #write cyclotomic polynomial index
                on = doc.createElement("index")
                on.appendChild(doc.createTextNode(str(int(2 * 2 ** self.poly_degree_log2))))
                mp.appendChild(on)

                pr.appendChild(mp)

                return pr

        def createPlaintextNode(self, doc):
                pt = doc.createElement("plaintext")
                cm = doc.createElement("coeff_modulo")

                cm.appendChild(doc.createTextNode(str(int(self.t))))
                pt.appendChild(cm)

                return pt

        def createNormalDistributionNode(self, doc, sigma, bound):
                nd = doc.createElement("normal_distribution")

                sn = doc.createElement("sigma")
                nd.appendChild(sn)

                sn.appendChild(doc.createTextNode(sigma))    

                bn = doc.createElement("bound")
                nd.appendChild(bn)

                bn.appendChild(doc.createTextNode(bound))    

                return nd
  
        def createCiphertextNode(self, doc):
                ct = doc.createElement("ciphertext")
                cm = doc.createElement("coeff_modulo_log2")
                ct.appendChild(cm)

                cm.appendChild(doc.createTextNode(str(int(self.log2_q))))

                ct.appendChild(self.createNormalDistributionNode(doc, self.mpf2str(self.sigma), self.mpf2str(self.error_bound)))

                return ct
  
        def createLinearizationNode(self, doc):
                ln = doc.createElement("linearization")

                #write linearization version
                n = doc.createElement("version")
                ln.appendChild(n)

                n.appendChild(doc.createTextNode("2"))

                #write linearization coefficient modulo
                n = doc.createElement("coeff_modulo_log2")
                ln.appendChild(n)

                n.appendChild(doc.createTextNode(str(int(self.log2_p))))

                #write linearization normal distribution
                ln.appendChild(self.createNormalDistributionNode(doc, self.mpf2str(self.sigma_k), self.mpf2str(self.B_k)))

                return ln

        def createSecretKeyNode(self, doc):
                skn = doc.createElement("secret_key")

                n = doc.createElement("hamming_weight")
                skn.appendChild(n)

                n.appendChild(doc.createTextNode(str(int(self._h))))

                return skn
    
        def createExtraNode(self,doc):
                en =  doc.createElement("extra") 

                n = doc.createElement("estimated_secu_level")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self._lambda_p))))

                n = doc.createElement("n")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self.n))))                
                
                n = doc.createElement("alpha")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(self.alpha)))

                n = doc.createElement("q")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self.q))))

                n = doc.createElement("gen_method")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(self.gen_method))

                n = doc.createElement("bkz_reduction_cost_model")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(eval(self.model).__name__))
                return en      
      
      
        def getXml(self):
                doc = minidom.Document()

                params = doc.createElement("fhe_params")

                params.appendChild(self.createPolynomialRingNode(doc))
                params.appendChild(self.createPlaintextNode(doc))    
                params.appendChild(self.createCiphertextNode(doc))    
                params.appendChild(self.createLinearizationNode(doc))    
                params.appendChild(self.createSecretKeyNode(doc))    
                params.appendChild(self.createExtraNode(doc))

                doc.appendChild(params)    

                return doc

class colors:
        MAGENTA = '\033[95m'
        BLUE = '\033[94m'
        GREEN = '\033[92m'
        YELLOW = '\033[93m'
        RED = '\033[91m'
        DEFAULT = '\033[0m'


                                                                                                                              


# To decrease computation time to generate parameters we use lower bound on bitsize of q given in [B18,p. 76]. 
# There is only values for mult depth multiple of 5.
# Values in dictionary should be updated when we change parameter set following a new attack.   
def lb_log2_q(mult_depth,omega=32):
        x= range(20)
        cases = map(lambda  mult_depth : int(mult_depth/5),x)
        # cases = {mult_depth: int(mult_depth/5) for mult_depth in range(20)}
        if (omega == 32):
                return {
                0:54,
                1:159,
                2:303,                   
                3:454,
                4:611,
                        }.get(tuple(cases), 54)   # default value
        elif (omega ==64):
                return {
                0:87,
                1:193,
                2:337,
                3:489,
                4:645,
                        }.get(tuple(cases), 54)   # default value
        else: 
                raise NotImplementedError      

def MinModulus(n,error_gwp, mult_depth=10,cryptosystem="FV",is_binary_secret="True",omega=32,word_size=64,gen_method="bitsizeinc"):  
#omega: basis during gadget decomposition, bigger relinearisation key but smaller error growth with omega = 32 rather than 64 
#print ("mult_depth=",mult_depth)
#print ("lb_log2_q(mult_depth,omega)",lb_log2_q(mult_depth,omega))
        q_min=2**(lb_log2_q(mult_depth,omega)-1)   
        first_pass = True
                                                                                                               
        if (is_binary_secret):
                t=2
                B_key=1
        else:
                raise NotImplementedError
        
        if (gen_method=="bitsizeinc"):  
                scale_factor=2
        elif (gen_method=="wordsizeinc"): 
                basis=2**word_size       
                scale_factor=basis
        else:
                raise NotImplementedError   
                     
        while first_pass or  (left_member>=right_member):
                first_pass = False      
                q_min=q_min*scale_factor
                Delta=floor(q_min/t)
                l=ceil(log(q_min)/log(omega), bits=1000)
                B_error=10*error_gwp                                                               
                B_0=B_error*(1+2*n*B_key)
                C=2*n*(4+n*B_key) 
                D=n^2*B_key*(B_key+4)+n*omega*l*B_error
                left_member= C^mult_depth*B_0+mult_depth*C^(mult_depth-1)*D
                right_member=(Delta*(1+t)-q_min)/2
          
        return q_min
    



# selection of BKZ (lattice reduction) cost model 
bkz_enum = BKZ.enum    #https://bitbucket.org/malb/lwe-estimator.git   In April 2018, BKZ.enum is reduction_default_cost in lwe-estimator.
bkz_sieve=BKZ.sieve 
core_sieve =  lambda beta, d, B: ZZ(2)**RR(0.292*beta)   #https://estimate-all-the-lwe-ntru-schemes.github.io/docs/        aka BKZ.ADPS16, mode="classical"
q_core_sieve =  lambda beta, d, B: ZZ(2)**RR(0.265*beta) #https://estimate-all-the-lwe-ntru-schemes.github.io/docs/        aka BKZ.ADPS16, mode="quantum"
bkz_enum.__name__="BKZ.enum"
bkz_sieve.__name__="BKZ.sieve"
core_sieve.__name__="lambda beta, d, B: ZZ(2)**RR(0.292*beta)"
q_core_sieve.__name__="lambda beta, d, B: ZZ(2)**RR(0.265*beta)"
# beta: block size, d: LWE dimension, B: bit-size of entries        


# variant of Algorithm 5.9 in [B18] where n is an input param, n has to be not too small for lwe-estimator, n is a power of two 
                                                                   
def ChooseParam(n,min_security_level,mult_depth=10,cryptosystem="FV",model=core_sieve,omega=32,word_size=64,gen_method="bitsizeinc"):
        first_pass=True
        nb_pass=1
        max_security_level=64*ceil(min_security_level/64)
        while first_pass or (estimated_security_level< min_security_level):
                first_pass = False
                nb_pass+=1    
                error_gwp=RR(2*sqrt(n))                                  # Regev reduction, see [P16,pages 3,18]  
                error_sd=RR(error_gwp/sqrt(2*pi))
                q=MinModulus(n,error_gwp,mult_depth,cryptosystem,"True",omega,word_size,gen_method)  #for fixed n, log2_q is minimized
                noise_rate = error_gwp/RR(q) #noise rate, denoted alpha in literature
                estimated_security_level=SecurityLevel(n,noise_rate,q,current_model=model)
                n=2*n
        return n/2,(estimated_security_level,floor(log(q)/log(2), bits=1000)),nb_pass,floor(log(q)/log(2**word_size), bits=1000),q, noise_rate 

  

def Describe(x):
        return {
                bkz_enum:    "BKZ.enum",
                bkz_sieve:   "BKZ.sieve",
                core_sieve:  "Core-Sieve",    # aka BKZ.ADPS16, classical mode
                q_core_sieve:"Q-Core-Sieve",  # aka BKZ.ADPS16, quantum mode   
                '_lambda_p':"security level",
                'L':"multiplicative depth",
                'sigma':"noise SD", 
                'sigma_k':"relin. v2 SD",
                'log2_sigma_k':"log_2(relin. v2 SD)", 
                'model':"BKZ cost model", 
                'log2_q':"log_2(q)",  
                'nb_lwe_estimator_calls':"# security estimations",
                'nb_64_bit_words_q':"# 64-bit words(q)",
        }.get(x, "42")   # default value


def SecurityLevel(n,alpha,q,current_model):
        ring_operations=primal_usvp(n, alpha, q, secret_distribution=secret_distribution, m=n, success_probability=success_probability, reduction_cost_model=eval(current_model))["rop"] 
        security_level= floor(log(ring_operations)/log(2))
        return security_level    

#######
# Parse command line arguments
parser = argparse.ArgumentParser(
        description='Generate parameters (XML file) for FV homomorphic encryption scheme',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        argument_default=argparse.SUPPRESS)

groupFile = parser.add_argument_group("configuration file input")
groupFile.add_argument('-c', '--config_file', help='Configuration file (XML)', type=argparse.FileType('r'))

groupArgs = parser.add_argument_group("command line input", "has priority over configuration file")
groupArgs.add_argument('--sk_hamm', help='Secret key hamming weight', default = 63, type = int)
groupArgs.add_argument('--lambda_p', help='Security level', default = 128, type = int)
groupArgs.add_argument('--pt_base', help='Plaintext base', default = 2, type = int)
groupArgs.add_argument('--mult_depth', help='Multiplicative depth', default = 5, type = int)
groupArgs.add_argument('--relin_k', help='Parameter k for the relinearization', default = 4, type = int, choices=[4,5])
groupArgs.add_argument('--eps_exp', help='Epsilon exponent', default = -64, type = int)
groupArgs.add_argument('--omega', help='Basis during gadget decomposition', default = 32, type = int)
groupArgs.add_argument('--word_size', help='Machine word size', default = 64, type = int)
groupArgs.add_argument('--model',help='BKZ cost model',default="bkz_sieve", type=str)
groupArgs.add_argument('--gen_method',help='Method to generate secure parameters',default="bitsizeinc", type=str) # values in ["wordsizeinc","bitsizeinc"]. Impacts time to estimate secure param and time to execute homomorphic computation. 


groupPoly = parser.add_argument_group("polynomial ring quotient", "cyclotomic polynomial Phi_m(x) parameters, for the moment only m=2^n polynomials are supported")
groupPoly.add_argument('--cyclotomic_poly_index', help='Cyclotomic polynomial index, m', default = 4096, type = int)

groupOut = parser.add_argument_group("output")
groupOut.add_argument('--output_xml', help='Output parameters file', default = "fhe_params.xml", type=str)

try:
        values = parser.parse_args(sys.argv[1:])
except IOError as msg:
        parser.error(str(msg))

#Build parameters object
params = _Parameters()
if 'config_file' in values:
        params.parseXml(values.config_file.readlines())
params.updateParams(values.__dict__)
                           

#Generate homomorphic encryption scheme parameters
paramsGen = _ParametersGenerator(params)
secret_distribution = ((0,1),paramsGen._h)
success_probability = 0.99  # for the primal uSVP attack  

param_set=paramsGen.comp_params()

paramsGen.write()
xmlStr = paramsGen.getXml().toprettyxml()


f = open(params.output_xml, "w")
f.write(xmlStr)
f.close()





