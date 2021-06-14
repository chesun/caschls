********************************************************************************
***************** check ethnicity discrepancy between survey and enrollment for secondary pooled data *********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

clear
set more off

use $projdir/dta/demographics/pooled/pooledsecdiagnostics, replace

grstyle init  //initializes the grstyle package
grstyle set plain   //set graph background to plain
grstyle set color Set1, opacity(50): histogram //use Set1 color palette (red and blue) for histogram bars fill color and set opacity to 50%
grstyle set color white, opacity(25): histogram_line //set color white and opacity 25% for histogram bar outline color

//generate checks to see if survey responses are more than enrollment
gen checkgr9 = 0
replace checkgr9 = 1 if svygr9total > enrgr9total
gen checkgr11 = 0
replace checkgr11 = 1 if svygr11total > enrgr11total
gen checkfemale = 0
replace checkfemale = 1 if svyfemaletotal > enrfemaletotal
gen checkhispanic = 0
replace checkhispanic = 1 if svyhispanictotal > enrhispanictotal
gen checkasian = 0
replace checkasian = 1 if svyasiantotal > enrasiantotal
gen checkblack = 0
replace checkblack = 1 if svyblacktotal > enrblacktotal
gen checkwhite = 0
replace checkwhite = 1 if svywhitetotal > enrwhitetotal

label var checkgr9 "dummy equals 1 if pooled grade 9 survey response > enrollment"
label var checkgr11 "dummy equals 1 if pooled grade 11 survey response > enrollment"
label var checkfemale "dummy equals 1 if pooled female survey response > enrollment"
label var checkhispanic "dummy equals 1 if hispanic survey response > enrollment"
label var checkasian "dummy equals 1 if asian survey response > enrollment"
label var checkblack "dummy equals 1 if black survey response > enrollment"
label var checkwhite "dummy equals 1 if white survey response > enrollment"

//generate variables for the discrepancy between survey response and enrollment for each ethnicity
gen hispdiscrep = svyhispanictotal - enrhispanictotal
gen asiandiscrep = svyasiantotal - enrasiantotal
gen blackdiscrep = svyblacktotal - enrblacktotal
gen whitediscrep = svywhitetotal - enrwhitetotal

label var hispdiscrep "hispanic survey response minus enrollment"
label var asiandiscrep "asian survey response minus enrollment"
label var blackdiscrep "black survey response minus enrollment"
label var whitediscrep "white survey response minus enrollment"


//generate variables for the discrepancy between survey response and enrollment for grade 9 and 11, and females
gen gr9discrep = svygr9total - enrgr9total
gen gr11discrep = svygr11total - enrgr11total
gen femalediscrep = svyfemaletotal - enrfemaletotal

label var gr9discrep "pooled grade 9 survey response minus enrollment"
label var gr11discrep "pooled grade 11 survey response minus enrollment"
label var femalediscrep "pooled female survey response minus enrollment"

//create histograms for the discrepancy between survey response and enrollment by ethnicity for schools with survey > enrollment
histogram hispdiscrep if checkhispanic == 1, freq width(10)
graph export $projdir/out/graph/pooleddiagnostics/sectroubleshooting/hispdiscrep.png, replace
histogram asiandiscrep if checkasian == 1, freq width(5)
graph export $projdir/out/graph/pooleddiagnostics/sectroubleshooting/asiandiscrep.png, replace
histogram blackdiscrep if checkblack == 1, freq width(5)
graph export $projdir/out/graph/pooleddiagnostics/sectroubleshooting/blackdiscrep.png, replace
histogram whitediscrep if checkwhite == 1, freq width(50)
graph export $projdir/out/graph/pooleddiagnostics/sectroubleshooting/whitediscrep.png, replace

//create histograms for the discrepancy between survey response and enrollment for grade 9, 11, and female for schools with survey > enrollment
histogram gr9discrep if checkgr9 == 1, freq width(10)
graph export $projdir/out/graph/pooleddiagnostics/sectroubleshooting/gr9discrep.png, replace
histogram gr11discrep if checkgr11 == 1, freq width(1)
graph export $projdir/out/graph/pooleddiagnostics/sectroubleshooting/gr11discrep.png, replace
histogram femalediscrep if checkfemale == 1, freq width(1)
graph export $projdir/out/graph/pooleddiagnostics/sectroubleshooting/femalediscrep.png, replace



grstyle clear // sets off grstyle
