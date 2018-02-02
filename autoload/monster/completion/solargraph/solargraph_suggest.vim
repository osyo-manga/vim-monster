scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! monster#completion#solargraph#solargraph_suggest#command(context, file)
	return printf(g:monster#completion#solargraph#complete_command . " suggest --line=%d --column=%d %s", a:context.line-1, a:context.complete_pos, a:file)
endfunction


function! monster#completion#solargraph#solargraph_suggest#check()
	return executable("solargraph")
endfunction


function! monster#completion#solargraph#solargraph_suggest#complete(context)
	if !executable(g:monster#completion#solargraph#complete_command)
		call monster#errmsg("No executable 'solargraph' command.")
		call monster#errmsg("Please install 'gem install solargraph'.")
		return
	endif
	try
		let shellredir = &shellredir
" 		echo "monster.vim - start solargraph"
		let file = monster#make_tempfile(a:context.bufnr, "rb")
		let command = monster#completion#solargraph#solargraph_suggest#command(a:context, file)
		if has("win32")
			set shellredir=>%s\ 2>NUL
		else
			set shellredir=>%s\ 2>/dev/null
		endif
		let result = system(command)
		let g:hoge = result
	finally
		call delete(file)
		let &shellredir = shellredir
	endtry
	call monster#debug_log(
\		"[solargraph_suggest.vim] solargraph command : " . command . "\n"
\	  . "[solargraph_suggest.vim] solargraph result : \n" . result
\	)
	if v:shell_error != 0
" 		call monster#errmsg(command)
" 		call monster#errmsg(result)
" 		echo "monster.vim - failed solargraph"
		return []
	endif
	echo "monster.vim - finish solargraph"
	return monster#completion#solargraph#parse(result)
endfunction


function! monster#completion#solargraph#solargraph_suggest#test()
	let start_time = reltime()
	let context = monster#context#get_current()
	let old_debug = g:monster#debug#enable
	let g:monster#debug#enable = 1
	call monster#debug#clear_log()
	
	try
		let result = monster#completion#solargraph#solargraph_suggest#complete(context)
		return { "context" : context, "result" : result, "log" : monster#debug#log() }
	finally
		let g:monster#debug#enable = old_debug
		echom "Complete time " . reltimestr(reltime(start_time))
	endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
