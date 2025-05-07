## Admix heritability data
Here are the summary data used for plotting in the manuscript.

1. ```admix_HI_vg_vgamma.txt``` and ```admix_CGF_vg_vgamma.txt```: expected and realized ancestry and genetic variance in theory and simulation.
 - Parameters
    - ```theta, gen, t, P, cov``` essential parameters in simulation: global ancestry, generation, time since admixture, strength of ancestry-based assortative mating, trait.
 - Expected values calculated using formula
    - ```exp.theta, exp.var.theta``` expected mean and variance in ancestry.
    - ```va.term1, va.term2, va.term3, va.term4``` expected values of 4 terms of genetic variance. 
    - ```exp.vg, exp.vgamma``` expected values of genetic variance due to genotype and due to local ancestry.
 - Realized values measured in simulation
    - ```mean.theta, var.theta``` realized mean and variance in ancestry.
    - ```vg.term1, vg.term2, vg.term3, vg.term4, vg.sum``` realized values of 4 terms of genetic variance and their sum.
    - ```var.prs.geno, var.prs.lanc``` realized genetic variance due to genotype and due to local ancestry.
2. ```admix_greml_vg_CI_P0_P9_w-woganc.txt```: genetic variance estimates with GREML for P = 0, 0.9 with and without ancestry.
3. ```admix_greml_vgamma_CI_P0_P9_w-woganc.txt```: local genetic variance estimates with GREML for P = 0, 0.9 with and without ancestry.
4. ```admix_greml_h2_CI_P0_P9_w-woganc.txt```: heritability estimates for P = 0, 0.9 with and without ancestry.
5. ```admix_HI_HE_wwoganc_vg_CI_grms.txt``` and ```admix_CGF_HE_wwoganc_vg_CI_grms.txt```: genetic variance estimates with HE regression for P=0, 0.9 with and without ancestry.
6. ```vpgCI.txt```: proportion of genetic variance components from 1000 Genomes ASW.
