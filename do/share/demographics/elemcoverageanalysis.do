********************************************************************************
***************** create graphs for elementary demographics *********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* this do file creates graphs by comparing survey sample against enrollment data
for elementary demographics datasets to investigate the survey sample representativrness  */

//install grstyle package for easy graphic settings and palettes & colrspace package for color palette settings
//ssc instasll grstyle
//ssc install palettes
//ssc install colrspace

//grstyle documentation: http://repec.sowi.unibe.ch/stata/grstyle/help-grstyle-set.html
cap log close _all
clear
set more off

log using $projdir/log/share/demographics/elemcoverageanalysis.smcl, replace name(elemcoverageanalysis)

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for elementary dataset years

grstyle init  //initializes the grstyle package
grstyle set plain   //set graph background to plain
grstyle set color Set1, opacity(50): histogram //use Set1 color palette (red and blue) for histogram bars fill color and set opacity to 50%
grstyle set color white, opacity(25): histogram_line //set color white and opacity 25% for histogram bar outline color

foreach i of local years {
  use $projdir/dta/demographics/analysis/elementary/elemdemo`i'analysis, clear

  local elemgrades 3 4 5 6 //create a local macro for the grades in the elementary survey data
  foreach j of local elemgrades {

    /* create and export frequency histograms for distribution of response rate in grade i */
    histogram svygr`j'resprate, freq
    graph export $projdir/out/graph/svycoverage/elemcoverage/elem`i'/gr`j'resprate.png, replace

    /* create and export frequency histograms for distribution of male and female percentage difference between survey sample and enrollment data */
    histogram femalegr`j'dif, freq
    graph export $projdir/out/graph/svycoverage/elemcoverage/elem`i'/gr`j'femaledif.png,replace
    histogram malegr`j'dif, freq
    graph export $projdir/out/graph/svycoverage/elemcoverage/elem`i'/gr`j'maledif.png, replace
  }


}

grstyle clear // sets off grstyle


log close elemcoverageanalysis
translate $projdir/log/share/demographics/elemcoverageanalysis.smcl $projdir/log/share/demographics/elemcoverageanalysis.log, replace 
