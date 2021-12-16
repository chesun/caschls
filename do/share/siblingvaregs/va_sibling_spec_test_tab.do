********************************************************************************
/* do file to create a regression output table for spec test for test score VA
with original sample, sibling sample without control, sibling sample with control */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* To run this do file:

do $projdir/do/share/siblingvaregs/va_sibling_spec_test_tab.do


 */


 //install VAM package to estimate value added models a la Chetty, Freidman, and Rockoff
 /* ssc install vam, replace  */
 clear all
 graph drop _all
 set more off
 set varabbrev off
 set graphics off
 set scheme s1color
 //capture log close: Stata should not complain if there is no log open to close
 cap log close _all

 *** macros for Matt's data directories
 local matthomedir "/home/research/ca_ed_lab/msnaven/common_core_va"
 local mattdofiles "/home/research/ca_ed_lab/msnaven/common_core_va/do_files/sbac"
 local common_core_va "/home/research/ca_ed_lab/msnaven/common_core_va"
 local ca_ed_lab "/home/research/ca_ed_lab"
 local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
 local public_access "/home/research/ca_ed_lab/data/public_access"
 local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
 local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"

 *** macros for my own datasets
 local va_dataset "$projdir/dta/common_core_va/va_dataset"
 local va_g11_dataset "$projdir/dta/common_core_va/va_g11_dataset"
 local va_g11_out_dataset "$projdir/dta/common_core_va/va_g11_out_dataset"
 local siblingxwalk "$projdir/dta/siblingxwalk/siblingpairxwalk"
 local ufamilyxwalk "$projdir/dta/siblingxwalk/ufamilyxwalk"
 local k12_postsecondary_out_merge "$projdir/dta/common_core_va/k12_postsecondary_out_merge"
 local sibling_out_xwalk "$projdir/dta/siblingxwalk/sibling_out_xwalk"





 //change directory to matt directory to reconcile the use of directories in his doh and do file
 cd `matthomedir'
 //starting log file
 log using $projdir/log/share/siblingvaregs/va_sibling_spec_test_tab.smcl, replace

 //include macros
 include do_files/sbac/macros_va.doh

 #delimit ;
 #delimit cr
 macro list


 timer on 1



********************************************************************************
********* Spec test table without peer controls



foreach subject in ela math {
  estimates use estimates/sbac/spec_test_va_cfr_g11_`subject'.ster
  eststo

  estimates use $projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_sibling_nocontrol.ster
  eststo

  estimates use $projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_sibling.ster
  eststo


  esttab using $projdir/out/csv/siblingvaregs/spec_test/spec_test_`subject'.csv ///
  , replace nonumbers  ///
  mtitles("Original" "Sibling Sample" "Sibling Controls") ///
  title("Spec Tests for ``subject'_str' VA")

  eststo clear

}




















 timer off 1
 log close

 cd "/home/research/ca_ed_lab/chesun/gsr/caschls"


 translate $projdir/log/share/siblingvaregs/va_sibling_spec_test_tab.smcl ///
 $projdir/log/share/siblingvaregs/va_sibling_spec_test_tab.log, replace
