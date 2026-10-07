" ~/.vim/plugin/blameline.vim
" GitLens-style inline blame for the cursor line, drawn as Vim 9 virtual text
" after the line once the cursor rests (CursorHold, see 'updatetime').
" Toggle with :BlameLineToggle; disable by default with g:blameline_enabled = 0.

if exists('g:loaded_blameline') || v:version < 901 || !has('textprop')
  finish
endif
let g:loaded_blameline = 1
let g:blameline_enabled = get(g:, 'blameline_enabled', 1)

call prop_type_add('blameline', {'highlight': 'Comment'})

function! s:Clear() abort
  call prop_remove({'type': 'blameline', 'all': 1})
endfunction

function! s:Ago(time) abort
  let l:d = localtime() - a:time
  for [l:secs, l:unit] in [[31536000, 'year'], [2592000, 'month'], [604800, 'week'],
        \ [86400, 'day'], [3600, 'hour'], [60, 'minute']]
    if l:d >= l:secs
      let l:n = l:d / l:secs
      return l:n . ' ' . l:unit . (l:n > 1 ? 's' : '') . ' ago'
    endif
  endfor
  return 'just now'
endfunction

function! s:Show() abort
  call s:Clear()
  let l:file = expand('%:p')
  if !g:blameline_enabled || &buftype !=# '' || !filereadable(l:file)
    return
  endif
  " --contents - blames the buffer as it is, so line numbers stay right while editing
  let l:out = systemlist('git -C ' . shellescape(fnamemodify(l:file, ':h'))
        \ . ' blame --porcelain --contents - -L ' . line('.') . ',+1 -- '
        \ . shellescape(l:file), getline(1, '$'))
  if v:shell_error || empty(l:out)
    return
  endif
  if l:out[0] =~# '^0\{40} '
    let l:text = 'You • Uncommitted changes'
  else
    let l:info = {}
    for l:l in l:out[1:]
      let l:m = matchlist(l:l, '^\(author\|author-time\|summary\) \(.*\)$')
      if !empty(l:m)
        let l:info[l:m[1]] = l:m[2]
      endif
    endfor
    let l:text = get(l:info, 'author', '?') . ', '
          \ . s:Ago(str2nr(get(l:info, 'author-time', '0'))) . ' • '
          \ . get(l:info, 'summary', '')
  endif
  call prop_add(line('.'), 0, {'type': 'blameline', 'text': '    ' . l:text,
        \ 'text_align': 'after'})
endfunction

function! s:Toggle() abort
  let g:blameline_enabled = !g:blameline_enabled
  if g:blameline_enabled | call s:Show() | else | call s:Clear() | endif
endfunction

command! BlameLineToggle call s:Toggle()

augroup blameline
  autocmd!
  autocmd CursorHold * call s:Show()
  autocmd CursorMoved,InsertEnter,BufLeave * call s:Clear()
augroup END
