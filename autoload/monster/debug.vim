scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:monster#debug#enable = get(g:, "monster#debug#enable", 0)


let s:log_data_list = []
function! monster#debug#echo(text)
	if !g:monster#debug#enable
		return
	endif
	let log = ""
	let log .= "---- " . strftime("%c", localtime()) . ' ---- | ' . "\n"
	let log .= (type(a:text) == type("") ? a:text : string(a:text))
	call add(s:log_data_list, log)
endfunction


function! monster#debug#log()
	return join(s:log_data_list, "\n")
endfunction


function! monster#debug#clear_log()
	let s:log_data_list = []
endfunction


function! monster#debug#callstack()
	try
		throw 'abc'
	catch /^abc$/
		return split(matchstr(v:throwpoint, 'function \zs.*\ze,.*'), '\.\.')[ : -2]
	endtry
endfunction


let s:name = "homu"
function! monster#debug#{s:name}()
	echo "mami"
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
