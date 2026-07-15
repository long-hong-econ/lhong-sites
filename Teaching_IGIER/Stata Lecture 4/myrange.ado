capture program drop myrange
program define myrange, rclass
version 13
syntax varlist(max = 1 numeric) [if] [in ] [, QUIET]   
								
marksample sample  			

quietly count if `sample'   

if `r(N)' == 0 {
							
	display as error "No Observations"						
	exit
}

tempname range

	qui sum `varlist' if `sample'     
	
	scalar `range' = r(max) - r(min)
	
	if "`noprint'" != "noprint"  {     
		display as text "Range: " `range'
	}
	
	return scalar myrange = `range'   
	
end
