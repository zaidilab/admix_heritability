


bolt --bfile=bed/admix_HI_g2_1 --phenoFile=phenotypes/admix_HI_g2_p0.01_1.max.fid.pheno \
--phenoCol=g \
--lmm --LDscoresFile=l2/admix_HI_g2_1.cov.2000k.l2.ldscore.gz \
--LDscoresCol L2 \
--statsFile=stats.tab \
--numLeaveOutChunks=100

