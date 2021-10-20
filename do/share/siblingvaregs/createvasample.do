********************************************************************************
/* create the VA sample dataset to save processing time. Using doh helpher files
each time to recreate the data takes too much time
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* to run this do file:
do $projdir/do/share/siblingvaregs/createvasample.do
 */


clear all
set more off
set varabbrev off

//input argument to determine which sample to generate
args sample

local matthomedir "/home/research/ca_ed_lab/msnaven/common_core_va"
local mattdofiles "/home/research/ca_ed_lab/msnaven/common_core_va/do_files/sbac"
//set the macros for directories in the same way as Matt do files
local ca_ed_lab "/home/research/ca_ed_lab"
local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
local public_access "/home/research/ca_ed_lab/data/public_access"
local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"

//change directory to matt directory to reconcile the use of directories in his doh and do file
cd `matthomedir'
//starting log file
log using $projdir/log/share/siblingvaregs/createvasample.smcl, replace


//run the do helper file to set the local macros
include `mattdofiles'/macros_va.doh

//set a timer for this do file to see how long it runs
timer on 1






 if "`sample'" == "full_va" {
    ** this creates the full VA sample
   //run the do helper file to create the VA sample
   include `mattdofiles'/create_va_sample.doh

   //Save it as a temporary dataset
   compress
   tempfile va_dataset
   save `va_dataset'

   save $projdir/dta/common_core_va/va_dataset, replace
 }

 if "`sample'" == "va_g11" {
   ** this creates the full VA sample
  //run the do helper file to create the VA sample
  include `mattdofiles'/create_va_sample.doh

  //Save it as a temporary dataset
  compress
  tempfile va_dataset
  save `va_dataset'

  save $projdir/dta/common_core_va/va_dataset, replace

  ********************************************************************************
  **create the VA dataset for the VA CFR regressions (score VA)
  ** use onoy 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
  include `mattdofiles'/create_va_g11_sample.doh

  **the above steps create the VA dataset for the VA CFR regressions (score VA)
  compress
  save $projdir/dta/common_core_va/va_g11_dataset, replace

  //erase the tempfile to avoid name conflict
  erase `va_dataset'
 }

if "`sample'" == "k12_out" {
  *** This merges the entire k12 test score sample onto postsecondary outcomes
  use `k12_test_scores'/k12_test_scores_clean, clear
  // merge on postsecondary Outcomes
  do `ca_ed_lab'/msnaven/data/do_files/merge_k12_postsecondary.doh enr_only
  drop enr enr_2year enr_4year
  rename enr_ontime enr
  rename enr_ontime_2year enr_2year
  rename enr_ontime_4year enr_4year]
  drop if missing(state_student_id)

  //save the merged k12 to postsecondary outcome dataset that has the largest student sample in order to calculate sibling outcomes
  compress
  save $projdir/dta/common_core_va/k12_postsecondary_out_merge, replace
}

if "`sample'" == "va_g11_out" {
  ********************************************************************************
  ** create the VA dataset for the long term outcome VA regressions
  use $projdir/dta/common_core_va/va_dataset, clear
  // merge on postsecondary Outcomes
  do `ca_ed_lab'/msnaven/data/do_files/merge_k12_postsecondary.doh enr_only
  drop enr enr_2year enr_4year
  rename enr_ontime enr
  rename enr_ontime_2year enr_2year
  rename enr_ontime_4year enr_4year



  * Save temporary dataset
  compress
  tempfile va_dataset
  save `va_dataset'



  ** need to create grade 11 sample for long term outcome VA, use create_va_g11_sample.doh

  // use only 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
  include `mattdofiles'/create_va_g11_out_sample.doh

  ** this creates the VA dataset for the long term outcome VA regressions
  compress
  save $projdir/dta/common_core_va/va_g11_out_dataset, replace

}











timer off 1
timer list
log close

//change directory back
cd "/home/research/ca_ed_lab/chesun/gsr/caschls"

//translate the log file to a text log file
translate $projdir/log/share/siblingvaregs/createvasample.smcl $projdir/log/share/siblingvaregs/createvasample.log, replace
