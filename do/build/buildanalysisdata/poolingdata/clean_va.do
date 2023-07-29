********************************************************************************
/* clean VA estimates to be used for survey data analysis, and merge to survey
analysis datasets */
********************************************************************************

*****************************************************
* First created by Christina (Che) Sun November 21, 2022
* this do file replaces poolingva.do and combineva.do
*****************************************************

/* To run this do file, type:
do $projdir/do/build//buildanalysisdata/poolingdata/clean_va.do
 */

/* CHANGE LOG:

 */



cap log close _all
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

log using $projdir/log/build//buildanalysisdata/clean_va.smcl, replace




local date1_va_scatter_plot = c(current_date)
local time1_va_scatter_plot = c(current_time)


//------------------------------------------------------------------------------
// collapse VA estimates to school level mean over the years 2015-2018
//------------------------------------------------------------------------------

foreach va_outcome in ela math enr enr_2year enr_4year {
  use $vaprojdir/estimates/va_cfr_all/va_est_dta/va_`va_outcome'_all.dta, clear
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
save $projdir/dta/buildanalysisdata/va/va_pooled_all.dta, replace



//------------------------------------------------------------------------------
// merge collapsed VA estimates onto survey data
//------------------------------------------------------------------------------
foreach svyname in sec parent staff {
  use $projdir/dta/buildanalysisdata/analysisready/`svyname'analysisready, clear
  merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/va_pooled_all.dta, keep(1 3) nogen

  save, replace
}





local date2_va_scatter_plot = c(current_date)
local time2_va_scatter_plot = c(current_time)

di "Do file clean_va.do start date time: `date1_va_scatter_plot' `time1_va_scatter_plot'"
di "End date time: `date2_va_scatter_plot' `time2_va_scatter_plot'"


log close
translate $projdir/log/build//buildanalysisdata/clean_va.smcl ///
  $projdir/log/build//buildanalysisdata/clean_va.log, replace
