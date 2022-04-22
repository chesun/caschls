********************************************************************************
/* do file to run forecast bias test on sibling long run outcomes VA sample, using
census tract variables as leave out variables . */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on April 14. 2022 ***************************

/* To run this do file:

do $projdir/do/share/siblingvaregs/va_sibling_out_forecast_bias

 */

clear all
set more off
set varabbrev off
set scheme s1color
//capture log close: Stata should not complain if there is no log open to close
cap log close _all

/* set trace on
set tracedepth 1 */

args setlimit

/* file path macros for datasets */
include $projdir/do/share/siblingvaregs/vafilemacros.doh

//change directory to common_core_va project directory
cd $vaprojdir

//starting log file
log using $projdir/log/share/siblingvaregs/va_sibling_out_forecast_bias.smcl, replace

//run the do helper file to set the local macros
include `vaprojdofiles'/sbac/macros_va.doh

#delimit ;
#delimit cr
macro list


timer on 1



********************************************************************************

//load the VA grade 11 college outcomes sample
use `va_g11_out_dataset', clear

//merge on to sibling outcomes crosswalk to get sibling enrollment controls
merge m:1 state_student_id using `sibling_out_xwalk', nogen keep(1 3)

drop if mi(has_older_sibling_enr_2year)
drop if mi(has_older_sibling_enr_4year)

compress
tempfile va_g11_out_sibling_dataset
save `va_g11_out_sibling_dataset'



********************************************************************************
*********** VA estimates for sibling VA sample matched to census tract sample
********************************************************************************

local drift_limit = max(`test_score_max_year' - `test_score_min_year' - 1, 1)



foreach outcome in enr enr_2year enr_4year {

  *************** Census Tract Forecast Bias Test for Sibling Long Run Outcome VA

  // dataset with geocoded addresses
  import delimited data/restricted_access/clean/crosswalks/address_list_census_batch_geocoded.csv ///
		, delimiter(tab) varnames(1) case(lower) stringcols(_all) clear
	rename id address_id
	gen census_sct = statefp + countyfp + tract
	keep address_id census_sct
	compress
	tempfile census_geocode
	save `census_geocode'

  // use the k12 test scores data
	use merge_id_k12_test_scores state_student_id student_id cdscode year grade ///
		street_address_line_one street_address_line_two city state zip_code ///
		using `k12_test_scores'/k12_test_scores_clean.dta, clear
	// keep students who are in grade 6 in 2010 to 2013 (2015-2018 11th graders)
	keep if grade==`census_grade' & inrange(year, `outcome_min_year'-(11-`census_grade'), `outcome_max_year'-(11-`census_grade'))
	drop if mi(state_student_id)
	// tag duplicates by student id
	duplicates tag state_student_id, gen(dup_ssid)
	// for students who have more than 1 observations, keep the observation with the earliest year
	egen year_min = min(year) if dup_ssid!=0, by(state_student_id)
	drop if year!=year_min & dup_ssid!=0
	duplicates drop state_student_id, force
	rename year year_grade`census_grade'
	keep state_student_id student_id year_grade`census_grade' street_address_line_one street_address_line_two city state zip_code
	compress
	tempfile lagged_address
	save `lagged_address'

  use data/restricted_access/clean/crosswalks/address_list.dta, clear
	keep address_id street_address_line_one city state zip_code
	duplicates drop
	compress
	tempfile address_id
	save `address_id'

	use data/public_access/clean/acs/acs_ca_census_tract_clean.dta, clear
	rename year year_grade`census_grade'
	compress
	tempfile lagged_acs
	save `lagged_acs'


  /* load the VA g11 subject sample with siblings outcome sample
  (those who have at least one older sibling matched to the postsecondary
  outcomes) */
  use `va_g11_out_sibling_dataset' if touse_g11_`outcome'==1 & sibling_out_sample == 1, clear
  merge m:1 state_student_id using `lagged_address' ///
		, keep(3) keepusing(street_address_line_one city state zip_code year_grade`census_grade') gen(merge_lagged_address)
	merge m:1 street_address_line_one city state zip_code using `address_id' ///
		, keep(3) gen(merge_address_id)
	merge m:1 address_id using `census_geocode' ///
		, keep(3) gen(merge_census_geocode)
	rename census_sct geoid2
	merge m:1 geoid2 year_grade`census_grade' using `lagged_acs' ///
		, keep(3) gen(merge_acs)
	rename geoid2 census_sct
	foreach v of varlist `census_controls' {
		drop if mi(`v')
	}





  **************** College Outcome VA without sibling controls
  ************** No peer controls
  ************* No TFX
  vam `outcome' ///
    , teacher(school_id) year(year) class(school_id) ///
    controls( ///
      i.year ///
      `school_controls' ///
      `demographic_controls' ///
      `ela_score_controls' ///
      `math_score_controls' ///
    ) ///
    data(merge tv score_r) ///
    driftlimit(`drift_limit') ///
    estimates($vaprojdir/estimates/sibling_va/outcome_va/vam_`outcome'_census_nosib_noacs.ster, replace)
  rename tv va_`outcome'_nosib_noacs
  rename score_r `outcome'_r_nosib_noacs

  ***** Spec Test: no peer controls, no tfx, no sibling controls
  reg `outcome'_r_nosib_noacs va_`outcome'_nosib_noacs, cluster(school_id)
  //save to my personal folder
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_`outcome'_census_nosib_noacs.ster, replace
  //save to va project folder
  estimates save $vaprojdir/estimates/sibling_va/outcome_va/spec_test_`outcome'_census_nosib_noacs.ster, replace




  **************** College Outcome VA with sibling controls
  ************** No peer controls
  ************* No TFX

  vam `outcome' ///
    , teacher(school_id) year(year) class(school_id) ///
    controls( ///
      i.year ///
      i.has_older_sibling_enr_2year ///
      i.has_older_sibling_enr_4year ///
      `school_controls' ///
      `demographic_controls' ///
      `ela_score_controls' ///
      `math_score_controls' ///
    ) ///
    data(merge tv score_r) ///
    driftlimit(`drift_limit') ///
    estimates($vaprojdir/estimates/sibling_va/outcome_va/vam_`outcome'_census_noacs.ster, replace)

    rename tv va_`outcome'_noacs
    rename score_r `outcome'_r_noacs

    ***** Spec Test: no peer controls, no tfx, with sibling controls
    reg `outcome'_r_noacs va_`outcome'_noacs, cluster(school_id)
    //save to my personal folder
    estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_`outcome'_census_noacs.ster, replace
    //save to va project folder
    estimates save $vaprojdir/estimates/sibling_va/outcome_va/spec_test_`outcome'_census_noacs.ster, replace



    **************** College Outcome VA with sibling controls and census controls
    ************** No peer controls
    ************* No TFX
    vam `outcome' ///
      , teacher(school_id) year(year) class(school_id) ///
      controls( ///
        i.year ///
        i.has_older_sibling_enr_2year ///
        i.has_older_sibling_enr_4year ///
        `school_controls' ///
        `demographic_controls' ///
        `ela_score_controls' ///
        `math_score_controls' ///
        `census_controls' ///
      ) ///
      data(merge tv score_r) ///
      driftlimit(`drift_limit') ///
      estimates($vaprojdir/estimates/sibling_va/outcome_va/vam_`outcome'_sib_census.ster, replace)

      rename tv va_`outcome'_sib_census
      rename score_r `outcome'_r_sib_census


      ***** Forecast bias test for sibling census sample: census controls as leave out var
      gen `outcome'_r_d = `outcome'_r_noacs - `outcome'_r_sib_census
      reg `outcome'_r_d va_`outcome'_noacs, cluster(school_id)
      estimates save $projdir/est/siblingvaregs/outcome_va/fb_test_`outcome'_census.ster, replace
      estimates save $vaprojdir/estimates/sibling_va/outcome_va/fb_test_`outcome'_census.ster, replace


      **************** Save Value Added Estimates
      collapse (firstnm) va_* ///
        (mean) `outcome'* ///
        (sum) n_g11_`outcome' = touse_g11_`outcome' ///
        , by(school_id cdscode grade year)
      //save to my personal folder
      save $projdir/dta/common_core_va/outcome_va/va_g11_`outcome'_sibling_census.dta, replace
      //save to VA project folder
      save $vaprojdir/data/sibling_va/outcome_va/va_g11_`outcome'_sibling_census.dta, replace

}









timer off 1
timer list

log close
translate $projdir/log/share/siblingvaregs/va_sibling_out_forecast_bias.smcl $projdir/log/share/siblingvaregs/va_sibling_out_forecast_bias.log, replace
