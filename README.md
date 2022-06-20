# caschls
 Stata code for Common Core VA project and calschls survey data work for CA Ed Lab GSR. ./dta directory contains only publicly available data from California Department of Education.

## Useful Guides

### file_dict.md
Contains descriptions and naming conventions for the files in this project.



## Project To-Do
To do list for merging the coding workflow and project infrastructure of Matt's repo and my repo. Matt's repo ```ca_ed_lab-common_core_va``` will be referred to as the *origin repo*, and the current working environment ```chesun/common_core_va_workflow_merge``` repo will be referred to as the *working repo*, and my own repo for the VA project, ```chesun/caschls```, will be referred to as *Che's repo*.
- [ ] Phase out local macros for where VA project directories are called such as `vaprojdofiles', use global macro $vaprojdir instead
- [ ] Update the settings file
- [ ] Merge the master do file
- [ ] Reconcile the do file folder structure:
  - [ ]


Tentative unified folder structure:
- Project root directory: ```/home/ca_ed_lab/projects/common_core_va```
  - /do: do files
    - /archive: archived do files from Matt's and Che's repos
    - /acs: do files to clean the census tract data
    - /cde_presentations: do files for past presentations, written by Matt
    - /kramer_nsc: do files to clean NSC data written by Kramer
    - /sbac: original value added do files, mostly written by Matt, some written by Che
    - /schl_chars: do files to clean CDE school characteristics data
    - /ado: ado files
    - /build: building datasets
      - /buildanalysisdata: creating analysis datasets for the survey data
        - /poolingdata: pooling survey data across years
        - /poolingva: pooling original va estimates for use in regressions with survey questions
        - /qoiclean: cleaning survey questions of interest (QOI)
          - /parent
          - /secondary
          - /staff
      - /prepare: cleaning and preparing raw data
      - /sample: checking sample characteristics
    - /check: ad hoc do files for checking data
      - /sbactroubleshoot
    - /local: do files to be run locally
    - /share: do files to create results for sharing
      - /demographics: do files that check the representativeness of surveys
      - /factoranalysis: factor analysis and PCA for survey questions
      - /outcomesumstats: ad hoc summary statistics for NSC outcomes
      - /siblingvaregs: sibling value added
      - /siblingxwalk: create sibling crosswalk used in constructing sibling VA sample
      - /svyvaregs: regressions with VA estimates and survey indices 
  - /log: log files
  - /out: output, includes /figures and /tables from the origin repo
  - /doc: documents, includes the /notes, /paper, /presentations, and /proposal folders from origin repo
  - /py: python files
  - /dta: non-confidential data
  - /est: stored estimates from stata



## Change Log
A list of major changes made while merging workflows.
- 06/16/2022
  - Changed /varegs folder name in Che's repo to /svyvaregs, Scribe server side updated
  - Deleted the /matt folder in Che's repo and moved its subfolder /ado to the /do folder, server side updated
