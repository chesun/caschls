********************************************************************************
/* rename and clean parent 1415 survey questions of interest */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off

use $clndtadir/parent/parent1415, clear

//only keep questions of interest. 1415 dataset does not have qoi30 32 34 64
keep cdscode q7 q13 q14 q15 q26 q39 q41
//delete all value labels not associated with variables
labdu , delete
//rename questions of interest using question numbers in 1819 as standard
rename q7 qoi9
elabel rename q7 qoi9
rename q13 qoi15
elabel rename q13 qoi15
rename q14 qoi16
elabel rename q14 qoi16
rename q15 qoi17
elabel rename q15 qoi17
rename q26 qoi27
elabel rename q26 qoi27
rename q39 qoi31
elabel rename q39 qoi31
rename q41 qoi33
elabel rename q41 qoi33

/* count the total number of responses in each school */
sort cdscode
by cdscode: gen totalresp = _N
label var totalresp "total number of responses at each school including missing"


********************************************************************************
/* generate dummies for each response option and missing for qoi 9 15-17 27 31 33 */

/* value labels for qoi 9 15-17 27 31 33:
1 strongly agree
2 agree
3 disagree
4 strongly disagree
5 don't know/NA

Recode:
-2 strongly disagree
-1 disagree
0 neutral
1 agree
2 strongly agree
*/

/* recode qoi 9 15/17 27 31 33 */
foreach i of numlist 9 15/17 27 31 33 {
  gen qoi`i'temp = .
  replace qoi`i'temp = -2 if qoi`i' == 4
  replace qoi`i'temp = -1 if qoi`i' == 3
  replace qoi`i'temp =  0 if qoi`i' == 5
  replace qoi`i'temp =  1 if qoi`i' == 2
  replace qoi`i'temp =  2 if qoi`i' == 1

  drop qoi`i'
  rename qoi`i'temp qoi`i'
}

foreach i of numlist 9 15/17 27 31 33 {
  gen stragree`i' = 0
  replace stragree`i' = 1 if qoi`i' == 2

  gen agree`i' = 0
  replace agree`i' = 1 if qoi`i' == 1

  gen disagree`i' = 0
  replace disagree`i' = 1 if qoi`i' == -1

  gen strdisagree`i' = 0
  replace strdisagree`i' = 1 if qoi`i' == -2

  gen dontknow`i' = 0
  replace dontknow`i' = 1 if qoi`i' == 0

  gen missing`i' = 0
  replace missing`i' = 1 if missing(qoi`i')
}

/* generate means for the qoi  */
foreach i of numlist 9 15/17 27 31 33 {
  egen qoi`i'mean = mean(qoi`i'), by(cdscode)
}


/* This is old code before the recoding of qoi values
 /* generate mean of vars, excluding don't know. */
 //generate temp vars for low and high bounds to use with rangestat
 gen lowbound = 1
 gen highbound = 4
foreach i of numlist 9 15/17 27 30/34 64 {
  rangestat (mean) qoi`i', interval(qoi`i' lowbound highbound) by(cdscode)
  rename qoi`i'_mean qoi`i'mean //rename the generated mean vars
}
/* Note: don't worry about missing values generated because it does not matter
after collapsing dataset */
drop lowbound highbound //drop the temp vars */


/* collapse the dataset, resulting dataset has mean for each qoi, total number
of responses, and number of responses for each option in each question */
collapse (mean) qoi*mean totalresp (sum) stragree* agree* disagree* strdisagree* dontknow* missing*, by(cdscode)
//some schools have missing means because they have very low number of responses and with either don't know or missing

**************************** relabel the vars **********************************
/* label mean vars */
label var qoi9mean "Mean (excluding don't know) of Q: promotes academic success for all students"

label var qoi15mean "Mean (excluding don't know) of Q: provides quality counseling or other ways..."
label var qoi16mean "Mean (excluding don't know) of Q: is a supportive and inviting place..."
label var qoi17mean "Mean (excluding don't know) of Q: allows input and welcomes parents'..."

label var qoi27mean "Mean (excluding don't know) of Q: encourages me to be an active partner..."

label var qoi31mean "Mean (excluding don't know) of Q: motivates students to learn"

label var qoi33mean "Mean (excluding don't know) of Q: has adults who really care about students"

label var totalresp "total number of responses in the school including missing"

/* label vars for the number of response for each option */
foreach i of numlist 9 15/17 27 31 33 {
  label var stragree`i' "number of people choosing strongly agree for qoi`i'"
  label var agree`i' "number of people choosing agree for qoi`i'"
  label var disagree`i' "number of people choosing disagree for qoi`i'"
  label var strdisagree`i' "number of people choosing strongly disagree for qoi`i'"
  label var dontknow`i' "number of people choosing don't know for qoi`i'"
  label var missing`i' "number of missing responses for qoi`i'"
}

/* generate a year var to prepare for constructing a panel */
gen year = 1415

label data "cleaned parent 1415 survey questions of interest with percent disagree/agree etc."
compress
save $projdir/dta/buildanalysisdata/qoiclean/parent/parentqoiclean1415, replace
