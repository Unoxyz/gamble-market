* Merge Process for Gamble Market
* 2018.12.2. namun@snu.ac.kr

clear all
cd "/Users/j/Documents/lecture/2018-02/ECON151(00).세계와한국경제/_experiments/02.prefRev/_calculation/"
insheet using "data/players.csv"
save data/_players,replace

local files : dir "log" files "*.csv"
local counter = 0 

local a_high = 50000
local a_low = 0
local a_prob = 0.8
local b_high = 400000
local b_low = 0
local b_prob = 0.1

foreach file in `files'{
	insheet using "log/`file'",clear
	save `file',replace
	use data/_players,clear
	merge 1:1 id using `file'
	rm `file'
	rename cash cash`counter'
	rename a a`counter'
	rename b b`counter'
	drop _merge
	local counter = `counter'+1
	save data/_players,replace
}

forval i=0/99{
	gen rnda`i'=runiform()
	gen cash_a`i'=0
	replace cash_a`i'= a`i'*`a_high' if rnda`i'<=`a_prob'
	replace cash_a`i' = a`i'* `a_low' if rnda`i' > `a_prob'
	gen rndb`i'=runiform()
	gen cash_b`i'=0
	replace cash_b`i'= b`i'*`b_high' if rndb`i'<=`b_prob'
	replace cash_b`i' = b`i' * `b_low' if rndb`i' > `b_prob'
}

gen total_trade_cash = 0
gen total_gamble_cash = 0

forvalues i=0/99{
	replace total_trade_cash = total_trade_cash + cash`i'
	replace total_gamble_cash = total_gamble_cash + cash_a`i' + cash_b`i'
}

gen total_cash = total_trade_cash + total_gamble_cash

egen rank=rank(-total_cash)

disp "Done. Do not forget to save this result!!"
