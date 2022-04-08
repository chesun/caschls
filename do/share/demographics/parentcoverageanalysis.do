********************************************************************************
******************* create graphs for parent demographics **********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* this do file creates graphs by comparing survey sample against enrollment data
for parent demographics datasets to investigate the survey sample representativrness  */
cap log close _all
clear
set more off

log using $projdir/log/share/demographics/parentcoverageanalysis.smcl, replace

grstyle init  //initializes the grstyle package
grstyle set plain   //set graph background to plain
grstyle set color Set1, opacity(50): histogram //use Set1 color palette (red and blue) for histogram bars fill color and set opacity to 50%
grstyle set color white, opacity(25): histogram_line //set color white and opacity 25% for histogram bar outline color

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for elementary dataset years

foreach year of local years {
  use $projdir/dta/demographics/analysis/parent/parentdemo`year'analysis, clear

  local grades `" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "' //local macro for kids' grades in parent survey, kindergarten enrollment not included so omit
  foreach i of local grades {
    /* create and export frequency histograms for distribution of response rate in grade i */
    histogram svygr`i'resprate, freq
    graph export $projdir/out/graph/svycoverage/parentcoverage/parent`year'/gr`i'resprate.png, replace
  }
}

grstyle clear // sets off grstyle

log close
translate $projdir/log/share/demographics/parentcoverageanalysis.smcl  $projdir/log/share/demographics/parentcoverageanalysis.log, replace 
