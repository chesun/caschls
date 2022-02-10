version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on June 6, 2019 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/projects/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local k12_test_scores "`home'/data/restricted_access/clean/k12_test_scores"
	local public_access "`home'/data/public_access"
	local k12_public_schools "`public_access'/clean/k12_public_schools"
	local k12_test_scores_public "`public_access'/clean/k12_test_scores"
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

log using log_files/sbac/prob_enr.smcl, replace

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
This do file runs an ordered probit for no college, 2-year college, and 4-year 
university in order to get predicted probabilities of each outcome for each 
student.
*/


**********
* Macros *
**********
include do_files/sbac/macros_va.doh

#delimit ;

#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
******************************** Value Added Sample
include do_files/sbac/create_va_sample.doh

******** Postsecondary Outcomes
do do_files/merge_k12_postsecondary.doh enr_only
drop enr enr_2year enr_4year
rename enr_ontime enr
rename enr_ontime_2year enr_2year
rename enr_ontime_4year enr_4year

gen enr_years = 0 if enr==0
replace enr_years = 2 if enr_2year==1
replace enr_years = 4 if enr_4year==1

* Save temporary dataset
compress
tempfile va_dataset
save `va_dataset'
































******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
include do_files/sbac/create_va_g11_out_sample.doh
keep if touse_g11_enr==1 | touse_g11_enr_2year==1 | touse_g11_enr_4year==1

**************** Ordered Probit
**** No Peer Controls
oprobit enr_years ///
	i.year ///
	`school_controls' ///
	`demographic_controls' ///
	`ela_score_controls' ///
	`math_score_controls'
predict enr_0year_prob, pr outcome(0)
predict enr_2year_prob, pr outcome(2)
predict enr_4year_prob, pr outcome(4)

**** Peer Controls
oprobit enr_years ///
	i.year ///
	`school_controls' ///
	`demographic_controls' ///
	`ela_score_controls' ///
	`math_score_controls' ///
	`peer_demographic_controls' ///
	`peer_ela_score_controls' ///
	`peer_math_score_controls'
predict enr_0year_prob_peer, pr outcome(0)
predict enr_2year_prob_peer, pr outcome(2)
predict enr_4year_prob_peer, pr outcome(4)


keep merge_id_k12_test_scores enr_*_prob*
compress
save data/sbac/enr_prob.dta, replace


timer off 1
timer list
log close
translate log_files/sbac/prob_enr.smcl log_files/sbac/prob_enr.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
