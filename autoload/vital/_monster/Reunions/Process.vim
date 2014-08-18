scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Base = s:V.import("Reunions.Process.Base")
	let s:Interactive = s:V.import("Reunions.Process.Interactive")
endfunction


function! s:_vital_depends()
	return [
\		"Reunions.Process.Base",
\		"Reunions.Process.Interactive",
\	]
endfunction


function! s:as_task(process)
" 	let process = copy(a:process)
	let process = a:process
	if has_key(process, "apply")
		return process
	endif
	function! process.apply(parent, ...)
		call self.update()
	endfunction
	return process
endfunction


function! s:as_autokill_task(process)
	let process = a:process
	if has_key(process, "apply")
		return process
	endif
	function! process.apply(parent, ...)
		if self.status() == "none"
			return
		endif
		call self.update()
		if self.is_killed()
			call a:parent.kill(self)
		endif
	endfunction
	return process
endfunction


function! s:make(...)
	return call(s:Base.make, a:000, s:Base)
endfunction


function! s:make_interactive(...)
	return call(s:Interactive.make, a:000, s:Interactive)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
