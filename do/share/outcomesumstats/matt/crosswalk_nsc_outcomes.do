version 16.0
cap log close _all

*****************************************************
* First created by Matthew Naven on August 8, 2018 *
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

log using log_files/crosswalk_nsc_outcomes.smcl, replace

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
local ids_2010_2017 `""state_student_id" "cdscode local_student_id""'
local ids_2010_2018 `""state_student_id"'

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
foreach dataset in "2010_2017" "2010_2018" {
	di "Dataset = nsc_`dataset'_clean.dta"
	
	use `cel_data'/restricted_access/clean/nsc/nsc_`dataset'_clean.dta, clear

	gen nsc_enr = 1 if recordfoundyn=="Y"
	replace nsc_enr = 0 if recordfoundyn=="N"

	gen nsc_enr_ontime = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1))
	replace nsc_enr_ontime = 0 if recordfoundyn=="N"

	levelsof collegesequence, local(college_nums)
	local college_nums "1 2"
	/*foreach college_num of local college_nums {
		di "college_num = `college_num'"
		
		gen nsc_college_code_`college_num' = collegecodebranch if collegesequence==`college_num'
		gen nsc_college_name_`college_num' = collegename if collegesequence==`college_num'
		gen nsc_college_state_`college_num' = collegestate if collegesequence==`college_num'
		gen nsc_major1_`college_num' = enrollmentmajor1 if collegesequence==`college_num'
		gen nsc_major1_cip_`college_num' = enrollmentcip1 if collegesequence==`college_num'
		gen nsc_major2_`college_num' = enrollmentmajor2 if collegesequence==`college_num'
		gen nsc_major2_cip_`college_num' = enrollmentcip2 if collegesequence==`college_num'
		gen nsc_deg_title_`college_num' = degreetitle if collegesequence==`college_num'
		gen nsc_deg_major1_`college_num' = degreemajor1 if collegesequence==`college_num'
		gen nsc_deg_cip1_`college_num' = degreecip1 if collegesequence==`college_num'
		gen nsc_deg_major2_`college_num' = degreemajor2 if collegesequence==`college_num'
		gen nsc_deg_cip2_`college_num' = degreecip2 if collegesequence==`college_num'
		gen nsc_deg_major3_`college_num' = degreemajor3 if collegesequence==`college_num'
		gen nsc_deg_cip3_`college_num' = degreecip3 if collegesequence==`college_num'
		gen nsc_deg_major4_`college_num' = degreemajor4 if collegesequence==`college_num'
		gen nsc_deg_cip4_`college_num' = degreecip4 if collegesequence==`college_num'
		gen nsc_college_type_`college_num' = college_type if collegesequence==`college_num'
		gen nsc_public_`college_num' = public if collegesequence==`college_num'
		gen nsc_deg_`college_num' = degree if collegesequence==`college_num'
	}*/

	gen nsc_enr_4year = 1 if recordfoundyn=="Y" ///
		& college_type==4
	gen nsc_enr_2year = 1 if recordfoundyn=="Y" ///
		& college_type==2
	gen nsc_enr_lt2year = 1 if recordfoundyn=="Y" ///
		& college_type==1

	gen nsc_enr_ontime_4year = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==4
	gen nsc_enr_ontime_2year = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==2
	gen nsc_enr_ontime_lt2year = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==1

	gen nsc_enr_pub = 1 if recordfoundyn=="Y" ///
		& public==1
	gen nsc_enr_priv = 1 if recordfoundyn=="Y" ///
		& public==0

	gen nsc_enr_ontime_pub = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& public==1
	gen nsc_enr_ontime_priv = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& public==0

	gen nsc_enr_4year_pub = 1 if recordfoundyn=="Y" ///
		& college_type==4 & public==1
	gen nsc_enr_4year_priv = 1 if recordfoundyn=="Y" ///
		& college_type==4 & public==0
	gen nsc_enr_2year_pub = 1 if recordfoundyn=="Y" ///
		& college_type==2 & public==1
	gen nsc_enr_2year_priv = 1 if recordfoundyn=="Y" ///
		& college_type==2 & public==0
	gen nsc_enr_lt2year_pub = 1 if recordfoundyn=="Y" ///
		& college_type==1 & public==1
	gen nsc_enr_lt2year_priv = 1 if recordfoundyn=="Y" ///
		& college_type==1 & public==0

	gen nsc_enr_ontime_4year_pub = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==4 & public==1
	gen nsc_enr_ontime_4year_priv = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==4 & public==0
	gen nsc_enr_ontime_2year_pub = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==2 & public==1
	gen nsc_enr_ontime_2year_priv = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==2 & public==0
	gen nsc_enr_ontime_lt2year_pub = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==1 & public==1
	gen nsc_enr_ontime_lt2year_priv = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==1 & public==0

	gen nsc_enr_instate = 1 if recordfoundyn=="Y" ///
		& collegestate=="CA"
	gen nsc_enr_outstate = 1 if recordfoundyn=="Y" ///
		& collegestate!="CA" & !mi(collegestate)

	gen nsc_enr_ontime_instate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& collegestate=="CA"
	gen nsc_enr_ontime_outstate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& collegestate!="CA" & !mi(collegestate)

	gen nsc_enr_4year_instate = 1 if recordfoundyn=="Y" ///
		& college_type==4 & collegestate=="CA"
	gen nsc_enr_4year_outstate = 1 if recordfoundyn=="Y" ///
		& college_type==4 & collegestate!="CA" & !mi(collegestate)
	gen nsc_enr_2year_instate = 1 if recordfoundyn=="Y" ///
		& college_type==2 & collegestate=="CA"
	gen nsc_enr_2year_outstate = 1 if recordfoundyn=="Y" ///
		& college_type==2 & collegestate!="CA" & !mi(collegestate)
	gen nsc_enr_lt2year_instate = 1 if recordfoundyn=="Y" ///
		& college_type==1 & collegestate=="CA"
	gen nsc_enr_lt2year_outstate = 1 if recordfoundyn=="Y" ///
		& college_type==1 & collegestate!="CA" & !mi(collegestate)

	gen nsc_enr_ontime_4year_instate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==4 & collegestate=="CA"
	gen nsc_enr_ontime_4year_outstate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==4 & collegestate!="CA" & !mi(collegestate)
	gen nsc_enr_ontime_2year_instate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==2 & collegestate=="CA"
	gen nsc_enr_ontime_2year_outstate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==2 & collegestate!="CA" & !mi(collegestate)
	gen nsc_enr_ontime_lt2year_instate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==1 & collegestate=="CA"
	gen nsc_enr_ontime_lt2year_outstate = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& college_type==1 & collegestate!="CA" & !mi(collegestate)

	gen nsc_enr_uc = 1 if recordfoundyn=="Y" ///
		& inlist(collegecodebranch, "001312-00", "001313-00", "001320-00", "001315-00", "001316-00", "001317-00", "001314-00", "001321-00", "041271-00") | inlist(collegecodebranch, "001319-00")
	* UC + Stanford, California Institute of Technology, University of Southern California
	gen nsc_enr_ucplus = 1 if recordfoundyn=="Y" ///
		& (inlist(collegecodebranch, "001312-00", "001313-00", "001320-00", "001315-00", "001316-00", "001317-00", "001314-00", "001321-00", "041271-00") | inlist(collegecodebranch, "001319-00") ///
		| inlist(collegecodebranch, "001305-00", "001131-00", "001328-00"))

	gen nsc_enr_ontime_uc = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& inlist(collegecodebranch, "001312-00", "001313-00", "001320-00", "001315-00", "001316-00", "001317-00", "001314-00", "001321-00", "041271-00") | inlist(collegecodebranch, "001319-00")
	* UC + Stanford, California Institute of Technology, University of Southern California
	gen nsc_enr_ontime_ucplus = 1 if recordfoundyn=="Y" ///
		& inrange(enrollment_begin, mdy(8, 1, year(search_date)), mdy(month(search_date), day(search_date), year(search_date) + 1)) ///
		& (inlist(collegecodebranch, "001312-00", "001313-00", "001320-00", "001315-00", "001316-00", "001317-00", "001314-00", "001321-00", "041271-00") | inlist(collegecodebranch, "001319-00") ///
		| inlist(collegecodebranch, "001305-00", "001131-00", "001328-00"))

	gen nsc_deg = 1 if degree==1

	gen nsc_deg_4year = 1 if degree==1 & college_type==4
	gen nsc_deg_2year = 1 if degree==1 & college_type==2
	gen nsc_deg_lt2year = 1 if degree==1 & college_type==1

	compress
	tempfile nsc_`dataset'
	save `nsc_`dataset''


	**** Save Dataset by State/Local Student ID
	foreach id of local ids_`dataset' {
		di "ID = `id'"
		
		if "`id'"=="state_student_id" {
			use `nsc_`dataset'' if !mi(state_student_id), clear
			
			egen tag_college_code = tag(`id' collegecodebranch) if !mi(state_student_id)
		}
		
		if "`id'"=="cdscode local_student_id" {
			use `nsc_`dataset'' if mi(state_student_id), clear
			
			egen tag_college_code = tag(`id' collegecodebranch) if mi(state_student_id)
		}
		
		gen nsc_enr_n_4year = 1 if college_type==4 & tag_college_code==1
		gen nsc_enr_n_2year = 1 if college_type==2 & tag_college_code==1
		gen nsc_enr_n_lt2year = 1 if college_type==1 & tag_college_code==1
		
		egen college_begin_date = min(enrollment_begin), by(`id' collegecodebranch)
		
		gen persist_year2_min_date = mdy( ///
			cond(mod(month(college_begin_date) + 11, 12)==0, 12, mod(month(college_begin_date) + 11, 12), .), ///
			min(day(college_begin_date), 28), ///
			year(college_begin_date) + cond(mod(month(college_begin_date) + 11, 12)==0, floor((month(college_begin_date) + 11) / 12) - 1, floor((month(college_begin_date) + 11) / 12), .) ///
			)
		gen persist_year2_max_date = mdy( ///
			cond(mod(month(college_begin_date) + 13, 12)==0, 12, mod(month(college_begin_date) + 13, 12), .), ///
			min(day(college_begin_date), 28), ///
			year(college_begin_date) + cond(mod(month(college_begin_date) + 13, 12)==0, floor((month(college_begin_date) + 13) / 12) - 1, floor((month(college_begin_date) + 13) / 12), .) ///
			)
		gen nsc_persist_year2 = 1 if inrange(enrollment_begin, persist_year2_min_date, persist_year2_max_date)
		gen nsc_persist_year2_4year = 1 if inrange(enrollment_begin, persist_year2_min_date, persist_year2_max_date) & college_type==4
		gen nsc_persist_year2_2year = 1 if inrange(enrollment_begin, persist_year2_min_date, persist_year2_max_date) & college_type==2
		
		gen persist_year3_min_date = mdy( ///
			cond(mod(month(college_begin_date) + 11, 12)==0, 12, mod(month(college_begin_date) + 11, 12), .), ///
			min(day(college_begin_date), 28), ///
			year(college_begin_date) + 1 + cond(mod(month(college_begin_date) + 11, 12)==0, floor((month(college_begin_date) + 11) / 12) - 1, floor((month(college_begin_date) + 11) / 12), .) ///
			)
		gen persist_year3_max_date = mdy( ///
			cond(mod(month(college_begin_date) + 13, 12)==0, 12, mod(month(college_begin_date) + 13, 12), .), ///
			min(day(college_begin_date), 28), ///
			year(college_begin_date) + 1 + cond(mod(month(college_begin_date) + 13, 12)==0, floor((month(college_begin_date) + 13) / 12) - 1, floor((month(college_begin_date) + 13) / 12), .) ///
			)
		gen nsc_persist_year3 = 1 if inrange(enrollment_begin, persist_year3_min_date, persist_year3_max_date)
		gen nsc_persist_year3_4year = 1 if inrange(enrollment_begin, persist_year3_min_date, persist_year3_max_date) & college_type==4
		
		gen persist_year4_min_date = mdy( ///
			cond(mod(month(college_begin_date) + 11, 12)==0, 12, mod(month(college_begin_date) + 11, 12), .), ///
			min(day(college_begin_date), 28), ///
			year(college_begin_date) + 2 + cond(mod(month(college_begin_date) + 11, 12)==0, floor((month(college_begin_date) + 11) / 12) - 1, floor((month(college_begin_date) + 11) / 12), .) ///
			)
		gen persist_year4_max_date = mdy( ///
			cond(mod(month(college_begin_date) + 13, 12)==0, 12, mod(month(college_begin_date) + 13, 12), .), ///
			min(day(college_begin_date), 28), ///
			year(college_begin_date) + 2 + cond(mod(month(college_begin_date) + 13, 12)==0, floor((month(college_begin_date) + 13) / 12) - 1, floor((month(college_begin_date) + 13) / 12), .) ///
			)
		gen nsc_persist_year4 = 1 if inrange(enrollment_begin, persist_year4_min_date, persist_year4_max_date)
		gen nsc_persist_year4_4year = 1 if inrange(enrollment_begin, persist_year4_min_date, persist_year4_max_date) & college_type==4
		
		sort `id' enrollment_begin
		collapse ///
			(max) nsc_enr ///
			nsc_enr_ontime ///
			nsc_enr_4year nsc_enr_2year nsc_enr_lt2year ///
			nsc_enr_ontime_4year nsc_enr_ontime_2year nsc_enr_ontime_lt2year ///
			nsc_enr_pub nsc_enr_priv ///
			nsc_enr_ontime_pub nsc_enr_ontime_priv ///
			nsc_enr_4year_pub nsc_enr_4year_priv nsc_enr_2year_pub nsc_enr_2year_priv nsc_enr_lt2year_pub nsc_enr_lt2year_priv ///
			nsc_enr_ontime_4year_pub nsc_enr_ontime_4year_priv nsc_enr_ontime_2year_pub nsc_enr_ontime_2year_priv nsc_enr_ontime_lt2year_pub nsc_enr_ontime_lt2year_priv ///
			nsc_enr_instate nsc_enr_outstate ///
			nsc_enr_ontime_instate nsc_enr_ontime_outstate ///
			nsc_enr_4year_instate nsc_enr_4year_outstate nsc_enr_2year_instate nsc_enr_2year_outstate nsc_enr_lt2year_instate nsc_enr_lt2year_outstate ///
			nsc_enr_ontime_4year_instate nsc_enr_ontime_4year_outstate nsc_enr_ontime_2year_instate nsc_enr_ontime_2year_outstate nsc_enr_ontime_lt2year_instate nsc_enr_ontime_lt2year_outstate ///
			nsc_enr_uc nsc_enr_ucplus ///
			nsc_enr_ontime_uc nsc_enr_ontime_ucplus ///
			nsc_persist_year2 nsc_persist_year2_4year nsc_persist_year2_2year ///
			nsc_persist_year3 nsc_persist_year3_4year ///
			nsc_persist_year4 nsc_persist_year4_4year ///
			nsc_deg nsc_deg_4year nsc_deg_2year nsc_deg_lt2year ///
			(rawsum) nsc_enr_n_4year nsc_enr_n_2year nsc_enr_n_lt2year ///
			/*(firstnm) degree_title_* degree_major1_* degree_major2_* degree_major3_* degree_major4_**/ ///
			, by(`id')
		
		foreach v of varlist nsc_enr ///
			nsc_enr_ontime ///
			nsc_enr_4year nsc_enr_2year nsc_enr_lt2year ///
			nsc_enr_ontime_4year nsc_enr_ontime_2year nsc_enr_ontime_lt2year ///
			nsc_enr_pub nsc_enr_priv ///
			nsc_enr_ontime_pub nsc_enr_ontime_priv ///
			nsc_enr_4year_pub nsc_enr_4year_priv nsc_enr_2year_pub nsc_enr_2year_priv nsc_enr_lt2year_pub nsc_enr_lt2year_priv ///
			nsc_enr_ontime_4year_pub nsc_enr_ontime_4year_priv nsc_enr_ontime_2year_pub nsc_enr_ontime_2year_priv nsc_enr_ontime_lt2year_pub nsc_enr_ontime_lt2year_priv ///
			nsc_enr_instate nsc_enr_outstate ///
			nsc_enr_ontime_instate nsc_enr_ontime_outstate ///
			nsc_enr_4year_instate nsc_enr_4year_outstate nsc_enr_2year_instate nsc_enr_2year_outstate nsc_enr_lt2year_instate nsc_enr_lt2year_outstate ///
			nsc_enr_ontime_4year_instate nsc_enr_ontime_4year_outstate nsc_enr_ontime_2year_instate nsc_enr_ontime_2year_outstate nsc_enr_ontime_lt2year_instate nsc_enr_ontime_lt2year_outstate ///
			nsc_enr_uc nsc_enr_ucplus ///
			nsc_enr_ontime_uc nsc_enr_ontime_ucplus ///
			nsc_persist_year2 nsc_persist_year2_4year nsc_persist_year2_2year ///
			nsc_persist_year3 nsc_persist_year3_4year ///
			nsc_persist_year4 nsc_persist_year4_4year ///
			nsc_deg nsc_deg_4year nsc_deg_2year nsc_deg_lt2year ///
			nsc_enr_n_4year nsc_enr_n_2year nsc_enr_n_lt2year ///
			nsc_enr_n_4year nsc_enr_n_2year nsc_enr_n_lt2year {
			replace `v' = 0 if mi(`v')
		}
		
		compress
		sort `id'
		
		if "`id'"=="state_student_id" {
			save restricted_access/clean/crosswalks/nsc_`dataset'_outcomes_crosswalk_ssid.dta, replace
		}
		
		if "`id'"=="cdscode local_student_id" {
			save restricted_access/clean/crosswalks/nsc_`dataset'_outcomes_crosswalk_lsid.dta, replace
		}
	}
}


timer off 1
timer list
log close
translate log_files/crosswalk_nsc_outcomes.smcl log_files/crosswalk_nsc_outcomes.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
