********************************************************************************
/* create a dataset with all pairwise combinations of siblings and their state student IDs.
Same combination with different orders are different observations. */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

***this resulting dataset can be used to merge siblings into a dataset with sibling pairs
cap log close _all
clear all
set more off

log using $projdir/log/share/siblingxwalk/siblingpairxwalk.smcl, replace

use $projdir/dta/siblingxwalk/uniquelinkedfamilyclean, clear

/* make tempfile for merging with joinby command */
drop year numsiblings street_address_line_one street_address_line_two city state zip_code
rename state_student_id sibling_state_student_id
rename first_name sibling_first_name
rename last_name sibling_last_name
rename birth_date sibling_birth_date
rename middle_intl sibling_middle_intl

label var sibling_state_student_id "Sibling State Student ID"
label var sibling_first_name "Sibling First Name"
label var sibling_last_name "Sibling Last Name"
label var sibling_birth_date "Sibling Birth Date"
label var sibling_middle_intl "Sibling Middle Initial"

tempfile formerge
save `formerge'

use $projdir/dta/siblingxwalk/uniquelinkedfamilyclean, clear
drop year numsiblings street_address_line_one street_address_line_two city state zip_code
joinby ufamilyid using `formerge'

/* drop observations where self joins on self */
drop if state_student_id == sibling_state_student_id

order ufamilyid state_student_id sibling_state_student_id


save $projdir/dta/siblingxwalk/siblingpairxwalk, replace




*******create unique sibling pairs by dropping permutations
//load the pairwise combination of siblings dataset
use $projdir/dta/siblingxwalk/siblingpairxwalk, clear
egen pairorder1 = concat(state_student_id sibling_state_student_id)
egen pairorder2 = concat(sibling_state_student_id state_student_id)

//pairorder1 has pairs in ascending order
replace pairorder1 = pairorder2 if state_student_id > sibling_state_student_id

//remove duplicate permutations within family
bysort ufamilyid pairorder1: gen i = _n
keep if i==1

drop pairorder1 pairorder2 i


//distance between birth dates for sibling pairs
gen birth_date_distance = abs(birth_date - sibling_birth_date)

bysort ufamilyid: egen avg_birth_date_distance_family = mean(birth_date_distance)

replace avg_birth_date_distance_family = avg_birth_date_distance_family/365
label var avg_birth_date_distance_family "Average distance of birth dates in family in years"


label data "Unique sibling pairs after dropping duplicate permutations"

save $projdir/dta/siblingxwalk/uniquesiblingpairxwalk, replace


log close
translate $projdir/log/share/siblingxwalk/siblingpairxwalk.smcl $projdir/log/share/siblingxwalk/siblingpairxwalk.log, replace
