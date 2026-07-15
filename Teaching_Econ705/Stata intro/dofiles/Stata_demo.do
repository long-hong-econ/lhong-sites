clear                                          // clear in interface
cd "~/Dropbox/Econ706/Stata section/dofiles"   // set directory

* Rule #1: -help- command is your master!

*----------------------------------------------------------------------------
* Import/Save data
*----------------------------------------------------------------------------

* Stata format
use "../data/auto", clear

* Other format
import delimited "../data/auto.csv", clear 
import excel "../data/auto.xls", firstrow clear

	* My (lazy) way:
	* Use manual way: File -> Import -> Choose file
	* Copy the command from review bar for future use
		
* Save 
save  "../data/auto_new", replace  // replace in case there is an existing file
erase "../data/auto_new.dta"      // erase any file from do file
		
*----------------------------------------------------------------------------
* Data management with commonly used commands
*----------------------------------------------------------------------------

* Generate variables
gen     temp = 1                        // generate variable
replace temp = 2 if price > 1000        // replace variable value
gen dummy = (price > 1000)              // convenient way in gen dummy
label variable dummy "=1 price high"    // label variables
rename dummy pricy                      // rename variables

* Keep/Drop
keep make - temp                        // keep from make to temp
drop temp                               // keep temp and dummy only
keep if price <= 10000                  // keep obs if price <= 10000
drop if price >  10000

* sort data/variables
sort price  					   	    // sort data from lowest to highest
order price make                        // order variable names
gen id = _n                             // generate an index according to row #

* Summary statistics
sum price                               // basic summarize
sum price, de                           // detailed summarize
tab foreign                             // tabulate frequency

* Advanced: useful variable generator
help egen                               // generate with functions

* Advanced: useful data management
help collapse                           // collapse/aggregate data
help reshape                            // reshape your data 
help merge                              // merge additional datasets

* Advanced: string variables
help tostring 
help destring 
help substr


*----------------------------------------------------------------------------
* Regression 
*----------------------------------------------------------------------------

* Regression model: price = alpha + beta*mpg + epsilon
regress price mpg, robust           // Plain OLS with robust standard errors


* Advanced: 
help xtreg                          // panel data regressions
help ivregress                      // user-written ivreg2 for more information
ssc install ivreg2

* Output regression tables
ssc install outreg2                 // download packages outreg2

regress price mpg, robust 
outreg2 using "../results/table1.xls", replace  // "replace" for new file
regress price mpg weight, robust   
outreg2 using "../results/table1.xls", append   // "append" 

help outreg2                        // see help file for bells and whistles


*----------------------------------------------------------------------------
* Loops/Local/Global
*----------------------------------------------------------------------------

* Efficiency 
help local 
help global

* Loops
help forvalues
help foreach 
help while


*----------------------------------------------------------------------------

* Consult SSCC to most of the coding questions
* Form study groups for coding 
* Download replication files from the published paper - learn from them!

*----------------------------------------------------------------------------

