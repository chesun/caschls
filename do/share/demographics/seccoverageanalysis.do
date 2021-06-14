********************************************************************************
***************** create graphs for secondary demographics *********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* this do file creates graphs by comparing survey sample against enrollment data
for secondary demographics datasets to investigate the survey sample representativrness  */

clear
set more off

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for elementary dataset years

grstyle init  //initializes the grstyle package
grstyle set plain   //set graph background to plain
grstyle set color Set1, opacity(50): histogram //use Set1 color palette (red and blue) for histogram bars fill color and set opacity to 50%
grstyle set color white, opacity(25): histogram_line //set color white and opacity 25% for histogram bar outline color

foreach year of local years {
  use $projdir/dta/demographics/analysis/secondary/secdemo`year'analysis, clear

  local secgrades `" "6" "7" "8" "9" "10" "11" "12" "' //generate a local macro for grades in the secondary datasets, excluding non traditional students for simplicity
  foreach i of local secgrades {
    /* create and export frequency histograms for distribution of response rate in grade i */
    histogram svygr`i'resprate, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/gr`i'resprate.png, replace

    /* create and export frequency histograms for distribution of male and female percentage difference between survey sample and enrollment data */
    histogram femalegr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/femalegr`i'dif.png, replace
    histogram malegr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/malegr`i'dif.png, replace

    /* create and export frequency histograms for distributions of percentage differences for each ethnicity between survey sample and enrollment data */
    histogram hispanicgr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/hispanicgr`i'dif.png, replace
    histogram nativegr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/nativegr`i'dif.png, replace
    histogram asiangr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/asiangr`i'dif.png, replace
    histogram blackgr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/blackgr`i'dif.png, replace
    histogram pacificgr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/pacificgr`i'dif.png, replace
    histogram whitegr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/whitegr`i'dif.png, replace
    histogram mixedgr`i'dif, freq
    graph export $projdir/out/graph/svycoverage/seccoverage/sec`year'/gr`i'/mixedgr`i'dif.png, replace
  }

}

grstyle clear // sets off grstyle
