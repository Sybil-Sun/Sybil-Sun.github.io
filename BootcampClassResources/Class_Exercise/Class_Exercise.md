### Day 2 afternoon

1. import the inbuilt auto.dta dataset
2. describe the whole dataset 
3. generate a new variable called "wtsq" which is the square of weight 
4. label the wtsq variable 
5. rename wtsq variable as "weight_square" 
6. keep the first 5 observations 
7. drop the variable "weight_square" 
8. only keep the fist four variables 



```stata
sysuse auto.dta,clear
des 
gen wtsq = weight * weight 
label var wtsq "square of weight"
rename wtsq weight_square
keep in 1/5
drop weight_square
keep make price mpg rep78
```



### Day 3 Moring 

1. Please generate a variable that indicates which observations are missing for the variable `rep78`. Count the number of missing values and enter that number in the corresponding cell in the Google sheet.

```stata
gen missing_rep78 = missing(rep78)
tab rep_78
```



2. Find where your saved dta file goes, and change your working directory to some other folder that makes sense to you. 



### Basic Stata commands 

```stata
split (make), gen (name_piece) parse("")
split(make), parse(.) 


cd "/Users/gesun/Desktop/Bootcamp2023/02_Intro_to_Stata/Class_Exercise/data"
use baseline_census_cleaned.dta, clear
```





#### Dofiles 

```stata
***********************************************
************ Class Exercise Day3 **************
***********************************************

/*
Author: Ge Sun 
Date: 20230517 
Stata version: SE 16.1
*/


// Basic Setting
clear 
clear all 
set more off
capture log close

cd "/Users/gesun/Desktop/Bootcamp2023/02_Intro_to_Stata/Class_Exercise"

log using "./log_files/fist_do_file", replace


// coding part
        sysuse auto.dta,clear 
        des 
        keep in 1/5


// this bottom line should also be in the format
capture log close
```



#### Afternoon

```stata
cd "/Users/gesun/Desktop/Bootcamp2023/02_Intro_to_Stata/Class_Exercise/data"
use lfs_examples_class08, clear
```





### Day 4 

```stata
***************** Conditional Expression *********************

cd "/Users/gesun/Desktop/Bootcamp2023/02_Intro_to_Stata/Class_Exercise/data"
use lfs_examples_class08, clear
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

use "$data/lfs_examples_class08", clear 
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
```

