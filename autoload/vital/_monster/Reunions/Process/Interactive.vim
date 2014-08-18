scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Base  = s:V.import("Reunions.Process.Base")
	let s:Dummy = s:Base.make("")
endfunction


function! s:_vital_depends()
	return [
\		"Reunions.Process.Base",
\	]
endfunction


let s:base = {
\	"__reunions_process_interactive" : {}
\}


" function! s:base.start(input)
" 	if !self.is_exit()
" 		return -1
" 	endif
" 	let vimproc = self.__reunions_process_base.vimproc
" 	call vimproc.stdin.write(a:input)
" 	let self.__reunions_process_base.result = ""
" 	let self.__reunions_process_base.status = "processing"
" endfunction


function! s:base.input(text, ...)
	if !self.is_exit()
		return -1
	endif
	let vimproc = self.__reunions_process_base.vimproc
	call vimproc.stdin.write(a:text . "\n")
	let self.__reunions_process_base.result = ""
	let self.__reunions_process_base.status = "processing"
	let self.__reunions_process_interactive.endpat
\		= get(a:, 1, self.__reunions_process_interactive.endpat)
endfunction


function! s:base.is_exit()
	return call(s:Dummy.is_exit, [], self)
\	|| self.__reunions_process_base.result =~ self.__reunions_process_interactive.endpat
endfunction


function! s:base.status()
	return self.__reunions_process_base.result =~ self.__reunions_process_interactive.endpat && !call(s:Dummy.is_exit, [], self)
\		? "waiting"
\		: call(s:Dummy.status, a:000, self)
endfunction


function! s:base.kill(...)
	if self.__reunions_process_base.result =~ self.__reunions_process_interactive.endpat && !get(a:, 1, 0)
		if has_key(self, "_then")
			call self._then(self.__reunions_process_base.result, self.as_result())
		elseif has_key(self, "then")
			call self.then(self.__reunions_process_base.result, self.as_result())
		endif
		return
	endif
	return call(s:Dummy.kill, a:000, self)
endfunction


function! s:make(command, endpat)
	let process = s:Base.make(a:command)
" 	call process.start()
	call extend(process, deepcopy(s:base))
	let process.__reunions_process_interactive.endpat = a:endpat
	return process
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
