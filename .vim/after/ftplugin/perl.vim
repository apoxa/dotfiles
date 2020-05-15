command! -range=% -nargs=* Tidy <line1>,<line2>!perltidy
function! DoTidy()
    let l = line(".")
    let c = col(".")
    :Tidy
    call cursor(l,c)
endfunction

nmap _ :call DoTidy()<CR>
vmap _ :Tidy()<CR>
PerlLocalLibPath
