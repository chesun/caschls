version 16.0
cap log close _all

*****************************************************
* First created by Matthew Naven on July 1, 2021 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/msnaven/data"
	local cel_data "/home/research/ca_ed_lab/data"
	local crosswalks "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/crosswalks"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="naven" {
	local home "/Users/naven/Documents/research/ca_ed_lab/data"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="navenm" {
	local home "/Users/navenm/Documents/research/ca_ed_lab/data"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="Naven" {
	local home "/Users/Naven/Documents/research/ca_ed_lab/data"
}
cd `home'

log using log_files/crosswalk_k12_siblings.smcl, replace

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
	%12.0gc
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
clear

******** STAR/CST
**** CST
foreach year of numlist 2004 (1) 2013 {
	append using `cel_data'/restricted_access/clean/cst/cst_`year'.dta ///
		, keep( ///
		state_student_id birth_date year ///
		first_name middle_intl last_name ///
		street_address_line_one street_address_line_two city state zip_code ///
		)
}
drop if mi(last_name, street_address_line_one)
tempfile master
save `master'




**** Siblings based on year, last name, and address
use `master', clear

* Keep one observation per state student ID, year, name, and address
duplicates report state_student_id birth_date year first_name middle_intl last_name street_address_line_one street_address_line_two city state zip_code
duplicates drop state_student_id birth_date year first_name middle_intl last_name street_address_line_one street_address_line_two city state zip_code, force

* Group observations if they match on year, last name, and address
egen long siblings_name_address_year = group(year last_name street_address_line_one street_address_line_two city state zip_code), mi
tostring siblings_name_address_year, replace format("%17.0f")

* Drop if no siblings
bysort siblings_name_address_year: drop if _N==1

* Save data
keep siblings_name_address_year year state_student_id first_name middle_intl last_name birth_date street_address_line_one street_address_line_two city state zip_code
order siblings_name_address_year year state_student_id first_name middle_intl last_name birth_date street_address_line_one street_address_line_two city state zip_code
sort siblings_name_address_year year
compress
save `crosswalks'/k12_siblings_crosswalk_name_address_year.dta, replace




**** Siblings based on last name, and address
use `master', clear

* Keep one observation per state student ID, last name, and address
duplicates report state_student_id birth_date first_name middle_intl last_name birth_date street_address_line_one street_address_line_two city state zip_code
duplicates drop state_student_id birth_date first_name middle_intl last_name birth_date street_address_line_one street_address_line_two city state zip_code, force

* Group observations if they match on last name, and address
egen long siblings_name_address = group(last_name street_address_line_one street_address_line_two city state zip_code), mi
tostring siblings_name_address, replace format("%17.0f")

* Drop if no siblings
bysort siblings_name_address: drop if _N==1

* Save data
keep siblings_name_address state_student_id first_name middle_intl last_name birth_date street_address_line_one street_address_line_two city state zip_code
order siblings_name_address state_student_id first_name middle_intl last_name birth_date street_address_line_one street_address_line_two city state zip_code
sort siblings_name_address
compress
save `crosswalks'/k12_siblings_crosswalk_name_address.dta, replace





timer off 1
timer list
log close
translate log_files/crosswalk_k12_siblings.smcl log_files/crosswalk_k12_siblings.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
