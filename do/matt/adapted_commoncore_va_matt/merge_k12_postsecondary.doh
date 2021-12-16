version 16.1

*****************************************************
* First created by Matthew Naven on June 11, 2018 *
*adapted by Che Sun Dec 13, 2021, changed crosswalks file path
*****************************************************

local crosswalks "/home/research/ca_ed_lab/projects/common_core_va/data/restricted_access/clean/crosswalks"

***************
* Description *
***************
/*
This file merges the K-12 data to the postsecondary data.
*/


**********
* Macros *
**********
args enr_only

local min_nsc_hs_grad_year "2010"
local max_nsc_hs_grad_year "2019"

local min_nsc_enr_year "2010"
local max_nsc_enr_year "2020"

local min_nsc_deg_year "2011"
local max_nsc_deg_year "2020"

local min_ccc_enr_year "1993"
local max_ccc_enr_year "2017"

local min_ccc_deg_year "1993"
local max_ccc_deg_year "2016"

local min_csu_app_year "2002"
local max_csu_app_year "2017"

local min_csu_enr_year "2002"
local max_csu_enr_year "2017"

local min_csu_deg_year "2002"
local max_csu_deg_year "2016"


*****************
* Begin Do File *
*****************
**** K-12 Variables
gen year_grad_hs = year + (12 - grade)
gen year_college = year + (13 - grade)




**** Merge to K-12/NSC crosswalk
gen k12_nsc_match = 0
gen k12_nsc_2010_2017_match = 0
/*gen k12_nsc_2010_2018_match = 0*/
gen k12_nsc_2018cde_match = 0
gen k12_nsc_2019cde_match = 0
compress


** NSC
/* changed the generated merge id to be consistent with the code  */
merge m:1 state_student_id ///
	using `crosswalks'/nsc_outcomes_crosswalk_ssid.dta ///
	, gen(merge_k12_nsc_ssid) keep(1 3 4 5) update
tab grade year
replace k12_nsc_match = 1 if inlist(merge_k12_nsc_ssid, 3, 4, 5)
drop merge_k12_nsc_ssid

** NSC 2010-2017
/*merge m:1 state_student_id ///
	using `crosswalks'/nsc_2010_2017_outcomes_crosswalk_ssid.dta ///
	, gen(merge_k12_nsc_2010_2017_ssid) keep(1 3 4 5) update
tab grade year
replace k12_nsc_match = 1 if merge_k12_nsc_2010_2017_ssid==3
replace k12_nsc_2010_2017_match = 1 if merge_k12_nsc_2010_2017_ssid==3
drop merge_k12_nsc_2010_2017_ssid

/*merge m:1 cdscode local_student_id ///
	using `crosswalks'/nsc_2010_2017_outcomes_crosswalk_lsid.dta ///
	, gen(merge_k12_nsc_2010_2017_lsid) keep(1 3 4 5) update
tab grade year
replace k12_nsc_match = 1 if merge_k12_nsc_2010_2017_lsid==3
replace k12_nsc_2010_2017_match = 1 if merge_k12_nsc_2010_2017_lsid==3
drop merge_k12_nsc_2010_2017_lsid*/


** NSC 2018
merge m:1 state_student_id ///
	using `crosswalks'/nsc_2018cde_outcomes_crosswalk_ssid.dta ///
	, gen(merge_k12_nsc_2018cde_ssid) keep(1 3 4 5) update
tab grade year
replace k12_nsc_match = 1 if merge_k12_nsc_2018cde_ssid==3
replace k12_nsc_2018cde_match = 1 if merge_k12_nsc_2018cde_ssid==3
drop merge_k12_nsc_2018cde_ssid

/*merge m:1 cdscode local_student_id ///
	using `crosswalks'/nsc_2018cde_outcomes_crosswalk_lsid.dta ///
	, gen(merge_k12_nsc_2018cde_lsid) keep(1 3 4 5) update
tab grade year
replace k12_nsc_match = 1 if merge_k12_nsc_2018cde_lsid==3
replace k12_nsc_2018cde_match = 1 if merge_k12_nsc_2018cde_lsid==3
drop merge_k12_nsc_2018cde_lsid*/


** NSC 2019
merge m:1 state_student_id ///
	using `crosswalks'/nsc_2019cde_provisional_outcomes_crosswalk_ssid.dta ///
	, gen(merge_k12_nsc_2019cde_ssid) keep(1 3 4 5) update
tab grade year
replace k12_nsc_match = 1 if merge_k12_nsc_2019cde_ssid==3
replace k12_nsc_2019cde_match = 1 if merge_k12_nsc_2019cde_ssid==3
drop merge_k12_nsc_2019cde_ssid

/*merge m:1 cdscode local_student_id ///
	using `crosswalks'/nsc_2019cde_provisional_outcomes_crosswalk_lsid.dta ///
	, gen(merge_k12_nsc_2019cde_lsid) keep(1 3 4 5) update
tab grade year
replace k12_nsc_match = 1 if merge_k12_nsc_2019cde_lsid==3
replace k12_nsc_2019cde_match = 1 if merge_k12_nsc_2019cde_lsid==3
drop merge_k12_nsc_2019cde_lsid*/
*/

** Edit NSC Variables
if "`enr_only'"=="enr_only" {
	local varlist "nsc_enr nsc_enr_lt2year nsc_enr_2year nsc_enr_4year nsc_enr_ontime nsc_enr_ontime_lt2year nsc_enr_ontime_2year nsc_enr_ontime_4year"
}
else if "`enr_only'"!="enr_only" {
	local varlist "nsc_*"
}
* Replace NSC variables with missing if no chance of matching to the NSC data
foreach v of varlist `varlist' {
	replace `v' = . if k12_nsc_match==0
}
macro drop _varlist
tab grade year

if "`enr_only'"!="enr_only" {
	* Replace NSC persistence variables with missing if never enrolled
	foreach v of varlist nsc_persist_year2 nsc_persist_year3 nsc_persist_year4 {
		replace `v' = . if nsc_enr!=1
	}
	tab grade year

	forvalues t = 2 (1) 4 {
		* Replace NSC persistence variables with 0 if they could have matched to the NSC data but didn't
		replace nsc_persist_year`t' = 0 if nsc_enr==1 & nsc_persist_year`t'!=1 & k12_nsc_match==1 & year_grad_hs + (`t' - 1)<=`max_nsc_enr_year' & !mi(year_grad_hs)
		* Replace NSC persistence variables with missing if they could not have matched to the NSC data
		replace nsc_persist_year`t' = . if nsc_enr==1 & /*nsc_persist_year`t'!=1 &*/ k12_nsc_match==1 & year_grad_hs + (`t' - 1)>`max_nsc_enr_year' & !mi(year_grad_hs)
	}
	tab grade year

	foreach v of varlist nsc_deg_lt2year {
		* Replace NSC less-than-2-year degree variable with 0 if they could have matched to the NSC data but didn't
		replace `v' = 0 if `v'!=1 & k12_nsc_match==1 & year_grad_hs + 2<=`max_nsc_deg_year' & !mi(year_grad_hs)
		* Replace NSC less-than-2-year degree variable with missing if they could not have matched to the NSC data
		replace `v' = . if /*`v'!=1 &*/ k12_nsc_match==1 & year_grad_hs + 2>`max_nsc_deg_year' & !mi(year_grad_hs)
	}
	tab grade year

	foreach v of varlist nsc_deg_2year {
		* Replace NSC 2-year degree variable with 0 if they could have matched to the NSC data but didn't
		replace `v' = 0 if `v'!=1 & k12_nsc_match==1 & year_grad_hs + 3<=`max_nsc_deg_year' & !mi(year_grad_hs)
		* Replace NSC 2-year degree variable with missing if they could not have matched to the NSC data
		replace `v' = . if /*`v'!=1 &*/ k12_nsc_match==1 & year_grad_hs + 3>`max_nsc_deg_year' & !mi(year_grad_hs)
	}
	tab grade year

	foreach v of varlist nsc_deg_4year {
		* Replace NSC 4-year degree variable with 0 if they could have matched to the NSC data but didn't
		replace `v' = 0 if `v'!=1 & k12_nsc_match==1 & year_grad_hs + 6<=`max_nsc_deg_year' & !mi(year_grad_hs)
		* Replace NSC 4-year degree variable with missing if they could not have matched to the NSC data
		replace `v' = . if /*`v'!=1 &*/ k12_nsc_match==1 & year_grad_hs + 6>`max_nsc_deg_year' & !mi(year_grad_hs)
	}
	tab grade year

	* NSC degree receipt conditional on enrollment
	gen nsc_enr_deg_lt2year = nsc_deg_lt2year if nsc_enr_lt2year==1
	gen nsc_enr_deg_2year = nsc_deg_2year if nsc_enr_2year==1
	gen nsc_enr_deg_4year = nsc_deg_4year if nsc_enr_4year==1
}
tab grade year




**** Merge to K-12/CCC crosswalk
gen k12_ccc_match = 0
compress

merge m:1 state_student_id ///
	using `crosswalks'/k12_ccc_crosswalk.dta ///
	, gen(merge_k12_ccc) keep(1 3) keepusing(student_id)
tab grade year
replace k12_ccc_match = 1 if merge_k12_ccc==3
drop merge_k12_ccc


**** Merge to CCC data
count if !mi(student_id)

merge m:1 student_id ///
	using `crosswalks'/ccc_outcomes_crosswalk.dta ///
	, gen(merge_k12_ccc) keep(1 3)
tab grade year


** Edit CCC Variables
foreach v of varlist ccc_enr {
	* Replace CCC enrollment with 0 if could have matched to the CCC data but didn't
	replace `v' = 0 if `v'!=1 & inrange(year_grad_hs, `min_ccc_enr_year', `max_ccc_enr_year')
	* Replace CCC enrollment with missing if could not have matched to the CCC data
	replace `v' = . if /*`v'!=1 &*/ !inrange(year_grad_hs, `min_ccc_enr_year', `max_ccc_enr_year')
}
tab grade year

* CCC on-time enrollment
gen ccc_enr_ontime = 1 if ccc_enr==1 ///
	& (ccc_enr_start_year==year_grad_hs & inlist(ccc_enr_start_term, 5, 6, 7, 8)) ///
	| (ccc_enr_start_year==year_grad_hs + 1 & inlist(ccc_enr_start_term, 1, 2, 3, 4))

if "`enr_only'"!="enr_only" {
	* Replace CCC remediation and persistence variables with missing if never enrolled
	foreach v of varlist ccc_remediation ccc_ela_remediation ccc_math_remediation ///
		ccc_persist_year2 ccc_persist_year3 ///
		ccc_deg ccc_deg_c ccc_deg_a ccc_deg_b {
		replace `v' = . if ccc_enr!=1
	}
	tab grade year

	forvalues t = 2 (1) 3 {
		* Replace CCC persistence variables with 0 if they could have matched to the CCC data but didn't
		replace ccc_persist_year`t' = 0 if ccc_enr==1 & ccc_persist_year`t'!=1 & k12_ccc_match==1 & year_grad_hs + (`t' - 1)<=`max_ccc_enr_year' & !mi(year_grad_hs)
		* Replace CCC persistence variables with missing if they could not have matched to the CCC data
		replace ccc_persist_year`t' = . if ccc_enr==1 & /*ccc_persist_year`t'!=1 &*/ k12_ccc_match==1 & year_grad_hs + (`t' - 1)>`max_ccc_enr_year' & !mi(year_grad_hs)
	}
	tab grade year

	foreach v of varlist ccc_deg ccc_deg_c ccc_deg_a ccc_deg_b {
		* Replace CCC degree variable with 0 if they could have matched to the CCC data but didn't
		replace `v' = 0 if `v'!=1 & inrange(year_grad_hs + 3, `min_ccc_deg_year', `max_ccc_deg_year')
		* Replace CCC degree variable with missing if they could not have matched to the CCC data
		replace `v' = . if /*`v'!=1 &*/ !inrange(year_grad_hs + 3, `min_ccc_deg_year', `max_ccc_deg_year')
	}
	tab grade year
}
tab grade year




**** Merge to K-12/CSU crosswalk
gen k12_csu_match = 0
compress

merge m:1 state_student_id ///
	using `crosswalks'/k12_csu_crosswalk.dta ///
	, gen(merge_k12_csu) keep(1 3) keepusing(idunique)
tab grade year
replace k12_csu_match = 1 if merge_k12_csu==3
drop merge_k12_csu


**** Merge to CSU data
count if !mi(idunique)

merge m:1 idunique ///
	using `crosswalks'/csu_outcomes_crosswalk.dta ///
	, gen(merge_k12_csu) keep(1 3)
tab grade year

** Edit CSU Variables
foreach v of varlist csu_enr {
	* Replace CSU enrollment with 0 if could have matched to the CSU data but didn't
	replace `v' = 0 if `v'!=1 & inrange(year_grad_hs, `min_csu_enr_year', `max_csu_enr_year')
	* Replace CSU enrollment with missing if could not have matched to the CSU data
	replace `v' = . if /*`v'!=1 &*/ !inrange(year_grad_hs, `min_csu_enr_year', `max_csu_enr_year')
}
tab grade year

* CSU on-time enrollment
gen csu_enr_ontime = 1 if csu_enr==1 ///
	& (csu_enr_start_year==year_grad_hs & inlist(csu_enr_start_term, 3, 4)) ///
	| (csu_enr_start_year==year_grad_hs + 1 & inlist(csu_enr_start_term, 1, 2))

if "`enr_only'"!="enr_only" {
	foreach v of varlist csu_applied csu_applied_multiple csu_accepted {
		* Replace CSU application with 0 if could have matched to the CSU data but didn't
		replace `v' = 0 if `v'!=1 & inrange(year_grad_hs, `min_csu_app_year', `max_csu_app_year')
		* Replace CSU application with missing if could not have matched to the CSU data
		replace `v' = . if /*`v'!=1 &*/ !inrange(year_grad_hs, `min_csu_app_year', `max_csu_app_year')
	}
	tab grade year

	* Replace CSU acceptance with missing if never applied
	foreach v of varlist csu_accepted {
		replace `v' = . if csu_applied!=1
	}
	tab grade year

	* Replace CSU remediation and persistence variables with missing if never enrolled
	foreach v of varlist ///
		csu_eng_remediation csu_math_remediation csu_first_maj_stem csu_first_maj_other csu_first_maj_undecided ///
		csu_persist_year2 csu_persist_year3 csu_persist_year4 ///
		csu_deg csu_deg_stem csu_deg_other {
		replace `v' = . if csu_enr!=1
	}
	tab grade year

	forvalues t = 2 (1) 4 {
		* Replace CSU persistence variables with 0 if they could have matched to the CSU data but didn't
		replace csu_persist_year`t' = 0 if csu_enr==1 & csu_persist_year`t'!=1 & k12_csu_match==1 & year_grad_hs + (`t' - 1)<=`max_csu_enr_year' & !mi(year_grad_hs)
		* Replace CSU persistence variables with missing if they could not have matched to the CSU data
		replace csu_persist_year`t' = . if csu_enr==1 & /*csu_persist_year`t'!=1 &*/ k12_csu_match==1 & year_grad_hs + (`t' - 1)>`max_csu_enr_year' & !mi(year_grad_hs)
	}
	tab grade year

	foreach v of varlist csu_deg csu_deg_stem csu_deg_other {
		* Replace CSU degree variable with 0 if they could have matched to the CSU data but didn't
		replace `v' = 0 if `v'!=1 & inrange(year_grad_hs + 6, `min_csu_deg_year', `max_csu_deg_year')
		* Replace CSU degree variable with missing if they could not have matched to the CSU data
		replace `v' = . if /*`v'!=1 &*/ !inrange(year_grad_hs + 6, `min_csu_deg_year', `max_csu_deg_year')
	}
	tab grade year

	* CSU degree receipt conditional on STEM major
	gen csu_maj_stem_deg_stem = csu_deg_stem if csu_first_maj_stem==1
	gen csu_maj_stem_deg_other = csu_deg_other if csu_first_maj_stem==1

	* Replace CSU degree receipt conditional on STEM major with missing if never enrolled
	foreach v of varlist ///
		csu_maj_stem_deg_stem csu_maj_stem_deg_other {
		replace `v' = . if csu_enr!=1
	}
	tab grade year
}




**** Drop observations that had no chance of matching to CCC/CSU data
compress
merge m:1 state_student_id ///
	using `crosswalks'/k12_unique_crosswalk.dta ///
	, gen(merge_k12_unique) keep(1 3)
tab grade year

if "`enr_only'"=="enr_only" {
	local varlist_ccc "ccc_enr_*"
	local varlist_csu "csu_enr_*"
}
else if "`enr_only'"!="enr_only" {
	local varlist_ccc "ccc_*"
	local varlist_csu "csu_*"
}
* Replace CCC variables with missing if could not have matched to the CCC data due to non-unique name/birth date/sex
foreach v of varlist `varlist_ccc' {
	replace `v' = . if k12_ccc_match==0 & uniq_first_last_bday_sex==0
	replace `v' = . if k12_ccc_match==0 & uniq_first3_last3_bday_sex==0 & inrange(year_grad_hs, 1993, 2011)
}
macro drop _varlist_ccc
tab grade year

* Replace CSU variables with missing if could not have matched to the CSU data due to non-unique name/birth date/sex
foreach v of varlist `varlist_csu' {
	replace `v' = . if k12_csu_match==0 & uniq_first_last_bday_sex_middle==0
}
macro drop _varlist_csu
tab grade year




**** All college outcomes
* Enrollment
gen enr = 1 if nsc_enr==1 /*| ccc_enr==1 | csu_enr==1*/
replace enr = 0 if nsc_enr==0 & ccc_enr!=1 & csu_enr!=1
label var enr "Enrolled at a Postsecondary Institution"

gen enr_ontime = 1 if nsc_enr_ontime==1 | ccc_enr_ontime==1 | csu_enr_ontime==1
replace enr_ontime = 0 if nsc_enr_ontime==0 & ccc_enr_ontime!=1 & csu_enr_ontime!=1
label var enr_ontime "Enrolled at a Postsecondary Institution"

gen enr_2year = 1 if nsc_enr_2year==1 | nsc_enr_lt2year==1 | ccc_enr==1
replace enr_2year = 0 if nsc_enr_2year==0 & nsc_enr_lt2year==0 & ccc_enr!=1
label var enr_2year "Enrolled at a 2-Year College"

gen enr_ontime_2year = 1 if nsc_enr_ontime_2year==1 | nsc_enr_ontime_lt2year==1 | ccc_enr_ontime==1
replace enr_ontime_2year = 0 if nsc_enr_ontime_2year==0 & nsc_enr_ontime_lt2year==0 & ccc_enr_ontime!=1
label var enr_ontime_2year "Enrolled at a 2-Year College"

gen enr_4year = 1 if nsc_enr_4year==1 | csu_enr==1
replace enr_4year = 0 if nsc_enr_4year==0 & csu_enr!=1
label var enr_4year "Enrolled at a 4-Year University"

replace enr_2year = 0 if enr_4year==1

gen enr_ontime_4year = 1 if nsc_enr_ontime_4year==1 | csu_enr_ontime==1
replace enr_ontime_4year = 0 if nsc_enr_ontime_4year==0 & csu_enr_ontime!=1
label var enr_ontime_4year "Enrolled at a 4-Year University"

replace enr_ontime_2year = 0 if enr_ontime_4year==1

gen enr_pub = 1 if nsc_enr_pub==1 | ccc_enr==1 | csu_enr==1
replace enr_pub = 0 if nsc_enr_pub==0 & ccc_enr!=1 & csu_enr!=1
label var enr_pub "Enrolled at a Public Institution"

gen enr_ontime_pub = 1 if nsc_enr_ontime_pub==1 | ccc_enr_ontime==1 | csu_enr_ontime==1
replace enr_ontime_pub = 0 if nsc_enr_ontime_pub==0 & ccc_enr_ontime!=1 & csu_enr_ontime!=1
label var enr_ontime_pub "Enrolled at a Public Institution"

gen enr_priv = 1 if nsc_enr_priv==1
replace enr_priv = 0 if nsc_enr_priv==0
label var enr_priv "Enrolled at a Private Institution"

replace enr_pub = 0 if enr_priv==1

gen enr_ontime_priv = 1 if nsc_enr_ontime_priv==1
replace enr_ontime_priv = 0 if nsc_enr_ontime_priv==0
label var enr_ontime_priv "Enrolled at a Private Institution"

replace enr_ontime_pub = 0 if enr_ontime_priv==1

gen enr_instate = 1 if nsc_enr_instate==1 | ccc_enr==1 | csu_enr==1
replace enr_instate = 0 if nsc_enr_instate==0 & ccc_enr!=1 & csu_enr!=1
label var enr_instate "Enrolled at a CA Institution"

gen enr_ontime_instate = 1 if nsc_enr_ontime_instate==1 | ccc_enr_ontime==1 | csu_enr_ontime==1
replace enr_ontime_instate = 0 if nsc_enr_ontime_instate==0 & ccc_enr_ontime!=1 & csu_enr_ontime!=1
label var enr_ontime_instate "Enrolled at a CA Institution"

gen enr_outstate = 1 if nsc_enr_outstate==1
replace enr_outstate = 0 if nsc_enr_outstate==0
label var enr_outstate "Enrolled at an Out-of-State Institution"

replace enr_instate = 0 if enr_outstate==1

gen enr_ontime_outstate = 1 if nsc_enr_ontime_outstate==1
replace enr_ontime_outstate = 0 if nsc_enr_ontime_outstate==0
label var enr_ontime_outstate "Enrolled at an Out-of-State Institution"

replace enr_ontime_instate = 0 if enr_ontime_outstate==1

tab grade year

* Persistence
if "`enr_only'"!="enr_only" {
	gen persist_year2 = 1 if nsc_persist_year2==1 | ccc_persist_year2==1 | csu_persist_year2==1
	replace persist_year2 = 0 if nsc_persist_year2==0 & ccc_persist_year2!=1 & csu_persist_year2!=1
	label var persist_year2 "Persisted to Year 2"

	gen persist_year3 = 1 if nsc_persist_year3==1 | ccc_persist_year3==1 | csu_persist_year3==1
	replace persist_year3 = 0 if nsc_persist_year3==0 & ccc_persist_year3!=1 & csu_persist_year3!=1
	label var persist_year3 "Persisted to Year 3"

	gen persist_year4 = 1 if nsc_persist_year4==1 /*| ccc_persist_year4==1*/ | csu_persist_year4==1
	replace persist_year4 = 0 if nsc_persist_year4==0 /*& ccc_persist_year4!=1*/ & csu_persist_year4!=1
	label var persist_year4 "Persisted to Year 4"
}
tab grade year

* Degree
if "`enr_only'"!="enr_only" {
	gen deg = 1 if nsc_deg==1 | ccc_deg==1 | csu_deg==1
	replace deg = 0 if nsc_deg==0 & ccc_deg!=1 & csu_deg!=1
	label var deg "Received a College Degree"

	gen deg_2year = 1 if nsc_deg_2year==1 | ccc_deg==1
	replace deg_2year = 0 if nsc_deg_2year==0 & ccc_deg!=1
	label var deg_2year "Received a 2-Year College Degree"

	gen deg_4year = 1 if nsc_deg_4year==1 | csu_deg==1
	replace deg_4year = 0 if nsc_deg_4year==0 & csu_deg!=1
	label var deg_4year "Received a 4-Year College Degree"
}
tab grade year


* Use only NSC sample + values of 1 from other samples
if "`enr_only'"=="enr_only" {
	local varlist "enr enr_2year enr_4year enr_pub enr_priv enr_instate enr_outstate enr_ontime enr_ontime_2year enr_ontime_4year enr_ontime_pub enr_ontime_priv enr_ontime_instate enr_ontime_outstate"
}
else if "`enr_only'"!="enr_only" {
	local varlist "enr enr_2year enr_4year enr_pub enr_priv enr_instate enr_outstate enr_ontime enr_ontime_2year enr_ontime_4year enr_ontime_pub enr_ontime_priv enr_ontime_instate enr_ontime_outstate deg deg_2year deg_4year"
}
foreach v of varlist `varlist' {
	replace `v' = . if /*`v'==0 &*/ k12_nsc_match==0
}
macro drop _varlist
tab grade year


* CCC
if "`enr_only'"!="enr_only" {
	gen ccc_transfer_4year = 1 if ccc_enr==1 & enr_4year==1
	replace ccc_transfer_4year = 0 if ccc_enr==1 & enr_4year==0
	replace ccc_transfer_4year = . ///
		if (inlist(ccc_enr_start_year, `max_ccc_enr_year') & inlist(ccc_enr_start_term, 7, 8)) ///
		| (inlist(ccc_enr_start_year, `max_ccc_enr_year' + 1) & inlist(ccc_enr_start_term, 1, 2, 3, 4, 5, 6))
	label var ccc_transfer_4year "Transfered to 4-Year University"

	replace ccc_persist_year2 = 1 if ccc_persist_year2==0 & ccc_transfer_4year==1
	replace ccc_persist_year3 = 1 if ccc_persist_year3==0 & ccc_transfer_4year==1
	replace ccc_deg = 1 if ccc_deg==0 & ccc_transfer_4year==1
	replace ccc_deg_a = 1 if ccc_deg_a==0 & ccc_transfer_4year==1
}
tab grade year


* CSU
if "`enr_only'"!="enr_only" {
	gen csu_transfer_uc = 1 if csu_enr==1 & nsc_enr_uc==1
	replace csu_transfer_uc = 0 if csu_enr==1 & nsc_enr_uc==0
	replace csu_transfer_uc = . ///
		if (inlist(csu_enr_start_year, `max_csu_enr_year') & inlist(csu_enr_start_term, 4)) ///
		| (inlist(csu_enr_start_year, `max_csu_enr_year' + 1) & inlist(csu_enr_start_term, 1, 2, 3))
	label var csu_transfer_uc "Transfered to a University of California"

	gen csu_transfer_ucplus = 1 if csu_enr==1 & nsc_enr_ucplus==1
	replace csu_transfer_ucplus = 0 if csu_enr==1 & nsc_enr_ucplus==0
	replace csu_transfer_ucplus = . ///
		if (inlist(csu_enr_start_year, `max_csu_enr_year') & inlist(csu_enr_start_term, 4)) ///
		| (inlist(csu_enr_start_year, `max_csu_enr_year' + 1) & inlist(csu_enr_start_term, 1, 2, 3))
	label var csu_transfer_ucplus "Transfered to a University of California +"

	replace csu_persist_year2 = 1 if csu_persist_year2==0 & csu_transfer_ucplus==1
	replace csu_persist_year3 = 1 if csu_persist_year3==0 & csu_transfer_ucplus==1
}
tab grade year
