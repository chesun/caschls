********************************************************************************
/* ad hoc master do files to run do files as needed
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on June 2, 2022 ***************************

/* To run this do file:

do $projdir/do/ad_hoc_master

 */

timer on 1

***************** run VA regressions for analysis datasets  ****************
////////////////////////////////////////////////////////////////////////////////
local do_va_regs = 1
if `do_va_regs' == 1 {
  /* clean VA estimates to be used for survey data analysis, and merge to survey
  analysis datasets */
  do $projdir/do/build//buildanalysisdata/poolingdata/clean_va.do



  //run VA regressions for all analysis datasets
  do $projdir/do/share/svyvaregs/allvaregs
  pause

}


***************** factor analysis for qoi pooled means  ****************
////////////////////////////////////////////////////////////////////////////////
local dofactor = 1
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
local do_index = 1
if `do_index' == 1 {

  // imputations for missing values in allsvyqoimeans.dta
  do $projdir/do/share/factoranalysis/imputation
  pause

  /* creates a linear index for each question cateogry using imputed data: school climate, teacher staff quality,
  student support, student motivation. Then run bivariate VA regressions on each index var */
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



timer off 1
timer list
