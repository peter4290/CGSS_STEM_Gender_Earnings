clear all
set more off
* import data

import excel "/Users/peter/Desktop/cgss2021_clean.xlsx", sheet("Sheet1") firstrow


* keep only STEM samples
keep if stem_edu == 1 | stem_occ == 1

* clean missing values
drop if missing(ln_income, female, age, actual_work_years, elite_univ, urban_hukou, father_edu_year, state_owned, work_hours)

* descriptive statistics
summarize ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours

* correlation analysis
correlate ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours

* multiple linear regression
reg ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours, robust

* output regression results
estimates store model1
esttab model1 using "regression_results.csv", replace se star(* 0.1 ** 0.05 *** 0.01)

* multicollinearity test
estat vif


* Heteroskedasticity test (White test)
estat imtest, white

* Heteroskedasticity-robust standard errors
reg ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours, vce(robust)

* classical assumption tests for the linear regression model

* 1. normality test (whether residuals are normally distributed)
predict e, resid
swilk e

* 2. overall model significance test (reported separately here)
testparm i.female i.age actual_work_years

* 3. ioint significance test of independent variables
test female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours

* advanced descriptive statistics (grouped statistics: by gender)
bysort female: summarize ln_income age actual_work_years work_hours

* export descriptive statistics
logout, save(export_descriptive_statistics) replace excel: summarize ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours

* residual normality test
reg ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours, robust
drop e
predict e, residuals
swilk e           // Shapiro-Wilk test
sktest e          // Jarque-Bera skewness/kurtosis test
qnorm e           // Q-Q plot
histogram e, normal // Histogram of residuals with normal density overlay

* Residual independence（No autocorrelation）
reg ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours, vce(cluster province)
* Linearity test (no nonlinearity / linearity assumption)
reg ln_income female age actual_work_years elite_univ urban_hukou father_edu_year state_owned work_hours
estat ovtest    // Ramsey RESET test

rvfplot, yline(0)    // Residuals vs fitted values plot

* Export final regression results
estimates store final_model
esttab final_model using "final_regression_results.csv", replace se star(* 0.1 ** 0.05 *** 0.01) ar2 scalar(F probf rss)

