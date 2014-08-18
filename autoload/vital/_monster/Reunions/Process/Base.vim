scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:base = {
\	"__reunions_process_base" : {
\		"callback" : {},
\		"result" : "",
\		"status" : "none"
\	}
\}


function! s:base.start(...)
	let args = get(a:, 1, "")
	let self.__reunions_process_base.status = "processing"
	let self.__reunions_process_base.result = ""
	let self.__reunions_process_base.vimproc
\		= vimproc#pgroup_open(self.__reunions_process_base.command . ' ' . args)
endfunction


function! s:base.update()
	if self.is_exit()
		return
	endif
	try
		let vimproc = self.__reunions_process_base.vimproc
		let var = self.__reunions_process_base
		if !vimproc.stdout.eof
			let var.result .= vimproc.stdout.read()
		endif

		if !vimproc.stderr.eof
			let var.result .= vimproc.stderr.read()
		endif
		let var.result = substitute(var.result, "\r\n", "\n", "g")
	finally
		if self.is_exit()
			call self.kill()
		endif
	endtry
endfunction


function! s:base.as_result()
	return {
\		"status" : self.status(),
\		"body"   : self.__reunions_process_base.result,
\	}
endfunction


function! s:base.is_exit()
	if !has_key(self.__reunions_process_base, "vimproc")
		return 1
	endif
	let vimproc = self.__reunions_process_base.vimproc
	return vimproc.stdout.eof && vimproc.stderr.eof
endfunctio


function! s:base.kill(...)
	if !(self.is_exit() || get(a:, 1, 0))
		return -1
	endif
	if !exists("self.__reunions_process_base.vimproc")
		return 0
	endif

	let vimproc = self.__reunions_process_base.vimproc
	if self.is_exit()
		let self.__reunions_process_base.status =
\			(get(vimproc, "status", 0) ? "failure" : "success")
	else
		let self.__reunions_process_base.status = "kill"
	endif

	if has_key(self, "_then")
		call self._then(self.__reunions_process_base.result, self.as_result())
	elseif has_key(self, "then")
		call self.then(self.__reunions_process_base.result, self.as_result())
	endif

	call vimproc.stdout.close()
	call vimproc.stderr.close()
	call vimproc.kill(9)
	call vimproc.waitpid()

	unlet self.__reunions_process_base.vimproc
endfunction


function! s:base.kill_force()
	return self.kill(1)
endfunction


function! s:base.is_killed()
	return self.status() == "success"
\		|| self.status() == "failure"
\		|| self.status() == "kill"
endfunction


function! s:base.status()
	return self.__reunions_process_base.status
endfunction


function! s:base.wait_for(time)
	let time = a:time
	let start_time = reltime()
	while !self.is_exit()
		if time > 0.0 && str2float(reltimestr(reltime(start_time))) > time
			return "timeout"
		endif
		call self.update()
	endwhile
	if self.is_exit()
		return "finish"
	endif
	return "processing"
endfunction


function! s:base.wait()
	return self.wait_for(0)
endfunction


function! s:base.get()
	call self.wait()
	return self.__reunions_process_base.result
endfunction


" function! s:base.as_task()
" 	let process = copy(self)
" 	if has_key(process, "apply")
" 		return process
" 	endif
" 	function! process.apply(parent, ...)
" 		call self.update()
" " 		if self.is_exit() || self.status() == "kill"
" " 			call a:parent.kill(self)
" " 		endif
" 	endfunction
" 	return process
" endfunction


function! s:make(cmd)
	let process = deepcopy(s:base)
	let process.__reunions_process_base.command = a:cmd
	let process.__reunions_process_base.callback.parent = process
	return process
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
