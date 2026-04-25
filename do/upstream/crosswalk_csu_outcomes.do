version 15.0
cap log close _all

*****************************************************
* First created by Matthew Naven on February 20, 2018 *
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
	local csu "/secure/ca_ed_lab/data/restricted_access/clean/csu actually clean"
}
cd `home'

log using log_files/crosswalk_csu_outcomes.smcl, replace

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
This file creates a crosswalk of CSU students to CSU outcomes such that there 
is one observation per student with the outcomes listed in a wide format.
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
******** Applied
clear

forvalues year = 1997 (1) 1997 {
	forvalues semester = 4 (1) 4 {
		append using "`csu'/era/era`year'`semester'.dta"
	}
}

forvalues year = 1998 (1) 1999 {
	forvalues semester = 2 (2) 4 {
		append using "`csu'/era/era`year'`semester'.dta"
	}
}

forvalues year = 2000 (1) 2002 {
	forvalues semester = 2 (1) 4 {
		append using "`csu'/era/era`year'`semester'.dta"
	}
}

forvalues year = 2003 (1) 2017 {
	forvalues semester = 1 (1) 4 {
		append using "`csu'/era/era`year'`semester'.dta"
	}
}

gen csu_applied = 1
label var csu_applied "Applied to a CSU"

egen student_campus_tag = tag(idunique campus)

gen csu_accepted = 1 if inlist(admissionstatus, 2, 5)
label var csu_accepted "Accepted to a CSU"


**** Keep one observation per idunique
drop if mi(idunique)
sort idunique year term
compress
collapse ///
	(max) csu_applied csu_accepted ///
	(sum) csu_num_campus_applied = student_campus_tag ///
	(median) hsgpa ///
	(firstnm) transfergpa ///
	, by(idunique) fast

label var csu_applied "Applied to a CSU"

gen csu_applied_multiple = 1 if csu_num_campus_applied>1 & !mi(csu_num_campus_applied)
label var csu_applied_multiple "Applied to Multiple CSU Campuses"

label var csu_accepted "Accepted to a CSU"

label var hsgpa "High School GPA"

label var transfergpa "Transfer GPA"


compress
tempfile era
save `era'








******** Enrolled
clear

forvalues year = 1997 (1) 1997 {
	forvalues semester = 4 (1) 4 {
		append using "`csu'/ers/ers`year'`semester'.dta"
	}
}

forvalues year = 1998 (1) 1998 {
	forvalues semester = 2 (2) 4 {
		append using "`csu'/ers/ers`year'`semester'.dta"
	}
}

forvalues year = 1999 (1) 2002 {
	forvalues semester = 2 (1) 4 {
		append using "`csu'/ers/ers`year'`semester'.dta"
	}
}

forvalues year = 2003 (1) 2017 {
	forvalues semester = 1 (1) 4 {
		append using "`csu'/ers/ers`year'`semester'.dta"
	}
}

gen csu_applied = 1
label var csu_applied "Applied to a CSU"

egen student_campus_tag = tag(idunique campus)

gen csu_accepted = 1
label var csu_accepted "Accepted to a CSU"

gen csu_enr = 1
label var csu_enr "Enrolled in a CSU"

egen csu_min_matyear = min(matyear), by(idunique)
egen csu_min_matterm = min(cond(matyear==csu_min_matyear, matterm, .)), by(idunique)
egen csu_min_year = min(year), by(idunique)
egen csu_min_term = min(cond(year==csu_min_year, term, .)), by(idunique)
gen csu_enr_start_year = csu_min_matyear
replace csu_enr_start_year = csu_min_year if mi(csu_min_matyear)
gen csu_enr_start_term = csu_min_matterm
replace csu_enr_start_term = csu_min_term if mi(csu_min_matyear)

gen csu_persist_year2 = 1 if year==csu_enr_start_year + 1 & term==csu_enr_start_term
label var csu_persist_year2 "Persisted to Year 2"

gen csu_persist_year3 = 1 if year==csu_enr_start_year + 2 & term==csu_enr_start_term
label var csu_persist_year3 "Persisted to Year 3"
replace csu_persist_year2 = 1 if csu_persist_year3==1

gen csu_persist_year4 = 1 if year==csu_enr_start_year + 3 & term==csu_enr_start_term
label var csu_persist_year4 "Persisted to Year 4"
replace csu_persist_year2 = 1 if csu_persist_year4==1
replace csu_persist_year3 = 1 if csu_persist_year4==1


**** Keep one observation per idunique
drop if mi(idunique)
sort idunique year term
compress
collapse ///
	(max) csu_applied csu_accepted csu_enr ///
	csu_persist_year2 csu_persist_year3 csu_persist_year4 ///
	(sum) csu_num_campus_applied = student_campus_tag ///
	(median) hsgpa ///
	(firstnm) csu_enr_start_year csu_enr_start_term ///
	first_transfer_gpa = transfergpa first_campus_gpa = campusgpa first_total_gpa = totalgpa first_maj = majorocedd ///
	(lastnm) final_transfer_gpa = transfergpa final_campus_gpa = campusgpa final_total_gpa = totalgpa final_maj = majorocedd ///
	(min) engprofsum mathprofsum ///
	, by(idunique) fast

label var csu_applied "Applied to a CSU"

gen csu_applied_multiple = 1 if csu_num_campus_applied>1 & !mi(csu_num_campus_applied)
label var csu_applied_multiple "Applied to Multiple CSU Campuses"

label var csu_accepted "Accepted to a CSU"

label var csu_enr "Enrolled in a CSU"

gen csu_eng_remediation = 1 if inlist(engprofsum, 3, 4)
replace csu_eng_remediation = 0 if inlist(engprofsum, 1, 2)
label var csu_eng_remediation "CSU English Remediation"

gen csu_math_remediation = 1 if inlist(mathprofsum, 3, 4)
replace csu_math_remediation = 0 if inlist(mathprofsum, 1, 2)
label var csu_math_remediation "CSU Math Remediation"

gen csu_first_maj_stem = 1 if first_maj==1
replace csu_first_maj_stem = 1 if first_maj==2
replace csu_first_maj_stem = 0 if first_maj==3
replace csu_first_maj_stem = 1 if first_maj==4
replace csu_first_maj_stem = 0 if first_maj==5
replace csu_first_maj_stem = 0 if first_maj==6
replace csu_first_maj_stem = 1 if first_maj==7
replace csu_first_maj_stem = 0 if first_maj==8
replace csu_first_maj_stem = 1 if first_maj==9
replace csu_first_maj_stem = 0 if first_maj==10
replace csu_first_maj_stem = 0 if first_maj==11
replace csu_first_maj_stem = 1 if first_maj==12
replace csu_first_maj_stem = 0 if first_maj==13
replace csu_first_maj_stem = 0 if first_maj==15
replace csu_first_maj_stem = 0 if first_maj==16
replace csu_first_maj_stem = 1 if first_maj==17
replace csu_first_maj_stem = 1 if first_maj==19
replace csu_first_maj_stem = 1 if first_maj==20
replace csu_first_maj_stem = 0 if first_maj==21
replace csu_first_maj_stem = 0 if first_maj==22
replace csu_first_maj_stem = 0 if first_maj==49
replace csu_first_maj_stem = 0 if first_maj==0 // missing
replace csu_first_maj_stem = 0 if mi(first_maj)
label var csu_first_maj_stem "CSU Initial Major STEM"

gen csu_first_maj_other = 0 if first_maj==1
replace csu_first_maj_other = 0 if first_maj==2
replace csu_first_maj_other = 1 if first_maj==3
replace csu_first_maj_other = 0 if first_maj==4
replace csu_first_maj_other = 1 if first_maj==5
replace csu_first_maj_other = 1 if first_maj==6
replace csu_first_maj_other = 0 if first_maj==7
replace csu_first_maj_other = 1 if first_maj==8
replace csu_first_maj_other = 0 if first_maj==9
replace csu_first_maj_other = 1 if first_maj==10
replace csu_first_maj_other = 1 if first_maj==11
replace csu_first_maj_other = 0 if first_maj==12
replace csu_first_maj_other = 1 if first_maj==13
replace csu_first_maj_other = 1 if first_maj==15
replace csu_first_maj_other = 1 if first_maj==16
replace csu_first_maj_other = 0 if first_maj==17
replace csu_first_maj_other = 0 if first_maj==19
replace csu_first_maj_other = 0 if first_maj==20
replace csu_first_maj_other = 1 if first_maj==21
replace csu_first_maj_other = 1 if first_maj==22
replace csu_first_maj_other = 1 if first_maj==49
replace csu_first_maj_other = 0 if first_maj==0 // missing
replace csu_first_maj_other = 0 if mi(first_maj)
label var csu_first_maj_other "CSU Initial Major Other"

gen csu_first_maj_undecided = 1 if first_maj==0
replace csu_first_maj_undecided = 1 if mi(first_maj)
replace csu_first_maj_undecided = 0 if csu_first_maj_stem==1 | csu_first_maj_other==1
label var csu_first_maj_undecided "CSU Initial Major Undecided"

label var csu_persist_year2 "Persisted to Year 2"

label var csu_persist_year3 "Persisted to Year 3"

label var csu_persist_year4 "Persisted to Year 4"

gen csu_final_maj_stem = 1 if final_maj==1
replace csu_final_maj_stem = 1 if final_maj==2
replace csu_final_maj_stem = 0 if final_maj==3
replace csu_final_maj_stem = 1 if final_maj==4
replace csu_final_maj_stem = 0 if final_maj==5
replace csu_final_maj_stem = 0 if final_maj==6
replace csu_final_maj_stem = 1 if final_maj==7
replace csu_final_maj_stem = 0 if final_maj==8
replace csu_final_maj_stem = 1 if final_maj==9
replace csu_final_maj_stem = 0 if final_maj==10
replace csu_final_maj_stem = 0 if final_maj==11
replace csu_final_maj_stem = 1 if final_maj==12
replace csu_final_maj_stem = 0 if final_maj==13
replace csu_final_maj_stem = 0 if final_maj==15
replace csu_final_maj_stem = 0 if final_maj==16
replace csu_final_maj_stem = 1 if final_maj==17
replace csu_final_maj_stem = 1 if final_maj==19
replace csu_final_maj_stem = 1 if final_maj==20
replace csu_final_maj_stem = 0 if final_maj==21
replace csu_final_maj_stem = 0 if final_maj==22
replace csu_final_maj_stem = 0 if final_maj==49
replace csu_final_maj_stem = 0 if final_maj==0 // missing
replace csu_final_maj_stem = 0 if mi(final_maj)
label var csu_final_maj_stem "CSU Final Major STEM"

gen csu_final_maj_other = 0 if final_maj==1
replace csu_final_maj_other = 0 if final_maj==2
replace csu_final_maj_other = 1 if final_maj==3
replace csu_final_maj_other = 0 if final_maj==4
replace csu_final_maj_other = 1 if final_maj==5
replace csu_final_maj_other = 1 if final_maj==6
replace csu_final_maj_other = 0 if final_maj==7
replace csu_final_maj_other = 1 if final_maj==8
replace csu_final_maj_other = 0 if final_maj==9
replace csu_final_maj_other = 1 if final_maj==10
replace csu_final_maj_other = 1 if final_maj==11
replace csu_final_maj_other = 0 if final_maj==12
replace csu_final_maj_other = 1 if final_maj==13
replace csu_final_maj_other = 1 if final_maj==15
replace csu_final_maj_other = 1 if final_maj==16
replace csu_final_maj_other = 0 if final_maj==17
replace csu_final_maj_other = 0 if final_maj==19
replace csu_final_maj_other = 0 if final_maj==20
replace csu_final_maj_other = 1 if final_maj==21
replace csu_final_maj_other = 1 if final_maj==22
replace csu_final_maj_other = 1 if final_maj==49
replace csu_final_maj_other = 0 if final_maj==0 // missing
replace csu_final_maj_other = 0 if mi(final_maj)
label var csu_final_maj_other "CSU Final Major Other"

gen csu_final_maj_undecided = 1 if final_maj==0
replace csu_final_maj_undecided = 1 if mi(final_maj)
replace csu_final_maj_undecided = 0 if csu_final_maj_stem==1 | csu_final_maj_other==1
label var csu_final_maj_undecided "CSU Final Major Undecided"

compress
tempfile ers
save `ers'








******** Degree
clear

forvalues year = 1993 (1) 1993 {
	forvalues semester = 3 (1) 4 {
		append using "`csu'/erd/erd`year'`semester'.dta"
	}
}

forvalues year = 1994 (1) 2006 {
	forvalues semester = 2 (1) 4 {
		append using "`csu'/erd/erd`year'`semester'.dta"
	}
}

forvalues year = 2007 (1) 2007 {
	forvalues semester = 2 (2) 2 {
		append using "`csu'/erd/erd`year'`semester'.dta"
	}
}

forvalues year = 2009 (1) 2009 {
	forvalues semester = 3 (1) 3 {
		append using "`csu'/erd/erd`year'`semester'.dta"
	}
}

forvalues year = 2002 (1) 2016 {
	append using "`csu'/erd/erd`year'.dta"
}

gen csu_applied = 1
label var csu_applied "Applied to a CSU"

egen student_campus_tag = tag(idunique campus)

gen csu_accepted = 1
label var csu_accepted "Accepted to a CSU"

gen csu_enr = 1
label var csu_enr "Enrolled in a CSU"

rename matyear csu_enr_year
rename matterm csu_enr_term

gen csu_ontime_year = csu_enr_year + 6
gen csu_ontime_term = csu_enr_term

gen csu_deg_year = year
gen csu_deg_term = term

gen csu_deg = 1
label var csu_deg "Received a CSU Degree"

gen csu_deg_ontime = real(string(csu_deg_year) + string(csu_deg_term)) ///
	< real(string(csu_ontime_year) + string(csu_ontime_term))
label var csu_deg_ontime "Received a CSU Degree within 6 Years"

gen csu_deg_stem = 1 if majordd==1
replace csu_deg_stem = 1 if majordd==2
replace csu_deg_stem = 0 if majordd==3
replace csu_deg_stem = 1 if majordd==4
replace csu_deg_stem = 0 if majordd==5
replace csu_deg_stem = 0 if majordd==6
replace csu_deg_stem = 1 if majordd==7
replace csu_deg_stem = 0 if majordd==8
replace csu_deg_stem = 1 if majordd==9
replace csu_deg_stem = 0 if majordd==10
replace csu_deg_stem = 0 if majordd==11
replace csu_deg_stem = 1 if majordd==12
replace csu_deg_stem = 0 if majordd==13
replace csu_deg_stem = 0 if majordd==15
replace csu_deg_stem = 0 if majordd==16
replace csu_deg_stem = 1 if majordd==17
replace csu_deg_stem = 1 if majordd==19
replace csu_deg_stem = 1 if majordd==20
replace csu_deg_stem = 0 if majordd==21
replace csu_deg_stem = 0 if majordd==22
replace csu_deg_stem = 0 if majordd==49
replace csu_deg_stem = . if majordd==0 // missing
replace csu_deg_stem = . if mi(majordd)
label var csu_deg_stem "Received a STEM CSU Degree"

gen csu_deg_other = 0 if majordd==1
replace csu_deg_other = 0 if majordd==2
replace csu_deg_other = 1 if majordd==3
replace csu_deg_other = 0 if majordd==4
replace csu_deg_other = 1 if majordd==5
replace csu_deg_other = 1 if majordd==6
replace csu_deg_other = 0 if majordd==7
replace csu_deg_other = 1 if majordd==8
replace csu_deg_other = 0 if majordd==9
replace csu_deg_other = 1 if majordd==10
replace csu_deg_other = 1 if majordd==11
replace csu_deg_other = 0 if majordd==12
replace csu_deg_other = 1 if majordd==13
replace csu_deg_other = 1 if majordd==15
replace csu_deg_other = 1 if majordd==16
replace csu_deg_other = 0 if majordd==17
replace csu_deg_other = 0 if majordd==19
replace csu_deg_other = 0 if majordd==20
replace csu_deg_other = 1 if majordd==21
replace csu_deg_other = 1 if majordd==22
replace csu_deg_other = 1 if majordd==49
replace csu_deg_other = . if majordd==0 // missing
replace csu_deg_other = . if mi(majordd)
label var csu_deg_other "Received an Other CSU Degree"


**** Keep one observation per idunique
drop if mi(idunique)
sort idunique year term
compress
collapse ///
	(max) csu_applied csu_accepted csu_enr csu_deg csu_deg_ontime csu_deg_stem csu_deg_other ///
	(sum) csu_num_campus_applied = student_campus_tag ///
	(median) transferunits deg_transfer_gpa = transfergpa deg_campus_gpa = campusgpa deg_total_gpa = totalgpa totalunits ///
	(firstnm) hsgradyr csu_enr_year csu_enr_term csu_ontime_year csu_ontime_term csu_deg_year csu_deg_term campus cip major majordd ///
	, by(idunique) fast

label var csu_applied "Applied to a CSU"

gen csu_applied_multiple = 1 if csu_num_campus_applied>1 & !mi(csu_num_campus_applied)
label var csu_applied_multiple "Applied to Multiple CSU Campuses"

label var csu_accepted "Accepted to a CSU"

label var csu_enr "Enrolled in a CSU"

label var csu_deg "Received a CSU Degree"

label var csu_deg_stem "Received a STEM CSU Degree"

label var csu_deg_other "Received an Other CSU Degree"

compress
tempfile erd
save `erd'








******** Combine ERA, ERS, and ERD datasets
use `era'
compress
merge 1:1 idunique using `ers', nogen update
compress
merge 1:1 idunique using `erd', nogen update

drop if mi(idunique)

foreach v of varlist csu_applied csu_applied_multiple csu_accepted csu_enr csu_deg {
	replace `v' = 0 if mi(`v')
}

foreach v of varlist csu_deg_stem csu_deg_other {
	replace `v' = 0 if mi(`v') & csu_deg==0
}

replace csu_persist_year2 = 0 if mi(csu_persist_year2) & csu_enr==1
replace csu_persist_year2 = . if (inlist(csu_enr_start_year, 2017) & inlist(csu_enr_start_term, 1, 2, 3, 4))
replace csu_persist_year2 = . if csu_persist_year2==0 & csu_deg==1

replace csu_persist_year3 = 0 if mi(csu_persist_year3) & csu_enr==1
replace csu_persist_year3 = . if (inlist(csu_enr_start_year, 2016, 2017) & inlist(csu_enr_start_term, 1, 2, 3, 4))
replace csu_persist_year3 = . if csu_persist_year3==0 & csu_deg==1

replace csu_persist_year4 = 0 if mi(csu_persist_year4) & csu_enr==1
replace csu_persist_year4 = . if (inlist(csu_enr_start_year, 2015, 2016, 2017) & inlist(csu_enr_start_term, 1, 2, 3, 4))
replace csu_persist_year4 = . if csu_persist_year4==0 & csu_deg==1

replace hsgpa = hsgpa / 100

replace first_transfer_gpa = first_transfer_gpa / 100
replace final_transfer_gpa = final_transfer_gpa / 100
replace deg_transfer_gpa = deg_transfer_gpa / 100

replace first_campus_gpa = first_campus_gpa / 100
replace final_campus_gpa = final_campus_gpa / 100
replace deg_campus_gpa = deg_campus_gpa / 100

replace first_total_gpa = first_total_gpa / 100
replace final_total_gpa = final_total_gpa / 100
replace deg_total_gpa = deg_total_gpa / 100


order idunique
sort idunique
compress
label data "CSU Outcomes Crosswalk"
save restricted_access/clean/crosswalks/csu_outcomes_crosswalk.dta, replace


timer off 1
timer list
log close
translate log_files/crosswalk_csu_outcomes.smcl log_files/crosswalk_csu_outcomes.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
