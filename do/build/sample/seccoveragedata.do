********************************************************************************
******************** generate vars that investigate secondary survey coverage *************************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* THis do file uses secondary  demographics datasets (merged with enrollment data) to
investigate survey coverage and representativeness*/

clear
set more off

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for dataset years

foreach year of local years {
  use $projdir/dta/demographics/secondary/secdemo`year', clear

  local secgrades `" "6" "7" "8" "9" "10" "11" "12" "' //generate a local macro for grades in the secondary datasets, excluding non traditional students for simplicity

  ******************************************************************************
  *******************generate survey sample diagnostics*************************
  ******************************************************************************
  foreach i of local secgrades {
    /* generate response rates for each grade and use extended missing value for labeling later */
    //generate a new var that calculates students in each grade in the survey as a percentage of total enrollment in that grade (i.e. response rate)
    gen svygr`i'resprate = .a
    label var svygr`i'resprate "grade `i' response rate"
    //make sure denominator is not 0 when calculating response rate
    replace svygr`i'resprate = svygr`i'/gr`i'enr if gr`i'enr != 0
    //label extended missing values for the cases where enrollment is 0
    label define svygr`i'resprate .a "grade `i' enrollment is 0"


    /* generate percentage of surveyed female students in each grade in survey sample and use extended missing value for labeling later */
    //generate a var that calculates the percentage of surveyed female students in each grade in the survey sample
    gen svyfemalegr`i'pct = .a
    label var svyfemalegr`i'pct "percent of female students in grade `i' in survey sample"
    // make sure denominator is not 0 when calculating percentage
    replace svyfemalegr`i'pct = svyfemalegr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for the cases where denominator is 0
    label define svyfemalegr`i'pct .a "no grade `i' student surveyed"

    /* generate percentage of surveyed male students in each grade in survey sample and use extended missing value for labeling later */
    //generate a var that calculates the percentage of surveyed male students in each grade in the survey sample
    gen svymalegr`i'pct = .a
    label var svymalegr`i'pct "percent of male students in grade `i' in survey sample"
    // make sure denominator is not 0 when calculating percentage
    replace svymalegr`i'pct = svymalegr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for the cases where denominator is 0
    label define svymalegr`i'pct .a "no grade `i' students surveyed"

    /* generate percentage of each race in each grade in the survey sample and use extended missing value for labeling later. The race vars are svyhispanicgr`i'
    svynativegr`i' svyasiangr`i' svyblackgr`i' svypacificgr`i' svywhitegr`i' svymixedgr`i' */
    //generate a var that calculates the percentage of surveyed hispanic students
    gen svyhispanicgr`i'pct = .a
    label var svyhispanicgr`i'pct "percent of hispanic students in grade `i' in survey sample"
    //make sure denominator is not 0 when calculating percentage
    replace svyhispanicgr`i'pct = svyhispanicgr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for the cases when denominator is 0
    label define svyhispanicgr`i'pct .a "no grade `i' students surveyed"

    //generate a var that caculates the percentage of surveyed Native American students in each grade
    gen svynativegr`i'pct = .a
    label var svynativegr`i'pct "percent of Native American students in grade `i' in survey sample"
    //make sure denominator is not 0 when calculating percentage
    replace svynativegr`i'pct = svynativegr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for the cases when denominator is 0
    label define svynativegr`i'pct .a "no grade `i' students surveyed"

    //generate a var that calculates the percentage of Asian students surveyed in each grade
    gen svyasiangr`i'pct = .a
    label var svyasiangr`i'pct "percent of Asian students in grade `i' in survey sample"
    //make sure denominator is not 0
    replace svyasiangr`i'pct = svyasiangr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for cases when denominator is 0
    label define svyasiangr`i'pct .a "no grade`i' students surveyed"

    //generate a var that calculates the percentage of black students surveyed in each graph grade
    gen svyblackgr`i'pct = .a
    label var svyblackgr`i'pct "percent of black students in grade `i' in survey sample"
    //make sure denominator is not 0
    replace svyblackgr`i'pct = svyblackgr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for cases when denominator is 0
    label define svyblackgr`i'pct .a "no grade `i' students surveyed"

    //generate a var that calculates the percentage of Pacific Islander students surveyed in each grade
    gen svypacificgr`i'pct = .a
    label var svypacificgr`i'pct "percent of Pacific Islander students in grade `i' in survey sample"
    //make sure denominator is not 0
    replace svypacificgr`i'pct = svypacificgr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for cases when denominator is 0
    label define svypacificgr`i'pct .a "no grade `i' students surveyed"

    //generate a var that calculates the percentage of white stuents surveyed in each grade
    gen svywhitegr`i'pct = .a
    label var svywhitegr`i'pct "percent of white students in grade `i' in survey sample"
    //make sure denominator is not 0
    replace svywhitegr`i'pct = svywhitegr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for cases when denominator is 0
    label define svywhitegr`i'pct .a "no grade `i' students surveyed"

    //generate a var that calculates the percentage of mixed race students surveyed in each grade
    gen svymixedgr`i'pct = .a
    label var svymixedgr`i'pct "percent of mixed race students in grade `i' in survey sample"
    //make sure denominator is not 0
    replace svymixedgr`i'pct = svymixedgr`i'/svygr`i' if svygr`i' != 0
    //label extended missing values for cases when denominator is 0
    label define svymixedgr`i'pct .a "no grade `i' students surveyed"

  }




  ******************************************************************************
  *******************generate enrollment sample diagnostics*********************
  ******************************************************************************

  /* generate a var that calculates the percentage of female and male students and students of each ethnicity in total enrollment */
  local enrgrades 1 2 3 4 5 6 7 8 9 10 11 12 //generate a kicak nacri for grade bynvers
  foreach j of local enrgrades {
    //generate a var that calculates the percentage of female students in each grade in the enrollment data
    gen enrfemalegr`j'pct = .a //generate extended missing value first for labeling later
    label var enrfemalegr`j'pct "percent of female students in grade `j' in enrollment data"
    replace enrfemalegr`j'pct = gr`j'femaleenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of female students in each grade in the enrollment data if denominator is not 0
    label define enrfemalegr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of male students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrmalegr`j'pct = .a //generate extended missing value first for labeling later
    label var enrmalegr`j'pct "percent of male students in grade `j' in enrollment data"
    replace enrmalegr`j'pct = gr`j'maleenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of male students in each grade in the enrollment data if denominator is not 0
    label define enrmalegr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of hispanic students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrhispanicgr`j'pct = .a //generate extended missing value first for labeling later
    label var enrhispanicgr`j'pct "percent of hispanic students in grade `j' in enrollment data"
    replace enrhispanicgr`j'pct = gr`j'hispanicenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of hispanic students in each grade in the enrollment data if denominator is not 0
    label define enrhispanicgr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of Native American students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrnativegr`j'pct = .a //generate extended missing value first for labeling later
    label var enrnativegr`j'pct "percent of Native American students in grade `j' in enrollment data"
    replace enrnativegr`j'pct = gr`j'nativeenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of Native American students in each grade in the enrollment data if denominator is not 0
    label define enrnativegr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of Asian students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrasiangr`j'pct = .a //generate extended missing value first for labeling later
    label var enrasiangr`j'pct "percent of Asian students in grade `j' in enrollment data"
    replace enrasiangr`j'pct = gr`j'asianenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of Asian students in each grade in the enrollment data if denominator is not 0
    label define enrasiangr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of black students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrblackgr`j'pct = .a //generate extended missing value first for labeling later
    label var enrblackgr`j'pct "percent of black students in grade `j' in enrollment data"
    replace enrblackgr`j'pct = gr`j'blackenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of black students in each grade in the enrollment data if denominator is not 0
    label define enrblackgr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of Pacific Islander students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrpacificgr`j'pct = .a //generate extended missing value first for labeling later
    label var enrpacificgr`j'pct "percent of Pacific Islander students in grade `j' in enrollment data"
    replace enrpacificgr`j'pct = gr`j'pacificenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of Pacific Islander students in each grade in the enrollment data if denominator is not 0
    label define enrpacificgr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of white students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrwhitegr`j'pct = .a //generate extended missing value first for labeling later
    label var enrwhitegr`j'pct "percent of white students in grade `j' in enrollment data"
    replace enrwhitegr`j'pct = gr`j'whiteenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of white students in each grade in the enrollment data if denominator is not 0
    label define enrwhitegr`j'pct .a "grade `j' enrollment is 0"

    //generate a var that calculates the percentage of mixed race students in each grade in the enrollment data, generate extended missing value first for labeling later
    gen enrmixedgr`j'pct = .a //generate extended missing value first for labeling later
    label var enrmixedgr`j'pct "percent of mixed race students in grade `j' in enrollment data"
    replace enrmixedgr`j'pct = gr`j'mixedenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of mixed race students in each grade in the enrollment data if denominator is not 0
    label define enrmixedgr`j'pct .a "grade `j' enrollment is 0"
  }


  ******************************************************************************************************
  *******************calculate difference between survey and enrollment diagnostics*********************
  ******************************************************************************************************

  foreach i of local secgrades {
    gen femalegr`i'dif = svyfemalegr`i'pct - enrfemalegr`i'pct //calculates the difference between the survey sample and enrollment data for female students in grade i
    gen malegr`i'dif = svymalegr`i'pct - enrmalegr`i'pct       //calculates the difference between the survey sample and enrollment data for male students in grade i
    label var femalegr`i'dif "Difference in grade `i' female percentage between survey sample and enrollment data"
    label var malegr`i'dif "Difference in grade `i' male percentage between survey sample and enrollment data"

    gen hispanicgr`i'dif = svyhispanicgr`i'pct - enrhispanicgr`i'pct //percentage point difference between survey sample and enrollment for hispanic students in grade i
    gen nativegr`i'dif = svynativegr`i'pct - enrnativegr`i'pct //percentage point difference between survey sample and enrollment for Native American students in grade i
    gen asiangr`i'dif = svyasiangr`i'pct - enrasiangr`i'pct //percentage point difference between survey sample and enrollment for Asian students in grade i
    gen blackgr`i'dif = svyblackgr`i'pct - enrblackgr`i'pct //percentage point difference between survey sample and enrollment for black students in grade i
    gen pacificgr`i'dif = svypacificgr`i'pct - enrpacificgr`i'pct //percentage point difference between survey sample and enrollment for Pacific Islander students in grade i
    gen whitegr`i'dif = svywhitegr`i'pct - enrwhitegr`i'pct //percentage point difference between survey sample and enrollment for white students in grade i
    gen mixedgr`i'dif = svymixedgr`i'pct - enrmixedgr`i'pct //percentage point difference between survey sample and enrollment for mixed race students in grade i
    label var hispanicgr`i'dif "difference in grade `i' hispanic percentage between survey sample and enrollment data"
    label var nativegr`i'dif "difference in grade `i' Native American percentage between survey sample and enrollment data"
    label var asiangr`i'dif "difference in grade `i' Asian percentage between survey sample and enrollment data"
    label var blackgr`i'dif "difference in grade `i' black percentage between survey sample and enrollment data"
    label var pacificgr`i'dif "difference in grade `i' Pacific Islander percentage between survey sample and enrollment data"
    label var whitegr`i'dif "difference in grade `i' white percentage between survey sample and enrollment data"
    label var mixedgr`i'dif "difference in grade `i' mixed race percentage between survey sample and enrollment data"
  }

  compress //compress dataset to save memory
  label data "Secondary `year' demographics data with survey coverage analysis variables"
  save $projdir/dta/demographics/analysis/secondary/secdemo`year'analysis, replace

}
