********************************************************************************
/* rename variables in surveys and merge all surveys for overall factor analysis, keeping
only the qoimean variables */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

/* CHANGE LOG:
11/21/2022: Rewrote code for using new VA estimates

12/19/2024: remove VA from analysis ready data when renaming, merge in again after merging survey datasets together

 */
 
cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/allsvymerge.smcl, replace

/* rename vars and prep parentanalysisready.dta for merging */
use $projdir/dta/buildanalysisdata/analysisready/parentanalysisready, clear

/* keep only the qoimean vars  and va to be used in factor analysis */
keep cdscode qoi* 

/* rename variables and drop common vars to prepare for merging across surveys */
rename qoi* parentqoi*

save $projdir/dta/allsvyfactor/formerge/parentqoimeans, replace


/* rename vars in secanalysisready.dta and prep for merging */
use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear

keep cdscode qoi* 
rename qoi* secqoi*

save $projdir/dta/allsvyfactor/formerge/secqoimeans, replace


/* rename vars in staffanalysisready.dta and prep for merging */
use $projdir/dta/buildanalysisdata/analysisready/staffanalysisready, clear

keep cdscode qoi* 
rename qoi* staffqoi*

save $projdir/dta/allsvyfactor/formerge/staffqoimeans, replace



/* merge all surveys */
use $projdir/dta/allsvyfactor/formerge/parentqoimeans, clear
merge 1:1 cdscode using $projdir/dta/allsvyfactor/formerge/secqoimeans, nogen 
merge 1:1 cdscode using $projdir/dta/allsvyfactor/formerge/staffqoimeans, nogen 

// merge on VA 
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/va_pooled_all.dta, keep(1 3) nogen 

save $projdir/dta/allsvyfactor/allsvyqoimeans, replace


log close
translate $projdir/log/share/factoranalysis/allsvymerge.smcl $projdir/log/share/factoranalysis/allsvymerge.log, replace
