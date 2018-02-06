scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:monster#completion#solargraph#http_port = get(g:, "monster#completion#solargraph#http_port", 7657)

let g:monster#completion#solargraph#backend = get(g:, "monster#completion#solargraph#backend", "solargraph_suggest")

let g:monster#completion#solargraph#complete_command = get(g:, "monster#completion#solargraph#complete_command", "solargraph")

function! s:item(value)
	return {
\		"word" : a:value.insert,
\		"menu" : a:value.kind,
\	}
endfunction


function! monster#completion#solargraph#parse(result)
	let g:hoge = a:result
	return map(json_decode(a:result).suggestions, "s:item(v:val)")
endfunction


function! monster#completion#solargraph#complete(context)
	return monster#completion#solargraph#{g:monster#completion#solargraph#backend}#complete(a:context)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
