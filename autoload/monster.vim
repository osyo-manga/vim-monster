scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:monster#debug = get(g:, "monster#debug", 1)


function! monster#errmsg(errors)
	if type(a:errors) != type([])
		return monster#errmsg(split("monster.vim : " . a:errors, '[\n\r]'))
	endif
	echohl ErrorMsg
	try
		for text in a:errors
			echom substitute(text, "\t", "        ", "g")
		endfor
	finally
		echohl NONE
	endtry
endfunction


let s:log_data_list = []
function! monster#debug_log(text)
	if !g:monster#debug
		return
	endif
	let log = ""
	let log .= "---- " . strftime("%c", localtime()) . ' ---- | ' . "\n"
	let log .= (type(a:text) == type("") ? a:text : string(a:text))
	call add(s:log_data_list, log)
endfunction


function! monster#get_debug_log()
	return join(s:log_data_list, "\n")
endfunction

function! monster#clear_debug_log()
	let s:log_data_list = []
endfunction


function! s:tempfile(ext)
	return strftime("%Y-%m-%d-%H-%M-%S.") . a:ext
endfunction


function! s:make_tempfile(bufnr, ...)
	let ext = get(a:, 1, expand("#" . a:bufnr . ":e"))
	let filename = expand("#" . a:bufnr . ":p:h") . "/" . s:tempfile(ext)
	let filename = substitute(filename, '\', '/', "g")
	if writefile(getbufline(a:bufnr, 1, "$"), filename) == -1
		return ""
	else
		return filename
	endif
endfunction


function! monster#make_tempfile(...)
	return call("s:make_tempfile", a:000)
endfunction


function! s:current_context(...)
	let base = get(a:, 1, {})
	let complete_pos = strwidth(matchstr(getline("."), '\zs.\{-}\ze\w*$'))
	return extend({
\		"bufnr" : bufnr("%"),
\		"col"  : col("."),
\		"complete_pos" : complete_pos,
\		"line" : line("."),
\		"cache_keyword" : printf("%d-%d-%d", bufnr("%"), complete_pos, line(".")),
\	}, base)
" \		"cache_keyword" : printf("%d-%d-%d", bufnr("%"), col("."), line(".")),
endfunction
function! monster#current_context(...)
	return call("s:current_context", a:000)
endfunction



function! monster#start_complete()
	call feedkeys("\<C-x>\<C-o>", "n")
endfunction


let s:cache = {}
function! monster#add_cache(context, data)
	let s:cache[a:context.cache_keyword] = a:data
endfunction


function! monster#remove_cache(context)
	unlet! s:cache[a:context.cache_keyword]
endfunction


let g:monster#enable_neocomplete = get(g:, "monster#enable_neocomplete", 0)


function! monster#complete(findstart, base)
	if a:findstart == 0 && exists("s:result")
		try
			return filter(copy(s:result), 'v:val.word =~ ''^'' . a:base')
		finally
			unlet! s:result
		endtry
	endif

	let failed = g:monster#enable_neocomplete ? -1 : -3

	" コメント時は補完しない
	if synIDattr(synIDtrans(synID(line("."), col(".")-1, 1)), 'name') ==# "Comment"
		return failed
	endif

	let context = s:current_context({ "col" : col(".") - 1 })
	if has_key(s:cache, context.cache_keyword)
		let s:result = s:cache[context.cache_keyword]
	else
		let s:result = monster#rcodetools#complete(context)
		if empty(s:result)
			return failed
		endif
		call monster#add_cache(context, s:result)
	endif
	return context.complete_pos
endfunction


augroup monster
	autocmd!
	autocmd InsertEnter * let s:cache = {}
augroup END


function! monster#test()
" 	let start_time = reltime()
" 	let result = monster#complete(0, 0)
" 	echo reltimestr(reltime(start_time))
" 	return result
	let start_time = reltime()
	let context = s:current_context()
	try
		let result = monster#rcodetools#complete(context)
		return result
	finally
		echom "Complete : " . reltimestr(reltime(start_time))
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
