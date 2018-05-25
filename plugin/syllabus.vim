"------------------------------------------------------------------------------
"  <从教务处获取课程表并显示>
"------------------------------------------------------------------------------
let s:syllabusPythonFilePath = expand('<sfile>:p:h')
func! GetClassList(index)
	new 课程表 
	setlocal buftype=nowrite
	setlocal nobuflisted
	set nowrap
	set ma
py3<< eof
import vim
sys.path.append(vim.eval('s:syllabusPythonFilePath'))
import syllabusBaseSupport
syllabusBaseSupport.setData(vim.eval('a:index'))
syllabusBaseSupport.showClassList()
eof
set noma
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

"强制从网页上获取刷新数据
func! NextGetClassList(index)
	new 课程表 
	setlocal buftype=nowrite
	setlocal nobuflisted
	set nowrap
	set ma
py3<< eof
import vim
sys.path.insert(0,vim.eval('s:syllabusPythonFilePath'))
import syllabusBaseSupport
syllabusBaseSupport.setData(vim.eval('a:index'))
syllabusBaseSupport.showClassList(syllabusBaseSupport.parseThisWeek()+1)
eof
set noma
endf
