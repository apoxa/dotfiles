Set-PSReadlineOption -EditMode vi
Set-PSReadLineKeyHandler -Chord ctrl+w -Function BackwardDeleteWord

# fzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion
