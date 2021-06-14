********************************************************************************
************** generate parent pooled across years datasets  ****************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* this do file combines the parent survey datasets across years and pool each
school across years for 9th and 11th grade */

clear
set more off

local years 1415 1516 1617 1718 1819 //local macro for dataset years

/* reconstruct parents demographics datasets for pooling across years */
local runparentforpooling = 1 //local toggle for reconstructing parents demographics data for pooling
if `runparentforpooling' == 1 {
  foreach year of local years {
    use $projdir/dta/demographics/parent/parentdemo`year', replace
    keep cdscode svygr9 svygr11 gr9enr gr11enr //there is no sex or ethnicity in parent data
    gen year = `year' //generate a variable for the survey year
    tostring year, replace //make into string
    label var year "survey year"

    compress
    save $projdir/dta/demographics/pooled/forpooling/parent/parentdemoforpooling`year', replace
  }
}

/* append all secondary datasets to construct a panel dataset */
use $projdir/dta/demographics/pooled/forpooling/parent/parentdemoforpooling1415, replace
append using $projdir/dta/demographics/pooled/forpooling/parent/parentdemoforpooling1516
append using $projdir/dta/demographics/pooled/forpooling/parent/parentdemoforpooling1617
append using $projdir/dta/demographics/pooled/forpooling/parent/parentdemoforpooling1718
append using $projdir/dta/demographics/pooled/forpooling/parent/parentdemoforpooling1819

compress
save $projdir/dta/demographics/pooled/paneldata/parentdemopanel, replace
