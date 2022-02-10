********************************************************************************
/* do file to merge census geocoded data with ACS data*/
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Jan 20. 2022 ***************************

/* To run this do file:

do $projdir/do/share/census/merge_census_acs

 */

 clear all
 set more off
 set varabbrev off
 set scheme s1color
 //capture log close: Stata should not complain if there is no log open to close
 cap log close _all

use $vaprojdir/data/public_access/clean/acs/acs_ca_census_tract_clean, clear 
