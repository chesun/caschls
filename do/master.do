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
  pause

  //running splitstaff0414.do
  do $projdir/do/build/prepare/splitstaff0414
  pause
}


***************** This block are do files that check data **********************
local do_check_data = 0
if `do_check_data' == 1 {
  do $projdir/do/check/sameschools
  pause

  do $projdir/do/check/schooloverlap
  pause

  do $projdir/do/check/gradetab
  pause

  do $projdir/do/build/prepare/enrollmentclean
  pause

}





*********************representativeness diagnostics******************************
local do_diagnostics = 0
if `do_diagnostics' == 1 {

  do $projdir/do/build/sample/elemdemographics
  pause

  do $projdir/do/build/sample/elemcoveragedata
  pause

  do $projdir/do/share/demographics/elemcoverageanalysis
  pause

  do $projdir/do/build/sample/secdemographics
  pause

  do $projdir/do/build/sample/seccoveragedata
  pause

  do $projdir/do/share/demographics/seccoverageanalysis
  pause

  do $projdir/do/build/sample/parentdemographics
  pause

  do $projdir/do/build/sample/parentcoveragedata
  pause

  do $projdir/do/share/demographics/parentcoverageanalysis
  pause

  do $projdir/do/build/sample/pooledsecdemographics
  pause

  do $projdir/do/build/sample/pooledsecdiagnostics
  pause

  do $projdir/do/share/demographics/pooledsecanalysis
  pause

  do $projdir/do/build/sample/pooledparentdemographics
  pause

  do $projdir/do/build/sample/pooledparentdiagnostics
  pause

  do $projdir/do/check/pooledparentcheck
  pause
}



******************building final analysis datasets******************************


************************* create response rates datasets ***********************
////////////////////////////////////////////////////////////////////////////////
local do_response_rate = 0
if `do_response_rate' == 1 {

  /* trim demographics data in secondary survey and rename vars to prepare for
  generating conditional response rate datasets */
  do $projdir/do/build/buildanalysisdata/responserate/trimsecdemo
  pause

  do $projdir/do/build/buildanalysisdata/responserate/secresponserate
  pause

  do $projdir/do/build/buildanalysisdata/responserate/trimparentdemo
  pause

  do $projdir/do/build/buildanalysisdata/responserate/parentresponserate
  pause

}




********************** clean secondary questions of interest *******************
////////////////////////////////////////////////////////////////////////////////
local do_clean_sec_qoi = 0
if `do_clean_sec_qoi' == 1 {

  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1819_1718_1516
  pause

  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1617
  pause

  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1415
  pause
}




********************** clean parent questions of interest **********************
////////////////////////////////////////////////////////////////////////////////
local do_clean_parent_qoi = 0
if `do_clean_parent_qoi' == 1 {

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1819_1718
  pause

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1617
  pause

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1516
  pause

  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1415
  pause

}




********************** clean staff questions of interest **********************
////////////////////////////////////////////////////////////////////////////////
//clean staff qoi 1718 and 1819
local do_clean_staff_qoi = 0
if `do_clean_staff_qoi' == 1 {

  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1819_1718
  pause

  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1617_1516
  pause

  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1415
  pause

}




***************** pool qoi datasets and merge with response rate****************
////////////////////////////////////////////////////////////////////////////////
local do_pool_qoi_merge = 0
if `do_pool_qoi_merge' == 1 {

  do $projdir/do/build/buildanalysisdata/poolingdata/secpooling
  pause

  do $projdir/do/build/buildanalysisdata/poolingdata/parentpooling
  pause

  do $projdir/do/build/buildanalysisdata/poolingdata/staffpooling
  pause

}




***************** merge 11th grade enrollment with analysis data****************
////////////////////////////////////////////////////////////////////////////////

//created pooled average grade 11 enrollment over years to merge with analysis data as weights
local do_pool_gr11_enr = 0
if `do_pool_gr11_enr' == 1 {

  do $projdir/do/build/prepare/poolgr11enr
  pause

  //merge gr11 enrollment to parent and secondary analysis datasets
  do $projdir/do/build/buildanalysisdata/poolingdata/mergegr11enr
  pause

}





***************** clean the VA datasets and merge with analysis data ****************
////////////////////////////////////////////////////////////////////////////////
local do_pool_merge_va = 0
if `do_pool_merge_va' == 1 {
  //create pooled average value added estimates over years
  do $projdir/do/build/buildanalysisdata/poolingva/poolva
  pause

  //combine all VA datasets into one dataset
  do $projdir/do/build/buildanalysisdata/poolingva/combineva
  pause

  //merge with analysis datasets
  do $projdir/do/build/buildanalysisdata/poolingdata/mergeva
  pause

}



***************** run VA regressions for analysis datasets  ****************
////////////////////////////////////////////////////////////////////////////////
local do_va_regs = 0
if `do_va_regs' == 1 {
  //run VA regressions for all analysis datasets
  do $projdir/do/share/varegs/allvaregs
  pause

}


***************** factor analysis for qoi pooled means  ****************
////////////////////////////////////////////////////////////////////////////////
local dofactor = 0
if `dofactor' == 1 {
  //running factor analysis and export factor laoding tables and screeplots for all analysis datasets
  do $projdir/do/share/factoranalysis/factor
  pause

  //merging all survey qoimean vars for factor analysis
  do $projdir/do/share/factoranalysis/allsvymerge
  pause

  //running factor analysis and export results for the allsvyqoimeans dataset
  do $projdir/do/share/factoranalysis/allsvyfactor
  pause

  //check the distrubution of missing for merged allsvyqoimeans.dta
  do $projdir/do/check/allsvymissing
  pause

}




***************** imputation and cateogry index for qoi pooled means  ****************
////////////////////////////////////////////////////////////////////////////////
local do_index = 0
if `do_index' == 1 {

  // imputations for missing values in allsvyqoimeans.dta
  do $projdir/do/share/factoranalysis/imputation
  pause

  /* creates a linear index for each question cateogry using imputed data: school climate, teacher staff quality,
  student support, student motivation  */
  do $projdir/do/share/factoranalysis/imputedcategoryindex
  pause

  /* creates a linear index for each question cateogry use complete case only: school climate, teacher staff quality,
  student support, student motivation  */
  do $projdir/do/share/factoranalysis/compcasecategoryindex
  pause

  /* lienar regressions of VA vars on all 4 index vars in a "horse race" type regression
  for both complete case and imputed data  */
  do $projdir/do/share/factoranalysis/indexhorserace
  pause

}



/* VA regs with index vars and school characteristics controls */
////////////////////////////////////////////////////////////////////////////////
local do_index_va_reg = 0
if `do_index_va_reg' == 1 {

  /* clean and pull school characteristics from the dataset created by Matt Naven, for use in
  VA regressions with index + school characteristics  */
  do $projdir/do/share/factoranalysis/mattschlchar
  pause

  /* pull SBAC test score data from Matt dataset to create controls for index regressions using 6th and 8th grade test scores  */
  do $projdir/do/share/factoranalysis/testscore
  pause

  /* Bivariate VA regressions on each category index with school demographics as controls  */
  do $projdir/do/share/factoranalysis/indexregwithdemo
  pause

  /* Cronbach's alpha test for survey qois */
  do $projdir/do/share/factoranalysis/alpha
  pause

  /* Cronbach's alpha for the 4 index categories */
  do $projdir/do/share/factoranalysis/indexalpha
  pause

  /* creates principal component scores from pca for all 3 surveys */
  do $projdir/do/share/factoranalysis/pcascore
  pause
}




/* matching siblings using CST data */
////////////////////////////////////////////////////////////////////////////////
local do_match_siblings = 0
if `do_match_siblings' == 1 {

  /* Use CST data to match students with their siblings. Code taken mostly from
  do file by Matt Naven  */
  do $projdir/do/share/siblingxwalk/siblingmatch
  pause

  /* use the sibling crosswalk dataset conditional on same year and create unique family ID
  to link siblings from the same family across years and delete duplicates  */
  do $projdir/do/share/siblingxwalk/uniquefamily
  pause

  /* create a dataset with all pairwise combinations of siblings and their state student IDs.
  Same combination with different orders are different observations. */
  do $projdir/do/share/siblingxwalk/siblingpairxwalk
  pause

}



/*
/* Create summary stats for NSC outcomes merged to K-12 test score data, both for 2010-2017
and 2010-2018 */
local dooutcomesumstats = 0
if `dooutcomesumstats' == 1 {
  /* create a txt file codebook for NSC clean datasets, both for 2010-2017
  and 2010-2018 */
  do $projdir/do/share/outcomesumstats/nsc_codebook.do
  pause
}
 */


/* va regressions with sibling controls */
////////////////////////////////////////////////////////////////////////////////
local do_sibling_va_regs = 1
if `do_sibling_va_regs' == 1 {

  /* create the VA sample dataset to save processing time. Using doh helpher files
  each time to recreate the data takes too much time    */
  do $projdir/do/share/siblingvaregs/createvasample.do
  pause

  /* create a sibling enrollment outcomes crosswalk dataset by merging k-12 test scores
  to the postsecondary outcomes and then merge to ufamilyxwalk.dta and calculuate
  number of older siblings enrolled and proportion of older siblings enrolled   */
   do $projdir/do/share/siblingvaregs/siblingoutxwalk.do
   pause

   /* create the VA samples markers with sibling outcomes merged on to make it easier
   to create sample sum stats.
   Using doh helpher files each time to recreate the data takes too much time    */
   do $projdir/do/share/siblingvaregs/siblingvasamples.do
   pause

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
    pause

    /* do file to create sum stats for the test score VA sibling samples */
    do $projdir/do/share/siblingvaregs/va_sibling_sample_sumstats
    pause

    /* sum stats for the test score VA estimates with additional demographic control
    for has at least one older sibling who enrolled in college (2 year, 4 year) */
    do $projdir/do/share/siblingvaregs/va_sibling_est_sumstats
    pause

    /* do file to create a regression output table for spec test for test score VA
    with original sample, sibling sample without control, sibling sample with control */
    do $projdir/do/share/siblingvaregs/va_sibling_spec_test_tab
    pause

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
     pause

     /* sum stats for the enrollment VA estimates with additional demographic control
     for has at least one older sibling who enrolled in college (2 year, 4 year) */
     do $projdir/do/share/siblingvaregs/va_sibling_out_est_sumstats
     pause

     /* do file to create a regression output table for spec test for college outcome
     VA with original sample, sibling sample without control, sibling sample with control */
     do $projdir/do/share/siblingvaregs/va_sibling_out_spec_test_tab
     pause

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
     pause

     /* do file to create a regression output table for forecast bias tests for test score VA
     and enrollment VA on different samples */
     do $projdir/do/share/siblingvaregs/va_sibling_fb_test_tab
     pause

}



timer off 1
timer list

pause off
