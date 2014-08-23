scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Group  = s:V.import("Reunions.Task.Group")
	let s:Timer  = s:V.import("Reunions.Task.Timer")
	let s:CursorHold = s:V.import("Reunions.Task.CursorHold")
	let s:global = s:Group.make()
endfunction


function! s:_vital_depends()
	return [
\		"Reunions.Task.Group",
\		"Reunions.Task.Timer",
\		"Reunions.Task.CursorHold",
\	]
endfunction


function! s:update()
	return s:global.update()
endfunction


function! s:register(...)
	return call(s:global.register, a:000, s:global)
endfunction


function! s:kill(...)
	return call(s:global.kill, a:000, s:global)
endfunction


" function! s:kill_all(...)
" 	return call(s:global.kill_all, a:000, s:global)
" endfunction


function! s:make_group()
	return s:Group.make()
endfunction


function! s:make_timer(...)
	return call(s:Timer.make, a:000, s:global)
endfunction


function! s:make_cursorhold(...)
	return call(s:CursorHold.make, a:000, s:global)
endfunction


function! s:log()
	return s:global.log()
endfunction


function! s:size()
	return s:global.size()
endfunction


function! s:debug()
	return s:global
endfunction




let &cpo = s:save_cpo
unlet s:save_cpo
