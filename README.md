dump -- 打印数据 带堆栈 （要打印的参数，标题，层级

copy -- 深复制
GetDay -- 获取当天的数值
GetWeek -- 获取本周的数值
IsSameWeek --两个时刻是否同一周
ListLen -- 获取表的长度 有多少个参数
GetRandItemIdxNoRepeat -- 随机抽取 抽奖的表，抽取数量，不重复 注意产出不能超过列表上限，可以用来产出一个打乱的列表idx
GetRandItemIdxByWeight -- 按照概率抽取 必须有weight参数,num抽取数量 可重复
InList -- 判断参数是否在列表内
GetTimeTbl -- 获取一个list类型的时间 wday 为星期几 周末是1 周一是2
GetDayMonth -- 获取到下个月还有多少天 时间
GetNextMonth -- 获取到下个月还有多少秒 时间
StrTbl -- 字符串转表
GetTodaySec -- 获取当天0点到现在的秒数
ButtonClose -- 关
IsButtonOpen -- 检查开关
ButtonOpen -- 开
TblStr -- 表转字符串
GetTblKey -- 获取表内的key，抛弃参数
GetTblValue -- 获取表内的参数，抛弃key
ColorHead
ShuShuBuild ---------数数通用-----构造函数=====
GetStringCharCount -- 获取字符串长度，文字只算1位
CreateRandomGenerator -- 创建一个新的随机数生成器
MinMax -- 返回参数限制在大小内
InMinMax -- 判断是否在范围内
GetOsTime -- 转换时间 将 "Y-M-D h:m:s"转换成时间戳
