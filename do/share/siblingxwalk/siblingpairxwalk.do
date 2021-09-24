********************************************************************************
/* create a dataset with all pairwise combinations of siblings and their state student IDs.
Same combination with different orders are different observations. */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

***this resulting dataset can be used to merge siblings into a dataset with sibling pairs 

clear all
set more off

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
