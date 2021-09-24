********************************************************************************
/* create the VA sample dataset to save processing time. Using doh helpher files
each time to recreate the data takes too much time
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* to run this do file:
do $projdir/do/share/siblingregs/createvasample.do
 */


clear all
set more off
set varabbrev off

local common_core_va "/home/research/ca_ed_lab/msnaven/common_core_va"
local ca_ed_lab "/home/research/ca_ed_lab"
local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
local public_access "/home/research/ca_ed_lab/data/public_access"
local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"


//create VA sample

//run the do helper file to set the local macros
include $projdir/do/share/siblingregs/macros_va.doh
//run the do helper file to create the VA sample
include $projdir/do/share/siblingregs/create_va_sample.doh

// merge on postsecondary Outcomes
do `ca_ed_lab'/msnaven/data/do_files/merge_k12_postsecondary.doh enr_only
drop enr enr_2year enr_4year
rename enr_ontime enr
rename enr_ontime_2year enr_2year
rename enr_ontime_4year enr_4year

//Save it as a temporary dataset
compress
tempfile va_dataset
save `va_dataset'

save $projdir/dta/common_core_va/va_dataset, replace



// use only 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
include do_files/sbac/create_va_g11_sample.doh







//merge on sibling outcomes
