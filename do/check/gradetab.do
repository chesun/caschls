********************************************************************************
******************** tabulation of grades in datasets  *************************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear
set more off

log using $projdir/log/check/gradetab, replace name(gradetab) // start log file for this do file

******************** Tabulate elementary datasets *******************************

local elemdtaname `" "elem1415" "elem1516" "elem1617" "elem1718" "elem1819" "' //local macro for elementary dataset names

foreach i of local elemdtaname {
  use $clndtadir/elementary/`i', clear
  estpost tab grade
  esttab using "$projdir/out/csv/gradetab/elementary/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') nonumber noobs nomtitle replace
}


*********************** Tabulate parent datasets *******************************

use $clndtadir/parent/parent1415, clear
estpost tab q6 //q6 is the question that asks about the grade of the child
esttab using "$projdir/out/csv/gradetab/parent/parent1415.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') nonumber noobs nomtitle replace

use $clndtadir/parent/parent1516, clear
estpost tab p7 //p7 is the question that asks about the grade of the child
esttab using "$projdir/out/csv/gradetab/parent/parent1516.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') nonumber noobs nomtitle replace

use $clndtadir/parent/parent1617, clear
estpost tab p7 //p7 is the question that asks about the grade of the child
esttab using "$projdir/out/csv/gradetab/parent/parent1617.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') nonumber noobs nomtitle replace

use $clndtadir/parent/parent1718, clear
estpost tab p7 //p7 is the question that asks about the grade of the child
esttab using "$projdir/out/csv/gradetab/parent/parent1718.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') nonumber noobs nomtitle replace

use $clndtadir/parent/parent1819, clear
estpost tab p7 //p7 is the question that asks about the grade of the child
esttab using "$projdir/out/csv/gradetab/parent/parent1819.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') nonumber noobs nomtitle replace



*********************** Tabulate secondary datasets ****************************

/* only tabulating the most recent 5 years  */

local secdtaname `" "sec1415" "sec1516" "sec1617" "sec1718" "sec1819" "' //local macro for secondary dataset names, only the most recent 5 years

foreach i of local secdtaname {
  use $clndtadir/secondary/`i', clear
  estpost tab grade
  esttab using "$projdir/out/csv/gradetab/secondary/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') nonumber noobs nomtitle replace
}




************************* Tabulate staff datasets ******************************

/* only tabulating the most recent 5 years  */

/* q1 teacher classifications vars
Question 1: What is your role(s) at this school? (Mark All That Apply.)

q1a: teacher in grade 5 or above
q1b: teacher in grade 4 or below
q1c: special education teacher
q1d: administrator
q1e: prevention staff nurse, or health aide
q1f: counselor, psychologist
q1g: police, resource officer, or safety personnel
q1h: Paraprofessional, teacher assistant, or instructional aide
q1i: Other certificated staff (e.g. librarian)
q1j: Other classified staff (e.g. janitor, secretarial or clerical, food service)
q1k: Other service provider (e.g. speech, occupational, physical therapist)

*/




local staffdtaname `" "staff1415" "staff1516" "staff1617" "staff1718" "staff1819" "' //local macro for staff dataset names, only the most recent 5 years

foreach i of local staffdtaname {

  use $clndtadir/staff/`i', clear

  gen below4above5 = . //generate a var that indicates whether the teacher teaches both above grade 5 and below grade 4
  replace below4above5 = 0 if q1a == 0 | q1b ==0
  replace below4above5 = 1 if q1a == 1 & q1b == 1

  estpost tab q1a
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("teacher in grade 4 or below") nonumber noobs nomtitle replace
  estpost tab q1b
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("teacher in grade 5 or above") nonumber noobs nomtitle append
  estpost tab below4above5
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("teacher in both above grade 5 and below grade 4") nonumber noobs nomtitle append
  estpost tab q1c
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("special education teacher") nonumber noobs nomtitle append
  /* estpost tab q1d
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("administrator") nonumber noobs nomtitle append
  estpost tab q1e
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("prevention staff nurse, or health aide") nonumber noobs nomtitle append
  estpost tab q1f
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("counselor, psychologist") nonumber noobs nomtitle append
  estpost tab q1g
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("police, resource officer, or safety personnel") nonumber noobs nomtitle append
  estpost tab q1h
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("paraprofessional, teacher assistant, or instructional aide") nonumber noobs nomtitle append
  estpost tab q1i
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("other certificated staff (e.g. librarian)") nonumber noobs nomtitle append
  estpost tab q1j
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("other classified staff (e.g. janitor, secretarial or clerical, food service)") nonumber noobs nomtitle append
  estpost tab q1k
  esttab using "$projdir/out/csv/gradetab/staff/`i'.csv", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(`e(labels)') title("other service provider (e.g. speech, occupational, physical therapist)") nonumber noobs nomtitle append */

  drop below4above5

}






log close gradetab //close this log file
translate $projdir/log/check/gradetab.smcl $projdir/log/check/gradetab.log, replace
