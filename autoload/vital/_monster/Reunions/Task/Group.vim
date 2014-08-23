scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:base = {
\	"variables" : {
\		"tasks" : [],
\		"log" : "",
\	}
\}


function! s:base.register(task)
	if type(a:task) == type(function("tr"))
		return self.register({ "apply" : a:task })
	endif
	call add(self.variables.tasks, a:task)
	return a:task
endfunction


function! s:base.log()
	return self.variables.log
endfunction


function! s:base.clear_log()
	let self.variables.log = ""
endfunction


function! s:base.add_log(mes)
	let self.variables.log = self.variables.log
\		. "\n\n------------------------------\n"
\		. a:mes . "\n"
\		. 'Caught "' . v:exception . "\n"
\		. '" in ' . v:throwpoint . ""
endfunction


function! s:base.list()
	return self.variables.tasks
endfunction


function! s:base.kill(task)
	for i in range(len(self.variables.tasks))
		if a:task is self.variables.tasks[i]
			call remove(self.variables.tasks, i)
			return 0
		endif
	endfor
	return -1
endfunction


" function! s:base.kill_all()
" 	call map(self.list(), "self.kill(v:val)")
" endfunction


function! s:base.update()
	let except = 0
	for task in self.variables.tasks
		try
			if has_key(task, "__reunions_task_apply")
				call task.__reunions_task_apply(self)
			else
				call task.apply(self)
			endif
		catch
			call self.add_log("Except in task_group.update")
			let except = 1
		endtry
	endfor
	if except
		echohl "Error"
		echo "vital-reunions : exception in update()."
		echohl "NONE"
	endif
endfunction


function! s:_repeat_cursorhold()
	call feedkeys(mode() =~# '[iR]' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
endfunction


function! s:base.update_in_cursorhold(...)
	if get(a:, 1, 0) && self.size()
		call s:_repeat_cursorhold()
	endif
	call self.update()
endfunction


function! s:base.size()
	return len(self.variables.tasks)
endfunction


function! s:base.apply(...)
	call self.update()
endfunction


function! s:make()
	return deepcopy(s:base)
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
