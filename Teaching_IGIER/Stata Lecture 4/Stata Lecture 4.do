******************************************************************************
******************************************************************************
******************************************************************************
***								Lecture 4								   ***
***								Long Hong								   ***
***							   May 09, 2016								   ***
******************************************************************************
******************************************************************************
******************************************************************************


* No more initial settings for ado file programming! :)


******************************************************************************
***			 		      Simple Programming							   ***
******************************************************************************

*** Program Define
capture program drop hello
program define hello 
	display "Hello Everyone! My name is Long."
end

hello

*** Args

* Example 1: My Random Generator

	* Recall Random Generator (3 inputs: 100, 0, 1)
	set seed 123456
	set obs 100
	gen random = rnormal(0,1)
	
capture program drop mynormal
program define mynormal
version 13
args size mean sd seed
	
	set seed `seed'
	set obs  `size'
	gen myrandom = rnormal(`mean', `sd')

end

mynormal 100 0 1 123456

sum   /// Exactly the same!


* Example 2: Simpler way for last week's example
capture program drop myrange
program define myrange
version 13
args myvar
	
	qui sum `myvar'
	scalar range = r(max) - r(min)
	display as text "Range: " range

end
	
	* Detour: quietly - Quietly perform Stata command
	regress random myrandom
	quietly regress random myrandom
		* How can I know the command worked?
		eststo: quietly regress random myrandom
		esttab

* Back to the program and test it.
myrange random


*** Exercise 1: 
	
	* Use "args" to program a generator for a Gamma random generator
	* to familarize the program command



******************************************************************************
***			 		      Syntax Programming							   ***
******************************************************************************

*** Study Stata Syntax
help summ

	* varlist
	* if/in
	* weight (not used often, skip)
	* option
	* Study them one by one


******************************************************************************
***			 		   Syntax Programming: Syntax						   ***
******************************************************************************

capture program drop myrange
program define myrange
version 13
syntax varlist(max = 1 numeric)
	
	qui sum `varlist'
	scalar range = r(max) - r(min)
	display as text "Range: " range

end

* Issues 1: What if there is a scalar "range" in the current dataset
* Solution: tempname
	
capture program drop myrange
program define myrange
version 13
syntax varlist(max = 1 numeric)
	
tempname range
	
	qui sum `varlist'
	scalar `range' = r(max) - r(min)
	display as text "Range: " `range'

end

scalar range = 1
myrange random

* Issue 2: The result is not stored.
scalar list   // only scalar range = 1

	* recall: "return list" - How to make this function available to "myrange"? 
	sum random
	return list

* Solution: rclass - store scalars in "return"
capture program drop myrange
program define myrange, rclass
version 13
syntax varlist(max = 1 numeric)
	
tempname range
	
	qui sum `varlist'
	scalar `range' = r(max) - r(min)
	display as text "Range: " `range'
	
	return scalar myrange = `range'    // it returns "r(myrange)"
	
end

myrange random
return list
scalar myrange = r(myrange)

scalar list


*** Exercise 2: 

	* Use "syntax" & "rclass" to range7525 
	* that is the distance from 75 percentile to 25 percentile
	* Hint: 
	summarize random, detail
	return list



******************************************************************************
***			 		   Syntax Programming: Options						   ***
******************************************************************************

*** Option Task: Creat an option that works the same as "quietly", 
	* i.e. do not display the result since it is already stored in r(myrange)
	
*** Option: 
	* square bracket, comma then option 
	* the option is a local macro
	* written in CAPITAL LETTER! - but is it actually defined in LOWER CASE!
capture program drop myrange
program define myrange, rclass
version 13
syntax varlist(max = 1 numeric) [, QUIET] 
								 * capital letter here
								
tempname range
	
	qui sum `varlist'
	scalar `range' = r(max) - r(min)
	
	if "`quiet'" != "quiet"  {     
		* lower case here
	
		display as text "Range: " `range'
	
	}
	
	return scalar myrange = `range'   

end

myrange random, quiet
return list


******************************************************************************
***			 	 Syntax Programming: Subset of Observations			 	  ***
******************************************************************************

*** IF/IN - Take IF for example (same for IN)
	* square bracket if and in like the help file
	* command: marksample - uses the information provided after "if" or "in"
		* save the information (e.g. x > 5) in a local macro

capture program drop myrange
program define myrange, rclass
version 13
syntax varlist(max = 1 numeric) [if] [in ] [, QUIET]   
								* like this

marksample sample  			// Save information in local macro "sample"

quietly count if `sample'   // think as "count if x > 5"

if `r(N)' == 0 {
						// 1. r(N): think of "return list" after count
							// the total number of observation is stored in r(N)
						// 2. because `sample' is a local macro, 
							// so also think r(N) as a local macro 
	
	display as error "No Observations"						
	exit
}

tempname range

	qui sum `varlist' if `sample'      // think as "sum x if x > 5"
	
	scalar `range' = r(max) - r(min)
	
	if "`quiet'" != "quiet"  {     
		display as text "Range: " `range'
	}
	
	return scalar myrange = `range'   
	
end


myrange random if random > 5
myrange random if random > 1

	* Check
	sum random if random > 1


*** Exercise 3: add if/in and option "quiet" in your program range7525  


*** Last point: trace your codes
set trace on
set trace off


******************************************************************************
***			 		      Document Programming							   ***
******************************************************************************

*** Save as .ado file
adopath   // Put ado file in "Base" -> program exists in computer permanently
	
clear programs
program drop _all     
program drop myrange  // Check: if we clear the program, does it work?

myrange random 		  // It works since it has become a build-in program.     



******************************************************************************
***			 		      Plan							   ***
******************************************************************************

* How to write a help file [SMCL: Stata Markup and Control Language]
help smcl
	
	* Example myrange.sthlp
	
* MLE in Stata


