scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:then(context, channel)
	let output = ""
	while ch_status(a:channel, {"part": "out"}) == "buffered"
		let output .= substitute(ch_read(a:channel), "\xff", "", "g")
	endwhile
	if output == ""
		return
	endif
	try
		call monster#cache#add(a:context, monster#completion#solargraph#parse(output))
	catch
		return
	endtry
	echo "monster.vim - finish async completion"
	if monster#context#get_current().cache_keyword !=# a:context.cache_keyword
		return
	endif
	if monster#start_complete(0, a:context) == 0
		if &completeopt !~ '\(noinsert\|noselect\)'
			call feedkeys("\<C-p>")
		endif
	endif
endfunction


function! monster#completion#solargraph#async_solargraph_suggest#complete(context)
	call monster#completion#solargraph#async_solargraph_suggest#cancel()
	if !executable("solargraph")
		call monster#errmsg("No executable 'solargraph' command.")
		call monster#errmsg("Please install 'gem install solargraph'.")
		return []
	endif
	if !exists('s:job') || job_status(s:job) != "run"
		let command = "solargraph" . (has('win32') ? ".bat" : "")
		let args = [command, "server", "--port=".g:monster#completion#solargraph#http_port]
		let s:job = job_start(args)
		augroup MonsterSolargraph
			au!
			au VimLeave * call job_stop(s:job)
		augroup END
	endif

	let tempfile = monster#make_tempfile(a:context.bufnr, "rb")
	let command = monster#completion#solargraph#solargraph_suggest#command(a:context, tempfile)
	let process = job_start(command, {
    \ 'close_cb': {ch -> [s:then(a:context, ch), delete(tempfile)]}
	\})

	call monster#debug_log(
\		"[async_solargraph_suggest.vim] solargraph command : " . command . "\n"
\	)

	let s:process = process
	
	return []
endfunction


function! monster#completion#solargraph#async_solargraph_suggest#is_alive_process()
	return !(exists("s:process") && job_status(s:process, "run"))
endfunction


function! monster#completion#solargraph#async_solargraph_suggest#cancel()
	if !exists("s:process")
		return
	endif
	echo "monster.vim - cancel async completion"
	call job_stop(s:process, 'kill')
	unlet s:process
endfunction


function! monster#completion#solargraph#async_solargraph_suggest#test()
	let start_time = reltime()
	let context = monster#context#get_current()
	let old_debug = g:monster#debug#enable
	let g:monster#debug#enable = 1
	call monster#debug#clear_log()
	try
		call monster#completion#solargraph#async_solargraph_suggest#complete(context)
		while job_status(s:process) == "run"
			sleep 100m
		endwhile
		let result = monster#cache#get(context)
		return { "context" : context, "result" : result, "log" : monster#debug#log() }
	finally
		let g:monster#debug#enable = old_debug
		echom "Complete time " . reltimestr(reltime(start_time))
	endtry
endfunction


augroup monster-completion-solargraph-async_solargraph_suggest
	autocmd!
	autocmd InsertEnter,InsertLeave * call monster#completion#solargraph#async_solargraph_suggest#cancel()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
