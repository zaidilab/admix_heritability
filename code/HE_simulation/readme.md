## Estimating ${V}_g$ with HE Regression 
* Script: **mmhe.sh, mmhe2.py**
* Requirement: Python 4.4.0
* Usage: ```./mmhe.sh ${model} ${arch} ${t} ${P}```
* Example: To estimate the genetic variance of the complex trait in the admixed population at generation 10 simulated above using HE regression: ```./mmhe.sh HI pos 10 0.9```
* Output: Genetic variance and heritibility estimates for 3 types of GRM and with and without ancestry as a covariate.

* Script: **concat_mmhe.sh**
* Usage: ```./concat_mmhe.sh```
* Output: A combined file with genetic variance estimates with their SE's without ancestry, another file with ancestry, and a phenotype file. 
