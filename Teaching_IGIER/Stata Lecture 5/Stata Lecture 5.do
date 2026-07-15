******************************************************************************
******************************************************************************
******************************************************************************
***								Lecture 5								   ***
***								Long Hong								   ***
***							   May 11, 2016								   ***
******************************************************************************
******************************************************************************
******************************************************************************


******************************************************************************
***			 		     Document Help File - SMCL						   ***
******************************************************************************

*** SMCL: Stata Markup and Control Language
help smcl  		 // To study this language in depth, refer to the help file
				 // Very simple, a bit like Latex language


*** An example

{smcl}                     // Start Do file with {smcl}

{cmd: help myrange}       // Let Stata know this is for "help myrange"

{hline}					  // Just a line

{title: Title}            // Make a section title
          
{phang}                   // Some default paragraph mode, others like pstd...

{bf: myrange {hline 1} Believe it or not, I calculate the range for you.}  // bf: bold 


{title: Syntax}  

{phang} 
{cmd: myrange} {varlist} {ifin} [{cmd:,} {cmd: quiet}]
				
				// myrange, comma, and quiet are all commands
				// {varlist} and {ifin} are default settings


{title: Options}

{phang}{opt quiet} I do not want to see the result...     // no ":" after opt


{title: Description}

{phang}{cmd: myrange} computes the range for a given numeric variable. Why range? 
becaue I do not know how to do math. By the way, the result is returned as a scalar.


{title: Example}

{phang}{stata "sysuse lifeexp": . sysuse lifeexp}{p_end}   
		// This allows you to click to run in Stata
		// "p_end" to end a paragraph
		
{phang}{stata "myrange lexp": . myrange lexp}{p_end}
{phang}{stata "return list": . return list}{p_end}


{title: Author}

{phang}Long Hong{p_end}
{phang}Bocconi University, Milan, Italy{p_end}
{phang}{browse "mailto:long.hong@studbocconi.it":long.hong@studbocconi.it}
	// A way to create a link to your email address.
	

*** Document it

* Save as myrange.sthlp
	* file name must be: myrange 
	* extension .sthlp

* Save it to the same folder as the ado file's


*** Exercise: Create your own help file for range7525


******************************************************************************
***			 		     Maximum Likelihood Estiamtion					   ***
******************************************************************************

*** Maximum Likelihood Estimation in Linear Form


*** Task: Estimate MLE for Normal Distribution 

** Try in the simulated data

clear 
set obs 1000
gen random = rnormal(3,5)


** Program likelihood function

capture program drop normal_mle
program normal_mle		// like matrix define, program define = program

version 12

args lnfj mu sigma 		// recall args from last class 

qui replace `lnfj' = (-1/2)*ln(2*_pi) - ln(`sigma') - (1/(2*(`sigma')^2))*(($ML_y1 - `mu')^2)	
															* $ML_y1: Default MLE notation for "y_i"
	* "replace": just remember as a rule for mle functions

end


** MLE
ml model lf normal_mle (mu: random =)(sigma:)    
		 * Use "lf" to indicate that "lnfj" can be linearly added
						* "mu:" "sigma:" to denote the parameter names
						* "random =" the observations to estimate mu and sigma

ml check            // Check if the model is correctly specified.

ml maximize         // MLE


*** Make it as a Stata package
	* Simple! Remember there is only one input in the example above: "random"
	* Only Tricky part: Program inside a program 
	* A note on this: the sequence of the program does not matter

capture program drop normal_mle
program normal_mle
version 12
args lnfj mu sigma 	
qui replace `lnfj' = (-1/2)*ln(2*_pi) - ln(`sigma') - (1/(2*(`sigma')^2))*(($ML_y1 - `mu')^2)	
end

capture program drop mynormal_mle
program define mynormal_mle
version 12
args input

ml model lf normal_mle (mu: `input' =)(sigma:)    
							* change "random" to `input'
							
ml maximize        

end 	


** Test it in Simulated data and real data

* Simulated Data
clear
set obs 1000

gen random1 = rnormal(1,2)
mynormal_mle random1

gen random2 = rnormal(5,9)
mynormal_mle random2	


* Real Data: Mile Age
sysuse auto, clear

	hist mpg, bin(10)
	* From the graph, the mean looks like around 25
	* Possibly s.d. is for sure less than 10

mynormal_mle mpg
	
	* Result: mean 21 and s.d. 5.7


*** Task: Estimate MLE for Exponential Distribution

capture program drop exp_mle
program exp_mle
version 12
args lnfj lambda	
qui replace `lnfj' = -ln(`lambda') - ($ML_y1/`lambda')
end

* Recall the random generator for exponential distribution from lesson 1:
clear
set obs 1000

gen p = runiform()
scalar lambda = 3
gen random = -ln(1-p)/(1/lambda)

* MLE
ml model lf exp_mle (lambda: random =) 

ml check 
ml maximize     


******************************************************************************
***			 		    End of the Stata Minicourse						   ***
******************************************************************************

capture program drop stataend
program define stataend
	display in red "End of the Stata Minicourse. Hope you like it."
end

stataend
	
