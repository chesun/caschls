*** do file cleancaaspp2018.do for Stata
*** version 16.0
*** by Kramer

/* 

This .do file cleans the 2017-2018 CAASP file (which contains 2017-2018 CADOE
standardized testing including SBAC scores.) It is based off of Matt's
clean_caaspp.do file which cleaned the 2014/2015 - 2016/2017 assessments.

This creates individual files for the following 2017-2018 assessments:

SBAC (ELA and Math)
CAA (ELA, Math, and Science)
CAST
STS

*/

*********** Set Up
clear all
capture log close
cd "/home/research/ca_ed_lab/data/restricted_access/"
log using "/home/research/ca_ed_lab/msnaven/data/log_files/caaspp/clean_caaspp_2018.smcl", replace
set more off
version 16.0

****************************************************************************
 ***                             Begin File                             ***
****************************************************************************


*** Clean the whole CAASP .do file ********************************************

******** 2017-2018
use "raw/caaspp/caasp1718.dta", clear

rename *, lower

**** Record Type
/*
Sourced from: Derived value based on each test  

Student test registration records for the CAAs for ELA and mathematics will be provided in the Production and LEA Student Data (downloadable) files. However, because these tests are post-equated for the 2017–18 year, the test results will not be included in V1 and P1.
 
The V1 file will contain demographic data based on the latest CALPADS file when the data are pulled, unless the LEA’s selected testing window has closed or students were exited from CALPADS, and the demographic snapshot was taken.
 
The P1 file will contain demographic data based on the latest CALPADS file when the data are pulled, unless the LEA’s selected testing window has closed or students were exited from CALPADS, and the demographic snapshot was taken.   There are exceptions that will prevent student records from appearing in the P1 data set due to edit/resolution processes.
 
The P2 file is the final operational file and includes 100 percent of the student population. When the P2 data set is produced, all data have been reconciled from end to end starting from the test delivery system through to scoring/rating processes, and then through all reporting systems. P2 delivery does not account for a potential 10-day testing window extension that can be requested by the LEA and that will result in a delay in the delivery of the P2 student and aggregate files.
 
LEA Student Data (downloadable) files will be ready at P1 and P2 for the 2017-18 administration. The student data files will be made available to LEAs pending approval for release by the CDE. All LEAs regardless of percentage of scoring completed will be provided a LEA Student Data (downloadable) file.

Acceptable Value: 
01  –  Smarter Balance Summative ELA  –  SB ELA, 
02  –  Smarter Balance Summative Mathematics  –  SB Math, 
03  –  California Alternate Assessment ELA  –  CAA ELA,
04  –  California Alternate Assessment Mathematics  –   CAA Math, 
05  –  California Alternate Assessment Science  –  CAA Science, 
06  –  California Science Test  –  CAST, 
08  –  Standard–based Tests in Spanish for Reading/Language Arts  –  STS
*/
tab rectype, missing
label def caaspp_record_type 1 "Smarter Balance ELA"
label def caaspp_record_type 2 "Smarter Balance Mathematics", add
label def caaspp_record_type 3 "CAA ELA", add
label def caaspp_record_type 4 "CAA Mathematics", add
label def caaspp_record_type 5 "CAA Science", add
label def caaspp_record_type 6 "CST", add
label def caaspp_record_type 8 "STS", add
destring rectype, gen(caaspp_record_type)
replace caaspp_record_type = . if !inlist(caaspp_record_type, 1, 2, 3, 4, 5, 6, 8)
label val caaspp_record_type caaspp_record_type
label var caaspp_record_type "Record Type"
drop rectype

**** Statewide Student Identifier (SSID)
* Sourced from CALPADS: SSID
* Acceptable Values: Alpha (0–9)
rename ssid state_student_id
replace state_student_id = upper(trim(itrim(state_student_id)))
label var state_student_id "Statewide Student Identifier (SSID)"

**** Student Last Name
* Sourced from CALPADS: LastorSurname
* Acceptable Values: alpha, numeric, space, comma, hyphen, apostrophe, or special characters
rename lastname last_name
* Remove space to the left and right of hyphens
replace last_name = regexr(last_name, "[a-zA-Z] ?- ?[a-zA-Z]", ///
	regexs(1) + regexs(2) + regexs(3)) ///
	if regexm(last_name, "([a-zA-Z]) ?(-) ?([a-zA-Z])")
* All uppercase and remove extra blanks
replace last_name = upper(trim(itrim(last_name)))
label var last_name "Student Last Name"

**** Student First Name
* Sourced from CALPADS: FirstName
* Acceptable Values: alpha, numeric, space, comma, hyphen, apostrophe, or special characters
rename firstname first_name
* Remove space to the left and right of hyphens
replace first_name = regexr(first_name, "[a-zA-Z] ?- ?[a-zA-Z]", ///
	regexs(1) + regexs(2) + regexs(3)) ///
	if regexm(first_name, "([a-zA-Z]) ?(-) ?([a-zA-Z])")
* All uppercase and remove extra blanks
replace first_name = upper(trim(itrim(first_name)))
label var first_name "Student First Name"

**** Student Middle Name
* Sourced from CALPADS: Middlename
* Acceptable Values: Blank, alpha, numeric, space, comma, hyphen, apostrophe, or special characters
rename middlename middle_name
* Remove space to the left and right of hyphens
replace middle_name = regexr(middle_name, "[a-zA-Z] ?- ?[a-zA-Z]", ///
	regexs(1) + regexs(2) + regexs(3)) ///
	if regexm(middle_name, "([a-zA-Z]) ?(-) ?([a-zA-Z])")
* All uppercase and remove extra blanks
replace middle_name = upper(trim(itrim(middle_name)))
label var middle_name "Student Middle Name"

**** Date of Birth
* Sourced from CALPADS: DateofBirth
* This is the Date of Birth value at the time the student started the first 
* test. If the student did not test, this is the Date of Birth value from the 
* demographic snapshot.
* Acceptable Values: Alphanumeric  or Blank  - YYYY-MM-DD
gen birth_date = date(dob, "YMD")
replace birth_date = . if mi(dob)
format birth_date %td
label var birth_date "Date of Birth"
drop dob

**** Gender
* Sourced from CALPADS: Sex
* Acceptable Values:
* Female, Male, or Blank
tab gender, missing
label def male 1 "Male" 0 "Female"
gen male:male = 1 if gender=="Male"
replace male = 0 if gender=="Female"
replace male = . if mi(gender)
label var male "Male"
drop gender

**** CALPADS Grade
* Sourced from CALPADS: Grade
* Latest grade received from CALPADS. If a student was exited from CALPADS for the current year and re-enrolled for subsequent school year, the next year grade will be present in this field. This field can be populated during registration, updated during testing, scoring, and reporting, and until the daily CALPADS file is stopped for processing in TOMS (Expected July 1, 2017).
* Acceptable Values:
* Alphanumeric (01-12, KN,UE,US) (leading zero if applicable)
rename grade x
tab x, missing
destring x, gen(grade) ignore("KNUES")
replace grade = 0 if x=="KN"
replace grade = . if x=="UE"
replace grade = . if x=="US"
replace grade = . if grade<0 | grade>12
replace grade = . if mi(x)
label var grade "CALPADS Grade"
drop x

**** Grade Assessed
* Sourced from: TOMS originally from CALPADS
* This is the locked grade at the time the student starts the first test. If the student did not test, this is the grade they were eligible to test.
* Acceptable Values:
* Numeric (02-12) (Leading zero if applicable)
tab gradetested, mi
destring gradetested, gen(grade_tested)
replace grade_tested = . if grade_tested<2 | grade_tested>12
replace grade_tested = . if mi(gradetested)
label var grade_tested "Grade Assessed"
drop gradetested

**** CALPADS District Code
* Sourced from CALPADS: ResponsibleDistrictIdentifier
* Latest District code received from CALPADS
* This field can be populated during registration, updated during testing, scoring, and reporting, and until the daily CALPADS file is stopped for processing in TOMS (Expected July 1, 2017).
* Acceptable Values:
* Numeric 14 digits
rename districtcode cd_code
replace cd_code = upper(trim(itrim(cd_code)))
label var cd_code "CALPADS District Code"

**** CALPADS School Code
* Sourced from CALPADS: ResponsibleSchoolIdentifier
* Latest School code received from CALPADS
* This field can be populated during registration, updated during testing, scoring, and reporting, and until the daily CALPADS file is stopped for processing in TOMS (Expected July 1, 2017).
* Acceptable Values:
* Numeric 14 digits
rename schoolcode school_code
replace school_code = upper(trim(itrim(school_code)))
label var school_code "CALPADS School Code"

**** CDS Code
gen cdscode = upper(trim(itrim(school_code)))
label var cdscode "County/District/School Code"

**** CALPADS Charter Code
* Sourced from CALPADS:
* Latest Charter code received from CALPADS
* This field will be populated from a separate file provided by CALPADS (Expected May 1, 2017).
* Acceptable Values:
* Alphanumeric 4 digits, Blank for noncharter schools
rename chartercode charter_code
replace charter_code = upper(trim(itrim(charter_code)))
label var charter_code "CALPADS Charter Code"

**** CALPADS Charter School Indicator
* Sourced from CALPADS: CharterSchoolIndicator
* This field can be populated during registration, updated during testing, scoring, and reporting, and until the daily CALPADS file is stopped for processing in TOMS.
* Acceptable Values: Alpha (DF, LF) or Blank
* DF = Directly Funded Charter School)
* LF = Locally Funded Charter School 
tab charterschool_ind, missing
generate charter = .
replace charter = 0 if charterschool_ind==""
replace charter = 1 if charterschool_ind=="DF"
replace charter = 2 if charterschool_ind=="LF"

label define charterl ///
0 "Not Charter" ///
1 "Directly Funded Charter" ///
2 "Locally Funded Charter" 
label values charter charterl
label variable charter "Charter School (Type)"

drop charterschool_ind

**** County/District Code of Accountability
* Sourced from CALPADS: EsilDSpecEduAcctbltyDist
* Acceptable Values:
* Numeric (0-9) or Blank
rename cdcodeofaccntbilty iep_residence_cd_code
replace iep_residence_cd_code = upper(trim(itrim(iep_residence_cd_code)))
label var iep_residence_cd_code "County/District Code of Accountability"

**** Section 504 Status
* Sourced from CALPADS: Section504Status
* Acceptable Values:
* Yes, No, or Blank
tab section504, missing
label def section_504 1 "Section 504" 0 "Not Section 504"
gen section_504:section_504 = 1 if section504=="Yes"
replace section_504 = 0 if section504=="No"
replace section_504 = . if mi(section504)
label var section_504 "Section 504 Status"
drop section504

**** Primary Disability Type
* Sourced from CALPADS: PrimaryDisabilityType
* (Codes listed in the Reference Table)
*This is the Primary Disability Type value at the time the student started the first test. If the student did not test, this is the Primary Disability Type value from the demographic snapshot.
* Acceptable Values:
* Alpha or Blank
* AUT	Autism
* DB	Deaf-blindness
* EMN	Emotional disturbance
* HI	Hearing impairment
* ID	Intellectual Disability
* MD	Multiple disabilities
* OI	Orthopedic impairment
* OHI	Other health impairment
* SLD	Specific learning disability
* SLI	Speech or language impairment
* TBI	Traumatic brain injury
* VI	Visual Impairment

tab disability, mi
label def disability_code 000 "Student Does Not Have an IEP"
label def disability_code 210 "Intellectual Disability", add
label def disability_code 220 "Hearing Impairment", add
label def disability_code 240 "Speech or Language Impairment", add
label def disability_code 250 "Visual Impairment", add
label def disability_code 260 "Emotional Disturbance", add
label def disability_code 270 "Orthopedic Impairment", add
label def disability_code 280 "Other Health Impairment", add
label def disability_code 290 "Specific Learning Disability", add
label def disability_code 300 "Deaf-Blindness", add
label def disability_code 310 "Multiple Disabilities", add
label def disability_code 320 "Autism", add
label def disability_code 330 "Traumatic Brain Injury", add
gen disability_code:disability_code = 320 if disability=="AUT"
replace disability_code = 300 if disability=="DB"
replace disability_code = 260 if disability=="EMN"
replace disability_code = 220 if disability=="HI"
replace disability_code = 210 if disability=="ID"
replace disability_code = 310 if disability=="MD"
replace disability_code = 270 if disability=="OI"
replace disability_code = 280 if disability=="OHI"
replace disability_code = 290 if disability=="SLD"
replace disability_code = 240 if disability=="SLI"
replace disability_code = 330 if disability=="TBI"
replace disability_code = 250 if disability=="VI"
replace disability_code = . if mi(disability)
label val disability_code disability_code
label var disability_code "Primary Disability Type"
tab disability_code, missing
drop disability

**** IDEA Indicator
* Sourced from CALPADS: IDEAIndicator
* This is the IDEA Indicator value at the time the student started the first test. If the student did not test, this is the IDEA Indicator value from the demographic snapshot.
* Acceptable Values:
* Yes, No, or Blank
tab idea, mi
label def disabled 1 "Disabled" 0 "Not Disabled"
gen disabled:disabled = 1 if idea=="Yes"
replace disabled = 0 if idea=="No"
replace disabled = . if mi(idea)
label var disabled "Individuals with Disabilities Education Act Indicator"
drop idea

**** Migrant Status
* Sourced from CALPADS: MigrantStatus
* Acceptable Values:
* Yes, No, or Blank
rename migrant x
tab x, mi
label def migrant 1 "Migrant" 0 "Not a Migrant"
gen migrant:migrant = 1 if x=="Yes"
replace migrant = 0 if x=="No"
replace migrant = . if mi(x)
label var migrant "Migrant Status"
drop x

**** LEP Status
* Sourced from CALPADS: LEPStatus
* Acceptable Values:
* Yes, No, or blank
tab lep, mi
rename lep x
label def lep 1 "LEP" 0 "Not LEP"
gen lep:lep = 1 if x=="Yes"
replace lep = 0 if x=="No"
replace lep = . if mi(x)
label var lep "LEP Status"
drop x

**** LEP Entry Date
* Sourced from CALPADS: LimitedEnglishProficiencyEntryDate
* Date the student was assigned as English Learner (EL)
* Acceptable Values:
* Alphanumeric  or Blank   - YYYY-MM-DD
rename lep_entrydate x
gen lep_entry_date = date(x, "YMD")
replace lep_entry_date = . if mi(x)
format lep_entry_date %td
label var lep_entry_date "Date student assigned as EL"
drop x

**** RFEP Date
* Sourced from CALPADS: LEPExitDate
* The student was reclassified as RFEP on this date in CALPDS
* Acceptable Values:
* Alphanumeric  or Blank   - YYYY-MM-DD
gen lep_exit_date = date(rfep_date, "YMD")
replace lep_exit_date = . if mi(rfep_date)
format lep_exit_date %td
label var lep_exit_date "Reclassified Fluent English Proficient Date"
drop rfep_date

**** First Entry Date in US School
* Sourced from CALPADS: FirstEntryDateIntoUSSchool
* Acceptable Values:
* Alphanumeric  or Blank   YYYY-MM-DD
gen first_enrolled_date_us = date(firstus_schooldate, "YMD")
replace first_enrolled_date_us = . if mi(firstus_schooldate)
format first_enrolled_date_us %td
label var first_enrolled_date_us "First Entry Date in US School"
drop firstus_schooldate

**** English Language Acquisition Status
* Sourced from CALPADS: EnglishLanguageAcquisitionStatus
* Acceptable Values:
* EO = English or American Sign Language Only
* IFEP = Initially fluent English proficient 
* EL = English learner
* RFEP = Reclassified fluent English proficient 
* TBD = To be determined
* Blank = No response
tab engprof, mi
label def english_proficiency 1 "English or American Sign Language Only"
label def english_proficiency 2 "Initially Fluent English Proficient", add
label def english_proficiency 3 "English Learner", add
label def english_proficiency 4 "Reclassified Fluent English Proficient", add
label def english_proficiency 5 "To Be Determined", add
gen english_proficiency:english_proficiency = 1 if engprof=="EO"
replace english_proficiency = 2 if engprof=="IFEP"
replace english_proficiency = 3 if engprof=="EL"
replace english_proficiency = 4 if engprof=="RFEP"
replace english_proficiency = 5 if engprof=="TBD"
replace english_proficiency = . if mi(engprof)
label var english_proficiency "English Language Acquisition Status"
tab english_proficiency, missing
drop engprof

**** Language Code
* Sourced from CALPADS: LanguageCode
* (Codes listed in the Reference Table)
* Acceptable Values:
* Alpha or Blank
* ENG	English
* SPA	Spanish
* VIE	Vietnamese
* CHI	Cantonese
* KOR	Korean
* PHI	Filipino (Tagalog)
* POR	Portuguese
* CHI	Mandarin (Putonghua)
* JPN	Japanese
* MKH	Khmer (Cambodian)
* LAO	Lao
* ARA	Arabic
* ARM	Armenian
* BUR	Burmese
* DUT	Dutch
* PER	Farsi (Persian)
* FRE	French
* GER	German
* GRE	Greek
* CHA	Chamorro (Guamanian)
* HEB	Hebrew
* HIN	Hindi
* HMN	Hmong
* HUN	Hungarian
* PHI	Ilocano
* IND	Indonesian
* ITA	Italian
* PAN	Punjabi
* RUS	Russian
* SMO	Samoan
* THA	Thai
* TUR	Turkish
* TON	Tongan
* URD	Urdu
* CEB	Cebuano (Yisayan)
* SGN	Sign Language
* UKR	Ukrainian
* CHI	Chaozhou (Chiuchow)
* PUS	Pashto
* POL	Polish
* SYR	Assyrian
* GUJ	Gujarati
* YAO	Mien (Yao)
* RUM	Rumanian
* CHI	Taiwanese
* SIT	Lahu
* MAH	Marshallese
* OTO	Mixteco
* MAP	Khmu
* KUR	Kurdish (Kurdi, Kurmanji)
* BAT	Serbo-Croatian (Bosnian, Croatian, Serbian
* SIT	Toishanese
* AFA	Chaldean
* ALB	Albanian
* TIR	Tigrinya
* SOM	Somali
* BEN	Bengali
* TEL	Telugu
* TAM	Tamil
* MAR	Marathi
* KAN	Kannada
* AMH	Amharic
* BUL	Bulgarian 
* KIK	Kikuyu (Gikuyu)
* KAS	Kashmiri
* SWE	Swedish 
* ZAP	Zapoteco 
* UZB	Uzbek
* MIS	Other non-English languages
* ZXX	Unknown
rename languagecode f22
tab f22, mi
label def language 11 "Arabic"
label def language 56 "Albanian", add
label def language 66 "Amharic", add
label def language 12 "Armenian", add
label def language 42 "Assyrian", add
label def language 61 "Bengali", add
label def language 67 "Bulgarian", add
label def language 13 "Burmese", add
label def language 03 "Cantonese", add
label def language 36 "Cebuano (Visayan)", add
label def language 54 "Chaldean", add
label def language 20 "Chamorro (Guamanian)", add
label def language 39 "Chaozhou (Chiuchow)", add
label def language 15 "Dutch", add
label def language 00 "English", add
label def language 16 "Farsi (Persian)", add
label def language 05 "Filipino (Pilipino or Tagalog)", add
label def language 17 "French", add
label def language 18 "German", add
label def language 19 "Greek", add
label def language 43 "Gujarati", add
label def language 21 "Hebrew", add
label def language 22 "Hindi", add
label def language 23 "Hmong", add
label def language 24 "Hungarian", add
label def language 25 "Ilocano", add
label def language 26 "Indonesian", add
label def language 27 "Italian", add
label def language 08 "Japanese", add
label def language 65 "Kannada", add
label def language 69 "Kashmiri", add
label def language 09 "Khmer (Cambodian)", add
label def language 50 "Khmu", add
label def language 68 "Kikuyu (Gikuyu)", add
label def language 04 "Korean", add
label def language 51 "Kurdish (Kurdi, Kurmanji)", add
label def language 47 "Lahu", add
label def language 10 "Lao", add
label def language 07 "Mandarin (Putonghua)", add
label def language 64 "Marathi", add
label def language 48 "Marshallese", add
label def language 44 "Mien (Yao)", add
label def language 49 "Mixteco", add
label def language 40 "Pashto", add
label def language 41 "Polish", add
label def language 06 "Portuguese", add
label def language 28 "Punjabi", add
label def language 45 "Rumanian", add
label def language 29 "Russian", add
label def language 30 "Samoan", add
label def language 52 "Serbo-Croatian (Bosnian, Croatian, Serbian)", add
label def language 37 "Sign Language", add
label def language 60 "Somali", add
label def language 01 "Spanish", add
label def language 70 "Swedish", add
label def language 46 "Taiwanese", add
label def language 63 "Tamil", add
label def language 62 "Telugu", add
label def language 32 "Thai", add
label def language 57 "Tigrinya", add
label def language 53 "Toishanese", add
label def language 34 "Tongan", add
label def language 33 "Turkish", add
label def language 38 "Ukrainian", add
label def language 35 "Urdu", add
label def language 72 "Uzbek", add
label def language 02 "Vietnamese", add
label def language 71 "Zapoteco", add
label def language 99 "All other non-English languages", add
gen language:language = 0 if f22=="ENG" // English does not have an assigned code
replace language = 01 if f22=="SPA"
replace language = 02 if f22=="VIE"
replace language = 03 if f22=="CHI" // multiple languages are designated "CHI"
replace language = 04 if f22=="KOR"
replace language = 05 if f22=="PHI"
replace language = 06 if f22=="POR"
replace language = 07 if f22=="CHI" // multiple languages are designated "CHI"
replace language = 08 if f22=="JPN"
replace language = 09 if f22=="MKH"
replace language = 10 if f22=="LAO"
replace language = 11 if f22=="ARA"
replace language = 12 if f22=="ARM"
replace language = 13 if f22=="BUR"
replace language = 15 if f22=="DUT"
replace language = 16 if f22=="PER"
replace language = 17 if f22=="FRE"
replace language = 18 if f22=="GER"
replace language = 19 if f22=="GRE"
replace language = 20 if f22=="CHA"
replace language = 21 if f22=="HEB"
replace language = 22 if f22=="HIN"
replace language = 23 if f22=="HMN"
replace language = 24 if f22=="HUN"
replace language = 25 if f22=="PHI"
replace language = 26 if f22=="IND"
replace language = 27 if f22=="ITA"
replace language = 28 if f22=="PAN"
replace language = 29 if f22=="RUS"
replace language = 30 if f22=="SMO"
replace language = 32 if f22=="THA"
replace language = 33 if f22=="TUR"
replace language = 34 if f22=="TON"
replace language = 35 if f22=="URD"
replace language = 36 if f22=="CEB"
replace language = 37 if f22=="SGN" // Sign Language does not have an assigned code
replace language = 38 if f22=="UKR"
replace language = 39 if f22=="CHI" // multiple languages are designated "CHI"
replace language = 40 if f22=="PUS"
replace language = 41 if f22=="POL"
replace language = 42 if f22=="SYR"
replace language = 43 if f22=="GUJ"
replace language = 44 if f22=="YAO"
replace language = 45 if f22=="RUM"
replace language = 46 if f22=="CHI" // multiple languages are designated "CHI"
replace language = 47 if f22=="SIT"
replace language = 48 if f22=="MAH"
replace language = 49 if f22=="OTO"
replace language = 50 if f22=="MAP"
replace language = 51 if f22=="KUR"
replace language = 52 if f22=="BAT"
replace language = 53 if f22=="SIT"
replace language = 54 if f22=="AFA"
replace language = 56 if f22=="ALB"
replace language = 57 if f22=="TIR"
replace language = 60 if f22=="SOM"
replace language = 61 if f22=="BEN"
replace language = 62 if f22=="TEL" // "Telugu" does not have an assigned code
replace language = 63 if f22=="TAM" // "Tamil" does not have an assigned code
replace language = 64 if f22=="MAR" // "Marathi" does not have an assigned code
replace language = 65 if f22=="KAN" // "Kannada" does not have an assigned code
replace language = 66 if f22=="AMH" // "Amharic" does not have an assigned code
replace language = 67 if f22=="BUL" // "Bulgarian" does not have an assigned code
replace language = 68 if f22=="KIK" // "Kikuyu (Gikuyu)" does not have an assigned code
replace language = 69 if f22=="KAS" // "Kashmiri" does not have an assigned code
replace language = 70 if f22=="SWE" // "Swedish" does not have an assigned code
replace language = 71 if f22=="ZAP" // "Zapoteco" does not have an assigned code
replace language = 72 if f22=="UZB" // "Uzbek" does not have an assigned code
replace language = 99 if f22=="MIS"
replace language = . if f22=="ZXX"
replace language = . if mi(f22)
label val language language
label var language "Language Code"
tab language, missing
drop f22

**** Economic Disadvantage Status
* Sourced from CALPADS: EconomicDisadvantageStatus
* In the V1 and P1 files, any Blank values will be set to No and reported in a separate data file for further investigation.  This rule will not be applicable for P2, any blank data will need be to be resolved prior to P2 generation.
* Acceptable Values:
* Yes or No
tab economic_status, mi
label def econ_disadvantage 1 "Economic Disadvantage" 0 "No Economic Disadvantage"
gen econ_disadvantage:econ_disadvantage = 1 if economic_status=="Yes"
replace econ_disadvantage = 0 if economic_status=="No"
replace econ_disadvantage = . if mi(economic_status)
label var econ_disadvantage "Economic Disadvantage Status"
tab econ_disadvantage, missing
drop economic_status

**** NPS School Flag
* Sourced from: CALPADS
* Acceptable Values:
* Y, N or Blank
tab nps, mi
label def nonpub_nonsect 1 "Nonpublic, Nonsectarian School" ///
	0 "Not a Nonpublic, Nonsectarian School"
gen nonpub_nonsect:nonpub_nonsect = 1 if nps=="Y"
replace nonpub_nonsect = 0 if nps=="N"
replace nonpub_nonsect = . if mi(nps)
label var nonpub_nonsect "Nonpublic, Nonsectarian School Flag
tab nonpub_nonsect, missing
drop nps

**** Hispanic or Latino
* Sourced from CALPADS:HispanicOrLatinoEthnicity
* Acceptable Values:
* Yes, No, or Blank
rename hispanic x
tab x, mi
label def hispanic 1 "Hispanic or Latino" 0 "Not Hispanic or Latino"
gen hispanic:hispanic = 1 if x=="Yes"
replace hispanic = 0 if x=="No"
replace hispanic = . if mi(x)
label var hispanic "Hispanic or Latino"
tab hispanic, missing
drop x

**** American Indian or Alaska Native
* Sourced from CALPADS: AmericanIndianOrAlaskaNative
* Acceptable Values:
* Yes, No, or Blank
rename amerindian_alaskanat x
tab x, mi
label def native_american 1 "American Indian or Alaska Native" ///
	0 "Not American Indian or Alaska Native"
gen native_american:native_american = 1 if x=="Yes"
replace native_american = 0 if x=="No"
replace native_american = . if mi(x)
label var native_american "American Indian or Alaska Native"
tab native_american, missing
drop x

**** Asian
* Sourced from CALPADS: Asian
* Acceptable Values:
* Yes, No, or Blank
rename asian x
tab x, mi
label def asian 1 "Asian" 0 "Not Asian"
gen asian:asian = 1 if x=="Yes"
replace asian = 0 if x=="No"
replace asian = . if mi(x)
label var asian "Asian"
tab asian, missing
drop x

**** Native Hawaiian or Other Pacific Islander
* Sourced from CALPADS: NativeHawaiianOrOtherPacificIslander
* Acceptable Values:
* Yes, No, or Blank
rename hawaiian x
tab x, mi
label def hawaiian_pac_island 1 "Native Hawaiian or Other Pacific Islander" ///
	0 "Not Native Hawaiian or Other Pacific Islander"
gen hawaiian_pac_island:hawaiian_pac_island = 1 if x=="Yes"
replace hawaiian_pac_island = 0 if x=="No"
replace hawaiian_pac_island = . if mi(x)
label var hawaiian_pac_island "Native Hawaiian or Other Pacific Islander"
tab hawaiian_pac_island, missing
drop x

**** Filipino
* Sourced from CALPADS: Filipino
* Acceptable Values:
* Yes, No, or Blank
rename filipino x
tab x, mi
label def filipino 1 "Filipino" 0 "Not Filipino"
gen filipino:filipino = 1 if x=="Yes"
replace filipino = 0 if x=="No"
replace filipino = . if mi(x)
label var filipino "Filipino"
tab filipino, missing
drop x

**** Black or African American
* Sourced from CALPADS: BlackOrAfricanAmerican
* Acceptable Values:
* Yes, No, or Blank
rename black x
tab x, mi
label def black 1 "Black or African American" 0 "Not Black or African American"
gen black:black = 1 if x=="Yes"
replace black = 0 if x=="No"
replace black = . if mi(x)
label var black "Black or African American"
tab black, missing
drop x

**** White
* Sourced from CALPADS: White
* Acceptable Values:
* Yes, No, or Blank
rename white x
tab x, mi
label def white 1 "White" 0 "Not White"
gen white:white = 1 if x=="Yes"
replace white = 0 if x=="No"
replace white = . if mi(x)
tab white, missing
label var white "White"
drop x

**** Two or More Races
* Sourced from CALPADS: DemographicRaceTwoOrMoreRaces
* Acceptable Values:
* Yes, No, or Blank
rename twoormore x
tab x, mi
label def biracial 1 "Two or More Races" 0 "Not Two or More Races"
gen biracial:biracial = 1 if x=="Yes"
replace biracial = 0 if x=="No"
replace biracial = . if mi(x)
label var biracial "Two or More Races"
tab biracial, missing
drop x

**** Reporting Ethnicity
* Sourced from: Derived field based on Yes values in fields 26-33
* Acceptable Values: Numeric           Blank
* 100 = American Indian or Alaska Native
* 200 = Asian
* 300 = Native Hawaiian or Pacific Islander
* 400 = Filipino
* 500 = Hispanic or Latino
* 600 = Black or African American
* 700 = White
* 800 = Two or More Races (refer to reference table for rules)
rename ethnicity x
tab x, mi
label def ethnicity 100 "American Indian or Alaska Native"
label def ethnicity 200 "Asian", add
label def ethnicity 300 "Native Hawaiian or Pacific Islander", add
label def ethnicity 400 "Filipino", add
label def ethnicity 500 "Hispanic or Latino", add
label def ethnicity 600 "Black or African American", add
label def ethnicity 700 "White", add
label def ethnicity 800 "Two or More Races", add // there is no reference table for reporting ethnicity, although the codebook says "refer to reference table for rules"
destring x, gen(ethnicity)
replace ethnicity = . if !inlist(ethnicity, 100, 200, 300, 400, 500, 600, 700, 800)
replace ethnicity = . if mi(x)
label val ethnicity ethnicity
label var ethnicity "Reporting Ethnicity"
tab ethnicity, missing
drop x

**** Parent Education Level
* Sourced from CALPADS: ParentHighestEducationLevel
* Acceptable Values: Numeric (10-15) or Blank
* 10 =  Graduate Degree or Higher   
* 11 = College Graduate
* 12 = Some College or Associate
* 13 = High School Graduate
* 14 = Not a high school graduate
* 15 = Decline to State
rename parented x
tab x, mi
label def parent_education 10 "Graduate Degree or Higher"
label def parent_education 11 "College Graduate", add
label def parent_education 12 "Some College or Associate", add
label def parent_education 13 "High School Graduate", add
label def parent_education 14 "Not a High School Graduate", add
label def parent_education 15 "Decline to State", add
destring x, gen(parent_education)
replace parent_education = . if !inlist(parent_education, 10, 11, 12, 13, 14, 15)
replace parent_education = . if mi(x)
label val parent_education parent_education
label var parent_education "Parent Education Level"
tab parent_education, missing
drop x

**** Smarter Balanced Field Test Participant
* Sourced from: Derived
* SB ELA/Math
* Identifies students that were randomly selected to participate in the Smarter Balanced Performance Task field testing.
* Acceptable Values:
* Y, N or Blank
* Default is set to N for Smarter Balanced tests
* Blank is an acceptable value only for CAA ELA, CAA Math, CAA Science, CAST, STS
rename fieldtestparticipant x
tab x, mi
label def field_test 1 "Smarter Balanced Performance Task Field Test Participant" ///
	0 "Not a Smarter Balanced Performance Task Field Test Participant"
gen field_test:field_test = 1 if x=="Y"
replace field_test = 0 if x=="N"
replace field_test = . if mi(x)
label var field_test "Smarter Balanced Performance Task Field Test Participant"
tab field_test, missing
drop x

**** Test Registration ID
* Sourced from: TOMS
* Acceptable Value:
* 16 digits numeric, leading zeroes
rename registration_id x
rename x test_registration_id
replace test_registration_id = upper(trim(itrim(test_registration_id)))
label var test_registration_id "Test Registration ID"


label def opp_status 1 "Completed"
label def opp_status 2 "Expired", add
label def opp_status 3 "Invalidated", add



forvalues i=1/3 {

if `i'==1 {
local name1 "npt"
local name2 "nonpt"
local lab "Non-Performance Task"
}
else if `i'==2 {
local name1 "pt"
local name2 "pt"
local lab "Performance Task"
}
else if `i'==3 {
local name1 "sci"
local name2 "sci"
local lab "CAA Science"
}

* 1 = Non-PT SB ELA/SB Math, CAA ELA, CAA Math, CAA Science, CAST, STS
* 2 = PT SB ELA/SB Math, and CAA Science
* 3 = CAA Science  

* See data dictionary for more


**** Opportunity ID
* Sourced from: AIR TDS, SB, and AIR DEI
* Unique testing opportunity identifier that allows linkage to a testing session and students responses
* Non-PT SB ELA/SB Math, 
* CAA ELA, CAA Math, and Doc ID for Paper test
* Acceptable Values:
* Numeric or Blank
rename opportunity_id_`i' x
rename x oppid`name1'
replace oppid`name1' = upper(trim(itrim(oppid`name1')))
label var oppid`name1' "Opportunity ID `i'"

**** Opportunity 1 Testing Status
* Sourced from: AIR TDS, SB, and AIR DEI
* Latest testing opportunity status code received from Test Delivery System. A completed test opportunity is submitted by the student. An expired test opportunity is either expired by the system using Smarter Balanced test expiration rules or manually expired after the LEA's selected testing window has closed. A manually expired test opportunity will likely have test completion after  the LEA's selected testing window end date. An invalidated opportunity is a result of an invalidated appeal.
* Acceptable Values:
* Alpha or Blank
* C - Completed
* E - Expired
* I - Invalidated
rename opportunity_`i'_status x
tab x, mi
/*
label def opp_status 1 "Completed"
label def opp_status 2 "Expired", add
label def opp_status 3 "Invalidated", add
*/
gen oppstat`name1':opp_status = 1 if x=="C"
replace oppstat`name1' = 2 if x=="E"
replace oppstat`name1' = 3 if x=="I"
replace oppstat`name1' = . if mi(x)
label var oppstat`name1' "Opportunity `i' Testing Status"
tab oppstat`name1', missing
drop x

**** Tested LEA Name 
* Sourced from CALPADS: District Name
* 1: This field is where the test was started by the student, regardless if moved or not. If the student exited before testing started, field will be blank.
* 2/3: For a paper-pencil test, this field is the same as Tested LEA Name 1 (field 45).
* Acceptable Values:
* Alpha or Blank
rename lea_name_`i'_`name2' x
rename x lea`name1'
replace lea`name1' = upper(trim(itrim(lea`name1')))
label var lea`name1' "`lab' Tested LEA Name"

**** Tested County/District Code
* Sourced from CALPADS: ResponsibleDistrictIdentifier
* 1: This field is where the test was started by the student, regardless if moved or not.  If the student exited before testing started, field will be blank.
* 2/3: For a paper-pencil test, this field is the same as Tested County/District Code 1 (field 46).
* Acceptable Values:
* Numeric 14 digits or Blank
rename cdcode_`i'_`name2' x
rename x cdcode`name1'
replace cdcode`name1' = upper(trim(itrim(cdcode`name1')))
label var cdcode`name1' "`lab' Tested County/District Code"

**** Tested School Name
* Sourced from CALPADS: School Name and SGID for paper-pencil test
* 1: This field is where the test was started by the student, regardless if moved or not.
* 2/3: For a paper-pencil test, this field is the same as Tested School Name 1 (field 47).
* Acceptable Values:
* Alpha or Blank
rename school_name_`i'_`name2' x
rename x schname`name1'
replace schname`name1' = upper(trim(itrim(schname`name1')))
label var schname`name1' "`lab' Tested School Name"

**** Tested School Code
* Sourced from CALPADS: ResponsibleSchoolIdentifier SGID for paper-pencil test
* 1: This field is where the test was started by the student, regardless if moved or not.
* 2/3: For a paper-pencil test, this field is the same as Tested School Code 1 (field 48).
* Acceptable Values:
* Numeric 14 digits or Blank
rename scode_`i'_`name2' x
rename x schcode`name1'
replace schcode`name1' = upper(trim(itrim(schcode`name1')))
label var schcode`name1' "`lab' Tested School Code"

**** Tested Charter School Directly Funded Indicator
* Sourced from CALPADS: Charter Status
* Acceptable Values:
* Alpha (DF) = Directly Funded Charter School) or Blank
rename charter_`i'_`name2' x
tab x, mi
generate chart`name1':charter = 0 if x==""
replace chart`name1' = 1 if x=="DF"
replace chart`name1' = 2 if x=="LF"
label values chart`name1' charterl
label var chart`name1' "`lab' Tested Charter School Directly Funded Indicator"
tab chart`name1', missing
drop x

**** Tested Charter School Code
* Sourced from CALPADS:
* Acceptable Values:
* Alphanumeric 4 digits or Blank
rename charterscode_`i'_`name2' x
rename x chartcode`name1'
replace chartcode`name1' = upper(trim(itrim(chartcode`name1')))
label var chartcode`name1' "`lab' Tested Charter School Code"

**** Tested School NPS Flag
* Sourced from CALPADS: NonPublicCertifiedSchool
* Acceptable Values:
* Y, N or Blank
rename nps_`i'_`name2' x
tab x, missing
generate nps`name1' = .
replace nps`name1' = 0 if x == "N"
replace nps`name1' = 1 if x == "Y"
label var nps`name1' "`lab' Tested School NPS Flag"
tab nps`name1', missing
drop x

**** Test Start Date 1
* Sourced from: AIR TDS
* Date Test Started for Non-PT SB ELA/SB Math, CAA ELA, CAA Math (online test), CAST
* Acceptable Value:
* Alphanumeric,  YYYY-MM-DD or Blank
rename startdate_`i'_`name2' f56
gen teststart`name1' = date(f56, "YMD")
replace teststart`name1' = . if mi(f56)
format teststart`name1' %td
label var teststart`name1' "`lab' Test Start Date"
drop f56

**** Test Completion Date 1
* Sourced from: AIR TDS
* Date Test Completed for Non-PT SB ELA/SB Math, CAA ELA, CAA Math (online test), CAST
* In the case of an expired test, the test completion date will be populated using the expiration date. A manually expired test opportunity will likely have test completion after the LEA's selected testing window end date.
* Acceptable Value:
* Alphanumeric, YYYY-MM-DD or Blank
* Validation - If numeric score data exists, the date and time are required.
rename completiondate_`i'_`name2' f57
gen testend`name1' = date(f57, "YMD")
replace testend`name1'= . if mi(f57)
format testend`name1' %td
label var testend`name1' "`lab' Task Test Completion Date"
drop f57

}

**** Paper and Pencil Test Completion Date (PAPER)
* Sourced from: SGID Sheet (Paper-pencil tests only)
* SB ELA/SB Math (Paper-pencil test), STS
* Acceptable Values:
* Alphanumeric
* Formatted YYYY–MM–DD 
* Blank is not an acceptable value for SB ELA/Math
rename paperpencildate x
gen completion_date_paper = date(x, "YMD") // date format assumed
replace completion_date_paper = . if mi(x)
format completion_date_paper %td
label var completion_date_paper "Paper and Pencil Test Completion Date (PAPER)"
drop x

forvalues i=1/3 {

if `i'==1 {
local name1 "pt"
local name2 "pt1"
local lab "Performance Task 1"
}
else if `i'==2 {
local name1 "pt"
local name2 "pt2"
local lab "Performance Task 2"
}
else if `i'==3 {
local name1 "sci"
local name2 "sci"
local lab "CAA Science"
}

**** School Selected Start of Test Window 1
* Sourced from: TOMS
* Published start date of the school’s selected testing window for the Non-PT or paper-pencil.
* This date is populated based on the student assignment to an administration within the LEA. A blank value will only occur if the LEA window is not set up in TOMS.
* Acceptable Value:
* Alphanumeric, YYYY-MM-DD or Blank
rename startofwindow_`i'_`name1' f60
gen windowstart`name2' = date(f60, "YMD")
replace windowstart`name2' = . if mi(f60)
format windowstart`name2' %td
label var windowstart`name2' "School Selected Start of Test Window"
drop f60

**** School Selected End of Test Window 1
* Sourced from: TOMS
* Published end date of the school’s selected testing window for the Non-PT or paper-pencil.
* This date is populated based on the student assignment to an administration within the LEA. A blank value will only occur if the LEA window is not set up in TOMS.
* Acceptable Value:
* Alphanumeric, YYYY-MM-DD or Blank
rename endofwindow_`i'_`name1' f61
gen windowend`name2' = date(f61, "YMD")
replace windowend`name2' = . if mi(f61)
format windowend`name2' %td
label var windowend`name2' "School Selected End of Test Window"
drop f61

}


**** Student Exit Code
* Sourced from: CALPADS: StuExitCatgKey
* SB ELA/MA, CAA ELA/MA, CAA Science, CAST, STS, populated with exit code received from CALPADS
* Last known exit code received from CALPADS
* Acceptable Value:
* Blank or Alphanumeric
rename stuexitcode f64
/*tab f64, mi*/
label def student_exit_code 125 "Student exited a special education transition program"
label def student_exit_code 130 "Student died while enrolled in school", add
label def student_exit_code 140 "The student, age six up until age 18, is truant as defined by Education Code Section 48260 (a)", add
label def student_exit_code 150 "One or more of the following pieces of information about the student is being updated: grade level, student school transfer code, district of geographic residence, or enrollment status code", add
label def student_exit_code 155 "The student exited a grade level (excluding high school completion) during the last 14 days of the current academic year because of summer break or year-end intersession", add
label def student_exit_code 230 "Student left school after completing his/her academic program at this school, whether or not the completion resulted in high school graduation", add
label def student_exit_code 300 "Student left school after being expelled, was subsequently referred to another educational service institution, but never showed up, and attempts to locate the student were unsuccessful", add
label def student_exit_code 400 "The student is 18 years old or older and has been absent from school for reasons that cannot be determined or for reasons other than those described in the Student Exit Category codes", add
label def student_exit_code 410 "Student withdrew from/left school due to medical reasons", add
label def student_exit_code 450 "Infant or student in pre-kindergarten through grade six, or ungraded elementary, exited/withdrew from school", add
label def student_exit_code 420 "Student completed an academic year at a school and did not return to the same school the following year when the student was expected to return, and no other exit code is appropriate", add
label def student_exit_code 430 "NoShowMatricSchl", add // "N430" not in codebook
label def student_exit_code 470 "The student’s enrollment was exited because the student was pre-enrolled in a school but did not show up as expected to attend the school", add
label def student_exit_code 160 "Transferred to another public school in California", add
label def student_exit_code 165 "The student was withdrawn from one school due to specified disciplinary reasons, and transferred to another California public school (within or outside the district)", add
label def student_exit_code 167 "The student was referred by a school and/or school district to enroll in an alternative education school, or the student voluntarily transferred to an independent study program in another California school", add
label def student_exit_code 180 "Transferred to a private school in California from which the student is expected to receive a regular high school diploma", add
label def student_exit_code 200 "Transferred to another public or private U.S. school outside California", add
label def student_exit_code 240 "Student withdrew from/left school to move to another country", add
label def student_exit_code 260 "Student withdrew from/left school to enroll in an adult education programprogram and there is evidence that the student is in attendance and is working toward the completion of a GED certificate, California High School Exit Exam preparation courses, or high school diploma through an adult education program", add
label def student_exit_code 270 "Student withdrew from/left school to enroll in an adult education program in order to obtain a GED certificate or high school diploma, but subsequently dropped out of the adult education program", add
label def student_exit_code 280 "Student withdrew from/left school and the district has received acceptable documentation that the student is enrolled in college, working toward an Associate’s or Bachelor’s degree or taking California High School Exit Exam preparation courses", add
label def student_exit_code 310 "Student withdrew from/left school and entered a health care facility", add
label def student_exit_code 370 "Student withdrew from/left school and entered an institution that is not primarily academic (military, job corps, justice system, etc.) and the student is in a secondary program leading toward a high school diploma", add
label def student_exit_code 380 "Student withdrew from/left school and entered an institution that is not primarily academic (military, job corps, justice system, etc.) and the student is not in a secondary program leading toward a high school diploma", add
label def student_exit_code 460 "Student withdrew from/left school for a home school setting not affiliated with a private school or independent study program at a public school", add
gen student_exit_code:student_exit_code = 125 if f64=="E125"
replace student_exit_code = 130 if f64=="E130"
replace student_exit_code = 140 if f64=="E140"
replace student_exit_code = 150 if f64=="E150"
replace student_exit_code = 155 if f64=="E155"
replace student_exit_code = 230 if f64=="E230"
replace student_exit_code = 300 if f64=="E300"
replace student_exit_code = 400 if f64=="E400"
replace student_exit_code = 410 if f64=="E410"
replace student_exit_code = 450 if f64=="E450"
replace student_exit_code = 420 if f64=="N420"
replace student_exit_code = 430 if f64=="N430"
replace student_exit_code = 470 if f64=="N470"
replace student_exit_code = 160 if f64=="T160"
replace student_exit_code = 165 if f64=="T165"
replace student_exit_code = 167 if f64=="T167"
replace student_exit_code = 180 if f64=="T180"
replace student_exit_code = 200 if f64=="T200"
replace student_exit_code = 240 if f64=="T240"
replace student_exit_code = 260 if f64=="T260"
replace student_exit_code = 270 if f64=="T270"
replace student_exit_code = 280 if f64=="T280"
replace student_exit_code = 310 if f64=="T310"
replace student_exit_code = 370 if f64=="T370"
replace student_exit_code = 380 if f64=="T380"
replace student_exit_code = 460 if f64=="T460"
replace student_exit_code = . if mi(f64)
label var student_exit_code "Student Exit Code"
drop f64

**** Student Exit Withdrawal date
* Sourced from: CALPADS: WithdrlDate
* Included for all tests
* Student exit withdrawal date that is entered by the LEA into CALPADS
* Acceptable Value:
* Alphanumeric, YYYY-MM-DD or Blank
rename stuexitwithdrawaldate f65
gen student_exit_date = date(f65, "YMD")
replace student_exit_date = . if mi(f65)
format student_exit_date %td
label var student_exit_date "Student Exit Withdrawal Date"
drop f65

*** Student removed from CALPADS file date
* Sourced from: AIR TDS
* Survey question answered by the student to indicate if this is his or her last science class.  Applicable for high school grades 10, 11, and 12.
* Acceptable Value:
* Alphanumeric or Blank
* Formatted YYYY–MM–DD
generate removedfromcp = date(sturemovedfromcalpadsdate, "YMD")
format removedfromcp %td
label var removedfromcp "Student removed from CALPADS file date"
drop sturemovedfromcalpadsdate

*** CAST Last Science Class flag
* Sourced from: AIR TDS
* Survey question answered by the student to indicate if this is his or her last science class. Applicable for high school grades 10, 11, and 12.
* Acceptable Value:
* Alphanumeric, or Blank 
* 1 = Yes
* 2 = No
generate castlastsci = .
replace castlastsci = 0 if cast_lastscienceclass=="2"
replace castlastsci = 1 if cast_lastscienceclass=="1"
label var castlastsci "CAST Last Science Class flag"
drop cast_lastscienceclass

*** CAST Percent of Points Earned
* Sourced from: Scoring
* This is the percent of points earned for the machine-scorable items in Segment A for the CAST field test.
* Represented as XXX
* Acceptable Value:
* Numeric or Blank
destring cast_percentpointsearned, generate(castpercent)
label var castpercent "CAST Percent of Points Earned"
drop cast_percentpointsearned

*** CAST Preliminary Indicator
* Sourced from: TOMS
* A preliminary indicator that describes the students’ performance on the CAST field test as Category 1, Category 2, and Category 3.
* Acceptable Values: 
* Numeric or Blank
* Category 1 = 1
* Category 2 = 2
* Category 3 = 3
destring cast_preliminary_indic, generate(castind)
replace castind = . if !inlist(castind, 1, 2, 3)
label var castind "CAST Preliminary Indicator"
drop cast_preliminary_indic

**** Condition Code
* Sourced from: TOMS
* (See Reference Table)
* "Acceptable Values:
* SB ELA - PGE, NTE, LOSS, C (PPT only), NEL, NT
* SB Math - PGE,  NTE, LOSS, C (PPT only), NT
* CAA ELA – PGE, NTE, SCL, NEL, NT, INC0, INC1
* CAA Math - PGE, NTE, SCL, NT, INC0, INC1
* CAA Science - PGE, NTE, NT
* CAST - PGE, NTE, NT
* STS – PGE, NTE, C, T, INC, NE, NT
* Blank
rename conditioncode f66
/*tab f66, mi*/
label def condition_code 1 "Not Testing by Parent/Guardian Request"
label def condition_code 2 "Not Tested due to Significant Medical Emergency (out for testing window)", add
label def condition_code 3 "Student Observed Cheating", add
label def condition_code 4 "Provided no answers", add
label def condition_code 5 "Incomplete Test", add
label def condition_code 6 "Lowest Obtainable Scale Score", add
label def condition_code 7 "INC1 -Incomplete Test / Lowest Obtainable Scale Score +1", add
label def condition_code 8 "INC0 -Incomplete Test / Lowest Obtainable Scale Score", add
label def condition_code 9 "Student is exempted from Smarter Balanced or CAA ELA test due to student entering the U.S. less than 12 months ago", add
label def condition_code 10 "Student took STS but is non-English Learner (EL)", add
label def condition_code 11 "Student completed test and grade administered does not match the enrolled grade", add
label def condition_code 12 "Not Tested", add
gen condition_code:condition_code = 1 if f66=="PGE"
replace condition_code = 2 if f66=="NTE"
replace condition_code = 3 if f66=="C"
replace condition_code = 4 if f66=="T"
replace condition_code = 5 if f66=="INC"
replace condition_code = 6 if f66=="LOSS"
replace condition_code = 7 if f66=="INC1"
replace condition_code = 8 if f66=="INC0"
replace condition_code = 9 if f66=="NEL"
replace condition_code = 10 if f66=="NE"
replace condition_code = 11 if f66=="SCL"
replace condition_code = 12 if f66=="NT"
label var condition_code "Condition Code"
drop f66

**** Attemptedness
* Sourced from: Scoring (derived value)
* (See Reference Table)
* Not applicable to CAST or CAA Science
* Acceptable Values:
* N  –  non-completion 
* P  –  partial-completion 
* Y  –  completion 
* Blank
rename attemptedness f67
/*tab f67, mi*/
label def test_attemptedness 0 "Non-Completion"
label def test_attemptedness 1 "Partial-Completion", add
label def test_attemptedness 2 "Completion", add
gen test_attemptedness:test_attemptedness = 0 if f67=="N"
replace test_attemptedness = 1 if f67=="P"
replace test_attemptedness = 2 if f67=="Y"
replace test_attemptedness = . if mi(f67)
label var test_attemptedness "Attemptedness"
drop f67

**** Score Status
* Sourced from: TOMS
* This field identifies when a score has been invalidated due to Condition Code C for cheating on paper-pencil tests, Invalidated Appeal, or Unlisted Resource Construct Change (Field 71) is a “Y”.
* Blank is only valid for candidates who did not receive scores
* Acceptable Values:
* I - invalid, V - valid and Blank
rename scorestatus f68
/*tab f68, mi*/
label def score_status 0 "Invalid" 1 "Valid"
gen score_status:score_status = 0 if f68=="I"
replace score_status = 1 if f68=="V"
replace score_status = . if mi(f68)
label var score_status "Score Status"
drop f68

*** Unlisted Resources Construct Change
* Sourced from: TOMS
* SB ELA/SB Math, CAA ELA, CAA Math, CAA Science, CAST
* Y—The approved unlisted resource changes the construct.
* N—The approved unlisted resource does not change the construct.
* Blank—No approved unlisted resource requested or other unapproved unlisted resource request.
* Acceptable Values:
* Y, N, or Blank
generate urcc = .
replace urcc = 0 if unlistedrconstructchnge=="N"
replace urcc = 1 if unlistedrconstructchnge=="Y"
label var urcc "Unlisted Resources Construct Change"
drop unlistedrconstructchnge

**** Test Mode -  Online or Paper
* Sourced from: TOMS
* This field identifies if the student tested online or a paper-pencil test form.
* Acceptable Values:
* O=Online, P=Paper
rename testmodeonlineorpaper f69
/*tab f69, mi*/
label def test_mode 1 "Online" 2 "Paper"
gen test_mode:test_mode = 1 if f69=="O"
replace test_mode = 2 if f69=="P"
replace test_mode = . if mi(f69)
label var test_mode "Test Mode - Online or Paper"
drop f69

**** Include Indicator
* Sourced from: TOMS (a derived value)
* (See Reference Table)
* Acceptable Values: Alpha
* SB ELA - N, E, T, R, Y
* SB Math - N, E, T, R, Y
* CAA ELA - N, E, R, Y
* CAA Math - N, E, R, Y
* CAA Science - N, T
* CAST - N, T
* STS - N, T, R, Y
rename includeindicator f70
/*tab f70, mi*/
label def include_indicator 1 "Student did not test, student who only completed in the content area one section [Non-PT] or [PT] of the assessment, had a parent/guardian exemption or significant medical emergency (out for testing window)"
label def include_indicator 2 "Student was exempt for ELA due to being in the country for less than 12 months", add
label def include_indicator 3 "Student was tested and did not meet either the scoring threshold or the completion / attemptedness is a value of P.  However, a T Include Indicator also includes the LOSS condition code, which could have either a P or Y value in the completion / attemptedness", add
label def include_indicator 4 "Student was tested with an unlisted resource where the test construct was changed, or the test was invalidated, or student observed cheating", add
label def include_indicator 5 "Student was enrolled during active testing window, completed the test, and has met completion / attemptedness", add
gen include_indicator:include_indicator = 1 if f70=="N"
replace include_indicator = 2 if f70=="E"
replace include_indicator = 3 if f70=="T"
replace include_indicator = 4 if f70=="R"
replace include_indicator = 5 if f70=="Y"
replace include_indicator = . if mi(f70)
label var include_indicator "Include Indicator"
drop f70

*** Theta Score
* Sourced from: Scoring
* SB ELA/SB Math
* NS is a record that is "Not Scored"
* Acceptable Values:
* Alphanumeric (format 99.99999) or Blank
* "NS" is valid value. 
destring thetascore, generate(theta) ignore("NS")
replace theta = . if thetascore=="NS"
label var theta "Theta Score"
drop thetascore

**** Raw Score
* Sourced from: Scoring
* Only applies to following: STS
* Acceptable Values:
* Alphanumeric (00-maximum), NS or Blank
rename rawscore f71
/*tab f71, mi*/
destring f71, gen(raw_score) ignore("NS")
replace raw_score = . if f71=="NS"
replace raw_score = . if mi(f71)
label var raw_score "Raw Score"
drop f71

**** Smarter Claim Performance Level
label def sbac_perf_level 1 "Below Standard" 2 "Near Standard" 3 "Above Standard" ///
	9 "No Score (Claim Not Attempted)"

**** Smarter Claim Score 1
* Sourced from: Scoring
* SB ELA/SB Math
* Acceptable Values:
* Numeric or Blank
rename smrtclaim1_score f72
/*tab f72, mi*/
destring f72, gen(sbac_claim1_score)
replace sbac_claim1_score = . if mi(f72)
label var sbac_claim1_score "Smarter Claim Score 1"
drop f72

**** Smarter Claim 1 Performance Level
* Sourced from: TOMS
* SB ELA/SB Math
* Acceptable Values: Numeric (1-3, 9) or Blank (did not take test)
* 1 = Below standard
* 2 = Near Standard
* 3 = Above Standard
* 9 = No score (claim not attempted)
rename smrtclaim1_level f73
/*tab f73, mi*/
destring f73, gen(sbac_claim1_perf_level)
replace sbac_claim1_perf_level = . if !inlist(sbac_claim1_perf_level, 1, 2, 3, 9)
replace sbac_claim1_perf_level = . if mi(f73)
label val sbac_claim1_perf_level sbac_perf_level
label var sbac_claim1_perf_level "Smarter Claim 1 Performance Level"
drop f73

**** Smarter Claim Score 2
* Sourced from: Scoring
* SB ELA/SB Math
* Acceptable Values:
* Numeric or Blank
rename smrtclaim2_score f74
/*tab f74, mi*/
destring f74, gen(sbac_claim2_score)
replace sbac_claim2_score = . if mi(f74)
label var sbac_claim2_score "Smarter Claim Score 2"
drop f74

**** Smarter Claim 2 Performance Level
* Sourced from: TOMS
* SB ELA/SB Math
* Acceptable Values: Numeric (1-3, 9) or Blank (did not take test)
* 1 = Below standard
* 2 = Near Standard
* 3 = Above Standard
* 9 = No score (claim not attempted)
rename smrtclaim2_level f75
/*tab f75, mi*/
destring f75, gen(sbac_claim2_perf_level)
replace sbac_claim2_perf_level = . if !inlist(sbac_claim2_perf_level, 1, 2, 3, 9)
replace sbac_claim2_perf_level = . if mi(f75)
label val sbac_claim2_perf_level sbac_perf_level
label var sbac_claim2_perf_level "Smarter Claim 2 Performance Level"
drop f75

**** Smarter Claim Score 3
* Sourced from: Scoring
* SB ELA/SB Math
* Acceptable Values:
* Numeric or Blank
rename smrtclaim3_score f76
/*tab f76, mi*/
destring f76, gen(sbac_claim3_score)
replace sbac_claim3_score = . if mi(f76)
label var sbac_claim3_score "Smarter Claim Score 3"
drop f76

**** Smarter Claim 3 Performance Level
* Sourced from: TOMS
* SB ELA/SB Math
* Acceptable Values: Numeric (1-3, 9) or Blank (did not take test)
* 1 = Below standard
* 2 = Near Standard
* 3 = Above Standard
* 9 = No score (claim not attempted)
rename smrtclaim3_level f77
/*tab f77, mi*/
destring f77, gen(sbac_claim3_perf_level)
replace sbac_claim3_perf_level = . if !inlist(sbac_claim3_perf_level, 1, 2, 3, 9)
replace sbac_claim3_perf_level = . if mi(f77)
label val sbac_claim3_perf_level sbac_perf_level
label var sbac_claim3_perf_level "Smarter Claim 3 Performance Level"
drop f77

**** Smarter Claim Score 4
* Sourced from: Scoring
* SB ELA
* Acceptable Values:
* Numeric or Blank
rename smrtclaim4_score f78
/*tab f78, mi*/
destring f78, gen(sbac_claim4_score)
replace sbac_claim4_score = . if mi(f78)
label var sbac_claim4_score "Smarter Claim Score 4"
drop f78

**** Smarter Claim 4 Performance Level
* Sourced from: TOMS
* SB ELA
* Acceptable Values: Numeric (1-3, 9) or Blank (did not take test)
* 1 = Below standard
* 2 = Near Standard
* 3 = Above Standard
* 9 = No score (claim not attempted)
rename smrtclaim4_level f79
/*tab f79, mi*/
destring f79, gen(sbac_claim4_perf_level)
replace sbac_claim4_perf_level = . if !inlist(sbac_claim4_perf_level, 1, 2, 3, 9)
replace sbac_claim4_perf_level = . if mi(f79)
label val sbac_claim4_perf_level sbac_perf_level
label var sbac_claim4_perf_level "Smarter Claim 4 Performance Level"
drop f79

**** Scale Score
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math, STS
* Acceptable Values:
* Numeric or Blank
rename sscore f80
/*tab f80, mi*/
destring f80, gen(scale_score)
replace scale_score = . if mi(f80)
label var scale_score "Scale Score"
drop f80

**** Smarter Standard Error Measurement - SEM
* Sourced from: Scoring
* SB ELA/SB Math
* Acceptable Values:
* Numeric or Blank
rename stderrormeasurement f81
destring f81, gen(sbac_std_error)
replace sbac_std_error = . if mi(f81)
label var sbac_std_error "Smarter Standard Error Measurement"
drop f81

**** Smarter Scale Scores Error Bands - Min
* Sourced from: Scoring
* SB ELA/SB Math
* Acceptable Values:
* Numeric or Blank
rename sscoreserrorbands_min f82
destring f82, gen(sbac_error_band_min)
replace sbac_error_band_min = . if mi(f82)
label var sbac_error_band_min "Smarter Scale Scores Error Bands - Min"
drop f82

**** Smarter Scale Scores Error Bands - Max
* Sourced from: Scoring
* SB ELA/SB Math
* Acceptable Values:
* Numeric or Blank
rename sscoreserrorbands_max f83
destring f83, gen(sbac_error_band_max)
replace sbac_error_band_max = . if mi(f83)
label var sbac_error_band_max "Smarter Scale Scores Error Bands - Max"
drop f83

**** Performance Level
* Sourced from: Scoring
* STS
* A blank value is present for SB ELA, SB Math, CAA ELA, and CAA Math
* Numeric (1 - 5, or 9) or Blank
* 5 = Advanced
* 4 = Proficient
* 3 = Basic
* 2 = Below Basic
* 1 = Far Below Basic
* 9 = Did not test
rename perflevel f84
/*tab f84, mi*/
label def perf_level 5 "Advanced" 4 "Proficient" 3 "Basic" 2 "Below Basic" ///
	1 "Far Below Basic" 9 "Did Not Test"
destring f84, gen(perf_level)
replace perf_level = . if !inlist(perf_level, 5, 4, 3, 2, 1, 9)
replace perf_level = . if mi(f84)
label val perf_level perf_level
label var perf_level "Performance Level"
drop f84

**** EAP  - Student Authorized ETS to Release Results to CSU and / or California Community Colleges
* Sourced from: AIR TD
* SB ELA/SB Math
* Acceptable Values:
* 1 - 2 or Blank;
* 1 = Release; 2 = Do not Release
rename eap f86
/*tab f86, mi*/
label def eap_college_release 1 "Authorized ETS to Release Results to CSU and/or California Community Colleges" ///
	2 "Did Not Authorize ETS to Release Results to CSU and/or California Community Colleges"
destring f86, gen(eap_college_release)
replace eap_college_release = . if !inlist(eap_college_release, 1, 2)
replace eap_college_release = . if mi(f86)
label val eap_college_release eap_college_release
label var eap_college_release "EAP - Student Authorized ETS to Release Results to CSU and/or California Community Colleges"
drop f86

**** Accommodations Available Indicator
* Sourced from: Derived
* If Embedded Accommodations or Non-Embedded Accommodations fields are populated then value will be set to Yes for Online or Paper tests. Fields 92-121 and 159-172
* Acceptable Values:
* Yes or No
rename hasaccommodations f87
/*tab f87, mi*/
label def accommodations 1 "Accommodations Available" 0 "No Accommodations Available"
gen accommodations:accommodations = 1 if f87=="YES"
replace accommodations = 0 if f87=="NO"
replace accommodations = . if mi(f87)
label var accommodations "Accommodations Available"
drop f87

**** Year
gen year = 2018
label var year "Year of Spring Semester"
format year %ty

compress
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", replace









*** Put together the SBAC file *****************************************

******** SBAC ELA
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", clear
keep if caaspp_record_type==1
drop caaspp_record_type

**** Achievement Levels
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math
* A blank value is present for STS records.
* Numeric (1 - 4, or 9) or Blank
* For SB ELA/SB Math
* 4 = Standard Exceeded
* 3 = Standard Met
* 2 = Standard Nearly Met
* 1 = Standard Not Met
* 9 = No score
* For CAA ELA/CAA Math
* 3 = Level 3 Alternate
* 2 = Level 2 Alternate
* 1 = Level 1 Alternate
* 9 = No score
* For CSA
* 3 = High Degree
* 2 = Moderate Degree
* 1 = Limited Degree
rename achievementlevel f85
/*tab f85, mi*/
destring f85, gen(achievementlevel)
replace achievementlevel = . if !inlist(achievementlevel, 4, 3, 2, 1, 9)
replace achievementlevel = . if mi(f85)
label def achievementlevel ///
	4 "Standard Exceeded" ///
	3 "Standard Met" ///
	2 "Standard Nearly Met" ///
	1 "Standard Not Met" ///
	9 "No Score"
label val achievementlevel achievementlevel
label var achievementlevel "Achievement Level"
drop f85

rename grade_tested sbac_ela_grade_tested
rename oppidnpt sbac_ela_cat_opp_id
rename oppidpt sbac_ela_pt_opp_id
drop oppidsci
rename test_registration_id sbac_ela_test_registration_id
rename leanpt sbac_ela_cat_district
rename cdcodenpt sbac_ela_cat_cd_code
rename schnamenpt sbac_ela_cat_school
rename schcodenpt sbac_ela_cat_school_code
rename chartcodenpt sbac_ela_cat_charter_code
rename leapt sbac_ela_pt_district
rename cdcodept sbac_ela_pt_cd_code
rename schnamept sbac_ela_pt_school
rename schcodept sbac_ela_pt_school_code
rename chartcodept sbac_ela_pt_charter_code
drop leasci
drop cdcodesci
drop schnamesci
drop schcodesci
drop chartcodesci
drop castpercent
drop castind
rename theta sbac_ela_theta_score
drop raw_score
rename sbac_claim1_score sbac_ela_claim1_score
rename sbac_claim1_perf_level sbac_ela_claim1_perf_level
rename sbac_claim2_score sbac_ela_claim2_score
rename sbac_claim2_perf_level sbac_ela_claim2_perf_level
rename sbac_claim3_score sbac_ela_claim3_score
rename sbac_claim3_perf_level sbac_ela_claim3_perf_level
rename sbac_claim4_score sbac_ela_claim4_score
rename sbac_claim4_perf_level sbac_ela_claim4_perf_level
rename scale_score sbac_ela_scale_score
rename sbac_std_error sbac_ela_std_error
rename sbac_error_band_min sbac_ela_error_band_min
rename sbac_error_band_max sbac_ela_error_band_max
rename achievementlevel sbac_ela_achievement_level
rename eap_college_release sbac_ela_eap_college_release
rename lep limited_eng_prof
rename field_test sbac_ela_field_test
rename oppstatnpt sbac_ela_cat_opp_status
rename chartnpt sbac_ela_cat_charter
rename npsnpt sbac_ela_cat_nonpub_nonsect
rename teststartnpt sbac_ela_cat_test_start_date
rename testendnpt sbac_ela_cat_test_end_date
rename oppstatpt sbac_ela_pt_opp_status
rename chartpt sbac_ela_pt_charter
rename npspt sbac_ela_pt_nonpub_nonsect
rename teststartpt sbac_ela_pt_test_start_date
rename testendpt sbac_ela_pt_test_end_date
drop oppstatsci
drop chartsci
drop npssci
drop teststartsci
drop testendsci
rename completion_date_paper sbac_ela_completion_date_paper
rename windowstartpt1 sbac_ela_cat_test_start_window
rename windowendpt1 sbac_ela_cat_test_end_window
rename windowstartpt2 sbac_ela_pt_test_start_window
rename windowendpt2 sbac_ela_pt_test_end_window
drop windowstartsci
drop windowendsci
drop castlastsci
rename condition_code sbac_ela_condition_code
rename test_attemptedness sbac_ela_test_attemptedness
rename score_status sbac_ela_score_status
rename urcc sbac_ela_urcc
rename test_mode sbac_ela_test_mode
rename include_indicator sbac_ela_include_indicator
rename accommodations sbac_ela_accommodations
drop perf_level

compress
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sbac/sbac_2018_ela.dta", replace


******** SBAC Math
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", clear
keep if caaspp_record_type==2
drop caaspp_record_type

**** Achievement Levels
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math
* A blank value is present for STS records.
* Numeric (1 - 4, or 9) or Blank
* For SB ELA/SB Math
* 4 = Standard Exceeded
* 3 = Standard Met
* 2 = Standard Nearly Met
* 1 = Standard Not Met
* 9 = No score
* For CAA ELA/CAA Math
* 3 = Level 3 Alternate
* 2 = Level 2 Alternate
* 1 = Level 1 Alternate
* 9 = No score
rename achievementlevel f85
/*tab f85, mi*/
destring f85, gen(achievementlevel)
replace achievementlevel = . if !inlist(achievementlevel, 4, 3, 2, 1, 9)
replace achievementlevel = . if mi(f85)
label def achievementlevel ///
	4 "Standard Exceeded" ///
	3 "Standard Met" ///
	2 "Standard Nearly Met" ///
	1 "Standard Not Met" ///
	9 "No Score"
label val achievementlevel achievementlevel
label var achievementlevel "Achievement Level"
drop f85

rename grade_tested sbac_math_grade_tested
rename oppidnpt sbac_math_cat_opp_id
rename oppidpt sbac_math_pt_opp_id
drop oppidsci
rename test_registration_id sbac_math_test_registration_id
rename leanpt sbac_math_cat_district
rename cdcodenpt sbac_math_cat_cd_code
rename schnamenpt sbac_math_cat_school
rename schcodenpt sbac_math_cat_school_code
rename chartcodenpt sbac_math_cat_charter_code
rename leapt sbac_math_pt_district
rename cdcodept sbac_math_pt_cd_code
rename schnamept sbac_math_pt_school
rename schcodept sbac_math_pt_school_code
rename chartcodept sbac_math_pt_charter_code
drop leasci
drop cdcodesci
drop schnamesci
drop schcodesci
drop chartcodesci
drop castpercent
drop castind
rename theta sbac_math_theta_score
drop raw_score
rename sbac_claim1_score sbac_math_claim1_score
rename sbac_claim1_perf_level sbac_math_claim1_perf_level
rename sbac_claim2_score sbac_math_claim2_score
rename sbac_claim2_perf_level sbac_math_claim2_perf_level
rename sbac_claim3_score sbac_math_claim3_score
rename sbac_claim3_perf_level sbac_math_claim3_perf_level
drop sbac_claim4_score
drop sbac_claim4_perf_level
rename scale_score sbac_math_scale_score
rename sbac_std_error sbac_math_std_error
rename sbac_error_band_min sbac_math_error_band_min
rename sbac_error_band_max sbac_math_error_band_max
rename achievementlevel sbac_math_achievement_level
rename eap_college_release sbac_math_eap_college_release
rename lep limited_eng_prof
rename field_test sbac_math_field_test
rename oppstatnpt sbac_math_cat_opp_status
rename chartnpt sbac_math_cat_charter
rename npsnpt sbac_math_cat_nonpub_nonsect
rename teststartnpt sbac_math_cat_test_start_date
rename testendnpt sbac_math_cat_test_end_date
rename oppstatpt sbac_math_pt_opp_status
rename chartpt sbac_math_pt_charter
rename npspt sbac_math_pt_nonpub_nonsect
rename teststartpt sbac_math_pt_test_start_date
rename testendpt sbac_math_pt_test_end_date
drop oppstatsci
drop chartsci
drop npssci
drop teststartsci
drop testendsci
rename completion_date_paper sbac_math_completion_date_paper
rename windowstartpt1 sbac_math_cat_test_start_window
rename windowendpt1 sbac_math_cat_test_end_window
rename windowstartpt2 sbac_math_pt_test_start_window
rename windowendpt2 sbac_math_pt_test_end_window
drop windowstartsci
drop windowendsci
drop castlastsci
rename condition_code sbac_math_condition_code
rename test_attemptedness sbac_math_test_attemptedness
rename score_status sbac_math_score_status
rename urcc sbac_math_urcc
rename test_mode sbac_math_test_mode
rename include_indicator sbac_math_include_indicator
rename accommodations sbac_math_accommodations
drop perf_level

compress
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sbac/sbac_2018_math.dta", replace


******** Merge ELA/Math
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sbac/sbac_2018_ela.dta", clear
merge 1:1 state_student_id using "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sbac/sbac_2018_math.dta", nogen update

order state_student_id cdscode grade year first_name middle_name last_name birth_date
sort state_student_id grade year
compress
label data "Smarter Balanced Assessment Consortium, Academic Year 2017-2018"
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sbac/sbac_2018.dta", replace



*** Put together the CAA file *****************************************

******** CAA ELA
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", clear
keep if caaspp_record_type==3
drop caaspp_record_type

**** Achievement Levels
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math
* A blank value is present for STS records.
* Numeric (1 - 4, or 9) or Blank
* For SB ELA/SB Math
* 4 = Standard Exceeded
* 3 = Standard Met
* 2 = Standard Nearly Met
* 1 = Standard Not Met
* 9 = No score
* For CAA ELA/CAA Math
* 3 = Level 3 Alternate
* 2 = Level 2 Alternate
* 1 = Level 1 Alternate
* 9 = No score
rename achievementlevel f85
/*tab f85, mi*/
destring f85, gen(achievementlevel)
replace achievementlevel = . if !inlist(achievementlevel, 3, 2, 1, 9)
replace achievementlevel = . if mi(f85)
label def achievementlevel ///
	3 "Level 3 Alternate" ///
	2 "Level 2 Alternate" ///
	1 "Level 1 Alternate" ///
	9 "No Score"
label val achievementlevel achievementlevel
label var achievementlevel "Achievement Level"
drop f85

rename grade_tested caa_ela_grade_tested
rename oppidnpt caa_ela_cat_opp_id
rename oppidpt caa_ela_pt_opp_id
drop oppidsci
rename test_registration_id caa_ela_test_registration_id
rename leanpt caa_ela_cat_district
rename cdcodenpt caa_ela_cat_cd_code
rename schnamenpt caa_ela_cat_school
rename schcodenpt caa_ela_cat_school_code
rename chartcodenpt caa_ela_cat_charter_code
rename leapt caa_ela_pt_district
rename cdcodept caa_ela_pt_cd_code
rename schnamept caa_ela_pt_school
rename schcodept caa_ela_pt_school_code
rename chartcodept caa_ela_pt_charter_code
drop leasci
drop cdcodesci
drop schnamesci
drop schcodesci
drop chartcodesci
drop castpercent
drop castind
drop theta
drop raw_score
drop sbac_claim1_score
drop sbac_claim1_perf_level
drop sbac_claim2_score
drop sbac_claim2_perf_level
drop sbac_claim3_score
drop sbac_claim3_perf_level
drop sbac_claim4_score
drop sbac_claim4_perf_level
rename scale_score caa_ela_scale_score
drop sbac_std_error
drop sbac_error_band_min
drop sbac_error_band_max
rename achievementlevel caa_ela_achievement_level
drop eap_college_release
rename lep limited_eng_prof
drop field_test
rename oppstatnpt caa_ela_cat_opp_status
rename chartnpt caa_ela_cat_charter
rename npsnpt caa_ela_cat_nonpub_nonsect
rename teststartnpt caa_ela_cat_test_start_date
rename testendnpt caa_ela_cat_test_end_date
rename oppstatpt caa_ela_pt_opp_status
rename chartpt caa_ela_pt_charter
rename npspt caa_ela_pt_nonpub_nonsect
rename teststartpt caa_ela_pt_test_start_date
rename testendpt caa_ela_pt_test_end_date
drop oppstatsci
drop chartsci
drop npssci
drop teststartsci
drop testendsci
drop completion_date_paper
rename windowstartpt1 caa_ela_cat_test_start_window
rename windowendpt1 caa_ela_cat_test_end_window
rename windowstartpt2 caa_ela_pt_test_start_window
rename windowendpt2 caa_ela_pt_test_end_window
drop windowstartsci
drop windowendsci
drop castlastsci
rename condition_code caa_ela_condition_code
rename test_attemptedness caa_ela_test_attemptedness
rename score_status caa_ela_score_status
rename urcc caa_ela_urcc
rename test_mode caa_ela_test_mode
rename include_indicator caa_ela_include_indicator
rename accommodations caa_ela_accommodations
drop perf_level

compress
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_ela.dta", replace


******** CAA Math
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", clear
keep if caaspp_record_type==4
drop caaspp_record_type

**** Achievement Levels
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math
* A blank value is present for STS records.
* Numeric (1 - 4, or 9) or Blank
* For SB ELA/SB Math
* 4 = Standard Exceeded
* 3 = Standard Met
* 2 = Standard Nearly Met
* 1 = Standard Not Met
* 9 = No score
* For CAA ELA/CAA Math
* 3 = Level 3 Alternate
* 2 = Level 2 Alternate
* 1 = Level 1 Alternate
* 9 = No score
* For CSA
* 3 = High Degree
* 2 = Moderate Degree
* 1 = Limited Degree
rename achievementlevel f85
/*tab f85, mi*/
destring f85, gen(achievementlevel)
replace achievementlevel = . if !inlist(achievementlevel, 4, 3, 2, 1, 9)
replace achievementlevel = . if mi(f85)
label def achievementlevel ///
	3 "Level 3 Alternate" ///
	2 "Level 2 Alternate" ///
	1 "Level 1 Alternate" ///
	9 "No Score"
label val achievementlevel achievementlevel
label var achievementlevel "Achievement Level"
drop f85

rename grade_tested caa_math_grade_tested
rename oppidnpt caa_math_cat_opp_id
rename oppidpt caa_math_pt_opp_id
drop oppidsci
rename test_registration_id caa_math_test_registration_id
rename leanpt caa_math_cat_district
rename cdcodenpt caa_math_cat_cd_code
rename schnamenpt caa_math_cat_school
rename schcodenpt caa_math_cat_school_code
rename chartcodenpt caa_math_cat_charter_code
rename leapt caa_math_pt_district
rename cdcodept caa_math_pt_cd_code
rename schnamept caa_math_pt_school
rename schcodept caa_math_pt_school_code
rename chartcodept caa_math_pt_charter_code
drop leasci
drop cdcodesci
drop schnamesci
drop schcodesci
drop chartcodesci
drop castpercent
drop castind
drop theta
drop raw_score
drop sbac_claim1_score
drop sbac_claim1_perf_level
drop sbac_claim2_score
drop sbac_claim2_perf_level
drop sbac_claim3_score
drop sbac_claim3_perf_level
drop sbac_claim4_score
drop sbac_claim4_perf_level
rename scale_score caa_math_scale_score
drop sbac_std_error
drop sbac_error_band_min
drop sbac_error_band_max
rename achievementlevel caa_math_achievement_level
drop eap_college_release
rename lep limited_eng_prof
drop field_test
rename oppstatnpt caa_math_cat_opp_status
rename chartnpt caa_math_cat_charter
rename npsnpt caa_math_cat_nonpub_nonsect
rename teststartnpt caa_math_cat_test_start_date
rename testendnpt caa_math_cat_test_end_date
rename oppstatpt caa_math_pt_opp_status
rename chartpt caa_math_pt_charter
rename npspt caa_math_pt_nonpub_nonsect
rename teststartpt caa_math_pt_test_start_date
rename testendpt caa_math_pt_test_end_date
drop oppstatsci
drop chartsci
drop npssci
drop teststartsci
drop testendsci
drop completion_date_paper
rename windowstartpt1 caa_math_cat_test_start_window
rename windowendpt1 caa_math_cat_test_end_window
rename windowstartpt2 caa_math_pt_test_start_window
rename windowendpt2 caa_math_pt_test_end_window
drop windowstartsci
drop windowendsci
drop castlastsci
rename condition_code caa_math_condition_code
rename test_attemptedness caa_math_test_attemptedness
rename score_status caa_math_score_status
rename urcc caa_math_urcc
rename test_mode caa_math_test_mode
rename include_indicator caa_math_include_indicator
rename accommodations caa_math_accommodations
drop perf_level

compress
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_math.dta", replace


******** CAA Science
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", clear
keep if caaspp_record_type==5
drop caaspp_record_type

**** Achievement Levels
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math
* A blank value is present for STS records.
* Numeric (1 - 4, or 9) or Blank
* For SB ELA/SB Math
* 4 = Standard Exceeded
* 3 = Standard Met
* 2 = Standard Nearly Met
* 1 = Standard Not Met
* 9 = No score
* For CAA ELA/CAA Math
* 3 = Level 3 Alternate
* 2 = Level 2 Alternate
* 1 = Level 1 Alternate
* 9 = No score
* For CSA
* 3 = High Degree
* 2 = Moderate Degree
* 1 = Limited Degree
rename achievementlevel f85
/*tab f85, mi*/
destring f85, gen(achievementlevel)
replace achievementlevel = . if !inlist(achievementlevel, 4, 3, 2, 1, 9)
replace achievementlevel = . if mi(f85)
label def achievementlevel ///
	3 "Level 3 Alternate" ///
	2 "Level 2 Alternate" ///
	1 "Level 1 Alternate" ///
	9 "No Score"
label val achievementlevel achievementlevel
label var achievementlevel "Achievement Level"
drop f85

rename grade_tested caa_sci_grade_tested
rename oppidnpt caa_sci_cat_opp_id
rename oppidpt caa_sci_pt_opp_id
rename oppidsci caa_sci_opp_id
rename test_registration_id caa_sci_test_registration_id
rename leanpt caa_sci_cat_district
rename cdcodenpt caa_sci_cat_cd_code
rename schnamenpt caa_sci_cat_school
rename schcodenpt caa_sci_cat_school_code
rename chartcodenpt caa_sci_cat_charter_code
rename leapt caa_sci_pt_district
rename cdcodept caa_sci_pt_cd_code
rename schnamept caa_sci_pt_school
rename schcodept caa_sci_pt_school_code
rename chartcodept caa_sci_pt_charter_code
rename leasci caa_sci_district
rename cdcodesci caa_sci_cd_code
rename schnamesci caa_sci_school
rename schcodesci caa_sci_school_code
rename chartcodesci caa_sci_charter_code
drop castpercent
drop castind
drop theta
drop raw_score
drop sbac_claim1_score
drop sbac_claim1_perf_level
drop sbac_claim2_score
drop sbac_claim2_perf_level
drop sbac_claim3_score
drop sbac_claim3_perf_level
drop sbac_claim4_score
drop sbac_claim4_perf_level
drop scale_score
drop sbac_std_error
drop sbac_error_band_min
drop sbac_error_band_max
drop achievementlevel
drop eap_college_release
rename lep limited_eng_prof
drop field_test
rename oppstatnpt caa_sci_cat_opp_status
rename chartnpt caa_sci_cat_charter
rename npsnpt caa_sci_cat_nonpub_nonsect
rename teststartnpt caa_sci_cat_test_start_date
rename testendnpt caa_sci_cat_test_end_date
rename oppstatpt caa_sci_pt_opp_status
rename chartpt caa_sci_pt_charter
rename npspt caa_sci_pt_nonpub_nonsect
rename teststartpt caa_sci_pt_test_start_date
rename testendpt caa_sci_pt_test_end_date
rename oppstatsci caa_sci_opp_status
rename chartsci caa_sci_charter
rename npssci caa_sci_nonpub_nonsect
rename teststartsci caa_sci_test_start_date
rename testendsci caa_sci_test_end_date
drop completion_date_paper
rename windowstartpt1 caa_sci_cat_test_start_window
rename windowendpt1 caa_sci_cat_test_end_window
rename windowstartpt2 caa_sci_pt_test_start_window
rename windowendpt2 caa_sci_pt_test_end_window
rename windowstartsci caa_sci_test_start_window
rename windowendsci caa_sci_test_end_window
drop castlastsci
rename condition_code caa_sci_condition_code
drop test_attemptedness
rename score_status caa_sci_score_status
rename urcc caa_sci_urcc
rename test_mode caa_sci_test_mode
rename include_indicator caa_sci_include_indicator
rename accommodations caa_sci_accommodations
drop perf_level

compress
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_sci.dta", replace


******** Merge ELA/Math/Science
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_ela.dta", clear
merge 1:1 state_student_id using "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_math.dta", nogen update
merge 1:1 state_student_id using "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_sci.dta", nogen update

order state_student_id cdscode grade year first_name middle_name last_name birth_date
sort state_student_id grade year
compress
label data "California Alternate Assessments, Academic Year 2017-2018"
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018.dta", replace



*** Put together the CAST file *****************************************
******** CAST
use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", clear
keep if caaspp_record_type==6
drop caaspp_record_type

**** Achievement Levels
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math
* A blank value is present for STS records.
* Numeric (1 - 4, or 9) or Blank
* For SB ELA/SB Math
* 4 = Standard Exceeded
* 3 = Standard Met
* 2 = Standard Nearly Met
* 1 = Standard Not Met
* 9 = No score
* For CAA ELA/CAA Math
* 3 = Level 3 Alternate
* 2 = Level 2 Alternate
* 1 = Level 1 Alternate
* 9 = No score
* For CSA
* 3 = High Degree
* 2 = Moderate Degree
* 1 = Limited Degree

rename grade_tested cast_grade_tested
rename oppidnpt cast_cat_opp_id
drop oppidpt
drop oppidsci
rename test_registration_id cast_test_registration_id
rename leanpt cast_cat_district
rename cdcodenpt cast_cat_cd_code
rename schnamenpt cast_cat_school
rename schcodenpt cast_cat_school_code
rename chartcodenpt cast_cat_charter_code
drop leapt
drop cdcodept
drop schnamept
drop schcodept
drop chartcodept
drop leasci
drop cdcodesci
drop schnamesci
drop schcodesci
drop chartcodesci
rename castpercent cast_percent_score
rename castind cast_prelim_ind
drop theta
drop raw_score
drop sbac_claim1_score
drop sbac_claim1_perf_level
drop sbac_claim2_score
drop sbac_claim2_perf_level
drop sbac_claim3_score
drop sbac_claim3_perf_level
drop sbac_claim4_score
drop sbac_claim4_perf_level
drop scale_score
drop sbac_std_error
drop sbac_error_band_min
drop sbac_error_band_max
drop achievementlevel
drop eap_college_release
rename lep limited_eng_prof
drop field_test
rename oppstatnpt cast_cat_opp_status
rename chartnpt cast_cat_charter
rename npsnpt cast_cat_nonpub_nonsect
rename teststartnpt cast_cat_test_start_date
rename testendnpt cast_cat_test_end_date
drop oppstatpt
drop chartpt
drop npspt
drop teststartpt
drop testendpt
drop oppstatsci
drop chartsci
drop npssci
drop teststartsci
drop testendsci
drop completion_date_paper
rename windowstartpt1 cast_cat_test_start_window
rename windowendpt1 cast_cat_test_end_window
drop windowstartpt2
drop windowendpt2
drop windowstartsci
drop windowendsci
rename castlastsci cast_last_sci_class
rename condition_code cast_condition_code
drop test_attemptedness
rename score_status cast_score_status
rename urcc cast_urcc
rename test_mode cast_test_mode
rename include_indicator cast_include_indicator
rename accommodations cast_accommodations
drop perf_level

order state_student_id cdscode grade year first_name middle_name last_name birth_date
sort state_student_id grade year
compress
label data "California Science Test, Academic Year 2017-2018"
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/cast/cast_2018.dta", replace




*** Put together the STS file *****************************************
******** STS

use "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta", clear
keep if caaspp_record_type==8
drop caaspp_record_type

**** Achievement Levels
* Sourced from: Scoring
* SB ELA/SB Math
* CAA ELA, CAA Math
* A blank value is present for STS records.
* Numeric (1 - 4, or 9) or Blank
* For SB ELA/SB Math
* 4 = Standard Exceeded
* 3 = Standard Met
* 2 = Standard Nearly Met
* 1 = Standard Not Met
* 9 = No score
* For CAA ELA/CAA Math
* 3 = Level 3 Alternate
* 2 = Level 2 Alternate
* 1 = Level 1 Alternate
* 9 = No score
* For CSA
* 3 = High Degree
* 2 = Moderate Degree
* 1 = Limited Degree


rename grade_tested sts_grade_tested
rename oppidnpt sts_cat_opp_id
drop oppidpt
drop oppidsci
rename test_registration_id sts_test_registration_id
rename leanpt sts_cat_district
rename cdcodenpt sts_cat_cd_code
rename schnamenpt sts_cat_school
rename schcodenpt sts_cat_school_code
rename chartcodenpt sts_cat_charter_code
drop leapt
drop cdcodept
drop schnamept
drop schcodept
drop chartcodept
drop leasci
drop cdcodesci
drop schnamesci
drop schcodesci
drop chartcodesci
drop castpercent
drop castind
drop theta
rename raw_score sts_raw_score
drop sbac_claim1_score
drop sbac_claim1_perf_level
drop sbac_claim2_score
drop sbac_claim2_perf_level
drop sbac_claim3_score
drop sbac_claim3_perf_level
drop sbac_claim4_score
drop sbac_claim4_perf_level
rename scale_score sts_scale_score
drop sbac_std_error
drop sbac_error_band_min
drop sbac_error_band_max
drop achievementlevel
drop eap_college_release
rename lep limited_eng_prof
drop field_test
rename oppstatnpt sts_cat_opp_status
rename chartnpt sts_cat_charter
rename npsnpt sts_cat_nonpub_nonsect
rename teststartnpt sts_cat_test_start_date
rename testendnpt sts_cat_test_end_date
drop oppstatpt
drop chartpt
drop npspt
drop teststartpt
drop testendpt
drop oppstatsci
drop chartsci
drop npssci
drop teststartsci
drop testendsci
drop completion_date_paper
rename windowstartpt1 sts_cat_test_start_window
rename windowendpt1 sts_cat_test_end_window
drop windowstartpt2
drop windowendpt2
drop windowstartsci
drop windowendsci
drop castlastsci
rename condition_code sts_condition_code
rename test_attemptedness sts_test_attemptedness
rename score_status sts_score_status
drop urcc
rename test_mode sts_test_mode
rename include_indicator sts_include_indicator
rename accommodations sts_accommodations
rename perf_level sts_perf_level

order state_student_id cdscode grade year first_name middle_name last_name birth_date
sort state_student_id grade year
compress
label data "Standards-Based Tests in Spanish, Academic Year 2017-2018"
save "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sts/sts_2018.dta", replace






erase "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caaspp_2018.dta"
erase "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sbac/sbac_2018_ela.dta"
erase "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/sbac/sbac_2018_math.dta"
erase "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_ela.dta"
erase "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_math.dta"
erase "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/caaspp/caa/caa_2018_sci.dta"

log close
