scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! monster#rcodetools#rct_complete#command(context, file)
	return printf("rct-complete --completion-class-info --dev --fork --line=%d --column=%d %s", a:context.line, a:context.complete_pos, a:file)
endfunction


function! monster#rcodetools#rct_complete#check()
	return executable("rct-complete")
endfunction


function! monster#rcodetools#rct_complete#complete(context)
	if !executable("rct-complete")
		call monster#errmsg("No executable 'rct-complete' command.")
		call monster#errmsg("Please install 'gem install rcodetools'.")
		return
	endif
	try
		echo "monster.vim - start rct-complete"
		let file = monster#make_tempfile(a:context.bufnr, "rb")
		let command = monster#rcodetools#rct_complete#command(a:context, file)
		let result = system(command)
	finally
		call delete(file)
	endtry
	if v:shell_error != 0
		call monster#errmsg(command)
		call monster#errmsg(result)
		echo "monster.vim - failed rct-complete"
		return []
	endif
	echo "monster.vim - finish rct-complete"
	call monster#debug_log(result)
	return monster#rcodetools#parse(result)
endfunction


function! monster#rcodetools#rct_complete#test()
	let start_time = reltime()
	let context = monster#current_context()
	try
		let result = monster#rcodetools#complete(context)
		return result
	finally
		echom "Complete time " . reltimestr(reltime(start_time))
	endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
