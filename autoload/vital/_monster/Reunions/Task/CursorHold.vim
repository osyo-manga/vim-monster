scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:base = {
\	"__reunions_task_cursorhold" : {}
\}


function! s:base.__reunions_task_apply(...)
	let task = self.__reunions_task_cursorhold
	let now = str2float(reltimestr(reltime()))
	if (now - task.last_time) > task.interval_time
		return call(self.apply, a:000, self)
	endif
endfunction


function! s:base.reset()
	let self.__reunions_task_cursorhold.last_time = str2float(reltimestr(reltime()))
endfunction


function! s:make(task, time)
	if type(a:task) == type(function("tr"))
		return s:make({ "apply" : a:task }, a:time)
	endif
	let result = extend(deepcopy(s:base), a:task)
	let result.__reunions_task_cursorhold = {
\		"interval_time" : a:time,
\		"last_time" : str2float(reltimestr(reltime()))
\	}
	return result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
