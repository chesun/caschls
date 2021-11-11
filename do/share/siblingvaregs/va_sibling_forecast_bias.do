********************************************************************************
/* do file to run forecast bias tests and spec tests for test score VA
regressions with sibling effects. Two versions of VA: one with leave out
7th grade score, one with leave out census tract
Include as controls the dummies for
1) has an older sibling enrolled in 2 year
2) has an older sibling enrolled in 4 year

Comment on family fixed effects: Too many fixed effects, not enough observations.
Stata returns an error "attempted to fit a model with too many variables"
Only 749488 obs but 600210 families, too many variables from family fixed effects

 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* To run this do file:
for origianl drift limit
do $projdir/do/share/siblingvaregs/va_sibling_forecast_bias.do


 */


 //install VAM package to estimate value added models a la Chetty, Freidman, and Rockoff
 /* ssc install vam, replace  */
 clear all
 set more off
 set varabbrev off
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
 log using $projdir/log/share/siblingvaregs/va_sibling_forecast_bias.smcl, replace

 //include macros
 include do_files/sbac/macros_va.doh

 #delimit ;
 #delimit cr
 macro list


 timer on 1

 ********************************************************************************






































 timer off 1
 timer list
 log close

 //change directory back
 cd "/home/research/ca_ed_lab/chesun/gsr/caschls"

 translate $projdir/log/share/siblingvaregs/va_sibling_forecast_bias.smcl ///
 $projdir/log/share/siblingvaregs/va_sibling_forecast_bias.log, replace
