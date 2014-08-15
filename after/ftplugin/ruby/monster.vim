
" if !monster#rcodetools#rct_complete#check()
" 	finish
" endif

setlocal omnifunc=monster#omnifunc


" augroup monster-ftplugin-ruby
" 	autocmd! * <buffer>
" 	autocmd InsertLeave <buffer> call monster#rcodetools#async_rct_complete#cancel()
" augroup END

