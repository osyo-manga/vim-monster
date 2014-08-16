scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:cache = {}

function! monster#cache#add(context, data)
	let s:cache[a:context.cache_keyword] = a:data
	return a:data
endfunction


function! monster#cache#clear(context)
	unlet! s:cache[a:context.cache_keyword]
endfunction


function! monster#cache#clear_all()
	let s:cache = {}
endfunction


function! monster#cache#is_exists(context)
	return has_key(s:cache, a:context.cache_keyword)
endfunction


function! monster#cache#get(context)
	if monster#cache#is_exists(a:context)
		return s:cache[a:context.cache_keyword]
	endif
	return []
endfunction



augroup monster-cache
	autocmd!
	autocmd InsertEnter * call monster#cache#clear_all()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
