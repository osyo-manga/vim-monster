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
	let base = get(a:, 1, {})
	let context = extend(monster#context#get_current(), base)
	PP context
	if mode() !~# 'i'
		startinsert!
		return feedkeys("\<C-R>=monster#start_complete()\<CR>", "n")
	endif
	call complete(context.start_col + 1, monster#completion#complete(context))
	return ""
endfunction



let g:monster#enable_neocomplete = get(g:, "monster#enable_neocomplete", 0)


function! monster#omnifunc(findstart, base)
	if a:findstart == 0
		try
			return filter(copy(s:result), 'v:val.word =~ ''^'' . a:base')
		finally
			unlet! s:result
		endtry
	endif
	unlet! s:result

	let failed = g:monster#enable_neocomplete ? -1 : -3

	" コメント時は補完しない
	if synIDattr(synIDtrans(synID(line("."), col(".")-1, 1)), 'name') ==# "Comment"
		return failed
	endif

	let context = monster#context#get_current()
	let s:result = monster#completion#complete(context)
	if empty(s:result)
		return failed
	endif
	return context.start_col
endfunction


augroup monster
	autocmd!
	autocmd InsertEnter * call monster#cache#clear_all()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
