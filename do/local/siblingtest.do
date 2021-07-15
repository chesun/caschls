/* test file using test data to find an algorithm to remove duplicate families across years */

cd "D:/Programs/Dropbox/Davis/Research Projects/Ed Lab GSR/caschls"

insheet using ./dta/raw/siblingxwalk/siblingtest.csv

tempfile master
save `master'

use `master', clear
rename year year2
rename state_student_id state_student_id2
rename firstname firstname2
rename lastname lastname2
rename address address2
rename city city2
rename state state2
save ./dta/cln/siblingxwalk/siblingtest, replace

use `master', clear

group_twoway familyid state_student_id, generate(ufamilyid)
