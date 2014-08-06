scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! monster#rcodetools#rct_complete#complete(context)
	if !executable("rct-complete")
		call monster#errmsg("No executable 'rct-complete' command.")
		call monster#errmsg("Please install 'gem install rcodetools'.")
		return
	endif
	let command = printf("rct-complete --completion-class-info --dev --fork --line=%d --column=%d %s", a:context.line, a:context.col, a:context.file)
	let result = system(command)
	if v:shell_error != 0
		call monster#errmsg(command)
		call monster#errmsg(result)
		return result
	endif
" 	call monster#debug_log(result)
	return monster#rcodetools#parse(result)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
