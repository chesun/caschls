********************************************************************************
************** generate diagnostics for pooled secondary data  ****************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

clear
set more off

use $projdir/dta/demographics/pooled/paneldata/secdemopanel, replace

/* gen gr9resprate = svygr9/gr9enr
gen gr11reprate = svygr11/gr11enr
label var gr9resprate "grade 9 response rate"
label var gr11resprate "grade 11 response rate" */

/* combine grades  */
gen svytotal = svygr9 + svygr11
gen svyfemaletotal = svyfemalegr9 + svyfemalegr11
gen svymaletotal = svymalegr9 + svymalegr11
gen svyhispanictotal = svyhispanicgr9 + svyhispanicgr11
gen svyasiantotal = svyasiangr9 + svyasiangr11
gen svyblacktotal = svyblackgr9 + svyblackgr11
gen svywhitetotal = svywhitegr9 + svywhitegr11

gen enrtotal = gr9enr + gr11enr
gen enrfemaletotal = gr9femaleenr + gr11femaleenr
gen enrmaletotal = gr9maleenr + gr11maleenr
gen enrhispanictotal = gr9hispanicenr + gr11hispanicenr
gen enrasiantotal = gr9asianenr + gr11asianenr
gen enrblacktotal = gr9blackenr + gr11blackenr
gen enrwhitetotal = gr9whiteenr + gr11whiteenr

//combine across years by collapse dataset
collapse (sum) svytotal svygr9 svygr11 svyfemaletotal svymaletotal svyhispanictotal svyasiantotal svyblacktotal svywhitetotal ///
              enrtotal gr9enr gr11enr enrfemaletotal enrmaletotal enrhispanictotal enrasiantotal enrblacktotal enrwhitetotal, by(cdscode)

rename svygr9 svygr9total
rename svygr11 svygr11total
label var svytotal "total number of students surveyed in grade 9 and 11 from 1415 to 1819"
label var svygr9total "total numeber of students surveyed in grade 9 from 1415 to 1819"
label var svygr11total "total numeber of students surveyed in grade 11 from 1415 to 1819"
label var svyfemaletotal "total number of females surveyed in grade 9 and 11 from 1415 to 1819"
label var svymaletotal "total number of males surveyed in grade 9 and 11 from 1415 to 1819"
label var svyhispanictotal "total number of hispanics surveyed in grade 9 and 11 from 1415 to 1819"
label var svyasiantotal "total number of asians surveyed in grade 9 and 11 from 1415 to 1819"
label var svyblacktotal "total number of blacks surveyed in grade 9 and 11 from 1415 to 1819"
label var svywhitetotal "total number of whites surveyed in grade 9 and 11 from 1415 to 1819"

rename gr9enr enrgr9total
rename gr11enr enrgr11total
label var enrtotal "total numeber of student enrollment in grade 9 and 11 from 1415 to 1819"
label var enrgr9total "total number of student enrollment in grade 9 from 1415 to 1819"
label var enrgr11total "total number of student enrollment in grade 11 from 1415 to 1819"
label var enrfemaletotal "total female enrollment in grade 9 and 11 from 1415 to 1819"
label var enrmaletotal "total male enrollment in grade 9 and 11 from 1415 to 1819"
label var enrhispanictotal "total hispanic enrollment in grade 9 and 11 from 1415 to 1819"
label var enrasiantotal "total asian enrollment in grade 9 and 11 from 1415 to 1819"
label var enrblacktotal "total black enrollment in grade 9 and 11 from 1415 to 1819"
label var enrwhitetotal "total white enrollment in grade 9 and 11 from 1415 to 1819"

gen pooledrr = svytotal/enrtotal
label var pooledrr "overall response rate pooling across grades and years"

gen pooledgr9rr = svygr9total/enrgr9total
label var pooledgr9rr "pooled response rate for grade 9 across years"
gen pooledgr11rr = svygr11total/enrgr11total
label var pooledgr11rr "pooled response rate for grade 11 across years"

/* note: denominator might be 0, causing missing entries */
gen pooledfemalerr = svyfemaletotal/enrfemaletotal
label var pooledfemalerr "overall female response rate pooling across grades and years"

gen pooledmalerr = svymaletotal/enrmaletotal
label var pooledmalerr "overall male response rate pooling across grades and years"

gen pooledhispanicrr = svyhispanictotal/enrhispanictotal
label var pooledhispanicrr "overall hispanic response rate pooling across grades and years"

gen pooledasianrr = svyasiantotal/enrasiantotal
label var pooledasianrr "overall asian response rate pooling across grades and years"

gen pooledblackrr = svyblacktotal/enrblacktotal
label var pooledblackrr "overall black response rate pooling across grades and years"

gen pooledwhiterr = svywhitetotal/enrwhitetotal
label var pooledwhiterr "overall white response rate pooling across grades and years"

compress
label data "Secondary demographics diagnostics pooled across grade 9 and 11 across all 5 years"
save $projdir/dta/demographics/pooled/pooledsecdiagnostics, replace
