********************************************************************************
/* use the sibling crosswalk dataset conditional on same year and create unique family ID
to link siblings from the same family across years and delete duplicates  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

use $projdir/dta/siblingxwalk/k12_xwalk_name_address_year, clear

/* install ssc package that group observations by the connected components of two variables  */
/* ssc install group_twoway, replace */

/* convert to string to match variable format of state student ID in order to run group_twoway */
tostring siblings_name_address_year, replace format("%17.0f")
/* make family ID and state student ID disjoint to avoid error with command
https://haghish.com/statistics/stata-blog/stata-programming/download/group_twoway.html  */
replace siblings_name_address_year = "family"+siblings_name_address_year

/* this creates a group for all students that are linked to each other through the same family across years.
This command links observations that are connected through famnily ID and student ID. So if two siblings are observed in the same year
but one of them is observed in another year with another sibling, they will be linked together. This also links siblings even if they move*/
group_twoway siblings_name_address_year state_student_id, generate(ufamilyid)

bysort ufamilyid: replace numsiblings = _N-1
save $projdir/dta/siblingxwalk/uniquelinkedfamilyraw, replace

/* keep one copy per student */
duplicates report state_student_id
duplicates drop state_student_id, force

bysort ufamilyid: replace numsiblings = _N-1
label var ufamilyid "unique family ID after linking all siblings in same family"

/* Note: for large number of siblings the reason could be cousins/other relatives with the same
last name lived in the same address at a certain point so that links all of the cousins etc */
drop siblings_name_address_year
order ufamilyid year numsiblings state_student_id first_name  last_name birth_date street_address_line_one street_address_line_two city state zip_code
save $projdir/dta/siblingxwalk/uniquelinkedfamilyclean, replace
