version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on September 18, 2018 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/msnaven/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
	local public_access "/home/research/ca_ed_lab/data/public_access"
	local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
	local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"
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

log using log_files/sbac/va_cfr_out_tab.smcl, replace

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
This do file creates tables for the estimates of school test score value added 
on long-run outcomes controlling for school test score value added.
*/


**********
* Macros *
**********
#delimit ;
local esttab_reg
	b(%5.3f) se(%4.3f)
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar
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
	va_*
	)
	order(
	va_*
	)
	;
#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
foreach outcome in enr enr_2year enr_4year {
	foreach subject in ela math {
		**** No Peer Controls
		** No TFX
		estimates use estimates/sbac/vam_cfr_g11_`outcome'_`subject'.ster
		eststo cfr_`outcome'_`subject'

		** TFX
		estimates use estimates/sbac/vam_tfx_g11_`outcome'_`subject'.ster
		eststo tfx_`outcome'_`subject'

		**** Peer Controls
		** No TFX
		estimates use estimates/sbac/vam_cfr_g11_`outcome'_`subject'_peer.ster
		eststo cfr_`outcome'_`subject'_peer

		** TFX
		estimates use estimates/sbac/vam_tfx_g11_`outcome'_`subject'_peer.ster
		eststo tfx_`outcome'_`subject'_peer
	}
	
	**** No Peer Controls
	** No TFX
	estimates use estimates/sbac/vam_cfr_g11_`outcome'_dk.ster
	eststo cfr_`outcome'

	** TFX
	estimates use estimates/sbac/vam_tfx_g11_`outcome'_dk.ster
	eststo tfx_`outcome'

	**** Peer Controls
	** No TFX
	estimates use estimates/sbac/vam_cfr_g11_`outcome'_dk_peer.ster
	eststo cfr_`outcome'_peer

	** TFX
	estimates use estimates/sbac/vam_tfx_g11_`outcome'_dk_peer.ster
	eststo tfx_`outcome'_peer
}




**** No Peer Controls
** No TFX
esttab cfr_enr_ela cfr_enr_math cfr_enr cfr_enr_2year_ela cfr_enr_2year_math cfr_enr_2year cfr_enr_4year_ela cfr_enr_4year_math cfr_enr_4year ///
	using tables/sbac/vam_cfr_g11.tex, ///
	`esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' `esttab_manual' prefoot(\midrule) ///
	coeflabel( ///
		enr_ontime "Enrolled" ///
		enr_ontime_2year "Enrolled 2-Year" ///
		enr_ontime_4year "Enrolled 4-Year" ///
		va_cfr_g11_ela "ELA VA" ///
		va_cfr_g11_math "Math VA" ///
	)

timer off 1
timer list
log close
translate log_files/sbac/va_cfr_out_tab.smcl log_files/sbac/va_cfr_out_tab.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
