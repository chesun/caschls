********************************************************************************
******************** convert CDE enrollment datasets to dta *************************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

//This is a local do file. Global settings for Scribe server do files don't apply

//codebook: https://www.cde.ca.gov/ds/sd/sd/fsenr.asp

/* run the follow two lines to run this do file */
// cd "D:\Programs\Dropbox\Davis\Research Projects\Ed Lab GSR\caschls"
// do ./do/clean/enrollment.do

clear
set more off

local enrlrawname `" "enr1415" "enr1516" "enr1617" "enr1718" "enr1819" "' //local macro for raw enrollment dataset names

foreach i of local enrlrawname {
  import delimited ./dta/raw/`i'.txt, clear

  rename cds_code cdscode
  rename ethnic ethnicity
  rename kdgn kdgtnenrl
  rename gr_1 gr1enrl
  rename gr_2 gr2enrl
  rename gr_3 gr3enrl
  rename gr_4 gr4enrl
  rename gr_5 gr5enrl
  rename gr_6 gr6enrl
  rename gr_7 gr7enrl
  rename gr_8 gr8enrl
  rename ungr_elm ungrelemenrl
  rename gr_9 gr9enrl
  rename gr_10 gr10enrl
  rename gr_11 gr11enrl
  rename gr_12 gr12enrl
  rename ungr_sec ungrsecenrl
  rename enr_total totalenrl

  label var cdscode "14 digit CDS Code"
  label var county "County"
  label var district "School District"
  label var school "School Name"
  label var ethnicity "Ethnicity"
  label var gender "Gender"
  label var kdgtnenrl "Kindergarten Enrollment"
  label var gr1enrl "Grade 1 Enrollment"
  label var gr2enrl "Grade 2 Enrollment"
  label var gr3enrl "Grade 3 Enrollment"
  label var gr4enrl "Grade 4 Enrollment"
  label var gr5enrl "Grade 5 Enrollment"
  label var gr6enrl "Grade 6 Enrollment"
  label var gr7enrl "Grade 7 Enrollment"
  label var gr8enrl "Grade 8 Enrollment"
  label var ungrelemenrl "Enrollment in ungraded elementary classes in kindergarten through grade 8"
  label var gr9enrl "Grade 9 Enrollment"
  label var gr10enrl "Grade 10 Enrollment"
  label var gr11enrl "Grade 11 Enrollment"
  label var gr12enrl "Grade 12 Enrollment"
  label var ungrsecenrl "Enrollment in ungraded secondary classes in grade 9 through 12"
  label var totalenrl "Total Enrollment for kindergarten through gr12 + ungrelemenrl + ungrsecenrl"
  label var adult "Adult enrollment in kindergarten through grade 12"

  tostring cdscode, replace format("%15.0f") //convert cdscode to string and apply a number format to enable string conversion

  // create a value label for ethnicity according to online codebook
  label define ethniclabel 0 "Not reported" 1 "American Indian or Alaska Native, Not Hispanic" 2 "Asian, Not Hispanic" 3 "Pacific Islander, Not Hispanic" 4 "Filipino, Not Hispanic" 5 "Hispanic or Latino" 6 "African American, not Hispanic" 7 "White, not Hispanic" 8 "Two or More Races, Not Hispanic"
  label values ethnicity ethniclabel

  compress
  save ./dta/cln/`i', replace
}
