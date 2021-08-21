version 15.0
cap log close _all

*****************************************************
* First created by Matthew Naven on February 25, 2018 *
*****************************************************

if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="Naven" {
	local home "/Users/Naven/Documents/research/ca_ed_lab/data"
}
if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="navenm" {
	local home "/Users/navenm/Documents/research/ca_ed_lab/data"
}
if c(hostname)=="sapper" {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/secure/ca_ed_lab/data"
	local ccc "/secure/ca_ed_lab/Community_College/data"
}
cd `home'

log using log_files/crosswalk_ccc_outcomes.smcl, replace

clear all
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984


***************
* Description *
***************
/*
This file creates a crosswalk of K-12 students to California Community College 
outcomes such that there is one observation per student with the outcomes 
listed in a wide format.
*/


**********
* Macros *
**********
#delimit ;
#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
******** Enrollment
use `ccc'/Raw/SXENRLM.dta

rename SX_COLLEGE_ID COLLEGE_ID
rename SX_STUDENT_ID STUDENT_KEY
compress
merge m:1 COLLEGE_ID STUDENT_KEY using `ccc'/Raw/STUDNTID.dta, keep(1 3) nogen
rename COLLEGE_ID SX_COLLEGE_ID
rename STUDENT_KEY SX_STUDENT_ID

rename SX_COLLEGE_ID CB_COLLEGE_ID
rename SX_TERM_ID CB_TERM_ID
rename SX_COURSE_ID CB_COURSE_ID
rename SX_CONTROL_NUMBER CB_CONTROL_NUMBER
compress
merge m:1 CB_COLLEGE_ID CB_TERM_ID CB_COURSE_ID CB_CONTROL_NUMBER using `ccc'/Raw/CBCRSINV.dta, keep(1 3)
rename CB_COLLEGE_ID SX_COLLEGE_ID
rename CB_TERM_ID SX_TERM_ID
rename CB_COURSE_ID SX_COURSE_ID
rename CB_CONTROL_NUMBER SX_CONTROL_NUMBER

tostring SX_TERM_ID, replace format("%03.0f")

gen year = substr(SX_TERM_ID, 1, 2)
replace year = "19" + year if inrange(real(year), 92, 99)
replace year = "20" + year if inrange(real(year), 00, 20)
destring year, replace

gen term = substr(SX_TERM_ID, 3, 1)
destring term, replace
recode term (6 = 5) (8 = 7) (2 = 1) (4 = 3)

gen ccc_enr = 1 if SX_UNITS_ATTEMPTED>0 & !mi(SX_UNITS_ATTEMPTED)
label var ccc_enr "Enrolled in a CA Community College"

gen ccc_remediation = 1 if CB_BASIC_SKILLS_STATUS=="B"
replace ccc_remediation = 0 if CB_BASIC_SKILLS_STATUS=="N"
label var ccc_remediation "CCC Remediation"

gen ccc_ela_remediation = 1 if CB_BASIC_SKILLS_STATUS=="B" & substr(CB_TOP_CODE, 1, 2)=="15"
replace ccc_ela_remediation = 0 if (CB_BASIC_SKILLS_STATUS=="N") | (CB_BASIC_SKILLS_STATUS=="B" & substr(CB_TOP_CODE, 1, 2)!="15")
label var ccc_ela_remediation "CCC ELA Remediation"

gen ccc_math_remediation = 1 if CB_BASIC_SKILLS_STATUS=="B" & substr(CB_TOP_CODE, 1, 2)=="17"
replace ccc_math_remediation = 0 if (CB_BASIC_SKILLS_STATUS=="N") | (CB_BASIC_SKILLS_STATUS=="B" & substr(CB_TOP_CODE, 1, 2)!="17")
label var ccc_math_remediation "CCC Math Remediation"


**** Keep one observation per STUDENT_ID per term
drop if mi(STUDENT_ID)
sort STUDENT_ID year term
compress
collapse (max) ccc_enr ///
	ccc_remediation ccc_ela_remediation ccc_math_remediation ///
	, by(STUDENT_ID year term) fast

egen ccc_enr_start_year = min(year), by(STUDENT_ID)
egen ccc_enr_start_term = min(cond(year==ccc_enr_start_year,term, .)), by(STUDENT_ID)

gen ccc_persist_year2 = 1 if year==ccc_enr_start_year + 1 & term==ccc_enr_start_term
label var ccc_persist_year2 "Persisted to Year 2"

gen ccc_persist_year3 = 1 if year==ccc_enr_start_year + 2 & term==ccc_enr_start_term
label var ccc_persist_year3 "Persisted to Year 3"
replace ccc_persist_year2 = 1 if ccc_persist_year3==1


**** Keep one observation per STUDENT_ID
drop if mi(STUDENT_ID)
sort STUDENT_ID year term
compress
collapse (max) ccc_enr ///
	ccc_remediation ccc_ela_remediation ccc_math_remediation ///
	ccc_persist_year2 ccc_persist_year3 ///
	(firstnm) ccc_enr_start_year ccc_enr_start_term ///
	, by(STUDENT_ID) fast

label var ccc_enr "Enrolled in a CA Community College"

label var ccc_persist_year2 "Persisted to Year 2"

label var ccc_persist_year3 "Persisted to Year 3"


compress
tempfile enrollment
save `enrollment'








******** Awards
use `ccc'/SPAWARDS_studentID.dta, clear

gen ccc_enr = 1
label var ccc_enr "Enrolled in a CA Community College"

gen ccc_deg_date = date(SP_DATE, "YMDhms")
gen ccc_deg_year = year(ccc_deg_date)
gen ccc_deg_term = 1 if month(ccc_deg_date)==1
replace ccc_deg_term = 3 if inrange(month(ccc_deg_date), 2, 5)
replace ccc_deg_term = 5 if inrange(month(ccc_deg_date), 6, 7)
replace ccc_deg_term = 7 if inrange(month(ccc_deg_date), 8, 12)

gen ccc_enr_year = real(substr(string(FIRST_TERM_VALUE_FIRST), 1, 4))
gen ccc_enr_term = real(substr(string(FIRST_TERM_VALUE_FIRST), 5, 1))

gen ccc_ontime_year = ccc_enr_year + 3
gen ccc_ontime_term = ccc_enr_term

gen ccc_deg = 1
label var ccc_deg "Received a CCC Degree"

gen ccc_deg_ontime = real(string(ccc_deg_year) + string(ccc_deg_term)) ///
	< real(string(ccc_ontime_year) + string(ccc_ontime_term))
label var ccc_deg_ontime "Received a CCC Degree within 3 Years"

gen ccc_deg_c = 1 if inlist(SP_AWARD, "E", "B", "L", "T", "F")
label var ccc_deg_c "Received a CCC Certificate"

gen ccc_deg_a = 1 if inlist(SP_AWARD, "A", "S")
label var ccc_deg_a "Received a CCC Associate's Degree"

gen ccc_deg_b = 1 if inlist(SP_AWARD, "Y", "Z")
label var ccc_deg_b "Received a CCC Bachelor's Degree"


**** Keep one observation per STUDENT_ID
drop if mi(STUDENT_ID)
sort STUDENT_ID
compress
collapse (max) ccc_enr ///
	ccc_deg ccc_deg_c ccc_deg_a ccc_deg_b ///
	(firstnm) ccc_deg_year ccc_deg_term ccc_enr_year ccc_enr_term ///
	, by(STUDENT_ID) fast

label var ccc_enr "Enrolled in a CA Community College"

label var ccc_deg "Received a CCC Degree"

label var ccc_deg_c "Received a CCC Certificate"

label var ccc_deg_a "Received a CCC Associate's Degree"

label var ccc_deg_b "Received a CCC Bachelor's Degree"


compress
tempfile awards
save `awards'








******** Combine Enrollment and Awards datasets
use `enrollment', clear
compress
merge 1:1 STUDENT_ID using `awards', nogen update

drop if mi(STUDENT_ID)

foreach v of varlist ccc_enr ccc_deg ccc_deg_c ccc_deg_a ccc_deg_b {
	replace `v' = 0 if mi(`v')
}

replace ccc_persist_year2 = 0 if mi(ccc_persist_year2) & ccc_enr==1
replace ccc_persist_year2 = . ///
	if (inlist(ccc_enr_start_year, 2016) & inlist(ccc_enr_start_term, 7)) ///
	| (inlist(ccc_enr_start_year, 2017) & inlist(ccc_enr_start_term, 1, 3, 5))
replace ccc_persist_year2 = . if ccc_persist_year2==0 & ccc_deg==1

replace ccc_persist_year3 = 0 if mi(ccc_persist_year3) & ccc_enr==1
replace ccc_persist_year3 = . ///
	if (inlist(ccc_enr_start_year, 2015, 2016) & inlist(ccc_enr_start_term, 7)) ///
	| (inlist(ccc_enr_start_year, 2016, 2017) & inlist(ccc_enr_start_term, 1, 3, 5))
replace ccc_persist_year3 = . if ccc_persist_year3==0 & ccc_deg==1


order STUDENT_ID
sort STUDENT_ID
compress
label data "CA Community College Outcomes Crosswalk"
save restricted_access/clean/crosswalks/ccc_outcomes_crosswalk.dta, replace


timer off 1
timer list
log close
translate log_files/crosswalk_ccc_outcomes.smcl log_files/crosswalk_ccc_outcomes.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
