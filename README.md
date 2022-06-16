# caschls
 Stata code for Common Core VA project and calschls survey data work for CA Ed Lab GSR. ./dta directory contains only publicly available data from California Department of Education.

## Useful Guides

### file_dict.md
Contains descriptions and naming conventions for the files in this project.



## Project To-Do
To do list for merging the coding workflow and project infrastructure of Matt's repo and my repo. Matt's repo ```ca_ed_lab-common_core_va``` will be referred to as the *origin repo*, and the current working environment ```chesun/common_core_va_workflow_merge``` repo will be referred to as the *working repo*, and my own repo for the VA project, ```chesun/caschls```, will be referred to as *Che's repo*.
- [ ] Phase out local macros for where VA project directories are called such as `vaprojdofiles', use global macro $vaprojdir instead
- [ ] Reconcile differences in the settings file
- [ ] Merge the master do file
- [ ] Tentative unified folder structure:
  - /do: do files
  - /log: log files
  - /out: output, includes /figures and /tables from the origin repo
  - /doc: documents, includes the /notes, /paper, /presentations, and /proposal folders from origin repo
  - /py: python files
  - /dta: non-confidential data
  - /est: stored estimates from stata
- [ ] Reconcile the do file folder structure:
  - [ ]



## Change Log
A list of major changes made while merging workflows.
- 06/16/2022
  - Changed /varegs folder name in Che's repo to /svyvaregs, updated locally and server side on Scribe
  - Deleted the /matt folder in Che's repo and moved its subfolder /ado to the /do folder, updated server side 
