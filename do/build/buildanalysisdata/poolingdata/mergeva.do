********************************************************************************
/* merge analysis datasets with value added estimates */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/poolingdata/mergeva.smcl, replace

local dtaname `" "sec" "parent" "staff" "' //local macro for looping over different survey analysis datasets

foreach name of local dtaname {
  use $projdir/dta/buildanalysisdata/analysisready/`name'analysisready, clear

  merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/combinedva
  drop _merge

  save, replace

}

/* NOte:
931 matched for secondary, 2883 not matched. 2454 from master, 429 from using.
427 matched for parent, 3502 not matched. 2569 from master, 933 from using
591 matched for staff, 4390 not matched, 3621 from master, 769 from using
*/


log close
translate $projdir/log/build/buildanalysisdata/poolingdata/mergeva.smcl $projdir/log/build/buildanalysisdata/poolingdata/mergeva.log, replace 
