scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:monster#completion#backend = get(g:, "monster#completion#backend", "rcodetools")


function! monster#completion#complete(context)
	let result = monster#cache#get(a:context)
	if !empty(result)
		return result
	endif
	let result = monster#completion#{g:monster#completion#backend}#complete(a:context)
	return monster#cache#add(a:context, result)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
