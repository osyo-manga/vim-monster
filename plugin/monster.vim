scriptencoding utf-8
if exists('g:loaded_monster')
  finish
endif
let g:loaded_monster = 1

let s:save_cpo = &cpo
set cpo&vim

command! -bar MonsterDebugLog echo monster#get_debug_log()

let &cpo = s:save_cpo
unlet s:save_cpo
