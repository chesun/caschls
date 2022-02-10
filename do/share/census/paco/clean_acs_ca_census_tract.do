version 16.0
cap log close _all

*****************************************************
* First created by Matthew Naven on June 1, 2020 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/msnaven/data"
	local cel_data "/home/research/ca_ed_lab/data"
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

log using log_files/clean_acs_ca_census_tract.smcl, replace

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
Census tract information from 2017 5-year ACS estimates
Downloaded 1/13/2020
Note that 2018 5-year estimates will be available soon, but as of today it looks like not all topics including education and poverty are included in the Census website
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
**** Education
import delimited using public_access/raw/acs/ACS_17_5YR_S1501_with_ann.csv, clear varnames(1) case(lower)

foreach v of varlist * {
	label var `v' `"`=`v'[1]'"'
	char `v'[varlabel] `"`=`v'[1]'"'
}
drop if _n==1

foreach v of varlist hc* {
	destring `v', replace ignore(",+(X)-*")
}

* Education Level Proportions
gen educ_hs_dropout_prop = (hc01_est_vc09 + hc01_est_vc10) / hc01_est_vc08
gen educ_deg_hs_prop = hc01_est_vc11 / hc01_est_vc08
gen educ_some_college_prop = hc01_est_vc12 / hc01_est_vc08
gen educ_deg_2year_prop = hc01_est_vc13 / hc01_est_vc08
gen educ_deg_4year_prop = hc01_est_vc14 / hc01_est_vc08
gen educ_deg_grad_prop = hc01_est_vc15 / hc01_est_vc08
gen educ_deg_4year_plus_prop = (hc01_est_vc14 + hc01_est_vc15) / hc01_est_vc08

tempvar tot_prop
gen `tot_prop' = (hc01_est_vc09 + hc01_est_vc10 + hc01_est_vc11 + hc01_est_vc12 + hc01_est_vc13 + hc01_est_vc14 + hc01_est_vc15) / hc01_est_vc08
sum `tot_prop'

keep geoid geoid2 geodisplaylabel educ_*
gen year = 2017
order geoid geoid2 geodisplaylabel year
isid geoid
tempfile education
save `education'




**** Poverty
import delimited using public_access/raw/acs/ACS_17_5YR_S1702_with_ann.csv, clear varnames(1) case(lower)

foreach v of varlist * {
	label var `v' `"`=`v'[1]'"'
	char `v'[varlabel] `"`=`v'[1]'"'
}
drop if _n==1

foreach v of varlist hc* {
	destring `v', replace ignore(",+(X)-*N")
}

gen fam_child_lt18_tot = hc01_est_vc02
gen pov_fam_child_lt18_pct = hc02_est_vc02

keep geoid geoid2 geodisplaylabel fam_child_lt18_tot pov_fam_child_lt18_pct
gen year = 2017
order geoid geoid2 geodisplaylabel year
isid geoid
tempfile poverty
save `poverty'




**** Income
import delimited using public_access/raw/acs/ACS_17_5YR_S1901_with_ann.csv, clear varnames(1) case(lower)

foreach v of varlist * {
	label var `v' `"`=`v'[1]'"'
	char `v'[varlabel] `"`=`v'[1]'"'
}
drop if _n==1

foreach v of varlist hc* {
	destring `v', replace ignore(",+(X)-*N")
}

* Households (hc01)
egen inc_lt10k_hh_pct = rowtotal(hc01_est_vc02), mi
egen inc_lt15k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03), mi
egen inc_lt25k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03 hc01_est_vc04), mi
egen inc_lt35k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03 hc01_est_vc04 hc01_est_vc05), mi
egen inc_lt50k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03 hc01_est_vc04 hc01_est_vc05 hc01_est_vc06), mi
egen inc_lt75k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03 hc01_est_vc04 hc01_est_vc05 hc01_est_vc06 hc01_est_vc07), mi
egen inc_lt100k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03 hc01_est_vc04 hc01_est_vc05 hc01_est_vc06 hc01_est_vc07 hc01_est_vc08), mi
egen inc_lt150k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03 hc01_est_vc04 hc01_est_vc05 hc01_est_vc06 hc01_est_vc07 hc01_est_vc08 hc01_est_vc09), mi
egen inc_lt200k_hh_pct = rowtotal(hc01_est_vc02 hc01_est_vc03 hc01_est_vc04 hc01_est_vc05 hc01_est_vc06 hc01_est_vc07 hc01_est_vc08 hc01_est_vc09 hc01_est_vc10), mi

gen inc_median_hh = hc01_est_vc13
gen inc_mean_hh = hc01_est_vc15

* Families (hc02)
egen inc_lt10k_fam_pct = rowtotal(hc02_est_vc02), mi
egen inc_lt15k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03), mi
egen inc_lt25k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03 hc02_est_vc04), mi
egen inc_lt35k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03 hc02_est_vc04 hc02_est_vc05), mi
egen inc_lt50k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03 hc02_est_vc04 hc02_est_vc05 hc02_est_vc06), mi
egen inc_lt75k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03 hc02_est_vc04 hc02_est_vc05 hc02_est_vc06 hc02_est_vc07), mi
egen inc_lt100k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03 hc02_est_vc04 hc02_est_vc05 hc02_est_vc06 hc02_est_vc07 hc02_est_vc08), mi
egen inc_lt150k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03 hc02_est_vc04 hc02_est_vc05 hc02_est_vc06 hc02_est_vc07 hc02_est_vc08 hc02_est_vc09), mi
egen inc_lt200k_fam_pct = rowtotal(hc02_est_vc02 hc02_est_vc03 hc02_est_vc04 hc02_est_vc05 hc02_est_vc06 hc02_est_vc07 hc02_est_vc08 hc02_est_vc09 hc02_est_vc10), mi

gen inc_median_fam = hc02_est_vc13
gen inc_mean_fam = hc02_est_vc15

* Married-Couple Families (hc03)
egen inc_lt10k_mcfam_pct = rowtotal(hc03_est_vc02), mi
egen inc_lt15k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03), mi
egen inc_lt25k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03 hc03_est_vc04), mi
egen inc_lt35k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03 hc03_est_vc04 hc03_est_vc05), mi
egen inc_lt50k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03 hc03_est_vc04 hc03_est_vc05 hc03_est_vc06), mi
egen inc_lt75k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03 hc03_est_vc04 hc03_est_vc05 hc03_est_vc06 hc03_est_vc07), mi
egen inc_lt100k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03 hc03_est_vc04 hc03_est_vc05 hc03_est_vc06 hc03_est_vc07 hc03_est_vc08), mi
egen inc_lt150k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03 hc03_est_vc04 hc03_est_vc05 hc03_est_vc06 hc03_est_vc07 hc03_est_vc08 hc03_est_vc09), mi
egen inc_lt200k_mcfam_pct = rowtotal(hc03_est_vc02 hc03_est_vc03 hc03_est_vc04 hc03_est_vc05 hc03_est_vc06 hc03_est_vc07 hc03_est_vc08 hc03_est_vc09 hc03_est_vc10), mi

gen inc_median_mcfam = hc03_est_vc13
gen inc_mean_mcfam = hc03_est_vc15

* Non-Family Households (hc04)
egen inc_lt10k_nonfamhh_pct = rowtotal(hc04_est_vc02), mi
egen inc_lt15k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03), mi
egen inc_lt25k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03 hc04_est_vc04), mi
egen inc_lt35k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03 hc04_est_vc04 hc04_est_vc05), mi
egen inc_lt50k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03 hc04_est_vc04 hc04_est_vc05 hc04_est_vc06), mi
egen inc_lt75k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03 hc04_est_vc04 hc04_est_vc05 hc04_est_vc06 hc04_est_vc07), mi
egen inc_lt100k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03 hc04_est_vc04 hc04_est_vc05 hc04_est_vc06 hc04_est_vc07 hc04_est_vc08), mi
egen inc_lt150k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03 hc04_est_vc04 hc04_est_vc05 hc04_est_vc06 hc04_est_vc07 hc04_est_vc08 hc04_est_vc09), mi
egen inc_lt200k_nonfamhh_pct = rowtotal(hc04_est_vc02 hc04_est_vc03 hc04_est_vc04 hc04_est_vc05 hc04_est_vc06 hc04_est_vc07 hc04_est_vc08 hc04_est_vc09 hc04_est_vc10), mi

gen inc_median_nonfamhh = hc04_est_vc13
gen inc_mean_nonfamhh = hc04_est_vc15


keep geoid geoid2 geodisplaylabel inc_*
gen year = 2017
order geoid geoid2 geodisplaylabel year
isid geoid
tempfile income
save `income'




**** Population
import delimited using public_access/raw/acs/ACS_17_5YR_S0601_with_ann.csv, clear varnames(1) case(lower)

foreach v of varlist * {
	di "`v'"
	label var `v' `"`=`v'[1]'"'
	char `v'[varlabel] `"`=`v'[1]'"'
}
drop if _n==1

foreach v of varlist hc* {
	destring `v', replace ignore(",+(X)-*N")
}

gen pop_517_tot = hc01_est_vc01 * (hc01_est_vc04 / 100)
gen pop_lt18_tot = (hc01_est_vc01 * (hc01_est_vc03 / 100)) + (hc01_est_vc01 * (hc01_est_vc04 / 100))

gen pop_native_tot = hc02_est_vc01 + hc03_est_vc01 + hc04_est_vc01
gen pop_native_prop = (hc02_est_vc01 + hc03_est_vc01 + hc04_est_vc01) / hc01_est_vc01

gen pop_517_native_tot = (hc02_est_vc01 * (hc02_est_vc04 / 100)) + (hc03_est_vc01 * (hc03_est_vc04 / 100)) + (hc04_est_vc01 * (hc04_est_vc04 / 100))
gen pop_517_native_prop = ((hc02_est_vc01 * (hc02_est_vc04 / 100)) + (hc03_est_vc01 * (hc03_est_vc04 / 100)) + (hc04_est_vc01 * (hc04_est_vc04 / 100))) / (hc01_est_vc01 * (hc01_est_vc04 / 100))

gen pop_lt18_native_tot = ((hc02_est_vc01 * (hc02_est_vc03 / 100)) + (hc03_est_vc01 * (hc03_est_vc03 / 100)) + (hc04_est_vc01 * (hc04_est_vc03 / 100))) + ((hc02_est_vc01 * (hc02_est_vc04 / 100)) + (hc03_est_vc01 * (hc03_est_vc04 / 100)) + (hc04_est_vc01 * (hc04_est_vc04 / 100)))
gen pop_lt18_native_prop = (((hc02_est_vc01 * (hc02_est_vc03 / 100)) + (hc03_est_vc01 * (hc03_est_vc03 / 100)) + (hc04_est_vc01 * (hc04_est_vc03 / 100))) + ((hc02_est_vc01 * (hc02_est_vc04 / 100)) + (hc03_est_vc01 * (hc03_est_vc04 / 100)) + (hc04_est_vc01 * (hc04_est_vc04 / 100)))) / ((hc01_est_vc01 * (hc01_est_vc03 / 100)) + (hc01_est_vc01 * (hc01_est_vc04 / 100)))

sum pop_*

gen eth_white_pct = hc01_est_vc20
gen eth_black_pct = hc01_est_vc21
egen eth_other_pct = rowtotal(hc01_est_vc22 hc01_est_vc24 hc01_est_vc25 hc01_est_vc26)
gen eth_asian_pct = hc01_est_vc23

gen eth_hispanic_pct = hc01_est_vc28
gen eth_white_nonhispanic_pct = hc01_est_vc29

keep geoid geoid2 geodisplaylabel pop_* eth_*
gen year = 2017
order geoid geoid2 geodisplaylabel year
isid geoid
tempfile population
save `population'




**** Merge
use `population', clear
merge 1:1 geoid using `education'
assert _merge==3
drop _merge
merge 1:1 geoid using `poverty'
assert _merge==3
drop _merge
merge 1:1 geoid using `income'
assert _merge==3
drop _merge

compress
order geoid geoid2 geodisplaylabel year
sort geoid geoid2 year
save public_access/clean/acs/acs_ca_census_tract_clean.dta, replace


timer off 1
timer list
log close
translate log_files/clean_acs_ca_census_tract.smcl log_files/clean_acs_ca_census_tract.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
