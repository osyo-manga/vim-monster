scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! monster#completion#solargraph#solargraph_suggest#command(context, file)
	return printf(
\		"curl -s -d line=%d -d column=%d -d filename=%s --data-urlencode text@%s http://localhost:%d/suggest",
\			a:context.line-1,
\			a:context.complete_pos,
\			a:file,
\			a:file,
\			g:monster#completion#solargraph#http_port)
endfunction


function! monster#completion#solargraph#solargraph_suggest#check()
	return executable("solargraph") && executable("curl")
endfunction


function! monster#completion#solargraph#solargraph_suggest#complete(context)
	if !executable(g:monster#completion#solargraph#complete_command)
		call monster#errmsg("No executable 'solargraph' command.")
		call monster#errmsg("Please install 'gem install solargraph'.")
		return
	endif
	if !exists('s:job')
		let args = ["solargraph", "server", "--port=".g:monster#completion#solargraph#http_port]
		let s:job = job_start(args)
		augroup MonsterSolargraph
			au!
			au VimLeave * call job_stop(s:job)
		augroup END
	endif
	try
" 		echo "monster.vim - start solargraph"
		let file = monster#make_tempfile(a:context.bufnr, "rb")
		let command = monster#completion#solargraph#solargraph_suggest#command(a:context, file)
		let result = system(command)
	finally
		call delete(file)
	endtry
	call monster#debug_log(
\		"[solargraph_suggest.vim] solargraph command : " . command . "\n"
\  	. "[solargraph_suggest.vim] solargraph result : \n" . result
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
