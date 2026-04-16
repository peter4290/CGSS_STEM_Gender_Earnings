clear all
set more off

* CGSS2021 data processing code based on questionnaire options
use "C:\Users\jd4290\Desktop\cgss2021\CGSS2021.dta", clear


gen year =2021
label variable year "Survey Year"

gen age = 2021 - A3_1 if A3_1 != . & A3_1 != 9998 & A3_1 != 9999
label variable age "Age"

gen female = (A2 == 2) if A2 != .
label variable female "Female (1=Yes)"

gen elite_univ = (A7e == 1) if A7e != . & !inlist(A7e, 98, 99)
label variable elite_univ "Elite University Attended"

gen stem_edu = inlist(A7f, 1,2,3,4,7, 8, 9, 10) if A7f != . & !inlist(A7f, 14, 98, 99)
label variable stem_edu "STEM Major"

gen stem_occ= inlist(A57b, 3, 8, 9, 10) if A57b !=  . & !inlist(A57b, 3, 8, 9, 10)
label variable stem_edu "STEM Occupation"
*no ISCO codes for occupation found in the current dataset, for usual use ISCO codes

gen employed = (A53 == 4) if A53 != . & !inlist(A53, 98, 99)
label variable employed "Employed"

gen urban_hukou = inlist(A18, 2, 4) if A18 != . & !inlist(A18, 98, 99)
label variable urban_hukou "Urban Hukou"

*  Father's years of education
gen father_edu_year = .
replace father_edu_year = 0 if A89b == 1
replace father_edu_year = 3 if A89b == 2
replace father_edu_year = 6 if A89b == 3
replace father_edu_year = 9 if A89b == 4
replace father_edu_year = 12 if inlist(A89b, 5, 6, 7, 8)
replace father_edu_year = 15 if inlist(A89b, 9, 10)
replace father_edu_year = 16 if inlist(A89b, 11, 12)
replace father_edu_year = 19 if A89b == 13
replace father_edu_year = . if inlist(A89b, 14, 98, 99)
label variable father_edu_year " Father's years of education"

* Mother's years of education
gen mother_edu_year = .
replace mother_edu_year = 0 if A90b == 1
replace mother_edu_year = 3 if A90b == 2
replace mother_edu_year = 6 if A90b == 3
replace mother_edu_year = 9 if A90b == 4
replace mother_edu_year = 12 if inlist(A90b, 5, 6, 7, 8)
replace mother_edu_year = 15 if inlist(A90b, 9, 10)
replace mother_edu_year = 16 if inlist(A90b, 11, 12)
replace mother_edu_year = 19 if A90b == 13
replace mother_edu_year = . if inlist(A90b, 14, 98, 99)
label variable mother_edu_year "Mother's years of education"

gen state_owned = inlist(A59k, 1, 2) if A59k != . & !inlist(A59k, 98, 99)
label variable state_owned "State-Owned Employer"

gen actual_work_years = A59c if A59c != . & !inlist(A59c, 98, 99)
label variable actual_work_years "Actual Years of Work Experience"

gen work_hours = A53 if A53 >= 1 & A53 <= 200
replace work_hours = A53aa if A53aa != . & A53aa < 998 & work_hours == .
label variable work_hours "Weekly Working Hours"

gen ln_income = ln(A8a) if A8a > 0 & A8a < 9999996
label variable ln_income "Log of Total Personal Income"

capture confirm  varible weight

* Missing Value Imputation
summ age female ln_income work_hours actual_work_years, detail
replace age = r(p50) if age == .
replace stem_edu = 0 if stem_edu == .
replace stem_occ = 0 if stem_occ == .

*replace work_hours = r(p50) if work_hours == . & employed == 1
replace actual_work_years = r(p50) if actual_work_years == .
*replace father_edu_year = r(p50) if father_edu_year == .
replace female = round(r(mean)) if female == .
replace urban_hukou = round(r(mean)) if urban_hukou == .
replace employed = round(r(mean)) if employed == .
*replace state_owned = round(r(mean)) if state_owned == . & employed == 1

* Unemployed
replace work_hours = 0 if work_hours == . & employed == 0
replace actual_work_years = 0 if actual_work_years == . & employed == 0

tab stem_edu, missing
tab stem_occ, missing
tab elite_univ, missing
tab urban_hukou, missing
tab state_owned, missing

keep if inrange(age, 22, 55)
keep if A7e < . & !inlist(A7e, 98, 99)

keep year id weight age female stem_edu stem_occ elite_univ ln_income father_edu_year urban_hukou work_hours state_owned actual_work_years

order year id weight age female stem_edu stem_occ elite_univ ln_income father_edu_year urban_hukou work_hours state_owned actual_work_years

sort id

export excel using"C:\Users\jd4290\Desktop\cgss2021\cgss2021_clean.xlsx", firstrow(variables) replace



compress