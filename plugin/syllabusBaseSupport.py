import requests
from pyquery import PyQuery as pq
import prettytable as pt
import time,datetime
import sys,os
import vim
data = {}
filePath=''
def setData(index):
	global data
	global filePath
	data = {
		'stuid':vim.eval('g:stuid[{}]'.format(index)),
		'pwd':vim.eval('g:stupwd[{}]'.format(index))
	}
	filePath=vim.eval('s:syllabusPythonFilePath')+'/data/'+data['stuid']+'.txt'

def parseThisWeek():
	beginDay = vim.eval('g:schoolTermStart')
	today = time.strftime('%Y-%m-%d',time.localtime(time.time()))
	beginDay=time.strptime(beginDay,"%Y-%m-%d")
	today=time.strptime(today,"%Y-%m-%d")
	beginDay=datetime.datetime(beginDay[0],beginDay[1],beginDay[2])
	today=datetime.datetime(today[0],today[1],today[2])
	days = int(str(today-beginDay).split(' ')[0])
	thisWeek=int(days/7)+1
	return thisWeek


def getClassListFromFile():
	with open(filePath,'r') as file:
		return eval(file.readline())


def getClassListFromWeb():
	response = requests.post('http://222.194.15.1:7777/pls/wwwbks/bks_login2.login',data=data,allow_redirects=False)
	cookie = response.headers['Set-Cookie']
	head={'Cookie':cookie}
	response = requests.get('http://222.194.15.1:7777/pls/wwwbks/xk.CourseView',headers=head)
	nodeList = []
	doc = pq(response.text)
	rs = doc('tr')
	for r in rs.items():
		if r.children().length==9:
			nodeList.append(r)
	classList=[]
	for oneClass in nodeList:
		name=oneClass.children().eq(0).text()[0:4]
		position=oneClass.children().eq(6).text()
		time=oneClass.children().eq(7).text().split('-')
		weeks=oneClass.children().eq(8).text()[:-2].split('-')
		oneClassData={
			'name':name,
			'position':position,
			'time':time,
			'weeks':weeks,
		}
		classList.append(oneClassData)
	with open(filePath,'w') as file:
		file.write(str(classList))
	print('获取成功')
	return classList


def getClassList():
	classList=[]
	if os.path.exists(filePath):
		classList=getClassListFromFile()
	else:
		classList=getClassListFromWeb()
	return classList


def showClassList(thisWeek=parseThisWeek()):
	classList = getClassList()
	# 列表推导式初始化列表
	tableClass=[['*****' for i in range(5)] for i in range(7)]
	for one in classList:
		start=one['weeks'][0]
		end=one['weeks'][1]
		if thisWeek<=int(end)and thisWeek>=int(start):
			tableClass[int(one['time'][0])-1][int(one['time'][1])-1]=one['name']+one['position']
	tb = pt.PrettyTable()
	tb.field_names = ["星期一","星期二","星期三","星期四","星期五","星期六","星期日"]
	for i in range(5):
		tb.add_row([tableClass[j][i] for j in range(7)])
	cb = vim.current.buffer
	cw = vim.current.window
	rs = str(tb).split('\n')
	cw.height=len(rs)
	cb[:]=rs
