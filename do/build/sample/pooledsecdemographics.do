********************************************************************************
************** generate secondary pooled across years datasets  ****************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* this do file combines the secondary survey datasets across years and pool each
school across years for 9th and 11th grade */

clear
set more off


local years 1415 1516 1617 1718 1819 //local macro for dataset years

/* reconstruct secondary demographics datasets for pooling across years */
local runsecforpooling = 1 //local toggle for reconstructing secondary demographics data for pooling
if `runsecforpooling' == 1 {
 foreach year of local years {
   use $projdir/dta/demographics/secondary/secdemo`year', replace
   replace gr9asianenr = gr9asianenr + gr9filipinoenr
   replace gr11asianenr = gr11asianenr + gr11filipinoenr
   keep cdscode svygr9 svygr11 svyfemalegr9 svyfemalegr11 svymalegr9 svymalegr11 ///
   svyhispanicgr9 svyhispanicgr11 svyasiangr9 svyasiangr11 svyblackgr9 svyblackgr11 svywhitegr9 svywhitegr11 ///
   gr9enr gr11enr gr9femaleenr gr9maleenr gr11femaleenr gr11maleenr ///
   gr9asianenr gr9hispanicenr gr9blackenr gr9whiteenr ///
   gr11asianenr gr11hispanicenr gr11blackenr gr11whiteenr

   gen year = `year' //generate a variable for the survey year
   tostring year, replace //make into string
   label var year "survey year"

   compress
   save $projdir/dta/demographics/pooled/forpooling/secondary/secdemoforpooling`year', replace
 }
}

/* append all secondary datasets to construct a panel dataset */
use $projdir/dta/demographics/pooled/forpooling/secondary/secdemoforpooling1415, replace
append using $projdir/dta/demographics/pooled/forpooling/secondary/secdemoforpooling1516
append using $projdir/dta/demographics/pooled/forpooling/secondary/secdemoforpooling1617
append using $projdir/dta/demographics/pooled/forpooling/secondary/secdemoforpooling1718
append using $projdir/dta/demographics/pooled/forpooling/secondary/secdemoforpooling1819

compress
save $projdir/dta/demographics/pooled/paneldata/secdemopanel, replace
