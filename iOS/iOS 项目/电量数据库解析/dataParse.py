#!/usr/local/bin/python3.7
import os
import sys
import json
import time
import sqlite3

# 将目标文件csv文件, 解析为对应的echarts 需要的json格式
# ID,timestamp,IsCharging,Level
 

#  0. 打开数据库
path = ''
if os.path.exists('./destination.PLSQL'):
    path = './destination.PLSQL'
else:
    path = '../destination.PLSQL'

connect = sqlite3.connect(path)
cursor = connect.cursor()
cursor.execute('select * from PLBatteryAgent_EventBackward_BatteryUI')

#  1. 解析系统电量数据 
line_list = []
for row in cursor:
    line_list.append(row) 
 
data_time = []
value = []
title = ''
for line in line_list:
    # 处理时间
    timestamp = round(float(line[1]))
    touple = time.localtime(timestamp)
    str_time = '%02d-%02d %02d:%02d' % (touple.tm_mon,touple.tm_mday, touple.tm_hour,touple.tm_min)
    data_time.append(str_time) 
    # 处理耗电量数据
    value.append(int(line[-1]))

option = {}
option['yAxis'] = {"type":'value','name':'电量'}
option['xAxis'] = {'type':'category','data':data_time,'name':'时间'}
option['series'] = [{'data':value,"name":"电量",'type':'line','smooth':True,'color':'#F19C38'}]
option['title'] = {'text':'电池电量百分比 - 统计次数: %d次,  起止日期: %s 至 %s' % (len(data_time), data_time[0].split(' ')[0],data_time[-1].split(' ')[0]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                   } 
option['tooltip'] = {'trigger': 'axis'}
option['dataZoom'] = [{'type':'inside'}]
option['textStyle'] = {'color':'#ccc'}
desPath = os.path.join(os.path.dirname(__file__),'PLBatteryAgent_EventBackward_BatteryUI.json')
desJson = json.dumps(option)
f = open(desPath,'w+')
f.write(desJson)
f.close() 
 

#  2. 解析PLApplicationAgent_EventForward_Application, app在什么时间以什么状态运行
cursor.execute('select * from PLApplicationAgent_EventForward_Application where Identifier like "%movesx"')

timeData = []
stateData = []
for row in cursor:
    touple = time.localtime(round(row[1]))
    str_time = '%02d-%02d %02d:%02d:%02d' % (touple.tm_mon,touple.tm_mday, touple.tm_hour,touple.tm_min,touple.tm_sec)
    timeData.append(str_time)
    stateData.append(row[-2])

option_state = {}
option_state['title'] = {'text':'状态变化 - 统计次数: %d次,  起止日期: %s 至 %s' % (len(timeData), timeData[0].split(' ')[0],timeData[-1].split(' ')[0]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                   } 
option_state['yAxis'] = {'type':'value','axisPointer':{'triggerTooltip':True},'name':'状态','splieNumber':4,'axisLine':{'show':True},'axisTick':{'show':True},'offset':10}
option_state['xAxis'] = {'data':timeData,'name':'时间'}
option_state['series'] = [{'type':'line','name':'状态信息','data':stateData,'smooth':True,}]
option_state['dataZoom'] = [{'type':'inside'}]
option_state['textStyle'] = {'color':'#ccc'}
option_state['tooltip'] = {'trigger': 'axis'}
desPath = os.path.dirname(__file__) + '/PLApplicationAgent_EventForward_Application.json'
f = open(desPath,'w')
f.write(json.dumps(option_state))
f.close()


# 3. PLAppTimeService_Aggregate_AppRunTime 运行时间统计, 每小时一条数据
cursor.execute('select * from PLAppTimeService_Aggregate_AppRunTime where BundleID like "%movesx"')
backgroundTimeData = []
screenTimeData = [] 
timeData = []
for row in cursor:
    backgroundTimeData.append(round(row[-4]))
    screenTimeData.append(round(row[-1]))
    touple = time.localtime(round(row[1]))
    str_time = '%02d-%02d %02d:%02d:%02d' % (touple.tm_mon,touple.tm_mday, touple.tm_hour,touple.tm_min,touple.tm_sec)
    timeData.append(str_time)


option_time = {}
option_time['title'] = {'text':'运行时间统计 - 统计次数: %d次,  起止日期: %s 至 %s' % (len(backgroundTimeData), timeData[0].split(' ')[0],timeData[-1].split(' ')[0]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                   } 
option_time['yAxis'] = {'type':'value','name':'时间(/s)'}
option_time['xAxis'] = {'data':timeData,'name':'时间'}
option_time['series'] = [{'type':'line','name':'后台时间','data':backgroundTimeData,'smooth':False,},
                          {'type':'line','name':'前台时间','data':screenTimeData,'smooth':True,}]
option_time['dataZoom'] = [{'type':'inside'}]
option_time['textStyle'] = {'color':'#ccc'}
option_time['tooltip'] = {'trigger': 'axis'}
option_time['legend'] = {'left':'42%','bottom':'10px','width':'200px','textStyle':{'color':'#aaa'}}
desPath = os.path.dirname(__file__) + '/PLAppTimeService_Aggregate_AppRunTime.json'
f = open(desPath,'w')
f.write(json.dumps(option_time))
f.close()


# 4. 目标app详细电量使用情况  //36481
cursor.execute('select * from PLAccountingOperator_Aggregate_RootNodeEnergy where NodeID is 34012 order by timestamp asc')
timeData = []
timeSet = []
series = {}
types = set()
for row in cursor:
    types.add(row[-1])

for k in types:
    series[k] = []

lastTimeStamp = 0
cursor.execute('select * from PLAccountingOperator_Aggregate_RootNodeEnergy where NodeID is 34012 order by timestamp asc')
for row in cursor: 
    timestamp = int(row[1])
    if lastTimeStamp != 0 and lastTimeStamp != timestamp:
        # 检查对应的数据, 没有的话就补0
        for key in types:
            if len(series[key]) != len(timeData):
                series[key].append(0)

    if timestamp not in timeSet:
       touple = time.localtime(timestamp)
       str_time = '%02d-%02d %02d:%02d:%02d' % (touple.tm_mon,touple.tm_mday, touple.tm_hour,touple.tm_min,touple.tm_sec)
       timeData.append(str_time)
       timeSet.append(timestamp)
       lastTimeStamp = timestamp
    rootNodeID = row[-1]
    if rootNodeID not in series:
        series[rootNodeID] = []
    series[rootNodeID].append(int(row[3]))

# 最后再补充检查一遍
for key in types:
    if len(series[key]) != len(timeData):
        series[key].append(0)

keys = sorted(series.keys())

cursor.execute('select * from PLAccountingOperator_EventNone_Nodes where ID < 100 order by ID asc')
names = {}
for row in cursor:
    names[row[0]] = row[-1]
 
options_detial = {}
options_detial['yAxis'] = {'type':'value','name':'耗电量'}
options_detial['textStyle'] = {'color':'#ccc'}
options_detial['xAxis'] = {'data':timeData,'name':'时间'}
options_detial['title'] = {'text':'MoveX详细数据统计 - 统计次数: %d次,  起止日期: %s 至 %s' % (len(timeData), timeData[0].split(' ')[0],timeData[-1].split(' ')[0]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                   }
options_detial['series'] = []                   
for key in keys:
    name = names[key]
    options_detial['series'].append({'type':'line','name':name,'data':series[key],'smooth':True})
options_detial['dataZoom'] = [{'type':'inside'}]
options_detial['legend'] = {'bottom':'10px','textStyle':{'color':'#aaa'}}
options_detial['tooltip'] = {'trigger': 'axis'}
path = os.path.dirname(__file__) + '/PLAccountingOperator_Aggregate_RootNodeEnergy.json'
f = open(path,'w')
f.write(json.dumps(options_detial))
f.close()


#  7. 解析PLProcessNetworkAgent_EventPoint_Connection, 网络连接次数统计  
cursor.execute('select * from PLProcessNetworkAgent_EventPoint_Connection where ProcessName like "%Moves X" order by timestamp ASC')

timeData = []
stateData = []
# request times in ten minutes
times = 0 
baseTimestamp = 0

for row in cursor:
    timestamp = row[1] 
    touple = time.localtime(round(row[1]))
    str_time = '%02d-%02d-%02d %02d:%02d' % (touple.tm_year,touple.tm_mon,touple.tm_mday, touple.tm_hour,touple.tm_min)
    
    if baseTimestamp == 0:
        baseTimestamp = timestamp
        timeData.append(str_time)
    if timestamp - baseTimestamp > 600:
        baseTimestamp = timestamp # change base time
        timeData.append(str_time)
        stateData.append(times)
        times = 1
    if timestamp - baseTimestamp < 600:
        # in a time period
        times += 1 

# if times large than 1, must to append the left datas to  array
if times > 0:
    stateData.append(times)

option_state = {}
option_state['title'] = {'text':'每10分钟请求次数: 起止日期: %s 至 %s' % (timeData[0] ,timeData[-1]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                   } 
option_state['yAxis'] = {'type':'value','axisPointer':{'triggerTooltip':True},'name':'次数','splieNumber':4,'axisLine':{'show':True},'axisTick':{'show':True},'offset':10}
option_state['xAxis'] = {'data':timeData,'name':'时间'}
option_state['series'] = [{'type':'line','name':'每10分钟请求次数','data':stateData,'smooth':True,}]
option_state['dataZoom'] = [{'type':'inside'}]
option_state['textStyle'] = {'color':'#ccc'}
option_state['tooltip'] = {'trigger': 'axis'}
option_state['legend'] = {'bottom':'10px','textStyle':{'color':'#aaa'}}
desPath = os.path.dirname(__file__) + '/request_times.json'
f = open(desPath,'w')
f.write(json.dumps(option_state))
f.close()



# 8. LocationDesiredAccuracy & DistanceFilter 变化曲线  TestLocationBattery
cursor.execute('select * from PLLocationAgent_EventForward_ClientStatus where Client like "%movesx" order by timestamp ASC')
timeData = []
filterData = []
accuracyData = [] 
 
for row in cursor:
    timestamp = row[1] 
    touple = time.localtime(round(row[1]))
    str_time = '%02d-%02d-%02d %02d:%02d:%02d' % (touple.tm_year,touple.tm_mon,touple.tm_mday, touple.tm_hour,touple.tm_min, touple.tm_sec)
    type = row[-2]
    filter = row[-3]
    accuracy = row[-4]
    if filter == None:
        filter = -5
    if accuracy == None:
        accuracy = -5
    timeData.append(str_time+"-"+type) 
    # timeData.append(str_time) 
    filterData.append(filter)
    accuracyData.append(accuracy)

option_state = {}
option_state['title'] = {'text':'LocationDesiredAccuracy & DistanceFilter 变化曲线: %s 至 %s' % (timeData[0] ,timeData[-1]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                } 
option_state['yAxis'] = {'type':'value','axisPointer':{'triggerTooltip':True},'name':'次数','splieNumber':4,'axisLine':{'show':True},'axisTick':{'show':True},'offset':10}
option_state['xAxis'] = {'data':timeData,'name':'时间'}
option_state['series'] = [{'type':'line','name':'DistanceFilter','data':filterData,'smooth':True,},
                            {'type':'line','name':'LocationDesiredAccuracy','data':accuracyData,'smooth':True}]
option_state['dataZoom'] = [{'type':'inside'}]
option_state['textStyle'] = {'color':'#ccc'}
option_state['tooltip'] = {'trigger': 'axis'}
option_state['legend'] = {'bottom':'10px','textStyle':{'color':'#aaa'}}
desPath = os.path.dirname(__file__) + '/locationDesiredAccuracy.json'
f = open(desPath,'w')
f.write(json.dumps(option_state))
f.close()
 

# --------------------------------- separate line ---------------------------------------------
# 关闭数据库
connect.close()