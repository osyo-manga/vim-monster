scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


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


function! s:current_context(...)
	let base = get(a:, 1, {})
	return extend({
\		"file" : s:make_tempfile(bufnr("%")),
\		"col"  : col("."),
\		"line" : line("."),
\		"keyword" : printf("%d-%d-%d", bufnr("%"), col("."), line(".")),
\	}, base)
endfunction


function! monster#complete(findstart, base)
	if a:findstart
		return col(".") - 1
	endif
	let context = s:current_context({ "col" : col(".") - 1 })
	try
		return monster#sync_rcodetools#complete(context)
	finally
		call delete(context.file)
	endtry
endfunction


function! monster#test()
" 	let start_time = reltime()
" 	let result = monster#complete(0, 0)
" 	echo reltimestr(reltime(start_time))
" 	return result
	let start_time = reltime()
	let context = s:current_context()
	try
		let result = monster#sync_rcodetools#complete(context)
		return result
	finally
		call delete(context.file)
		echom "Complete : " . reltimestr(reltime(start_time))
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
