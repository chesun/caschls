/* do file to check whether the order of merge VA and imputation matters 
to investigate results inconsistency in survey VA regression results */
************* First created 12/19/2024 ******************************

/* to run this:

do $projdir/do/debug/test_merge_imputation.do
 */



cap log close _all
clear all
set more off

/* save all datasets produced here to debug dta folder */
local debugdtadir "$projdir/dta/debug"









********************************************************************************

// below is clean_va.do




//------------------------------------------------------------------------------
// collapse VA estimates to school level mean over the years 2015-2018
//------------------------------------------------------------------------------

foreach va_outcome in ela math enr enr_2year enr_4year {
  use $vaprojdir/estimates/va_cfr_all_v1/va_est_dta/va_`va_outcome'_all.dta, clear
  collapse (mean) va*, by(cdscode)

  tempfile va_`va_outcome'
  save `va_`va_outcome''
}

//------------------------------------------------------------------------------
// merge collapsed VA estimates
//------------------------------------------------------------------------------

// use a macro to store the command to initialize the data for merge
local merge_command use
local merge_options clear

foreach va_outcome in ela math enr enr_2year enr_4year {
  `merge_command' `va_`va_outcome'', `merge_options'
  local merge_command "merge 1:1 cdscode using"
  local merge_options nogen
}

label data "Pooled  School Level VA mean estimates for all test scores and enrollment over 2015-2018"
save `debugdtadir'/va_pooled_all.dta, replace



//------------------------------------------------------------------------------
// merge collapsed VA estimates onto survey data
//------------------------------------------------------------------------------
foreach svyname in sec parent staff {
  use $projdir/dta/buildanalysisdata/analysisready/`svyname'analysisready, clear
  merge 1:1 cdscode using `debugdtadir'/va_pooled_all.dta, keep(1 3) nogen 

  save, replace
}







//-------------------------------------------------------
// below section is allsvymerge.do, check merge rate
//-------------------------------------------------------

/* rename vars and prep parentanalysisready.dta for merging */
use $projdir/dta/buildanalysisdata/analysisready/parentanalysisready, clear

/* keep only the qoimean vars  and va to be used in factor analysis */
keep cdscode qoi* va*

/* rename variables and drop common vars to prepare for merging across surveys */
rename qoi* parentqoi*

save `debugdtadir'/parentqoimeans, replace


/* rename vars in secanalysisready.dta and prep for merging */
use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear

keep cdscode qoi* va*
rename qoi* secqoi*

save `debugdtadir'/secqoimeans, replace


/* rename vars in staffanalysisready.dta and prep for merging */
use $projdir/dta/buildanalysisdata/analysisready/staffanalysisready, clear

keep cdscode qoi* va*
rename qoi* staffqoi*

save `debugdtadir'/staffqoimeans, replace



/* merge all surveys */
/* use `debugdtadir'/parentqoimeans, clear
merge 1:1 cdscode using `debugdtadir'/secqoimeans, keep(3) nogen update


merge 1:1 cdscode using `debugdtadir'/staffqoimeans, keep(3) nogen update */


// old code 
use `debugdtadir'/parentqoimeans, clear
merge 1:1 cdscode using `debugdtadir'/secqoimeans
/* keep only matched schools */
keep if _merge == 3
drop _merge

merge 1:1 cdscode using `debugdtadir'/staffqoimeans
keep if _merge == 3
// 2300 records matched among all 3 surveys
drop _merge

/* 

April 6 2022 commit 9fdb41a: //940 records not matched from the master dataset. 1360 records matched
Nov 21 2022 commit:  2300 records matched, 
    this is when each analysisready dataset is merged to VA first, then the analysisready the resulting datasets are merged together
Dec 19 2024:  1345 records matched
 */



missings dropobs *mean_pooled, force //drop all observations with all qoimean vars missing

save `debugdtadir'/allsvyqoimeans, replace



