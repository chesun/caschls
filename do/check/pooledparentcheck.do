********************************************************************************
***************** check discrepancy between survey and enrollment for parent pooled data *********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear
set more off

log using $projdir/log/check/pooledparentcheck.smcl, replace

use $projdir/dta/demographics/pooled/pooledparentdiagnostics, replace

grstyle init  //initializes the grstyle package
grstyle set plain   //set graph background to plain
grstyle set color Set1, opacity(50): histogram //use Set1 color palette (red and blue) for histogram bars fill color and set opacity to 50%
grstyle set color white, opacity(25): histogram_line //set color white and opacity 25% for histogram bar outline color

//generate checks to see if survey responses are more than enrollment
gen checkgr9 = 0
replace checkgr9 = 1 if svygr9total > enrgr9total
gen checkgr11 = 0
replace checkgr11 = 1 if svygr11total > enrgr11total

label var checkgr9 "dummy equals 1 if pooled grade 9 survey response > enrollment"
label var checkgr11 "dummy equals 1 if pooled grade 11 survey response > enrollment"

//generate variables for the discrepancy between survey response and enrollment for grade 9 and 11
gen gr9discrep = svygr9total - enrgr9total
gen gr11discrep = svygr11total - enrgr11total

label var gr9discrep "pooled grade 9 survey response minus enrollment"
label var gr11discrep "pooled grade 11 survey response minus enrollment"

//create histograms for the discrepancy between survey response and enrollment for grade 9 and 11 for schools with survey > enrollment
histogram gr9discrep if checkgr9 == 1, freq width(1)
graph export $projdir/out/graph/pooleddiagnostics/parenttroubleshooting/gr9discrep.png, replace
histogram gr11discrep if checkgr11 == 1, freq width(1)
graph export $projdir/out/graph/pooleddiagnostics/parenttroubleshooting/gr11discrep.png, replace





grstyle clear // sets off grstyle


log close
translate $projdir/log/check/pooledparentcheck.smcl $projdir/log/check/pooledparentcheck.log, replace 
