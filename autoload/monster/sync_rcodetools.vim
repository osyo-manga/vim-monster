scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:parse(text)
	let parsed = split(a:text, '\t')
	return {
\		"word" : get(parsed, 0, ""),
\		"menu" : get(parsed, 1, ""),
\		"info" : a:text,
\	}
endfunction


function! monster#sync_rcodetools#parse(result)
	return map(split(a:result, '[\r\n]'), "s:parse(v:val)")
endfunction


function! monster#sync_rcodetools#complete(context)
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
	return map(split(result, '[\r\n]'), "s:parse(v:val)")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
