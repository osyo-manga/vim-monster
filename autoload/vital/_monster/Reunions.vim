scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Task = s:V.import("Reunions.Task")
	let s:Process = s:V.import("Reunions.Process")
	let s:Web = s:V.import("Reunions.Web")
endfunction


function! s:_vital_depends()
	return [
\		"Reunions.Task",
\		"Reunions.Process",
\		"Reunions.Web",
\	]
endfunction


function! s:update()
	call s:Task.update()
endfunction


function! s:_repeat_cursorhold()
	call feedkeys(mode() =~# '[iR]' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
endfunction


function! s:update_in_cursorhold(...)
	call s:update()
	if get(a:, 1, 0) && s:Task.size()
		call s:_repeat_cursorhold()
	endif
endfunction


function! s:register(...)
	return call(s:Task.register, a:000, s:Task)
endfunction


function! s:task_kill(task)
	return call(s:Task.kill, a:000, s:Task)
endfunction


function! s:task(...)
	return call(s:Task.register, a:000, s:Task)
endfunction


function! s:timer(...)
	return s:register(call(s:Task.make_timer, a:000, s:Task))
endfunction


function! s:cursorhold(...)
	return s:register(call(s:Task.make_cursorhold, a:000, s:Task))
endfunction


function! s:process(cmd)
" 	let parsed  = matchlist(a:cmd, '^\(\S\+\)\(.*\)')
" 	let command = parsed[1]
" 	let args    = parsed[2]
	let process = s:Process.make(a:cmd)
	let process = s:register(s:Process.as_autokill_task(process))
	call process.start()
	return process
endfunction


function! s:interactive(...)
	let process = call(s:Process.make_interactive, a:000, s:Process)
	let process = s:register(s:Process.as_autokill_task(process))
	call process.start()
	return process
endfunction


function! s:http_get(...)
	let process = call(s:Web.make_get_process, a:000, s:Web)
	let process = s:register(s:Process.as_autokill_task(process))
	call process.start()
	return process
endfunction


function! s:http_post(...)
	let process = call(s:Web.make_post_process, a:000, s:Web)
	let process = s:register(s:Process.as_autokill_task(process))
	call process.start()
	return process
endfunction


function! s:log()
	return s:Task.log()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
