# File Dictionary
A handy guide for the file contents of the project folder. Includes descriptions of files and naming conventions for file names.

## /out

### Overview

This is the output folder. It contains output files organized by file type. The ```/csv``` folder contains csv format tables, ```/dta``` folder contains stata .dta format output that is non-confidential (e.g. coefficient table converted to .dta), the ```/graph``` folder contains graphs, ```/ster``` contains stata .ster regression estimate files, ```/txt``` contains windows .txt text files, and ```/xls``` contains excel .xls files (usually coefficient tables).


### /out/csv

#### ./acs
Data dictionaries for the ACS subject tables datasets.

#### ./factoranalysis
Output tables from the factor analysis for the caschls survey data.

- ```alpha.xlsx```: Cronbach's alpha test for survey questions of interest
  - Output of ```.do/share/factoranalysis/alpha.do```
- ```[svyname]factorall.csv```: Factor analysis for svyname survey questions including all factors
  - Output of ```.do/share/factoranalysis/factor.do```
- ```[svyname]factoreigen1```: Factor analysis for svyname survey questions including only factor with eigenvalue above 1
  - Output of ```.do/share/factoranalysis/factor.do```
- ```./allsvy```: Factor analysis for merged dataset with QOI means from all 3 surveys (secondary, parent, staff). Naming conventions same as single survey factor analysis output files
  - Output of ```.do/share/factoranalysis/allsvyfactor.do```
- ```./indexhorserace```: Linear regressions results of VA estimates on all 3 survey indices (school climate, teacher and staff quality, student support) in a "horse race" type regression for both complete case and imputed data
  - Output of ```.do/share/factoranalysis/indexhorserace.do```
  - Imputation uses ```.do/share/factoranalysis/imputation.do``` and ```.do/share/factoranalysis/imputedcategoryindex.do```

#### ./gradetab
Intermediate .csv output files created for tabulating the grades of the survey respondents. Contains files written by ```.do/build/check/gradetab.do```

#### ./schooloverlap
Intermediate .csv output files created for checking the overlap of the schools across years who participated in the surveys.

*NOTE: DEPRECATED*

#### ./siblingvaregs
Output tables of sibling VA analysis.

- ##### ./fb_test: Forecast Bias test results
  - Files in the root folder are from sibling VA sample.
    - Tables are organized by subject and enrollment outcome
  - Files in ```./fbtest/sib_acs_restr_smp``` are from the Sibling Census Restricted Sample
    - Tables for outcome VA, test score VA, and deep knowledge VA
- #### ./spec_test: Specification test results
  - Similar naming conventions as ```/fb_test```
- #### ./persistence: Results from regressing enrollment on VA estimates
  - ```reg_outcome_va_[subject].csv```: regressing enrollment outcomes on ```subject``` VA
  - ```het_reg_outcome_va_[subject]_x_prior_[prior_subject].csv```: regressing enrollment on ```subject``` VA interacted with prior ```prior_subject``` test score deciles
- #### ./vam: Coefficients from the VAM commands

#### ./varegs
Output tables of regressing the original sample VA estimates on the survey questions.
