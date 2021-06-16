********************************************************************************
******* master do file for caschls survey data project do files ****************
***this master file executes all do files for the project in correct order *****
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* IMPORTAMT: before running this master do file, make sure the directories global macros
are set correctly in the settings.do file according to your current file structure */
// cd "/home/research/ca_ed_lab/chesun/gsr/caschls"

/* to run this master do file, run the following line of code  */
// do "./do/master.do"

/* For convenience of copy pasting:
cd "/home/research/ca_ed_lab/chesun/gsr/caschls"
do "./do/settings.do"
*/

clear all
set varabbrev off, perm //set variable abbreviation permanently off

do "./do/settings.do" //set global project settings
/* log using "$projdir/log/master.smcl", replace name(master) //start log file for the master do file and overwrite existing log file */


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
}


*************** This block are do files that prepare/build data *****************

//running renamedata.do
local dorenamedata = 0
if `dorenamedata' == 1 {
  do "$projdir/do/build/prepare/renamedata.do"
}



//running splitstaff0414.do
local dosplitstaff0414 = 0
if `dosplitstaff0414' == 1 {
  do $projdir/do/build/prepare/splitstaff0414
}


***************** This block are do files that check data **********************

//running sameschools.do
local dosameschools = 0
if `dosameschools' == 1 {
  do $projdir/do/check/sameschools
}

//running schooloverlap.do
local doschooloverlap = 0
if `doschooloverlap' == 1 {
  do $projdir/do/check/schooloverlap
}

//running gradetab.do
local dogradetab = 0
if `dogradetab' == 1 {
  do $projdir/do/check/gradetab
}



//running enrollmentclean.do
local doenrollmentclean = 0
if `doenrollmentclean' == 1 {
  do $projdir/do/build/prepare/enrollmentclean
}


*********************representativeness diagnostics******************************

//running elemdemographics.do
local doelemdemographics = 0
if `doelemdemographics' == 1 {
  do $projdir/do/build/sample/elemdemographics
}


//running elemcoveragedata.do
local doelemcoveragedata = 0
if `doelemcoveragedata' == 1 {
  do $projdir/do/build/sample/elemcoveragedata
}

//running elemcoverageanalysis.do
local elemcoverageanalysis = 0
if `elemcoverageanalysis' == 1 {
  do $projdir/do/share/demographics/elemcoverageanalysis
}

//running secdemographics.do
local dosecdemographics = 0
if `dosecdemographics' == 1 {
  do $projdir/do/build/sample/secdemographics
}

//running seccoveragedata.do
local doseccoveragedata = 0
if `doseccoveragedata' == 1 {
  do $projdir/do/build/sample/seccoveragedata
}

//running seccoverageanalysis.do
local doseccoverageanalysis = 0
if `doseccoverageanalysis' == 1 {
  do $projdir/do/share/demographics/seccoverageanalysis
}

//running parentdemographics.do
local doparentdemographics = 0
if `doparentdemographics' == 1 {
  do $projdir/do/build/sample/parentdemographics
}

//running parentcoveragedata.do
local doparentcoveragedata = 0
if `doparentcoveragedata' == 1 {
  do $projdir/do/build/sample/parentcoveragedata
}

//running parentcoverageanalysis.do
local doparentcoverageanalysis = 0
if `doparentcoverageanalysis' == 1 {
  do $projdir/do/share/demographics/parentcoverageanalysis
}


//running pooledsecdemographics.do
local dopooledsecdemographics = 0
if `dopooledsecdemographics' == 1 {
  do $projdir/do/build/sample/pooledsecdemographics
}

//running pooledsecdiagnostics.do
local dopooledsecdiagnostics = 0
if `dopooledsecdiagnostics' == 1 {
  do $projdir/do/build/sample/pooledsecdiagnostics
}

//running pooledsecanalysis.do
local dopooledsecanalysis = 0
if `dopooledsecanalysis' == 1 {
  do $projdir/do/share/demographics/pooledsecanalysis
}

//running pooledparentdemographics.do
local dopooledparentdemographics = 0
if `dopooledparentdemographics' == 1 {
  do $projdir/do/build/sample/pooledparentdemographics
}

//running pooledparentdiagnostics.do
local dopooledparentdiagnostics = 0
if `dopooledparentdiagnostics' == 1 {
  do $projdir/do/build/sample/pooledparentdiagnostics
}

//running pooledparentcheck.do
//checking discrepancy between parent survey and enrollment data
local dopooledparentcheck = 0
if `dopooledparentcheck' == 1 {
  do $projdir/do/check/pooledparentcheck
}


******************building final analysis datasets******************************


************************* create response rates datasets ***********************
////////////////////////////////////////////////////////////////////////////////
//running trimsecdemo.do
/* trim demographics data in secondary survey and rename vars to prepare for
generating conditional response rate datasets */
local dotrimsecdemo = 0
if `dotrimsecdemo' == 1 {
  do $projdir/do/build/buildanalysisdata/responserate/trimsecdemo
}

//running secresponserate.do
/* merging trimmed secondary demographics to generate conditional response rates */
local dosecresponserate = 0
if `dosecresponserate' == 1 {
  do $projdir/do/build/buildanalysisdata/responserate/secresponserate
}

//running trimparentdemo.do
local runtrimparentdemo = 0
if `runtrimparentdemo' == 1 {
  do $projdir/do/build/buildanalysisdata/responserate/trimparentdemo
}

//running parentresponserate.do
local doparentresponserate = 0
if `doparentresponserate' == 1 {
  do $projdir/do/build/buildanalysisdata/responserate/parentresponserate
}
////////////////////////////////////////////////////////////////////////////////
********************************************************************************





********************** clean secondary questions of interest *******************
////////////////////////////////////////////////////////////////////////////////
//running secqoiclean1819_1718_1516.do
local dosecqoiclean1819_1718_1516 = 0
if `dosecqoiclean1819_1718_1516' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1819_1718_1516
}


//running secqoiclean1617.do
local dosecqoiclean1617 = 0
if `dosecqoiclean1617' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1617
}


//running secqoiclean1415.do
local dosecqoiclean1415 = 0
if `dosecqoiclean1415' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/secondary/secqoiclean1415
}


////////////////////////////////////////////////////////////////////////////////
********************************************************************************


********************** clean parent questions of interest **********************
////////////////////////////////////////////////////////////////////////////////
//running parentqoiclean1819
local doparentqoiclean1819_1718 = 0
if `doparentqoiclean1819_1718' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1819_1718
}

//running parentqoiclean1617
local doparentqoiclean1617 = 0
if `doparentqoiclean1617' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1617
}

//running parentqoiclean1516
local doparentqoiclean1516 = 0
if `doparentqoiclean1516' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1516
}

//running parentqoiclean1415
local doparentqoiclean1415 = 0
if `doparentqoiclean1415' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/parent/parentqoiclean1415
}


////////////////////////////////////////////////////////////////////////////////
********************************************************************************



********************** clean staff questions of interest **********************
////////////////////////////////////////////////////////////////////////////////
//clean staff qoi 1718 and 1819
local dostaffqoiclean1819_1718 = 0
if `dostaffqoiclean1819_1718' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1819_1718
}

//clean staff qoi 1617 and 1516
local dostaffqoiclean1617_1516 = 0
if `dostaffqoiclean1617_1516' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1617_1516
}

//clean staff qoi 1415
local dostaffqoiclean1415 = 0
if `dostaffqoiclean1415' == 1 {
  do $projdir/do/build/buildanalysisdata/qoiclean/staff/staffqoiclean1415
}



***************** pool qoi datasets and merge with response rate****************
////////////////////////////////////////////////////////////////////////////////

//running secpooling.do
local dosecpooling = 1
if `dosecpooling' == 1 {
  do $projdir/do/build/buildanalysisdata/poolingdata/secpooling
}

//running parentpooling.do
local doparentpooling = 1
if `doparentpooling' == 1 {
  do $projdir/do/build/buildanalysisdata/poolingdata/parentpooling
}

//pooling staff data
local dostaffpooling = 1
if `dostaffpooling' == 1 {
  do $projdir/do/build/buildanalysisdata/poolingdata/staffpooling
}



***************** merge 11th grade enrollment with analysis data****************
////////////////////////////////////////////////////////////////////////////////

//created pooled average grade 11 enrollment over years to merge with analysis data as weights
local dopoolgr11enr = 0
if `dopoolgr11enr' == 1 {
  do $projdir/do/build/prepare/poolgr11enr
}

//merge gr11 enrollment to parent and secondary analysis datasets
local domergegr11enr = 1
if `domergegr11enr' == 1 {
  do $projdir/do/build/buildanalysisdata/poolingdata/mergegr11enr
}



***************** clean the VA datasets and merge with analysis data ****************
////////////////////////////////////////////////////////////////////////////////

//create pooled average value added estimates over years
local dopoolva = 0
if `dopoolva' == 1 {
  do $projdir/do/build/buildanalysisdata/poolingva/poolva
}

//combine all VA datasets into one dataset
local docombineva = 0
if `docombineva' == 1 {
  do $projdir/do/build/buildanalysisdata/poolingva/combineva
}

//merge with analysis datasets
local domergeva = 0
if `domergeva' == 1 {
  do $projdir/do/build/buildanalysisdata/poolingdata/mergeva
}



***************** run VA regressions for analysis datasets  ****************
////////////////////////////////////////////////////////////////////////////////

/* //run VA regressions for secondary analysis dataset
local dosecvareg = 0
if `dosecvareg' == 1 {
  do $projdir/do/share/varegs/secvareg
}

//run VA regressions for parent analysis dataset
local dosecvareg = 0
if `dosecvareg' == 1 {
  do $projdir/do/share/varegs/parentvareg
}

//run VA regressions for staff analysis dataset
local dosecvareg = 0
if `dosecvareg' == 1 {
  do $projdir/do/share/varegs/staffvareg
} */

//run VA regressions for all analysis datasets
local doallvaregs = 0
if `doallvaregs' == 1 {
  do $projdir/do/share/varegs/allvaregs
}

***************** factor analysis for qoi pooled means  ****************
////////////////////////////////////////////////////////////////////////////////

//running factor analysis and export factor laoding tables and screeplots for all analysis datasets
local dofactor = 0
if `dofactor' == 1 {
  do $projdir/do/share/factoranalysis/factor.do
}


//merging all survey qoimean vars for factor analysis
local doallsvymerge = 0
if `doallsvymerge' == 1 {
  do $projdir/do/share/factoranalysis/allsvymerge
}


//running factor analysis and export results for the allsvyqoimeans dataset
local doallsvyfactor = 0
if `doallsvyfactor' == 1 {
  do $projdir/do/share/factoranalysis/allsvyfactor
}



//check the distrubution of missing for merged allsvyqoimeans.dta
local doallsvymissing = 0
if `doallsvymissing' == 1 {
  do $projdir/do/check/allsvymissing
}

***************** imputation and cateogry index for qoi pooled means  ****************
////////////////////////////////////////////////////////////////////////////////

// imputations for missing values in allsvyqoimeans.dta
local doimputation = 0
if `doimputation' == 1 {
  do $projdir/do/share/factoranalysis/imputation
}


/* creates a linear index for each question cateogry using imputed data: school climate, teacher staff quality,
student support, student motivation  */
local doimputedcategoryindex = 0
if `doimputedcategoryindex' == 1 {
  do $projdir/do/share/factoranalysis/imputedcategoryindex
}


/* creates a linear index for each question cateogry use complete case only: school climate, teacher staff quality,
student support, student motivation  */
local docompcasecategoryindex = 0
if `docompcasecategoryindex' == 1 {
  do $projdir/do/share/factoranalysis/compcasecategoryindex
}


/* lienar regressions of VA vars on all 4 index vars in a "horse race" type regression
for both complete case and imputed data  */
local doindexhorserace = 0
if `doindexhorserace' == 1 {
  do $projdir/do/share/factoranalysis/indexhorserace 
}


/* VA regs with index vars and school characteristics controls */
////////////////////////////////////////////////////////////////////////////////
/* making pooled school demographics dataset */
//pool cleaned CDE enrollment datasets over 5 years: 1415 - 1819
local dopoolenrollment = 0
if `dopoolenrollment' == 1 {
  do $projdir/do/build/prepare/poolenrollment
}

/* Bivariate VA regressions on each category index with school demographics as controls  */
local doindexregwithdemo = 0
if `doindexregwithdemo' == 1 {
  do $projdir/do/share/factoranalysis/indexregwithdemo
}





/* log close master // close the master log file */
