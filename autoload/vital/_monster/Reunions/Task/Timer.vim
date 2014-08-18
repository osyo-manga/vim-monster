scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:base = {
\	"__reunions_task_timer" : {}
\}
function! s:base.__reunions_task_apply(...)
	let task = self.__reunions_task_timer
	let reltimef = str2float(reltimestr(reltime()))
	if (reltimef - task.last_time) > task.interval_time
		try
			return call(self.apply, a:000, self)
		finally
			let task.last_time = reltimef
		endtry
	endif
endfunction


function! s:make(task, time)
	if type(a:task) == type(function("tr"))
		return s:make({ "apply" : a:task }, a:time)
	endif
	let result = extend(deepcopy(s:base), a:task)
	let result.__reunions_task_timer = {
\		"interval_time" : a:time,
\		"last_time" : str2float(reltimestr(reltime()))
\	}
	return result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
