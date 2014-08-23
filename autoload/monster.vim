scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:monster#debug = get(g:, "monster#debug", 1)


function! monster#errmsg(errors)
	if type(a:errors) != type([])
		return monster#errmsg(split("[monster.vim] " . a:errors, '[\n\r]'))
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
	return monster#debug#echo(a:text)
endfunction


function! monster#get_debug_log()
	return monster#debug#log()
endfunction

function! monster#clear_debug_log()
	return monster#debug#clear_log()
endfunction


function! monster#current_context(...)
	return call("monster#context#get_current", a:000)
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


function! monster#start_complete(...)
	let force = get(a:, 1, 0)
	let base = get(a:, 2, get(s:, "start_complete_context", {}))
	let context = extend(monster#context#get_current(), base)

	if mode() !~# 'i' && !force
		return -1
	endif
	if mode() !~# 'i'
		startinsert!
		let s:start_complete_context = base
		call feedkeys("\<C-R>=monster#start_complete()?'':''\<CR>", "n")
		return 0
	endif

	let baseline = getline(".")[context.start_col : col(".")]
" 	if baseline =~ '\s'
" 		return ""
" 	endif

	let items = monster#completion#complete(context)
	call filter(items, 'v:val.word =~ ''^'' . baseline')
	if empty(items)
		return -1
	endif

	call complete(context.start_col + 1, items)
	return 0
endfunction



let g:monster#enable_neocomplete = get(g:, "monster#enable_neocomplete", 0)


function! monster#omnifunc(findstart, base)
	if a:findstart == 0
		if empty(s:result)
			return []
		endif
		try
			return filter(copy(s:result), 'v:val.word =~ ''^'' . a:base')
		finally
			echo "monster.vim - finish completion"
			unlet! s:result
		endtry
	endif
	unlet! s:result

" 	let failed = g:monster#enable_neocomplete ? -1 : -3
	let failed = -1
" 	PP! monster#debug#callstack()
" 	if monster#debug#callstack()[0] == "monster#omnifunc"
" 		let failed = -3
" 	else
" 		let failed = -1
" 	endif

	" コメント時は補完しない
	if synIDattr(synIDtrans(synID(line("."), col(".")-1, 1)), 'name') ==# "Comment"
		echo "monster.vim - failed completion"
		return failed
	endif

	echo "monster.vim - start completion"
	let context = monster#context#get_current()
	let s:result = monster#completion#complete(context)
	if empty(s:result)
		echom "monster.vim - empty completion"
		return -1
	endif
	return context.start_col
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
