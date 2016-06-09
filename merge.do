* Merge Process for Gamble Market
* 2016.6.9. namun@snu.ac.kr

clear all
insheet using "data/players.csv"
save _players,replace

local files : dir "log" files "*.csv"
local counter = 0 

foreach file in `files'{
	insheet using "log/`file'",clear
	save `file',replace
	use _players,clear
	merge 1:1 id using `file'
	rm `file'
	rename cash cash`counter'
	rename a a`counter'
	rename b b`counter'
	drop _merge
	local counter = `counter'+1
	save _players,replace
}
