scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:monster#rcodetools#backend = get(g:, "monster#rcodetools#backend", "rct_complete")


function! s:parse(text)
	let parsed = split(a:text, '\t')
	return {
\		"word" : get(parsed, 0, ""),
\		"menu" : get(parsed, 1, ""),
\		"info" : a:text,
\	}
endfunction


function! monster#rcodetools#parse(result)
	return map(split(a:result, '[\r\n]'), "s:parse(v:val)")
endfunction


function! monster#rcodetools#complete(context)
" 	return monster#rcodetools#async_rct_complete#complete(a:context)
" 	return monster#rcodetools#rct_complete#complete(a:context)
	return monster#rcodetools#{g:monster#rcodetools#backend}#complete(a:context)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
