scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:monster#completion#backend = get(g:, "monster#completion#backend", "rcodetools")


function! monster#completion#complete(context)
	if monster#cache#is_exists(a:context)
		return monster#cache#get(a:context)
	endif
	let result = monster#completion#{g:monster#completion#backend}#complete(a:context)
	if empty(result)
		return []
	endif
	return monster#cache#add(a:context, result)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
