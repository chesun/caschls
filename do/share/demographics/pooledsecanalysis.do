********************************************************************************
***************** create graphs for secondary pooled diagnostics *********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear
set more off

log using $projdir/log/share/demographics/pooledsecanalysis.smcl, replace

use $projdir/dta/demographics/pooled/pooledsecdiagnostics, replace

grstyle init  //initializes the grstyle package
grstyle set plain   //set graph background to plain
grstyle set color Set1, opacity(50): histogram //use Set1 color palette (red and blue) for histogram bars fill color and set opacity to 50%
grstyle set color white, opacity(25): histogram_line //set color white and opacity 25% for histogram bar outline color

//create and export frequency histogram for pooled response rate (pooled across grades 9 and 11 and all 5 years)
histogram pooledrr, freq
graph export $projdir/out/graph/pooleddiagnostics/secondary/pooledrr.png, replace

//create and export frequency histogram for pooled female response rate
histogram pooledfemalerr, freq
graph export $projdir/out/graph/pooleddiagnostics/secondary/pooledfemalerr.png, replace

//create and export frequency histograms for pooled response rates for 4 races/ethnicities

//generate checks to see if survey responses are more than enrollment
gen checkhispanic = 0
replace checkhispanic = 1 if svyhispanictotal > enrhispanictotal
gen checkasian = 0
replace checkasian = 1 if svyasiantotal > enrasiantotal
gen checkblack = 0
replace checkblack = 1 if svyblacktotal > enrblacktotal
gen checkwhite = 0
replace checkwhite = 1 if svywhitetotal > enrwhitetotal

drop if checkhispanic == 1
drop if checkasian == 1
drop if checkblack == 1
drop if checkwhite == 1

histogram pooledhispanicrr, freq
graph export $projdir/out/graph/pooleddiagnostics/secondary/pooledhispanicrr.png, replace

histogram pooledasianrr, freq
graph export $projdir/out/graph/pooleddiagnostics/secondary/pooledasianrr.png, replace

histogram pooledblackrr, freq
graph export $projdir/out/graph/pooleddiagnostics/secondary/pooledblackrr.png, replace

histogram pooledwhiterr, freq
graph export $projdir/out/graph/pooleddiagnostics/secondary/pooledwhiterr.png, replace




grstyle clear // sets off grstyle


log close
translate $projdir/log/share/demographics/pooledsecanalysis.smcl $projdir/log/share/demographics/pooledsecanalysis.log, replace 
