******************* Set directory **************************
************************************************************
global main_loc "/Users/gesun/Desktop/Bootcamp2023/02_Intro_to_Stata/Class_Exercise"
global data "$main_loc/data"
global logfile "$main_loc/log_files"



******************** 0202 quick start ************************ 
**************************************************************
sysuse auto.dta,clear 

des 
codebook 

gen new_var = 1 
// gen new_var = 2 

gen wtsq = weight * weight 
gen preference = -0.8 * price - 1.3 * rep78 
sort preference 

tab rep78 foreign
hist price
gen rep78_mi = missing(rep78)

use "$data/baseline_census_cleaned.dta", clear 



******************** 0203 more tricks ************************ 
**************************************************************
use "$data/lfs_examples_class08", clear 

tab Sector_Sep2003, gen(work_type) 
des work_type*

recode race(4=2), gen(race_new)

label define race_newl 1 "black" 2 "white"
label values race_new race_newl

bys age: sum earnings_week
bysort Indus_Sep2003: egen industry_mean = mean(earnings_week)
bys Prov_Sep2003: egen sum_employers = sum(Q44NrEmp_Sep2003)



******************** 0204 do files *************************** 
**************************************************************

capture log close
log using "$logfile/the_first_coding.log", replace

use "$data/baseline_census_cleaned.dta", clear 

lookfor district
keep Ctot_p Cp_lit Cp_ill treatment tru district districtname subdistt districtname district 

// Why set more off
rename * C_* // this is a crazy silly try 
sum C_*,detail

capture log close





**************** 0205 Basic Programming ********************** 
**************************************************************

***************** Conditional Expression *********************

use "$data/lfs_examples_class08", clear 
keep UqNr age earnings_week black female hours Indus_Sep2003
keep if _n < 21
count if age < 30 | age > 45
list UqNr if hours >=65 & black ==1


****************** r-class & e-class command *****************

cd "/Users/gesun/Desktop/Bootcamp2023/02_Intro_to_Stata/Class_Exercise/data"
use lfs_examples_class08, clear

sum earnings_week if female==1 & hours >= 40
return list 
display r(mean)
scalar mean_earnings = r(mean)
scalar range_earnings = r(max)-r(min)

use lfs_examples_class08, clear
rename Q16aHiEd_Sep2003 edu
rename Indus_Sep2003 ind
keep UqNr age earnings_week black female hours edyears ind

gen wage_hr =  earnings_week/hours
gen age_sq = age*age

gen ln_wage_hr = log(wage_hr)

reg ln_wage_hr age age_sq female black edyears
ereturn list 
matrix define B = e(b)
matrix define V = e(V)
display V[3,3]
scalar var_3 = V[3,3]



************************ macros *************************************

local a = 1 
dis `a'


clear all
global b 3
local c 4
scalar d = 5 
display $b _skip(3) `c' _skip(3) d 
clear 
display $b 
display `c' 
display d
clear all  
display $b  
display d



************************ Loops *************************************

* Make artificial dataset of 100 observations on 4 uniform variables
clear 
set obs 100
set seed 10101 // so that the subsequent program lead to the same random numbers being drawn 
gen x1var = runiform() //runiform(lowerbound, upperbound)
gen x2var = runiform()
gen x3var = runiform()
gen x4var = runiform()
gen sum = x1var + x2var + x3var + x4var
sum sum

* The foreach loop 
gen sum2 = 0 
foreach var of varlist x1var x2var x3var x4var{
    quietly replace sum2 = sum2 + `var'
}
sum sum2
display sum == sum2

gen sum3 =0
local vars x1var x2var x3var x4var
foreach var of varlist `vars'{
    quietly replace sum3 = sum3 + `var'
}
display sum == sum3

gen sum4 = 0
foreach num of numlist 1 2 3 4{
    replace sum4 = sum4 + `num'
}
display sum4 // notice that "gen" will create an variable that with dimension of "obs" set before

*if we just want to sum over some scalars
scalar sum5 = 0 
foreach num of numlist 1 2 3 4{
    scalar sum5 = sum5 + `num' //
}
display sum5 

* Forvalues loop 
gen sum6 = 0
forvalues i = 1/4{
    quietly replace sum6 = sum6 + x`i'var 
}
sum sum6

* While loop 
gen sum7 = 0 
local i 1 
while `i' <= 4 {
    quietly replace sum7 = sum7 + x`i'var
    local i = `i' + 1
}
sum sum7





********************* 0300 Graphs *************************** 
*************************************************************

********************* Graphs Examples ***********************

use "$data/lfs_examples_class08", clear 
keep UqNr age earnings_week black female hours Indus_Sep2003

// Histogram
gen wage_hr =  earnings_week/hours
gen ln_wage_hr = log(wage_hr)
hist ln_wage_hr

// Box graph
graph box ln_wage_hr, over(black, relabel(1 "white" 2 "black"))
graph export "$logfile/box.pdf", as(pdf) name("Graph") replace

// Area graph
clear 
webuse gnp96 //webuse filename loads the specified dataset, obtaining it over the web. By default, datasets are obtained from https://www.stata-press.com/data/r17/.
twoway area d.gnp96 date
graph export "$logfile/area.pdf", as(pdf) name("Graph") replace




********************* Graphs Syntax ***********************

use "$data/GSS2018.dta",clear 
// a little preparation for the data
destring weight, replace
destring height, replace
destring age,replace 

// The scatter plot 
twoway scatter weight height 
// How about we want to rename the axis 
label var weight weight
label var height height
twoway scatter weight height

// Advanced Stata Commands
twoway scatter weight height if region == 1
twoway scatter weight height in 5/1005

// The distribution of the points suggests a positive relationship between height and weight (i.e. tall people tend to weigh more). So we could add a regression line: 
scatter weight height || lfit weight height
twoway (scatter weight height) (lfit weight height)



********************* More Options ***********************
// legend options
scatter weight height if sex==1 || scatter weight height if sex==2
//Unfortunately, the default legend at the bottom is completely useless, so you'll need to specify what it should say.
codebook sex
scatter weight height if sex==1 || scatter weight height if sex==2, legend(order(1 "Males" 2 "Females"))
scatter weight height if sex==1 || scatter weight height if sex==2, legend(off)
//Another way to achieve the same sub-sample scatter plot
separate weight, by(sex)
scatter weight1 weight2 height

// axis options 
scatter weight height if sex==1 || scatter weight height if sex==2, legend(order(1 "Males" 2 "Females")) ylabel(80(80)480) ymtick(80(50)480) ytitle("Weight(pounds)") xlabel(45(10)80) xmtick(45(5)80) xtitle("Height(inch)")

// showmarkers
showmarkers , over(msymbol) 
showmarkers , over(msize) 

// Bar graphs
graph bar edu, over(class)
graph hbar edu, over(class)

graph bar (count), over(class)
graph hbar (count), over(class) blabel(bar)




******************* 0400 Regressions ************************ 
*************************************************************

********************* Understand OLS ************************

use "$data/regression_example.dta",clear
local i 1 
while `i' < 10{
    local i = `i' +1 
    dis `i'
    append using "$data/regression_example.dta"
}
des 
return list
scalar a = r(N)
set obs 120 
set seed 98034
generate u1 = 100*runiform(-1,1)
generate u2 = 100*runiform(-10, 10)

gen wage1 = wage + u1 
gen wage2 = wage + u2

scatter wage1 edu 
scatter wage2 edu

twoway (scatter wage1 edu, msize(medlarge) msymbol(circle)) (lfit wage1 edu), ytitle(wage) xtitle(education) scheme(s2mono)

graph export "$logfile/small_variance.pdf", as(pdf) name("Graph") replace

twoway (scatter wage2 edu, msize(med) msymbol(circle)) (lfit wage1 edu), ytitle(wage) xtitle(education) scheme(s2mono)
graph export "$logfile/large_variance.pdf", as(pdf) name("Graph") replace



**************** export regression tables ********************

use "$data/lfs_examples_class08.dta",clear
rename Indus_Sep2003 ind
keep UqNr age earnings_week black female hours edyears ind

gen wage_hr =  earnings_week/hours
gen ln_wage_hr = log(wage_hr)
gen age_sq = age*age

label var age_sq "age squared"
label var edyears "educational years"

reg ln_wage_hr age age_sq edyears
cd "$logfile"
outreg2 using simiple_reg_results, word 
// outreg2 using simiple_reg_results, tex replace


reg ln_wage_hr age age_sq edyears female black
outreg2 using simiple_reg_results, word replace

reg ln_wage_hr age age_sq edyears
outreg2 using simiple_reg_results, word replace
reg ln_wage_hr age age_sq edyears female black 
outreg2 using simiple_reg_results, word append

reg ln_wage_hr age age_sq edyears
outreg2 using simiple_reg_results, word ctitle(Model1) replace
reg ln_wage_hr age age_sq edyears female black 
outreg2 using simiple_reg_results, word ctitle(Model2) append

reg ln_wage_hr age age_sq edyears
outreg2 using simiple_reg_results, word ctitle(Model1,ln_wage_hr) replace
reg ln_wage_hr age age_sq edyears female black 
outreg2 using simiple_reg_results, word ctitle(Model2,ln_wage_hr) append

reg ln_wage_hr age age_sq edyears
outreg2 using simiple_reg_results, word ctitle(Model1,ln_wage_hr) ///
 label replace
reg ln_wage_hr age age_sq edyears female black 
outreg2 using simiple_reg_results, word ctitle(Model2,ln_wage_hr) label append

reg ln_wage_hr age age_sq edyears
est store Model1
reg ln_wage_hr age age_sq edyears female black 
est store Model2
outreg2 [Model1 Model2] using simiple_reg_results, word ctitle(Model1, ln_wage_hr; Model2, ln_wage_hr) label dec(3) addnote(Notes: You can add notes here!) title(Regression Table)

esttab Model1 Model2
esttab Model1 Model2, b(2) se(2) r2
esttab Model1 Model2, b(2) se(2) r2





************** 0500 Relational Database ********************* 
*************************************************************

********************* collapse ******************************

use https://stats.idre.ucla.edu/stat/stata/modules/kids, clear 
collapse age, by(famid) 
collapse (mean) avgage=age, by(famid) 
collapse (mean) avgage=age avgwt=wt, by(famid) 
collapse (mean) avgage=age avgwt=wt (count) numkids=birth, by(famid) 

tabulate sex, generate(sexdum) 
collapse (count) numkids=birth (sum) girls=sexdum1 boys=sexdum2, by(famid) 


****************** preserve & restore ************************

use https://stats.idre.ucla.edu/stat/stata/modules/kids, clear 
preserve 
collapse (mean) avgage=age avgwt=wt (count) numkids=birth, by(famid)
list 
restore 




graph export "$logfile/toy_example.pdf",  as(pdf) name("Graph")





use https://stats.idre.ucla.edu/stat/stata/modules/kids, clear 
tabulate sex, generate(sexdum) 
collapse (count) numkids=birth (sum) girls=sexdum1 boys=sexdum2, by(famid) 



******************* merge & append  ***************************
cd "$data/merge_example"
use merge_1.dta,clear

use merge_base.dta,clear
merge 1:1 kidname using merge_2.dta

use merge_base.dta,clear
merge 1:1 kidname using merge_2.dta 

use merge_base.dta,clear 
merge 1:1 kidname using merge_3.dta

use merge_base.dta,clear
merge 1:1 kidname using merge_4.dta

use kids_number.dta,clear
merge 1:m famid using original_data.dta 

use merge_base.dta,clear 
append using merge_1.dta

gen 




****************** 0800 String Commands ********************* 
*************************************************************

clear
set obs 6
******************* split and substr ************************
input str15 date
"1940/12/10"
"1958/10/14"
"1939/09/03"
"1973/05/29"
"1965/07/08"
"1983/03/02"
// end 

input str15 tel
"1-512-471-3434"
"1-212-854-1754"
"1-650-723-2300"
"1-615-322-7311"
"1-412-268-2000"
"1-512-471-3434"
// end 

input str15 tv 
"2 3 5"
""
"3 6"
"2"
"1 3 4 6"
"1"
// end 

// How can you get these six people's last name?
input str50 names
"Rachel Karen Green"
"Monica Geller-Bing"
"Phoebe Buffay-Hannigan"
"Chandler M. Bing"
"Joey Tribbiani"
"Ross Geller"
// end

split date, parse(/)
split tel, parse(-)
split tv, gen(tv_program)



****************** Regular expression *******************

use "$data/string_exercise.dta",clear

* Example for logical "or" |
list Name if regexm(Name,"^[A-E]+")
list Name if regexm(Name,"^[M-Z]+")
list Name if regexm(Name,"^[A-E|M-Z]+")

* Exercise from class slices
list tel if regexm(tel, "^[0-9][0-9][0-9]-")

replace tel = strltrim(tel)
replace tel = strrtrim(tel)

replace tel =subinstr(tel," ","",.)
replace tel = ustrltrim(tel)
replace tel = ustrrtrim(tel)
list if regexm(tel,"^[0-9]+\.")

gen str tel_new = regexs(1) + "-" + regexs(2) if regexm(tel, "^\(([0-9]+)\)(.*)")
replace tel_new = regexs(1) + "-" + regexs(2) + "-" + regexs(3) if regexm(tel,"^([0-9]+)\.([0-9]+)\.([0-9]+)")
replace tel_new = tel if regexm(tel, "^[0-9][0-9][0-9]\-+")
replace tel_new = regexs(1) + "-" + regexs(2) if regexm(tel_new,"^([0-9]+)\-\-(.*)")





******************* 0900 Other things *********************** 
*************************************************************

******************** Regression Tables **********************
** Data **
use "$data/ExampleRegressionDataCDPR.dta", clear

** Regression Table **
// Create a local to hold the variables which are used in each regression. The i. means that each outcome of the variable is considered as a separate dummy variable in the regression. One of the dummy variables will be excluded. 
local alwaysvars logusd i.zona i.month female_manager agemanager
// Quietly run regressions (remove "quietly" to view the regression outputs in the command window/log file).
quietly reg `alwaysvars', robust
eststo reg1
quietly reg `alwaysvars' agemanagersq, robust
eststo reg2
quietly reg `alwaysvars' agemanagersq highschool, robust
eststo reg3
quietly reg `alwaysvars' agemanagersq highschool capacitado, robust
eststo reg4
quietly reg `alwaysvars' agemanagersq highschool capacitado n_empleados female_owner foodexp ownerismanager motivation_*_1 numberdependants married rented twojobs additionalproducts, robust
eststo reg5
quietly reg `alwaysvars' agemanagersq highschool capacitado n_empleados female_owner foodexp ownerismanager motivation_*_1 numberdependants married rented twojobs additionalproducts n_casas cmi smartphone_owner formalloan, robust
eststo reg6

* Statistics (note that these numbers can be found by looking at the data but this method makes it possible to provide the appropriate numbers with different datasets without having to manually check for each new dataset).
// Mark the first observation of each ID code
by codigo, sort: gen numfranchises = (_n == 1)
// Assign a consecutive number to each unique ID 
replace numfranchises = sum(numfranchises)
// Assign the max number to all IDs, this holds the information on how many distinctive IDs there are
replace numfranchises = numfranchises[_N]
// Find the number of years of data in the dataset
sum year, meanonly
gen numyears = (r(max)-r(min)) 
replace numyears = numyears + 1
// Find the total number of months in the dataset
egen nummonths = max(month)

* Assign notation to regression columns by creating locals. This show Y for a column including a particular scalar of variables, or N for not including those controls. 
estadd local monthd "Y" : reg1 reg2 reg3 reg4 reg5 reg6
estadd local zoned "Y" : reg1 reg2 reg3 reg4 reg5 reg6
estadd local controls1 "N" : reg1 reg2 reg3 reg4 
estadd local controls1 "Y" : reg5 reg6
estadd local controls2 "N" : reg1 reg2 reg3 reg4 reg5
estadd local controls2 "Y" : reg6
estadd local obsyear = numyears : reg1 reg2 reg3 reg4 reg5 reg6
estadd local obsmonth = nummonths : reg1 reg2 reg3 reg4 reg5 reg6
estadd local franchises = numfranchises : reg1 reg2 reg3 reg4 reg5 reg6

// sum logusd 
// scalar a = round(r(mean),0.01)
// estadd local mean = round(r(mean),0.01): reg1 reg2 reg3 reg4 reg5 reg6

* Create table
// Output in Stata:
esttab reg1 reg2 reg3 reg4 reg5 reg6, keep(female_manager agemanager agemanagersq highschool capacitado) scalars("monthd Month Dummies" "zoned Zone Dummies" "controls1 Controls" "controls2 Additional Controls" "franchises Franchises" "obsyear Years" "obsmonth Months") b(3) r2 se(3) nomtitle label obslast note("Control variables are number of employees, female owner dummy, previous experience with food dummy, owner as the manager dummy, motiviation for opening the franchise, number of dependents, marriage dummy, renting building dummy, having an additional job dummy, and additional products sold.  Additional controls are number of franchises, previous CMI training dummy, owns a smartphone dummy, and a dummy for having a formal loan. ")

// Same output to a Latex file: 
esttab  reg1 reg2 reg3 reg4 reg5 reg6 using "$logfile/SalesRegressions.tex", replace keep(female_manager agemanager agemanagersq highschool capacitado) scalars("monthd Month Dummies" "zoned Zone Dummies" "controls1 Controls" "controls2 Additional Controls" "franchises Franchises" "obsyear Years" "obsmonth Months") b(3) r2 se(3) nomtitle label obslast alignment(D{.}{.}{-3}) 


********************** Summary Statistics *************************

** Data **
use "$data/ExampleRegressionDataCDPR.dta", clear

* SUmmary statistics table
// Create the table and save it
estpost sum usd lnusd month zona edad agesq sex_encargado sex_dueno capacitado smartphone_owner n_empleados  n_casas active openyear class additionalproducts

// Output the table into the stata command window (this step is not necessary but it is useful to see the table before exporting to Latex)
esttab ., cells((mean(label(Mean) fmt(%9.4f)) sd(label(St. Dev.)) min(label(Min.) fmt(%9.0f)) max(label(Max.) fmt(%9.0f)) count(label(Obs.) fmt(%9.0f)))) nonumber nomtitle noobs label note("Year Month is a continuous variable. Each month is assigned a consequitive number from 1-47 starting in 2017 and ending in 2020.")

// Export as a Latex file
esttab . using "$logfile/MonthlySumStats.tex", replace cells((mean(label(Mean) fmt(%9.4f)) sd(label(St. Dev.)) min(label(Min.) fmt(%9.0f)) max(label(Max.) fmt(%9.0f)) count(label(Obs.) fmt(%9.0f)))) nonumber nomtitle noobs label alignment(D{.}{.}{.}{-3}) nonotes