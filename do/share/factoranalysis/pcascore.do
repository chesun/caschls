********************************************************************************
/* creates compiste scores from pca for all 3 surveys */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

/* creating pca compiste score for secondary survey */
use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear

pca *mean_pooled
predict pc1, score
histogram pc1, freq
graph export $projdir/out/graph/factoranalysis/pcascore/secpcascore.png, replace


/* creating pca compiste score for parent survey */
use $projdir/dta/buildanalysisdata/analysisready/parentanalysisready, clear

pca *mean_pooled
predict pc1, score
histogram pc1, freq
graph export $projdir/out/graph/factoranalysis/pcascore/parentpcascore.png, replace


/* creating pca compiste score for staff survey */
use $projdir/dta/buildanalysisdata/analysisready/staffanalysisready, clear

pca *mean_pooled
predict pc1 pc2, score
histogram pc1, freq
graph export $projdir/out/graph/factoranalysis/pcascore/staffpc1score.png, replace
histogram pc1, freq
graph export $projdir/out/graph/factoranalysis/pcascore/staffpc2score.png, replace
