********************************************************************************
/* Macros for common core VA project folder file paths, and relevant datasets to make it possible
to use Matt's doh files  */
********************************************************************************
********************************************************************************
/* First written by Che Sun, 12/13/2021
1/27/2022: changed mattdofiles path to the do files folder in project folder
after Matt updated the do files to reconcile file paths. Now direct run these
do files from the $vaprojdir/do_files_sbac folder*/

/* to include this in do files:
include $projdir/do/share/siblingvaregs/vafilemacros.doh
 */

 local vaprojdofiles "$vaprojdir/do_files"

*** macros for my own datasets
local va_dataset "$projdir/dta/common_core_va/va_dataset"
local va_g11_dataset "$projdir/dta/common_core_va/va_g11_dataset"
local va_g11_out_dataset "$projdir/dta/common_core_va/va_g11_out_dataset"
local siblingxwalk "$projdir/dta/siblingxwalk/siblingpairxwalk"
local ufamilyxwalk "$projdir/dta/siblingxwalk/ufamilyxwalk"
local k12_postsecondary_out_merge "$projdir/dta/common_core_va/k12_postsecondary_out_merge"
local sibling_out_xwalk "$projdir/dta/siblingxwalk/sibling_out_xwalk"
