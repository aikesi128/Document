
import os
import json
import time
import sqlite3

# 每天每小时的平均耗电量(average_hour) = 当天sum耗电量 / 当天运行时间
# 每周的平均每小时耗电量 = Sum(average_hour) / 7


# 计算每天每小时平均耗电量

# 1. 在运行时间的表里和详细耗电量表中, 以时间稍微晚点的时间戳为基准, 开始统计另外一张表中的数据
#  统计电量和运行时间

path = '../destination.PLSQL'
if not os.path.exists(path):
    path = './destination.PLSQL'
connect = sqlite3.connect(path)
cursor = connect.cursor()

# 找出运行时间的数据 每小时一条数据
cursor.execute('select * from PLAppTimeService_Aggregate_AppRunTime where BundleID like "%movesx" order by timestamp asc')
timeDataArray = []
for row in cursor:
    timeDataArray.append(row)

# 找出详细电量的数据
cursor.execute('select * from PLAccountingOperator_Aggregate_RootNodeEnergy where NodeID is 34012 and RootNodeID = 48 order by timestamp asc')
energyData = []
for row in cursor:
    energyData.append(row)

# 保证统计时间再同一时间区间内
baseStartTimestamp = 0
baseEndTimestamp = 0

sum_backgroundtime = 0
sum_screentime = 0
sum_energy = 0

dayset = set()

# 数据结果
runtimeDictionary = {}
energyDictionary = {}


# 确定结束节点
if timeDataArray[-1][1] < energyData[-1][1]:
    baseEndTimestamp = timeDataArray[-1][1]
else:
    baseEndTimestamp = energyData[-1][1]

if timeDataArray[0][1] <= energyData[0][1]:
    # 电量数据统计的较晚, 以电量的数据为基准开始统计运行时间数据
    baseStartTimestamp = energyData[0][1]
    for row in timeDataArray:
        if row[1] >= baseStartTimestamp and row[1] <= baseEndTimestamp:
            # 开始取数据
            touple = time.localtime(round(row[1]))
            timeString = '%d-%02d-%02d' % (touple.tm_year,touple.tm_mon,touple.tm_mday)
            if timeString not in dayset:
                dayset.add(timeString)
                runtimeDictionary[timeString] = []
            runtimeDictionary[timeString].append(row[-1] + row[-4])
            print(row[-4])
            print(row[-1])
            sum_screentime += row[-1]
            sum_backgroundtime += row[-4] 
    # 计算电量时间
    dayset = set()
    for row in energyData:
        if row[1] <= baseEndTimestamp:
             # 开始取数据
            touple = time.localtime(round(row[1]))
            timeString = '%d-%02d-%02d' % (touple.tm_year,touple.tm_mon,touple.tm_mday)
            if timeString not in dayset:
                dayset.add(timeString)
                energyDictionary[timeString] = []
            energyDictionary[timeString].append(round(row[-3] / 1000,2))
            sum_energy += row[-3]
    print('aikesi--电量统计数据开始较晚')        
else:
    # 运行时间数据统计的较晚, 以运行时间的数据为基准开始统计电量数据 
    baseStartTimestamp = timeDataArray[0][1]
    for row in energyData:
        if row[1] >= baseStartTimestamp and row[1] <= baseEndTimestamp:
            # 开始取数据
            touple = time.localtime(round(row[1]))
            timeString = '%d-%02d-%02d' % (touple.tm_year,touple.tm_mon,touple.tm_mday)
            if timeString not in dayset:
                dayset.add(timeString)
                energyDictionary[timeString] = []
            energyDictionary[timeString].append(round(row[-3] / 1000, 2))
            sum_energy += row[-3]
    dayset = set()
    # 计算运行时间
    for row in timeDataArray:
        if row[1] <= baseEndTimestamp:
             # 开始取数据
            touple = time.localtime(round(row[1]))
            timeString = '%d-%02d-%02d' % (touple.tm_year,touple.tm_mon,touple.tm_mday)
            if timeString not in dayset:
                dayset.add(timeString)
                runtimeDictionary[timeString] = []
            runtimeDictionary[timeString].append(row[-1] + row[-4])
            sum_screentime += row[-1]
            sum_backgroundtime += row[-4]
    print('aikesi--运行时间统计数据开始较晚')

print(sum_energy) # 2473427.0000119996
print(sum_screentime) #4562
print(sum_backgroundtime) #381959

'''
// 最终字典格式为:
// 运行时间
{'12-07':[23,456,777,5454],
'12-08':[23,456,777,5454],
'12-09':[23,456,777,5454],}

// 耗电量
{'12-07':[22,44,11,44],
'12-08':[23,22,43,22],
'12-09':[33,11,2,4],}
'''

test = [runtimeDictionary, energyDictionary]
string = json.dumps(test)
f = open('./test.json','w')
f.write(string)
f.close()

# 计算平均时间
series = []
for key, value in (energyDictionary.items()):
    if key in runtimeDictionary.keys():
        # 运行时间 小时
        totalTime = sum(runtimeDictionary[key]) / 3600 
        # 耗电量 mAh
        energyArr = energyDictionary[key]
        totalEnergy = sum(energyArr)
        average = totalEnergy / totalTime
        series.append(round(average,2))
        print(key,average)

nodeTime = '12-14' # 新v1版本时间节点
sum_beforNodeTime = 0
sum_afterNodeTime = 0
arraiveNode = 10000
jump = 0
for index,key in enumerate(sorted(runtimeDictionary.keys())):
    if key not in energyDictionary.keys():
        jump-=1
        continue
    x = index + jump
    if key == nodeTime:
        arraiveNode = x + 1
    if x < arraiveNode and arraiveNode != 10000:
        sum_beforNodeTime += series[x]
    else:
        sum_afterNodeTime += series[x]
if arraiveNode == 10000:
    arraiveNode = -1    
average_first_stage = sum_beforNodeTime / arraiveNode
average_second_stage = sum_afterNodeTime / (len(series) - 0)
data_average = [] 
for x, v in enumerate(series):
    if x < arraiveNode:
        data_average.append(round(average_first_stage,2))
    else:
        data_average.append(round(average_second_stage,2)) 

# 计算每天的运行总时间
totalConsume = []
totalTime = []
# 计算每天消耗的总电量
for k, v in energyDictionary.items():
    totalConsume.append(round(sum(v),2))
    if k in runtimeDictionary.keys():
        totalTime.append(round((sum(runtimeDictionary[k]) / 3600),2))


option_average = {}
option_average['title'] = {'text':'平均每天每小时耗电量,  起止日期: %s 至 %s' % (sorted(dayset)[0],sorted(dayset)[-1]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                   } 
option_average['yAxis'] = [{'type':'value','name':'耗电量/小时(mAh)'}]
option_average['xAxis'] = {'data':sorted(dayset),'name':'时间'}
option_average['series'] = [{'type':'line','name':'平均每小时耗电量/天/mAh','data':series,'smooth':True},
                            {'type':'line','name':'平均耗电量/mAh','data':data_average,'step':'middle','color':'red'}]
option_average['dataZoom'] = [{'type':'inside'}]
option_average['textStyle'] = {'color':'#ccc'}
option_average['tooltip'] = {'trigger': 'axis'}
option_average['legend'] = {'left':'10%','bottom':'10px','textStyle':{'color':'#aaa'}}

# 当天平均每小时耗电量和 该阶段平均每小时耗电量
desPath = os.path.dirname(__file__) + '/average_hours.json'
f = open(desPath,'w')
f.write(json.dumps(option_average))
f.close()

option_average['title'] = {'text':'平均每天运行时长及耗电量,  起止日期: %s 至 %s' % (sorted(dayset)[0],sorted(dayset)[-1]),
                    'textStyle':{'color':"#FFF",'width':'100%','height':'40px',},
                    'textAlign':'center',
                    'left':'50%',
                    'top':'20px'
                   } 
option_average['yAxis'] = [{'type':'value','name':'耗电量/天(mAh)'},{'type':'value','name':'运行时间/小时'}]
option_average['xAxis'] = {'data':sorted(dayset),'name':'时间'}
option_average['series'] = [{'type':'line','name':'总消耗/mAh','data':totalConsume,'smooth':True} ,                            
                            {'type':'line','name':'总运行时间/h','data':totalTime,'smooth':True,'yAxisIndex':1}]
option_average['dataZoom'] = [{'type':'inside'}]
option_average['textStyle'] = {'color':'#ccc'}
option_average['tooltip'] = {'trigger': 'axis'}
option_average['legend'] = {'left':'10%','bottom':'10px','textStyle':{'color':'#aaa'}}

# 总运行时间和总的耗电量
desPath = os.path.dirname(__file__) + '/totalRunTime.json'
f = open(desPath,'w')
f.write(json.dumps(option_average))
f.close()