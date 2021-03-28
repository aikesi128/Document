
使用方法:

1. 将系统统计的格式为xxx.PLSQL 的数据库文件, 放在根目录('parser或者parser-date')下, 并且重命名为destination.PLSQL
2. 使用VSCode打开根目录
3. 运行dataParse.py文件, 将会生成dataDisplay.html文件中需要的部分json数据, 继续运行calculate_average.py文件, 将会生成平均耗电量json数据. 
4. 使用浏览器打开dataDisplay.html文件, 即可看到相关耗电量数据分析 