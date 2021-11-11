version 15.0
cap log close _all

*****************************************************
* First created by Matthew Naven on March 25, 2019 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/common_core_va"
	local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
	local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"
	local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="naven" {
	local home "/Users/naven/Documents/research/ca_ed_lab/common_core_va"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="navenm" {
	local home "/Users/navenm/Documents/research/ca_ed_lab/common_core_va"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="Naven" {
	local home "/Users/Naven/Documents/research/ca_ed_lab/common_core_va"
}
cd `home'

log using log_files/sbac/clean_address_list.smcl, replace

clear all
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
/* Color Order
color p       gs6
color p1      navy
color p2      maroon
color p3      forest_green
color p4      dkorange
color p5      teal
color p6      cranberry
color p7      lavender
color p8      khaki
color p9      sienna
color p10     emidblue
color p11     emerald
color p12     brown
color p13     erose
color p14     gold
color p15     bluishgray
*/
/* Marker Symbol Order
circle             O
diamond            D
triangle           T
square             S
plus               +
X                  X
arrowf             A
arrow              a
pipe               |
V                  V
*/
/* Line Pattern Order
solid
dash
dot
dash_dot
shortdash
shortdash_dot
longdash
longdash_dot
*/
set seed 1984


***************
* Description *
***************
/*

*/


**********
* Macros *
**********
#delimit ;
local esttab_reg
	b(%12.3gc) se(%12.3gc)
	star(* 0.1 ** 0.05 *** 0.01)
	;
local esttab_sum_stats
	main(mean %12.3gc) aux(sd %12.3gc)
	brackets
	nomtitles nonumbers nonotes
	;
local esttab_tab_stat
	cells(mean(fmt(%12.3gc)) sd(fmt(%12.3gc) par([ ])) count(fmt(%12.3gc) par(\{ \})))
	nomtitles nonumbers nonotes collabels(none)
	;
local esttab_scalars
	scalars(
	"N Observations"
	"r2 $ R^2 $"
	)
	sfmt(
	%12.3gc
	%12.3g
	)
	noobs
	;
local esttab_layout
	compress
	label interaction(\times)
	booktabs
	replace
	;
local esttab_manual
	nolines
	nomtitles nonumbers nonotes
	fragment
	;
local esttab_mgroups
	nomtitles
	mgroups(""
	, pattern()
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
	;
local esttab_keep
	keep(
	
	)
	order(
	
	)
	;
#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
**************** Create VA sample list of state student IDs
use merge_id_k12_test_scores state_student_id student_id year cdscode ///
	/*if substr(cdscode, 1, 7)=="3768338"*/ ///
	using `k12_test_scores'/k12_test_scores_clean.dta, clear
count

merge 1:1 merge_id_k12_test_scores using data/sbac/va_samples.dta ///
	, nogen keep(3) keepusing(touse*)
keep if touse_g11_ela==1 | touse_g11_math==1 | touse_g11_enr==1 | touse_g11_enr_2year==1 | touse_g11_enr_4year==1

keep state_student_id
duplicates report
duplicates drop
compress
tempfile va_sample_ssid
save `va_sample_ssid'

**************** Create 6th grade addresses
use merge_id_k12_test_scores state_student_id student_id cdscode year grade ///
	street_address_line_one street_address_line_two city state zip_code ///
	/*if substr(cdscode, 1, 7)=="3768338"*/ ///
	using `k12_test_scores'/k12_test_scores_clean.dta, clear
count

keep if grade==6 & inrange(year, 2015-(11-6), 2017-(11-6))

drop if mi(state_student_id)
duplicates report state_student_id
duplicates tag state_student_id, gen(dup_ssid)
egen year_min = min(year) if dup_ssid!=0, by(state_student_id)
drop if year!=year_min & dup_ssid!=0
duplicates report state_student_id
duplicates drop state_student_id, force
merge 1:1 state_student_id using `va_sample_ssid' ///
	, nogen keep(3)

keep state_student_id student_id street_address_line_one street_address_line_two city state zip_code
compress
tempfile address_g6
save `address_g6'

**************** Merge VA sample to 6th grade addresses
use merge_id_k12_test_scores state_student_id student_id year cdscode ///
	/*if substr(cdscode, 1, 7)=="3768338"*/ ///
	using `k12_test_scores'/k12_test_scores_clean.dta, clear

count
merge 1:1 merge_id_k12_test_scores using data/sbac/va_samples.dta ///
	, nogen keep(3) keepusing(touse*)
keep if touse_g11_ela==1 | touse_g11_math==1 | touse_g11_enr==1 | touse_g11_enr_2year==1 | touse_g11_enr_4year==1

count
merge 1:1 state_student_id using `address_g6' ///
	, nogen keep(3)


**************** Create address list
pause
keep year street_address_line_one street_address_line_two city state zip_code
duplicates drop

drop if mi(street_address_line_one) & mi(street_address_line_two) & mi(city) & mi(state) & mi(zip_code)

egen long address_year_id_full = group(street_address_line_one street_address_line_two city state zip_code year), missing
tostring address_year_id_full, replace format("%17.0f")
isid address_year_id_full

egen long address_year_id = group(street_address_line_one city state zip_code year), missing
tostring address_year_id, replace format("%17.0f")

egen long address_id_full = group(street_address_line_one street_address_line_two city state zip_code), missing
tostring address_id_full, replace format("%17.0f")
isid address_id_full year

egen long address_id = group(street_address_line_one city state zip_code), missing
tostring address_id, replace format("%17.0f")

compress
save data/sbac/address_list.dta, replace




**** Census
use data/sbac/address_list.dta, clear

keep address_id street_address_line_one city state zip_code
duplicates drop

replace zip_code = substr(zip_code, 1, 5) + "-" + substr(zip_code, 6, 4) if strlen(zip_code)==9

** Individual fields
replace street_address_line_one = trim(itrim(upper(street_address_line_one)))
replace city = trim(itrim(upper(city)))
replace state = trim(itrim(upper(state)))
replace zip_code = trim(itrim(upper(zip_code)))

keep address_id street_address_line_one city state zip_code
duplicates drop

count
compress
order address_id street_address_line_one city state zip_code
export delimited data/sbac/address_list_census.csv, replace delimiter(tab) nolabel

** Single field
gen address_census = `"""' + trim(itrim(upper(street_address_line_one))) + `"""' ///
	+ ", " + trim(itrim(upper(city))) ///
	+ ", " + trim(itrim(upper(state))) ///
	+ ", " + trim(itrim(upper(zip_code)))

keep address_id address_census
duplicates drop

count
compress
order address_id address_census
export delimited data/sbac/address_list_census.csv, replace delimiter(tab) nolabel quote
*save restricted_access/clean/crosswalks/address_list_census.dta, replace



timer off 1
timer list
log close
translate log_files/sbac/clean_address_list.smcl log_files/sbac/clean_address_list.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
