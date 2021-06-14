********************************************************************************
******************** generate vars that investigate elementary survey coverage *************************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* THis do file uses elementary demographics datasets (merged with enrollment data) to
investigate survey coverage and representativeness*/

clear
set more off

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for elementary dataset years

 foreach i of local years {
   use $projdir/dta/demographics/elementary/elemdemo`i', clear

   /* generate response rates for grade 3, 4, 5, 6 and use extended missing value for labeling later */
   //generate a new var that calculates students in each grade in the survey as a percentage of total enrollment in that grade (i.e. response rate)
   gen svygr3resprate = .a
   gen svygr4resprate = .a
   gen svygr5resprate = .a
   gen svygr6resprate = .a

   label var svygr3resprate "grade 3 response rate"
   label var svygr4resprate "grade 4 response rate"
   label var svygr5resprate "grade 5 response rate"
   label var svygr6resprate "grade 6 response rate"

   //make sure denominator is not 0 when calculating response rate
   replace svygr3resprate = svygr3/gr3enr if gr3enr != 0
   replace svygr4resprate = svygr4/gr4enr if gr4enr != 0
   replace svygr5resprate = svygr5/gr5enr if gr5enr != 0
   replace svygr6resprate = svygr6/gr6enr if gr6enr != 0

   /* //recode missing values using extended missing values for labeling
   recode svygr3resprate (missing = .a)
   recode svygr4resprate (missing = .a)
   recode svygr5resprate (missing = .a)
   recode svygr6resprate (missing = .a) */

   //label extended missing values for the cases where enrollment is 0
   label define svygr3resprate .a "Grade 3 Enrollment is 0"
   label define svygr4resprate .a "Grade 4 Enrollment is 0"
   label define svygr5resprate .a "Grade 5 Enrollment is 0"
   label define svygr6resprate .a "Grade 6 Enrollment is 0"

   /* generate percentage of surveyed female students in each grade in survey sample and use extended missing value for labeling later */
   //generate a var that calculates the percentage of surveyed female students in each grade in the survey sample
   gen svyfemalegr3pct = .a
   gen svyfemalegr4pct = .a
   gen svyfemalegr5pct = .a
   gen svyfemalegr6pct = .a

   label var svyfemalegr3pct "percent of female students in grade 3 in survey sample"
   label var svyfemalegr4pct "percent of female students in grade 4 in survey sample"
   label var svyfemalegr5pct "percent of female students in grade 5 in survey sample"
   label var svyfemalegr6pct "percent of female students in grade 6 in survey sample"

   // make sure denominator is not 0 when calculating percentage
   replace svyfemalegr3pct = svyfemalegr3/svygr3 if svygr3 != 0
   replace svyfemalegr4pct = svyfemalegr4/svygr4 if svygr4 != 0
   replace svyfemalegr5pct = svyfemalegr5/svygr5 if svygr5 != 0
   replace svyfemalegr6pct = svyfemalegr6/svygr6 if svygr6 != 0

   //label extended missing values for the cases where denominator is 0
   label define svyfemalegr3pct .a "no grade 3 students surveyed"
   label define svyfemalegr4pct .a "no grade 4 students surveyed"
   label define svyfemalegr5pct .a "no grade 5 students surveyed"
   label define svyfemalegr6pct .a "no grade 6 students surveyed"


   /* generate percentage of surveyed male students in each grade in survey sample and use extended missing value for labeling later */
   //generate a var that calculates the percentage of surveyed male students in each grade in the survey sample
   gen svymalegr3pct = .a
   gen svymalegr4pct = .a
   gen svymalegr5pct = .a
   gen svymalegr6pct = .a

   label var svymalegr3pct "percent of male students in grade 3 in survey sample"
   label var svymalegr4pct "percent of male students in grade 4 in survey sample"
   label var svymalegr5pct "percent of male students in grade 5 in survey sample"
   label var svymalegr6pct "percent of male students in grade 6 in survey sample"

   // make sure denominator is not 0 when calculating percentage
   replace svymalegr3pct = svymalegr3/svygr3 if svygr3 != 0
   replace svymalegr4pct = svymalegr4/svygr4 if svygr4 != 0
   replace svymalegr5pct = svymalegr5/svygr5 if svygr5 != 0
   replace svymalegr6pct = svymalegr6/svygr6 if svygr6 != 0

   //label extended missing values for the cases where denominator is 0
   label define svymalegr3pct .a "no grade 3 students surveyed"
   label define svymalegr4pct .a "no grade 4 students surveyed"
   label define svymalegr5pct .a "no grade 5 students surveyed"
   label define svymalegr6pct .a "no grade 6 students surveyed"



   /* generate a var that calculates the percentage of female and male students in total enrollment */
   local grades 1 2 3 4 5 6 7 8 9 10 11 12 //generate a kicak nacri for grade bynvers
   foreach j of local grades {
     //generate a var that calculates the percentage of female students in each grade in the enrollment data
     gen enrfemalegr`j'pct = .a //generate extended missing value first for labeling later
     label var enrfemalegr`j'pct "percent of female students in grade `j' in enrollment data"
     replace enrfemalegr`j'pct = gr`j'femaleenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of surveyed female students in each grade in the enrollment data if denominator is not 0
     label define enrfemalegr`j'pct .a "grade `j' enrollment is 0"

     //generate a var that calculates the percentage of male students in each grade in the enrollment data, generate extended missing value first for labeling later
     gen enrmalegr`j'pct = .a //generate extended missing value first for labeling later
     label var enrmalegr`j'pct "percent of male students in grade `j' in enrollment data"
     replace enrmalegr`j'pct = gr`j'maleenr/gr`j'enr if gr`j'enr != 0 //calculates the percentage of surveyed male students in each grade in the enrollment data if denominator is not 0
     label define enrmalegr`j'pct .a "grade `j' enrollment is 0"
   }

   /* generate a var that is the difference between survey sample and enrollment data of percent of female and male students in grade 3  */
   local elemgrades 3 4 5 6 //create a local macro for the grades in the elementary survey data
   foreach k of local elemgrades {
     gen femalegr`k'dif = svyfemalegr`k'pct - enrfemalegr`k'pct //calculates the difference between the survey sample and enrollment data for female students in grade i
     gen malegr`k'dif = svymalegr`k'pct - enrmalegr`k'pct       //calculates the difference between the survey sample and enrollment data for male students in grade i
     label var femalegr`k'dif "Difference in grade `k' female percentage between survey sample and enrollment data"
     label var malegr`k'dif "Difference in grade `k' male percentage between survey sample and enrollment data"
   }

   compress //compress dataset to save space
   label data "Elementary `i' demographics data with survey coverage analysis variables"
   save $projdir/dta/demographics/analysis/elementary/elemdemo`i'analysis, replace

 }
