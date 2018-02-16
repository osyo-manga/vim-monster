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
		call monster#cache#add(a:context, monster#completion#rcodetools#parse(output))
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


function! monster#completion#rcodetools#async_rct_complete#complete(context)
	call monster#completion#rcodetools#async_rct_complete#cancel()
	if !executable("rct-complete")
		call monster#errmsg("No executable 'rct-complete' command.")
		call monster#errmsg("Please install 'gem install rcodetools'.")
		return []
	endif

	let tempfile = monster#make_tempfile(a:context.bufnr, "rb")
	let command = monster#completion#rcodetools#rct_complete#command(a:context, tempfile)
	let process = job_start(command, {
    \ 'close_cb': {ch -> [s:then(a:context, ch), delete(tempfile)]}
	\})

	call monster#debug_log(
\		"[async_rct_complete.vm] rct-complete command : " . command . "\n"
\	)

	let s:process = process

	return []
endfunction


function! monster#completion#rcodetools#async_rct_complete#is_alive_process()
	return !(exists("s:process") && s:process.is_exit())
endfunction


function! monster#completion#rcodetools#async_rct_complete#cancel()
	if !exists("s:process")
		return
	endif
	echo "monster.vim - cancel async completion"
	call s:process.kill(1)
	unlet s:process
endfunction


function! monster#completion#rcodetools#async_rct_complete#test()
	let start_time = reltime()
	let context = monster#context#get_current()
	let old_debug = g:monster#debug#enable
	let g:monster#debug#enable = 1
	call monster#debug#clear_log()
	try
		call monster#completion#rcodetools#async_rct_complete#complete(context)
		call s:process.wait()
		let result = monster#cache#get(context)
		return { "context" : context, "result" : result, "log" : monster#debug#log() }
	finally
		let g:monster#debug#enable = old_debug
		echom "Complete time " . reltimestr(reltime(start_time))
	endtry
endfunction



let s:count = 0
augroup monster-completion-rcodetools-async_rct_complete
	autocmd!
" 	autocmd CursorHoldI * echo s:count | let s:count += 1
\|	call feedkeys(mode() =~# '[iR]' ? "\<C-r>\<Esc>" : "g\<Esc>", 'n')

" 	autocmd InsertCharPre * call feedkeys("\<Plug>(monster-exit-completion-mode-hoge)")

	autocmd InsertCharPre,CursorHoldI * call s:Reunions.update_in_cursorhold(1)
	autocmd InsertEnter,InsertLeave * call monster#completion#rcodetools#async_rct_complete#cancel()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
