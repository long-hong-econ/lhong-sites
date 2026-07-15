******************************************************************************
******			        Problem Set 1     							    ******
******************************************************************************

* Set your own working dictionary
* Creat log file lession_one
* Import excel file ccode.xlsx and save it as an older version Stata data
* Use lifeexp dataset in Stata
* In one line code: create a dummy = 1 if the country is Italy; 0 otherwise
* Calculate the highest life expectancy in each region (egen)

* Show me your saved log file and finished do file. (10 mins)


******************************************************************************
******			        Problem Set 1     							    ******
******************************************************************************

global working "/Users/admin/Dropbox/Stata Minicourse/Stata Lecture 1"

cd "$working"

capture log close
log using lesson_one, replace

import excel "$working\ccode.xlsx", sheet("Sheet 1") firstrow clear

saveold ccode, replace

sysuse lifeexp, clear

gen dummy = (country == "Italy")

bysort region: egen high = max(lexp)


log close

