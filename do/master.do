********************************************************************************
******* master do file for common core va project do files ****************
***this master file executes all do files for the project in correct order *****
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* IMPORTAMT: before running this master do file, make sure the directories global macros
are set correctly in the settings.do file according to your current file structure
cd "/home/research/ca_ed_lab/chesun/gsr/caschls"
 */


/* to run this master do file, run the following line of code
do "./do/master.do"
 */


/* For convenience of copy pasting:
cd "/home/research/ca_ed_lab/users/chesun/gsr/caschls"
do "./do/settings.do"
*/

cap log close _all
clear all
set varabbrev off, perm //set variable abbreviation permanently off
graph drop _all
set more off

/* If pause is on, the pause [message] command displays message and temporarily suspends execution
of the program, returning control to the keyboard. Execution of keyboard commands continues until
you type end or q, at which time execution of the program resumes. Typing BREAK in pause mode
(as opposed to pressing the Break key) also resumes program execution, but the break signal is sent
to the calling program. */
pause off

do "./do/settings.do" //set global project settings
log using "$projdir/log/master.smcl", replace name(master) //start log file for the master do file and overwrite existing log file

timer on 1

************ install packages needed for do files for this project *************
local installssc = 0
if `installssc' == 1 {
  ssc install elabel, replace //install the elabel package for easy renaming of labels
  ssc install tabout, replace //install the tabout package
  ssc install grstyle, replace //install grstyle package for easy graphic settings and palettes & colrspace package for color palette settings
  ssc install palettes, replace
  ssc install colrspace, replace
  ssc install labutil2, replace //package to help with managing value labels because stata sucks in that regard
  ssc install labundef, replace //package to list undefined value labels
  ssc install rangestat, replace //package to help with generate means with special requirements
  ssc install _gwtmean, replace //package to allow use of weights in egen mean
  ssc install estout, replace
  ssc install outreg2, replace
  ssc install regsave, replace
  /* install ssc package that group observations by the connected components of two variables  */
  ssc install group_twoway, replace
  ssc install vam, replace
  ssc install binscatter, replace
  ssc install descsave, replace
  ssc install parmest, replace
}


*************** This block are do files that prepare/build data *****************
//Note: do not need to run this. no longer have access to raw data. Use clean data
local do_build_data = 0
if `do_build_data'==1 {
  //running renamedata.do
  do $projdir/do/build/prepare/renamedata
  pause finished running $projdir/do/build/prepare/renamedata

  //running splitstaff0414.do
  do $projdir/do/build/prepare/splitstaff0414
  pause finished running $projdir/do/build/prepare/splitstaff0414
}


***************** This block are do files that check data **********************
local do_check_data = 1
if `do_check_data' == 1 {
  do $projdir/do/check/sameschools
  pause finished running $projdir/do/check/sameschools

  do $projdir/do/check/schooloverlap
  pause finished running $projdir/do/check/schooloverlap

  do $projdir/do/check/gradetab
  pause finished running $projdir/do/check/gradetab

  do $projdir/do/build/prepare/enrollmentclean
  pause finished running $projdir/do/build/prepare/enrollmentclean

}





*********************representativeness diagnostics******************************
local do_diagnostics = 1
if `do_diagnostics' == 1 {

  do $projdir/do/build/sample/elemdemographics
  pause finished running do $projdir/do/build/sample/elemdemographics

  do $projdir/do/build/sample/elemcoveragedata
  pause finished running $projdir/do/build/sample/elemcoveragedata

  do $projdir/do/share/demographics/elemcoverageanalysis
  pause finished running $projdir/do/share/demographics/elemcoverageanalysis

  do $projdir/do/build/sample/secdemographics
  pause finished running $projdir/do/build/sample/secdemographics

  do $projdir/do/build/sample/seccoveragedata
  pause finished running $projdir/do/build/sample/seccoveragedata

  do $projdir/do/share/demographics/seccoverageanalysis
  pause finished running $projdir/do/share/demographics/seccoverageanalysis

  do $projdir/do/build/sample/parentdemographics
  pause finished running $projdir/do/build/sample/parentdemographics

  do $projdir/do/build/sample/parentcoveragedata
  pause finished running $projdir/do/build/sample/parentcoveragedata

  do $projdir/do/share/demographics/parentcoverageanalysis
  pause finished running $projdir/do/share/demographics/parentcoverageanalysis

  do $projdir/do/build/sample/pooledsecdemographics
  pause finished running $projdir/do/build/sample/pooledsecdemographics

  do $projdir/do/build/sample/pooledsecdiagnostics
  pause finished running $projdir/do/build/sample/pooledsecdiagnostics

  do $projdir/do/share/demographics/pooledsecanalysis
  pause finished running $projdir/do/share/demographics/pooledsecanalysis

  do $projdir/do/build/sample/pooledparentdemographics
  pause finished running $projdir/do/build/sample/pooledparentdemographics

  do $projdir/do/build/sample/pooledparentdiagnostics
  pause finished running $projdir/do/build/sample/pooledparentdiagnostics

  do $projdir/do/check/pooledparentcheck
  pause finished running $projdir/do/check/pooledparentcheck
}



******************building final analysis datasets******************************


************************* create response rates datasets ***********************
////////////////////////////////////////////////////////////////////////////////
local do_response_rate = 1
if `do_response_rate' == 1 {

  /* trim demographics data in secondary survey and rename vars to prepare for
  generating conditional response rate datasets */
  do $projdir/do/build/buildanalysisdata/responserate/trimsecdemo
  pause finished running $projdir/do/build/buildanalysisdata/responserate/trimsecdemo

  do $projdir/do/build/buildanalysisdata/responserate/secresponserate
  pause finished running $projdir/do/build/buildanalysisdata/responserate/secresponserate

  do $projdir/do/build/buildanalysisdata/responserate/trimparentdemo
  pause finished running $projdir/do/build/buildanalysisdata/responserate/trimparentdemo

  do $projdir/do/build/buildanalysisdata/responserate/parentresponserate
  pause finished running $projdir/do/build/buildanalysisdata/responserate/parentresponserate

}




********************** clean secondary questions of interest *******************
////////////////////////////////////////////////////////////////////////////////
local do_clean_sec_qoi = 1
if `do_clean_sec_qoi' == 1 {

  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1819_1718_1516
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1819_1718_1516

  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1617
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1617

  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1415
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1415
}




********************** clean parent questions of interest **********************
////////////////////////////////////////////////////////////////////////////////
local do_clean_parent_qoi = 1
if `do_clean_parent_qoi' == 1 {

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1819_1718
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1819_1718

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1617
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1617

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1516
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1516

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1415
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1415

}




********************** clean staff questions of interest **********************
////////////////////////////////////////////////////////////////////////////////
//clean staff qoi 1718 and 1819
local do_clean_staff_qoi = 1
if `do_clean_staff_qoi' == 1 {

  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1819_1718
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1819_1718

  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1617_1516
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1617_1516

  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1415
  pause finished running $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1415

}




***************** pool qoi datasets and merge with response rate****************
////////////////////////////////////////////////////////////////////////////////
local do_pool_qoi_merge = 1
local `do_pool_qoi_merge' == 1 {

  do $projdir/do/build/buildanalysisdata/poolingdata/secpooling
  pause finished running $projdir/do/build/buildanalysisdata/poolingdata/secpooling

  do $projdir/do/build/buildanalysisdata/poolingdata/parentpooling
  pause finished running $projdir/do/build/buildanalysisdata/poolingdata/parentpooling

  do $projdir/do/build/buildanalysisdata/poolingdata/staffpooling
  pause finished running $projdir/do/build/buildanalysisdata/poolingdata/staffpooling

}




***************** merge 11th grade enrollment with analysis data****************
////////////////////////////////////////////////////////////////////////////////

//created pooled average grade 11 enrollment over years to merge with analysis data as weights
local do_pool_gr11_enr = 1
if `do_pool_gr11_enr' == 1 {

  do $projdir/do/build/prepare/poolgr11enr
  pause finished running $projdir/do/build/prepare/poolgr11enr

  //merge gr11 enrollment to parent and secondary analysis datasets
  do $projdir/do/build/buildanalysisdata/poolingdata/mergegr11enr
  pause finished running $projdir/do/build/buildanalysisdata/poolingdata/mergegr11enr

}





***************** clean the VA datasets and merge with analysis data ****************
////////////////////////////////////////////////////////////////////////////////
local do_pool_merge_va = 1
if `do_pool_merge_va' == 1 {
  //create pooled average value added estimates over years
  do $projdir/do/build/buildanalysisdata/poolingva/poolva
  pause finished running $projdir/do/build/buildanalysisdata/poolingva/poolva

  //combine all VA datasets into one dataset
  do $projdir/do/build/buildanalysisdata/poolingva/combineva
  pause finished running $projdir/do/build/buildanalysisdata/poolingva/combineva

  //merge with analysis datasets
  do $projdir/do/build/buildanalysisdata/poolingdata/mergeva
  pause finished running $projdir/do/build/buildanalysisdata/poolingdata/mergeva

}



***************** run VA regressions for analysis datasets  ****************
////////////////////////////////////////////////////////////////////////////////
local do_va_regs = 1
if `do_va_regs' == 1 {
  //run VA regressions for all analysis datasets
  do $projdir/do/share/varegs/allvaregs
  pause finished running $projdir/do/share/varegs/allvaregs

}


***************** factor analysis for qoi pooled means  ****************
////////////////////////////////////////////////////////////////////////////////
local dofactor = 1
if `dofactor' == 1 {
  //running factor analysis and export factor laoding tables and screeplots for all analysis datasets
  do $projdir/do/share/factoranalysis/factor
  pause finished running $projdir/do/share/factoranalysis/factor

  //merging all survey qoimean vars for factor analysis
  do $projdir/do/share/factoranalysis/allsvymerge
  pause finished running $projdir/do/share/factoranalysis/allsvymerge

  //running factor analysis and export results for the allsvyqoimeans dataset
  do $projdir/do/share/factoranalysis/allsvyfactor
  pause finished running $projdir/do/share/factoranalysis/allsvyfactor

  //check the distrubution of missing for merged allsvyqoimeans.dta
  do $projdir/do/check/allsvymissing
  pause finished running $projdir/do/check/allsvymissing

}




***************** imputation and cateogry index for qoi pooled means  ****************
////////////////////////////////////////////////////////////////////////////////
local do_index = 1
if `do_index' == 1 {

  // imputations for missing values in allsvyqoimeans.dta
  do $projdir/do/share/factoranalysis/imputation
  pause finished running $projdir/do/share/factoranalysis/imputation

  /* creates a linear index for each question cateogry using imputed data: school climate, teacher staff quality,
  student support, student motivation  */
  do $projdir/do/share/factoranalysis/imputedcategoryindex
  pause finished running $projdir/do/share/factoranalysis/imputedcategoryindex

  /* creates a linear index for each question cateogry use complete case only: school climate, teacher staff quality,
  student support, student motivation  */
  do $projdir/do/share/factoranalysis/compcasecategoryindex
  pause finished running $projdir/do/share/factoranalysis/compcasecategoryindex

  /* lienar regressions of VA vars on all 4 index vars in a "horse race" type regression
  for both complete case and imputed data  */
  do $projdir/do/share/factoranalysis/indexhorserace
  pause finished running $projdir/do/share/factoranalysis/indexhorserace

}



/* VA regs with index vars and school characteristics controls */
////////////////////////////////////////////////////////////////////////////////
local do_index_va_reg = 1
if `do_index_va_reg' == 1 {

  /* clean and pull school characteristics from the dataset created by Matt Naven, for use in
  VA regressions with index + school characteristics  */
  do $projdir/do/share/factoranalysis/mattschlchar
  pause finished running $projdir/do/share/factoranalysis/mattschlchar

  /* pull SBAC test score data from Matt dataset to create controls for index regressions using 6th and 8th grade test scores  */
  do $projdir/do/share/factoranalysis/testscore
  pause finished running $projdir/do/share/factoranalysis/testscore

  /* Bivariate VA regressions on each category index with school demographics as controls  */
  do $projdir/do/share/factoranalysis/indexregwithdemo
  pause finished running $projdir/do/share/factoranalysis/indexregwithdemo

}




/* matching siblings using CST data */
////////////////////////////////////////////////////////////////////////////////
local do_match_siblings = 1
if `do_match_siblings' == 1 {

  /* Use CST data to match students with their siblings. Code taken mostly from
  do file by Matt Naven  */
  do $projdir/do/share/siblingxwalk/siblingmatch
  pause finished running $projdir/do/share/siblingxwalk/siblingmatch

  /* use the sibling crosswalk dataset conditional on same year and create unique family ID
  to link siblings from the same family across years and delete duplicates  */
  do $projdir/do/share/siblingxwalk/uniquefamily
  pause finished running $projdir/do/share/siblingxwalk/uniquefamily

  /* create a dataset with all pairwise combinations of siblings and their state student IDs.
  Same combination with different orders are different observations. */
  do $projdir/do/share/siblingxwalk/siblingpairxwalk
  pause finished running $projdir/do/share/siblingxwalk/siblingpairxwalk

}




/* Create summary stats for NSC outcomes merged to K-12 test score data, both for 2010-2017
and 2010-2018 */
local dooutcomesumstats = 1
if `dooutcomesumstats' == 1 {
  do $projdir/do/share/outcomesumstats/k12_nsc_match_sumstats.do
  pause finished running $projdir/do/share/outcomesumstats/k12_nsc_match_sumstats.do
}



/* va regressions with sibling controls */
////////////////////////////////////////////////////////////////////////////////
local do_sibling_va_regs = 1
if `do_sibling_va_regs' == 1 {

  /* create the VA sample dataset to save processing time. Using doh helpher files
  each time to recreate the data takes too much time    */
  do $projdir/do/share/siblingvaregs/createvasample.do
  pause finished running $projdir/do/share/siblingvaregs/createvasample.do

  /* create a sibling enrollment outcomes crosswalk dataset by merging k-12 test scores
  to the postsecondary outcomes and then merge to ufamilyxwalk.dta and calculuate
  number of older siblings enrolled and proportion of older siblings enrolled   */
   do $projdir/do/share/siblingvaregs/siblingoutxwalk.do
   pause finished running $projdir/do/share/siblingvaregs/siblingoutxwalk.do

   /* create the VA samples markers with sibling outcomes merged on to make it easier
   to create sample sum stats.
   Using doh helpher files each time to recreate the data takes too much time    */
   do $projdir/do/share/siblingvaregs/siblingvasamples.do
   pause finished running $projdir/do/share/siblingvaregs/siblingvasamples.do

   /* do file to run test score VA regressions with sibling effects.
   Include as controls the dummies for
   1) has an older sibling enrolled in 2 year
   2) has an older sibling enrolled in 4 year

   Comment on family fixed effects: Too many fixed effects, not enough observations.
   Stata returns an error "attempted to fit a model with too many variables"
   Only 749488 obs but 600210 families, too many variables from family fixed effects    */

    /* To run this do file:
    for origianl drift limit
    do $projdir/do/share/siblingvaregs/va_sibling 0

    otherwise set a number   */
    do $projdir/do/share/siblingvaregs/va_sibling 0
    pause finished running $projdir/do/share/siblingvaregs/va_sibling

    /* do file to create sum stats for the test score VA sibling samples */
    do $projdir/do/share/siblingvaregs/va_sibling_sample_sumstats
    pause finished running $projdir/do/share/siblingvaregs/va_sibling_sample_sumstats

    /* sum stats for the test score VA estimates with additional demographic control
    for has at least one older sibling who enrolled in college (2 year, 4 year) */
    do $projdir/do/share/siblingvaregs/va_sibling_est_sumstats
    pause finished running $projdir/do/share/siblingvaregs/va_sibling_est_sumstats

    /* do file to create a regression output table for spec test for test score VA
    with original sample, sibling sample without control, sibling sample with control */
    do $projdir/do/share/siblingvaregs/va_sibling_spec_test_tab
    pause finished running $projdir/do/share/siblingvaregs/va_sibling_spec_test_tab

    /* do file to run enrollment outcome VA regressions with sibling effects.
    Include as controls the dummies for
    1) has an older sibling enrolled in 2 year
    2) has an older sibling enrolled in 4 year

    Comment on family fixed effects: Too many fixed effects, not enough observations. */

    /* To run this do file:
    for origianl drift limit
    do $projdir/do/share/siblingvaregs/va_sibling_out 0

    otherwise set a number if encounting an error

    do $projdir/do/share/siblingvaregs/va_sibling_out 2
     */
     do $projdir/do/share/siblingvaregs/va_sibling_out 0
     pause finished running $projdir/do/share/siblingvaregs/va_sibling_out

     /* sum stats for the enrollment VA estimates with additional demographic control
     for has at least one older sibling who enrolled in college (2 year, 4 year) */
     do $projdir/do/share/siblingvaregs/va_sibling_out_est_sumstats
     pause finished running $projdir/do/share/siblingvaregs/va_sibling_out_est_sumstats

     /* do file to create a regression output table for spec test for college outcome
     VA with original sample, sibling sample without control, sibling sample with control */
     do $projdir/do/share/siblingvaregs/va_sibling_out_spec_test_tab
     pause finished running $projdir/do/share/siblingvaregs/va_sibling_out_spec_test_tab

     /* do file to run forecast bias tests and spec tests for test score VA
     regressions with sibling effects. Two versions of VA: one with leave out
     7th grade score, one with leave out census tract
     Include as controls the dummies for
     1) has an older sibling enrolled in 2 year
     2) has an older sibling enrolled in 4 year

     Comment on family fixed effects: Too many fixed effects, not enough observations.
     Stata returns an error "attempted to fit a model with too many variables"
     Only 749488 obs but 600210 families, too many variables from family fixed effects */
     do $projdir/do/share/siblingvaregs/va_sibling_forecast_bias
     pause finished running $projdir/do/share/siblingvaregs/va_sibling_forecast_bias

     /* do file to create a regression output table for forecast bias tests for test score VA
     and enrollment VA on different samples */
     do $projdir/do/share/siblingvaregs/va_sibling_fb_test_tab
     pause finished running $projdir/do/share/siblingvaregs/va_sibling_fb_test_tab

}

timer off 1
timer list

pause off

log close master // close the master log file
translate $projdir/log/master.smcl $projdir/log/master.log
