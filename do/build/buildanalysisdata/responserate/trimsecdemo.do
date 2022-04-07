********************************************************************************
/* trim demographics data for secondary survey and rename vars to prepare for
generating conditional response rate datasets */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear
set more off

log using $projdir/log/build/buildanalysisdata/responserate/trimsecdemo.smcl, replace

********************************************************************************
/* rename variables in the secondary demographics datasets to indicate year, keep only vars needed to calculate response rates */
local grades `" "9" "10" "11" "12" "' //local macro for grades

use $projdir/dta/demographics/secondary/secdemo1415, replace
keep cdscode svygr9 svygr10 svygr11 svygr12 gr9enr gr10enr gr11enr gr12enr
//renaming vars to indicate the year of the dataset to prepare for merging with other years later
foreach i of local grades {
  rename svygr`i' svygr`i'_1415
  rename gr`i'enr enrgr`i'_1415
  label var svygr`i'_1415 "number of grade `i' responses in 1415"
  label var enrgr`i'_1415 "grade `i' enrollment in 1415"
}
label data "trimmed secondary demographics 1415 including only survey response and enrollment for grades 9-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1415, replace


use $projdir/dta/demographics/secondary/secdemo1516, replace
keep cdscode svygr9 svygr10 svygr11 svygr12 gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1516
  rename gr`i'enr enrgr`i'_1516
  label var svygr`i'_1516 "number of grade `i' responses in 1516"
  label var enrgr`i'_1516 "grade `i' enrollment in 1516"
}
label data "trimmed secondary demographics 1516 including only survey response and enrollment for grades 9-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1516, replace


use $projdir/dta/demographics/secondary/secdemo1617, replace
keep cdscode svygr9 svygr10 svygr11 svygr12 gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1617
  rename gr`i'enr enrgr`i'_1617
  label var svygr`i'_1617 "number of grade `i' responses in 1617"
  label var enrgr`i'_1617 "grade `i' enrollment in 1617"
}
label data "trimmed secondary demographics 1617 including only survey response and enrollment for grades 9-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1617, replace


use $projdir/dta/demographics/secondary/secdemo1718, replace
keep cdscode svygr9 svygr10 svygr11 svygr12 gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1718
  rename gr`i'enr enrgr`i'_1718
  label var svygr`i'_1718 "number of grade `i' responses in 1718"
  label var enrgr`i'_1718 "grade `i' enrollment in 1718"
}
label data "trimmed secondary demographics 1718 including only survey response and enrollment for grades 9-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1718, replace


use $projdir/dta/demographics/secondary/secdemo1819, replace
keep cdscode svygr9 svygr10 svygr11 svygr12 gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1819
  rename gr`i'enr enrgr`i'_1819
  label var svygr`i'_1819 "number of grade `i' responses in 1819"
  label var enrgr`i'_1819 "grade `i' enrollment in 1819"
}
label data "trimmed secondary demographics 1819 including only survey response and enrollment for grades 9-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1819, replace
********************************************************************************



log close
translate $projdir/log/build/buildanalysisdata/responserate/trimsecdemo.smcl $projdir/log/build/buildanalysisdata/responserate/trimsecdemo.log, replace 
