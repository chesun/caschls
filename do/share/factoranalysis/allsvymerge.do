********************************************************************************
/* rename variables in surveys and merge all surveys for overall factor analysis, keeping
only the qoimean variables */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off

/* rename vars and prep parentanalysisready.dta for merging */
use $projdir/dta/buildanalysisdata/analysisready/parentanalysisready, clear

/* keep only the qoimean vars to be used in factor analysis */
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
merge 1:1 cdscode using $projdir/dta/allsvyfactor/formerge/secqoimeans
/* keep only matched schools */
keep if _merge == 3
drop _merge

merge 1:1 cdscode using $projdir/dta/allsvyfactor/formerge/staffqoimeans
keep if _merge == 3
// 2300 records matched among all 3 surveys
drop _merge



/* merge with va vars */
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/combinedva
//940 records not matched from the master dataset. 1360 records matched
keep if _merge == 3
drop _merge

missings dropobs *mean_pooled, force //drop all observations with all qoimean vars missing

save $projdir/dta/allsvyfactor/allsvyqoimeans, replace
