"------------------------------------------------------------------------------
"  <从教务处获取课程表并显示>
"------------------------------------------------------------------------------
let s:syllabusPythonFilePath = expand('<sfile>:p:h')
func! GetClassList(index)
	new 课程表 
	setlocal buftype=nowrite
	setlocal nobuflisted
	set nowrap
    map <buffer> q :q<cr>
    " n,j下一周; p,k上一周
    map <buffer> n :call <SID>NextWeek()<cr>
    map <buffer> p :call <SID>PrevWeek()<cr>
    map <buffer> k :call <SID>PrevWeek()<cr>
    map <buffer> j :call <SID>NextWeek()<cr>
    let s:currentPerson = a:index
    call s:DrawTable()
endf

"强制从网页上获取刷新数据
func! RGetClassList(index)
py3<< eof
import sys
import os
sys.path.insert(0,vim.eval('s:syllabusPythonFilePath'))
import syllabusBaseSupport
syllabusBaseSupport.setData(vim.eval('a:index'))
syllabusBaseSupport.getClassListFromWeb()
eof
set noma
endf

func! <SID>NextWeek()
    let s:currentWeek += 1
    call s:DrawTable()
endf

func! <SID>PrevWeek()
    let s:currentWeek -= 1
    call s:DrawTable()
endf

func! s:DrawTable()
set ma
py3<< eof
import vim
sys.path.insert(0,vim.eval('s:syllabusPythonFilePath'))
import syllabusBaseSupport
eof
if !exists('s:currentWeek')
    let s:currentWeek = py3eval('syllabusBaseSupport.parseThisWeek()')
endif
py3<< eof
syllabusBaseSupport.setData(vim.eval('s:currentPerson'))
syllabusBaseSupport.showClassList(int(vim.eval('s:currentWeek')))
eof
set noma
endf
