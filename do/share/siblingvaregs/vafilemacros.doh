********************************************************************************
/* Macros for common core VA project folder file paths, and relevant datasets to make it possible
to use Matt's doh files  */
********************************************************************************
********************************************************************************
/* First written by Che Sun, 12/13/2021  */

/* to include this in do files:
include $projdir/do/share/siblingvaregs/vafilemacros.doh
 */

//adapted matt do files
local mattdofiles "$projdir/do/matt/adapted_commoncore_va_matt"

local ca_ed_lab "/home/research/ca_ed_lab"
local k12_test_scores "$vaprojdir/data/restricted_access/clean/k12_test_scores"
local public_access "/home/research/ca_ed_lab/data/public_access"
local k12_public_schools "/home/research/ca_ed_lab/projects/common_core_va/data/public_access/clean/k12_public_schools"
local k12_test_scores_public "/home/research/ca_ed_lab/projects/common_core_va/data/public_access/clean/k12_test_scores"

*** macros for my own datasets
local va_dataset "$projdir/dta/common_core_va/va_dataset"
local va_g11_dataset "$projdir/dta/common_core_va/va_g11_dataset"
local va_g11_out_dataset "$projdir/dta/common_core_va/va_g11_out_dataset"
local siblingxwalk "$projdir/dta/siblingxwalk/siblingpairxwalk"
local ufamilyxwalk "$projdir/dta/siblingxwalk/ufamilyxwalk"
local k12_postsecondary_out_merge "$projdir/dta/common_core_va/k12_postsecondary_out_merge"
local sibling_out_xwalk "$projdir/dta/siblingxwalk/sibling_out_xwalk"
