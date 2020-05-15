" Function to trim trailing white space
" Make your own mappings
function! myfunctions#StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfunction
