********************************************************************************
/* output regression estimates from regressing enrollment outcomes on DK VA
from the restricted sibling census sample to csv files */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on May 10, 2022 ***************************

/* To run this do file:

do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs_dk_tab

 */

/* CHANGE LOG

*/

clear all
graph drop _all
set more off
set varabbrev off
set scheme s1color
//capture log close: Stata should not complain if there is no log open to close
cap log close _all

/* set trace on
set tracedepth 2 */

//starting log file
log using $projdir/log/share/siblingvaregs/reg_out_va_sib_acs_dk_tab.smcl, replace

/* change directory to common_core_va project directory for all value added
do files because some called subroutines written by Matt may use relative file paths  */
cd $vaprojdir

/* file path macros for datasets */
include $projdir/do/share/siblingvaregs/vafilemacros.doh

//run Matt's do helper file to set the local macros for VA project
include $vaprojdir/do_files/sbac/macros_va.doh

macro list

//startomg timer
timer on 1


********************************************************************************
* begin main code












timer off 1
timer list

cd $projdir
set trace off

log close
translate $projdir/log/share/siblingvaregs/reg_out_va_sib_acs_dk_tab.smcl ///
  $projdir/log/share/siblingvaregs/reg_out_va_sib_acs_dk_tab.log, replace
