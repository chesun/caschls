********************************************************************************
/* trim demographics data for parent survey and rename vars to prepare for
generating conditional response rate datasets */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/responserate/trimparentdemo.smcl, replace

/* rename variables in the secondary demographics datasets to indicate year, keep only vars needed to calculate response rates */
local grades `" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "' //local macro for grades

use $projdir/dta/demographics/parent/parentdemo1415, replace
keep cdscode svygr1 svygr2 svygr3 svygr4 svygr5 svygr6 svygr7 svygr8 svygr9 svygr10 svygr11 svygr12 ///
gr1enr gr2enr gr3enr gr4enr gr5enr gr6enr gr7enr gr8enr gr9enr gr10enr gr11enr gr12enr
//renaming vars to indicate the year of the dataset to prepare for merging with other years later
foreach i of local grades {
  rename svygr`i' svygr`i'_1415
  rename gr`i'enr enrgr`i'_1415
  label var svygr`i'_1415 "number of grade `i' household responses in 1415"
  label var enrgr`i'_1415 "grade `i' enrollment in 1415"
}
label data "trimmed parent demographics 1415 including only survey responses and enrollment for grades 1-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1415, replace


use $projdir/dta/demographics/parent/parentdemo1516, replace
keep cdscode svygr1 svygr2 svygr3 svygr4 svygr5 svygr6 svygr7 svygr8 svygr9 svygr10 svygr11 svygr12 ///
gr1enr gr2enr gr3enr gr4enr gr5enr gr6enr gr7enr gr8enr gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1516
  rename gr`i'enr enrgr`i'_1516
  label var svygr`i'_1516 "number of grade `i' household responses in 1516"
  label var enrgr`i'_1516 "grade `i' enrollment in 1516"
}
label data "trimmed parent demographics 1516 including only survey responses and enrollment for grades 1-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1516, replace


use $projdir/dta/demographics/parent/parentdemo1617, replace
keep cdscode svygr1 svygr2 svygr3 svygr4 svygr5 svygr6 svygr7 svygr8 svygr9 svygr10 svygr11 svygr12 ///
gr1enr gr2enr gr3enr gr4enr gr5enr gr6enr gr7enr gr8enr gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1617
  rename gr`i'enr enrgr`i'_1617
  label var svygr`i'_1617 "number of grade `i' household responses in 1617"
  label var enrgr`i'_1617 "grade `i' enrollment in 1617"
}
label data "trimmed parent demographics 1617 including only survey responses and enrollment for grades 1-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1617, replace


use $projdir/dta/demographics/parent/parentdemo1718, replace
keep cdscode svygr1 svygr2 svygr3 svygr4 svygr5 svygr6 svygr7 svygr8 svygr9 svygr10 svygr11 svygr12 ///
gr1enr gr2enr gr3enr gr4enr gr5enr gr6enr gr7enr gr8enr gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1718
  rename gr`i'enr enrgr`i'_1718
  label var svygr`i'_1718 "number of grade `i' household responses in 1718"
  label var enrgr`i'_1718 "grade `i' enrollment in 1718"
}
label data "trimmed parent demographics 1718 including only survey responses and enrollment for grades 1-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1718, replace


use $projdir/dta/demographics/parent/parentdemo1819, replace
keep cdscode svygr1 svygr2 svygr3 svygr4 svygr5 svygr6 svygr7 svygr8 svygr9 svygr10 svygr11 svygr12 ///
gr1enr gr2enr gr3enr gr4enr gr5enr gr6enr gr7enr gr8enr gr9enr gr10enr gr11enr gr12enr
foreach i of local grades {
  rename svygr`i' svygr`i'_1819
  rename gr`i'enr enrgr`i'_1819
  label var svygr`i'_1819 "number of grade `i' household responses in 1819"
  label var enrgr`i'_1819 "grade `i' enrollment in 1819"
}
label data "trimmed parent demographics 1819 including only survey responses and enrollment for grades 1-12"
compress
save $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1819, replace

log close
translate $projdir/log/build/buildanalysisdata/responserate/trimparentdemo.smcl $projdir/log/build/buildanalysisdata/responserate/trimparentdemo.log, replace 
