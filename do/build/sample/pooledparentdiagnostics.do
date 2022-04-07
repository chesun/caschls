********************************************************************************
************** generate diagnostics for pooled parent data  ****************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear
set more off

log using $projdir/log/build/sample/pooledparentdiagnostics.smcl, replace

use $projdir/dta/demographics/pooled/paneldata/parentdemopanel, replace

/* gen gr9resprate = svygr9/gr9enr
gen gr11reprate = svygr11/gr11enr
label var gr9resprate "grade 9 response rate"
label var gr11resprate "grade 11 response rate" */

/* combine grades  */
gen svytotal = svygr9 + svygr11
gen enrtotal = gr9enr + gr11enr


//combine across years by collapse dataset
collapse (sum) svytotal enrtotal svygr9 svygr11 gr9enr gr11enr, by(cdscode)

label var svytotal "total number of parents surveyed in grade 9 and 11 from 1415 to 1819"
label var enrtotal "total number of student enrollment in grade 9 and 11 from 1415 to 1819"

rename svygr9 svygr9total
rename svygr11 svygr11total
label var svygr9total "total numeber of parents surveyed in grade 9 from 1415 to 1819"
label var svygr11total "total numeber of parents surveyed in grade 11 from 1415 to 1819"

rename gr9enr enrgr9total
rename gr11enr enrgr11total
label var enrgr9total "total number of student enrollment in grade 9 from 1415 to 1819"
label var enrgr11total "total number of student enrollment in grade 11 from 1415 to 1819"


gen pooledrr = svytotal/enrtotal
label var pooledrr "overall response rate pooling across grades and years"

gen pooledgr9rr = svygr9total/enrgr9total
label var pooledgr9rr "pooled response rate for grade 9 across years"
gen pooledgr11rr = svygr11total/enrgr11total
label var pooledgr11rr "pooled response rate for grade 11 across years"

compress
label data "Parent demographics diagnostics pooled across grade 9 and 11 across all 5 years"
save $projdir/dta/demographics/pooled/pooledparentdiagnostics, replace

log close
translate $projdir/log/build/sample/pooledparentdiagnostics.smcl $projdir/log/build/sample/pooledparentdiagnostics.log, replace 
