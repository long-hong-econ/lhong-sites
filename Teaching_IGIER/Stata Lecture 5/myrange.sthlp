{smcl}
{cmd: help myrange}       
{hline}

{title: Title}            
          
{phang}{bf: myrange {hline 1} Believe it or not, I calculate the range for you.}  

{title: Syntax}  

{phang}{cmd: myrange} {varlist} {ifin} [{cmd:,} {cmd: quiet}]
				
{title: Options}

{phang}
{opt quiet} I do not want to see the result...

{title: Description}

{phang}
{cmd: myrange} computes the range for a given numeric variable. Why range? 
becaue I do not know how to do math. By the way, the result is returned as a scalar.

{title: Example}

{phang}{stata "sysuse lifeexp": . sysuse lifeexp}{p_end}
{phang}{stata "myrange lexp": . myrange lexp}{p_end}
{phang}{stata "return list": . return list}{p_end}

{title: Author}

{phang}Long Hong{p_end}
{phang}Bocconi University, Milan, Italy{p_end}
{phang}{browse "mailto:long.hong@studbocconi.it":long.hong@studbocconi.it}
	
