scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! monster#context#get_current(...)
	let base = get(a:, 1, {})
	let complete_pos = strwidth(matchstr(getline("."), '\zs.\{-}\ze\w*$'))
	let start_col = getline(".") == "" ? 1 : complete_pos
	return extend({
\		"bufnr" : bufnr("%"),
\		"col"  : col("."),
\		"start_col"  : start_col,
\		"complete_pos" : complete_pos,
\		"line" : line("."),
\		"cache_keyword" : printf("%d-%d-%d", bufnr("%"), complete_pos, line(".")),
\	}, base)
endfunction


function! monster#current_context(...)
	return call("s:current_context", a:000)
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
