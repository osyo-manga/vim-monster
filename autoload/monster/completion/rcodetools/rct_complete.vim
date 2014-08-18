scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! monster#completion#rcodetools#rct_complete#command(context, file)
	return printf("rct-complete --completion-class-info --dev --fork --line=%d --column=%d %s", a:context.line, a:context.complete_pos, a:file)
endfunction


function! monster#completion#rcodetools#rct_complete#check()
	return executable("rct-complete")
endfunction


function! monster#completion#rcodetools#rct_complete#complete(context)
	if !executable("rct-complete")
		call monster#errmsg("No executable 'rct-complete' command.")
		call monster#errmsg("Please install 'gem install rcodetools'.")
		return
	endif
	try
" 		echo "monster.vim - start rct-complete"
		let file = monster#make_tempfile(a:context.bufnr, "rb")
		let command = monster#completion#rcodetools#rct_complete#command(a:context, file)
		let result = system(command)
	finally
		call delete(file)
	endtry
	call monster#debug_log(
\		"[rct_complete.vm] rct-complete command : " . command . "\n"
\	  . "[rct_complete.vm] rct-complete result : \n" . result
\	)
	if v:shell_error != 0
" 		call monster#errmsg(command)
" 		call monster#errmsg(result)
" 		echo "monster.vim - failed rct-complete"
		return []
	endif
	echo "monster.vim - finish rct-complete"
	return monster#completion#rcodetools#parse(result)
endfunction


function! monster#completion#rcodetools#rct_complete#test()
	let start_time = reltime()
	let context = monster#context#get_current()
	try
		let result = monster#completion#rcodetools#rct_complete#complete(context)
		return { "context" : context, "result" : result }
	finally
		echom "Complete time " . reltimestr(reltime(start_time))
	endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
