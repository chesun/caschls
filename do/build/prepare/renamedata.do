********************************************************************************
**************** rename datasets for easier manipulation ***********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
clear
set more off

log using "$projdir/log/renamedata.smcl", replace name(renamedata) //start log file and overwrite existing log file for this do file

************************** elementary CHKS surveys *****************************

//14-15
use "$rawdtadir/elementary/CHKS_1415_ElemData_AllDistricts_012916.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/elementary/elem1415", replace

//15-16
use "$rawdtadir/elementary/CHKS_1516_ElemData_AllDistricts_ID_032217.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/elementary/elem1516", replace

//16-17
use "$rawdtadir/elementary/CHKS_1617_ElementaryData_Statewide_ID_081817.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/elementary/elem1617", replace

//17-18
use "$rawdtadir/elementary/CHKS_1718_ElementaryData_Statewide_ID_082818.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/elementary/elem1718", replace

//18-19
use "$rawdtadir/elementary/CHKS_1819_ElementaryData_Statewide_ID_091819.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/elementary/elem1819", replace





************************** Parent CSPS surveys *********************************
/* csv does not have 13-14 and 14-15, whereas dta has them. the "csps 1314 all.dta"
does not have cds code*/

//14-15
use "$rawdtadir/parent/csps1415 all.dta", clear

tostring cnty dist schl, replace //convert numbers to strings for easier concatenation

/* cnty is stored as long, so two digit county codes with leading zeros show up as 1 digit,
specifically there are three 1-digit cnty codes in the dataset, namely 2, 7, and 9. Here I make
the plausible assumption that these are 02, 07, and 09, which respecitively represent Alpine,
Contra Costa, and El Dorado counties */
replace cnty = strtrim(cnty) //remove leading and trailing blanks
replace cnty = stritrim(cnty) //collapse all internal consecutive blanks to one blank
replace cnty = "02" if cnty == "2" // reconstruct the correct cnty codes
replace cnty = "07" if cnty == "7"
replace cnty = "09" if cnty == "9"

/* dist are all 5 digits, so safe for the following operations */
replace dist = strtrim(dist) //remove leading and trailing blanks
replace cnty = stritrim(cnty) //collapse all internal consecutive blanks to one blank

/* IMPORTANT NOTE 1: There are 2 school IDs that are single digit: 3 and 4, for a total of 5 responses. Filling in leading zeros
for the school code and searhc with the resulting cds code did not produce any result in the California School Directory.
Therefore I assume these are missing or incorrectly entered data and discard them.  */
/* IMPORTANT NOTE 2: There are also many school IDs that are 6 digits instead of 7, and I fill in one leading 0 for them. Spot checks
with the resulting cds code produces matches in the california school directory  */
replace schl = strtrim(schl) //remove leading and trailing blanks
replace schl = stritrim(schl) //collapse all internal consecutive blanks to one blank
replace schl = "0" + schl if inrange(length(schl), 6, 6) // add leading zero if schl code is 6 digits

gen cdcode = cnty + dist //generate 7 digit county-district code
label var cdcode "7 digit county-district code"
gen cdscode = cdcode + schl //generate 14 digit cds code by combining cdcode and school code
save "$clndtadir/parent/parent1415", replace

//15-16
use "$rawdtadir/parent/CSPS_1516_ParentData_AllDistricts_ID_103116", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/parent/parent1516", replace

//16-17
use "$rawdtadir/parent/CSPS_1617_ParentData_Statewide_ID_102617", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/parent/parent1617", replace

//17-18
use "$rawdtadir/parent/CSPS_1718_ParentData_Statewide_ID_082818", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/parent/parent1718", replace

//18-19
use "$rawdtadir/parent/CSPS_1819_ParentData_Statewide_ID_102819", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/parent/parent1819", replace



************************** Secondary CHKS surveys *****************************

/* NOte: Stata codebooks exist for 11-12 and 12-13 but no dta files, only csv files
for these years. Following code will make corresponding dta files from csv files */

// IMPORTANT: When importing CSV FILES, need to convert cdscode to string, otherwise information is lost

//11-12
import delimited "$rawcsvdir/secondary/CHKS_1112_SecData_Statewide_School_ID_1213Var_110414.csv", clear
tostring cdscode, replace format("%15.0f") //apply a number format to enable string conversion
save "$clndtadir/secondary/sec1112", replace

//12-13
import delimited "$rawcsvdir/secondary/CHKS_1213_SecData_Statewide_School_ID_111114.csv", clear
tostring cdscode, replace format("%15.0f") //apply a number format to enable string conversion
save "$clndtadir/secondary/sec1213", replace

//13-14
use "$rawdtadir/secondary/CHKS_1314_SecData_AllDistricts_050718.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/secondary/sec1314", replace

//14-15
use "$rawdtadir/secondary/CHKS_1415_SecData_AllDistricts_012916.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/secondary/sec1415", replace

//15-16
use "$rawdtadir/secondary/CHKS_1516_SecData_AllDistricts_ID_032817.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/secondary/sec1516", replace

//16-17
use "$rawdtadir/secondary/CHKS_1617_SecondaryData_Statewide_ID_110917.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/secondary/sec1617", replace

//17-18
use "$rawdtadir/secondary/CHKS_1718_SecondaryData_Statewide_ID_011619b.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/secondary/sec1718", replace

//18-19
use "$rawdtadir/secondary/CHKS_1819_SecondaryData_Statewide_ID_091619.dta", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/secondary/sec1819", replace




************************** Staff CSSS surveys *****************************

//04-14
use "$rawdtadir/staff/CSSS_0405to1314_15var_ID_100219", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/staff/staff0414", replace

//14-15
use "$rawdtadir/staff/CSSS_1415_StaffData_AllDistricts_ID_082315", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/staff/staff1415", replace

//15-16
use "$rawdtadir/staff/CSSS_1516_StaffData_AllDistricts_ID_092616", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/staff/staff1516", replace

//16-17
use "$rawdtadir/staff/CSSS_1617_StaffData_Statewide_ID_081817", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/staff/staff1617", replace

//17-18
use "$rawdtadir/staff/CSSS_1718_StaffData_Statewide_ID_082918", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/staff/staff1718", replace

//18-19
use "$rawdtadir/staff/CSSS_1819_StaffData_Statewide_ID_090319", clear
replace cdscode = strtrim(cdscode) //remove leading and trailing blanks
replace cdscode = stritrim(cdscode) //collapse all internal consecutive blanks to one blank
compress
save "$clndtadir/staff/staff1819", replace


log close renamedata //close log file
