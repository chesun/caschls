********************************************************************************
/* Use CST data to match students with their siblings. Code taken mostly from
do file by Matt Naven  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

//append all years of CST datasets, from 2004 to 2013
foreach year of numlist 2004 (1) 2013 {
  append using $cstdtadir/cst_`year', keep (state_student_id birth_date year ///
  first_name middle_intl last_name ///
  street_address_line_one street_address_line_two city state zip_code)
}

//drop observations with missing street address line 1. Note that missing() does not work since some observations have one character such as Y or 0
drop if strlen(street_address_line_one) <= 1
drop if missing(state_student_id)
tempfile master
save `master'


********************************************************************************
/* Match siblings based on last name, address, and year. This rules out cases
where someone with the same last name moves to the same address after the previous
student moves out */
local matchonsameyear = 1
if `matchonsameyear' == 1 {

  use `master', clear

  /* check for duplicates. Do not need middle initial and zip code to be the same to count as duplicates, because
  middle initial has 38.56% missing and zip code has 7.36% missing, whereas city and state have around 0.01% and 0% missing, respectively.
  This avoids treating the same person with and w/o middle initial or zip code as different people
  Q: what if 2 people with same last and first names but different middle initial and born on the same day are twins? */
  duplicates report state_student_id year street_address_line_one street_address_line_two city state
  /* only keep one observation per state student ID, year, name, and address*/
  duplicates drop state_student_id year street_address_line_one street_address_line_two city state, force



  /* generate family groups based on last name, address, and year. Treat missing
  as any other variables and group observations with match vars missing into the same family */
  egen long siblings_name_address_year = group(year last_name street_address_line_one street_address_line_two city state zip_code), mi
  /* tostring siblings_name_address_year, replace format("%17.0f") */

  /* drop if no siblings */
  bysort siblings_name_address_year: drop if _N==1

  //generate a variable for number of siblings for each student
  bysort siblings_name_address_year: gen numsiblings = _N-1
  label var numsiblings "number of siblings excluding self"


  // Save data
  order siblings_name_address_year year numsiblings state_student_id first_name  last_name birth_date street_address_line_one street_address_line_two city state zip_code
  sort siblings_name_address_year year
  label var siblings_name_address_year "family ID after matching on name address and year"
  compress

  label data "CST data siblings crosswalk matching on same year, last name, and address"

  save $projdir/dta/siblingxwalk/k12_xwalk_name_address_year, replace
}

/* duplicates report state_student_id birth_date first_name last_name street_address_line_one street_address_line_two city state zip_code
duplicates report state_student_id birth_date first_name last_name street_address_line_one street_address_line_two city state */


********************************************************************************
/* Match siblings based on last name and address */
local matchacrossyears = 1
if `matchacrossyears' == 1 {
  use `master', clear

  /* check for duplicates and keep one observation per state student ID, last name, and address*/
  duplicates report state_student_id street_address_line_one street_address_line_two city state
  duplicates drop state_student_id street_address_line_one street_address_line_two city state, force

  // Group observations if they match on last name, and address
  egen long siblings_name_address = group(last_name street_address_line_one street_address_line_two city state zip_code), mi
  /* tostring siblings_name_address, replace format("%17.0f") */

  // Drop if no siblings
  bysort siblings_name_address: drop if _N==1

  //generate a variable for number of siblings for each student
  bysort siblings_name_address: gen numsiblings = _N-1
  label var numsiblings "number of siblings excluding self"

  //save data
  order siblings_name_address numsiblings state_student_id first_name last_name birth_date street_address_line_one street_address_line_two city state zip_code
  sort siblings_name_address
  label var siblings_name_address "family ID after matching on name and address"
  compress

  label data "CST data siblings crosswalk matching on same last name and address"

  save $projdir/dta/siblingxwalk/k12_xwalk_name_address, replace
}
