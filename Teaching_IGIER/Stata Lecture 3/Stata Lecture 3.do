
******************************************************************************
******************************************************************************
******************************************************************************
***								Lecture 3								   ***
***								Long Hong								   ***
***							  April 27, 2016							   ***
******************************************************************************
******************************************************************************
******************************************************************************


******************************************************************************
****			       	Problem Set 2 				 	        		  ****
******************************************************************************

* Use "/* ... */ to inactive the codes.
/*

1. Use -global- to set up your own working dictionary

2. Use "ccode_s" in data folder:
	2.a. replace ccode from string to numeric 
	2.b. generate a new variable "abb" that contains only the first 
		 three letters of "country"
		 
3. Use "reshape" in the data folder: make the data to a "long" shape
   [Hint: Always remember to check duplicates!]

4. System use "lifeexp": 
	a. make some regressions by your own choices
	b. output them to a table using either esttab or outreg

5. Organize all your codes in a single do file
	[Hint: do not forget the initial settings!]

*/


* Show me your final DO file. (15 mins)


* Question 1
global working "/Users/admin/Dropbox/Stata Minicourse/Stata Lecture 2"
cd "$working"

* Question 2
use "$working/Data/ccode_s", clear
destring ccode, replace
gen abb = substr(country, 1, 3)

* Question 3
use "$working/Data/reshape", clear
duplicates list
duplicates drop
reshape long inc, i(id) j(year)

* Question 4
sysuse lifeexp, clear
eststo clear
eststo: reg lexp popgrowth, robust
esttab

* Question 5
	* done.


******************************************************************************
***			 		      Initial Set Ups								   ***
******************************************************************************

global working "/Users/admin/Dropbox/Stata Minicourse/Stata Lecture 3"

cd "$working"

clear all
set more off

capture log close
log using lesson_three, replace

	*** A note on local and global
	* quotation mark is not necessary to define a local macro or a global macro
	global working "/Users/admin/Dropbox/Stata Minicourse"	
	global working /Users/admin/Dropbox/Stata Minicourse
	local control "gdp gnp"
	local control gdp gnp
	* Quotation mark to make things easier to read.


******************************************************************************
***			 		      Scalar and Matrix								   ***
******************************************************************************

*** Scalars

* Create scalars and operations
scalar a = 1
scalar b = 2
scalar c = a + b          
scalar d = sqrt(b)   
scalar a = 5        /// replace by simply define it again, like R and Matlab

* Display scalars
display c            /// display straightforward - not recommended

display a c          /// confusing if display more

	display a " " c  /// better way?

scalar list          /// proper way to list scalar - list all scalars

scalar list a c      /// list certain scalars


*** Matrix

help matrix

* Define Matrix
matrix define A = (1, 2, 3 \ 4, 5, 6)

	* define can be omitted - again, replace simply by re-defining
	matrix A = (10, 2, 3 \ 4, 5, 6)

matrix list A

	* Change row and colum names?
	matrix rownames A =  rowone rowtwo
	matrix colnames A = colone coltwo colthree
	matrix list A

* Matrix Operations
matrix A[1,1] = A[1,2]
matrix list A

matrix B = A, A
matrix list B

matrix C = A \ A
matrix list C

matrix D = A + 2*A
matrix list D 

matrix E = D'
matrix list E

matrix F = (1, 2 \ 3, 4)
matrix Finv = inv(F)
matrix list Finv

* Get scalars from Matrix
scalar a = Finv[1,1]
scalar list a


*** Application

sysuse lifeexp, clear

* return list: list all the "restored" results 
	* - better sense after ado file programming
sum lexp
return list                 /// better idea if you know ado programming

scalar mean = r(mean)
scalar list mean

* ereturn list: post all the estimation results
regress lexp safewater, robust 

	return list   
	matrix table = r(table)
	matrix list table       /// not very useful here
	
ereturn list
scalar r2 = e(r2)
matrix B = e(b)
matrix list B
scalar b_water = B[1,1]
scalar b_cons  = B[1,2]

	* Alternatives:
	scalar b_water = _b[safewater]
	scalar b_cons  = _b[_cons]

matrix V = e(V)
matrix list V           /// Variance Covariance Matrix



******************************************************************************
***			 		    Instrumental Variable							   ***
******************************************************************************

global data    "/Users/admin/Dropbox/Stata Minicourse/Stata Lecture 3/Data"

use "$data/card", clear


* Examine Causal relation between Wage and Education
global controls "exper expersq black south reg* smsa66"

eststo clear                         /// use esttab to create tables

*** Plain OLS: Problem 
eststo: reg lwage educ $control, robust
	* education is endogenous: omitted variable bias 
	* education and ability - wage and ability

***	Theoretical Formula

* First Stage: instrument education with distance between college and home
reg educ nearc2 nearc4 $controls, robust
testparm nearc2 nearc4   /// Check the relevance condition - significant
						 /// Weak instrument problem! F-statistic = 9.55 < 10

predict educ_hat

* Second Stage
eststo: reg lwage educ_hat $controls, robust


*** Direct Command
eststo: ivregress 2sls lwage $controls (educ = nearc2 nearc4), robust

estat firststage

estat overid        

	* H0: overidentification restrictions are valid
	* if p-value > 0.1, cannot reject H0 at 90% confident level

*** Compare results
esttab, cells(b(star fmt(3)) se(par fmt(3))) ///
starlevels( * 0.10 ** 0.05 *** 0.01) keep(educ educ_hat) nogap 

	* "ivregress 2sls" also adjust the s.d. to make it more precise
	* recommended


*** Report Weak Instrument and over identification all together
ivreg2 lwage (educ = nearc2 nearc4) $controls, robust   /// F-statistics = 9.55


******************************************************************************
***			 		      Loops											   ***
******************************************************************************

* From now on, Do files will be intensively used.


*** forvalues 

clear
set obs 10
gen x = .

forvalues i = 1/10 {
  
	replace x = `i'  in `i'

}
browse

forv i = 1(1)10 {
  
	replace x = 2*`i'  in `i'

}
browse

forv i = 1 3 to 10 {
  
	replace x = `i' + 100  in `i'

}
browse        /// Odd # of observations changes


*** while
clear 
set obs 10
gen x = .

local i = 1   /// equal to local i 1 or local i "1"

while `i' <= 10 {
	
	replace x = `i' in `i'
	
	local i = `i' + 1    /// to proceed to the next step 

}
browse


*** foreach 

sysuse lifeexp, clear
local controlchoice "popgrowth gnppc"

eststo clear
foreach c of local controlchoice {

	eststo: regress lexp safewater `c', robust

}
esttab

	** Advanced: macro in macro
	local control1 "popgrowth"
	local control2 "popgrowth gnppc"
	local control3 "popgrowth gnppc region"

	* Alternative 1:
	eststo clear
	forv i = 1/3  {
	
	eststo: regress lexp safewater `control`i'', robust
	
	}
	
	* Alternative 2:
	local control "control1 control2 control3"

	foreach c of local control{
	
	eststo: regress lexp safewater ``c'', robust
	
	}
	esttab using trial.txt, replace


******************************************************************************
***			 		    Ado File Programming							   ***
******************************************************************************

* Example
*! myrange v1.0.0 Long Hong 22Apr2016
capture program drop myrange      /// to drop the program you previously have

program define myrange, rclass    /// create a program
								  /// rclass: allow store results in "return"

version 13                        /// using Stata version 13

syntax varlist (max = 1 numeric)  /// only one variable is allowed

tempname range                    /// temporarily use the name
								  /// it is a local macro

quietly summarize `varlist'       /// quietly: result does not shown in screen

scalar `range' = r(max) - r(min)  /// tempname range is know a local macro

return scalar myrange = `range'   /// store result in "return"

display as text "Range: " `range' /// print the result

end                               /// Never forget to put "end" to end program



* Try the program
sysuse lifeexp, clear
myrange lexp

* Check
sum lexp


