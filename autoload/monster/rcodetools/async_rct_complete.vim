scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

call vital#of("vital").unload()
let s:Reunions = vital#of("vital").import("Reunions")


function! monster#rcodetools#async_rct_complete#complete(context)
	return []
	if !executable("rct-complete")
		call monster#errmsg("No executable 'rct-complete' command.")
		call monster#errmsg("Please install 'gem install rcodetools'.")
		return
	endif

	let file = monster#make_tempfile(a:context.bufnr, "rb")
	let command = monster#rcodetools#rct_complete#command(a:context, file)
	let process = s:Reunions.process(command)
	let process.file = file
	let process.context = a:context
	function! process.then(result, ...)
		call monster#debug_log(a:result)
		call delete(self.file)
		call monster#add_cache(self.context, result)
		echo "finish"
" 		call monster#start_complete()
	endfunction
	let s:process = process
	echo "start"

	return []
endfunction


function! monster#rcodetools#async_rct_complete#cancel()
	
endfunction


function! s:finish()
	if exists("s:process") && !s:process.is_exit()
		echom "exit"
		call delete(s:process.file)
		call s:process.kill()
		unlet s:process
	endif
endfunction


let s:count = 0
augroup monster-rcodetools-async_rct_complete
	autocmd!
" 	autocmd CursorHoldI * echo s:count | let s:count += 1
" 	autocmd CursorHoldI,InsertCharPre * call s:Reunions.update_in_cursorhold(1)
" 	autocmd InsertLeave * call s:finish()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
