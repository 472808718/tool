-- 张航龙
-- 代码基于lua5.1版本，如果使用其他版本倾请主意是否兼容

function init()
	_G.dump = dump -- 打印数据 带堆栈 （要打印的参数，标题，层级
	_G.copy = copy -- 深复制
	_G.clone = clone -- 深复制，如果是原表会将原表格式也复制过去
	_G.GetDay = GetDay -- 获取当天的数值
	_G.GetWeek = GetWeek -- 获取本周的数值
	_G.IsSameWeek = IsSameWeek --两个时刻是否同一周
	_G.ListLen = ListLen -- 获取表的长度 有多少个参数
	_G.GetRandItemIdxNoRepeat = GetRandItemIdxNoRepeat -- 随机抽取 抽奖的表，抽取数量，不重复 注意产出不能超过列表上限，可以用来产出一个打乱的列表idx
	_G.GetRandItemIdxByWeight = GetRandItemIdxByWeight -- 按照概率抽取 必须有weight参数,num抽取数量 可重复
	_G.InList = InList -- 判断参数是否在列表内
	_G.GetTimeTbl = GetTimeTbl -- 获取一个list类型的时间 wday 为星期几 周末是1 周一是2
	_G.GetDayMonth = GetDayMonth -- 获取到下个月还有多少天 时间
	_G.GetNextMonth = GetNextMonth -- 获取到下个月还有多少秒 时间
	_G.StrTbl = StrTbl -- 字符串转表
	_G.GetTodaySec = GetTodaySec -- 获取当天0点到现在的秒数
	_G.ButtonClose = ButtonClose -- 关
	_G.IsButtonOpen = IsButtonOpen -- 检查开关
	_G.ButtonOpen = ButtonOpen -- 开
	_G.TblStr = TblStr -- 表转字符串
	_G.GetTblKey = GetTblKey -- 获取表内的key，抛弃参数
	_G.GetTblValue = GetTblValue -- 获取表内的参数，抛弃key
	_G.GetStringCharCount = GetStringCharCount -- 获取字符串长度，文字只算1位
	_G.CreateRandomGenerator = CreateRandomGenerator -- 创建一个新的随机数生成器
	_G.MinMax = MinMax -- 返回参数限制在大小内
	_G.InMinMax = InMinMax -- 判断是否在范围内
	_G.GetOsTime = GetOsTime -- 转换时间 将 "Y-M-D h:m:s"转换成时间戳
end

function GetTblKey(tb)
	local list = {}
	for k in pairs(tb) do
		list[#list+1] = k
	end
	return list
end

function GetTblValue(tb)
	local list = {}
	for _, v in pairs(tb) do
		list[#list+1] = v
	end
	return list
end

-- 深复制
function copy(tb)
	local out = {}
	for k, v in pairs(tb) do
		if type(v) == "table" then
			out[k] = copy(v)
		else
			out[k] = v
		end
	end
	return out
end

-- 连原表都一起复制
function clone(t)
	if not t or type(t) ~= "table" then return t end
	local result = {}

	local m = getmetatable(t)
	if m then
		setmetatable(result, getmetatable(t))
	end

	for k, v in pairs(t) do
		result[k] = clone(v, withmeta)
	end
	return result
end

local function copyr(tb)
	local out = {}
	for k, v in pairs(tb) do
		out[k] = {
			idx = k,
			weight = v.weight,
		}
	end
	return out
end

------------------------------------
local function rshift(x,n)
	return math.floor(math.fmod(x)/2^n)
end

local function lshift(a,disp)
	disp = disp -1
  if disp < 0 then return rshift(a,-disp) end 
  return (a * 2^disp) % 2^32
end

local bitMOD = 2^32
local bitMODM = bitMOD-1

function band(a,b)
	a = a%bitMOD
	b = b%bitMOD
	return ((a+b) - bxor(a,b))/2
end

function bor(a,b)  
	a = a%bitMOD
	b = b%bitMOD
	return bitMODM - band(bitMODM - a, bitMODM - b) 
end

local function make_bitop_uncached(t, m)
	local function bitop(a, b)
		local res,p = 0,1
		while a ~= 0 and b ~= 0 do
			local am, bm = a%m, b%m
			res = res + t[am][bm]*p
			a = (a - am) / m
			b = (b - bm) / m
			p = p*m
		end
		res = res + (a+b)*p
		return res
	end
	return bitop
end

local function memoize(f)
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k)
		t[k] = v
		return v
	end
	return t
end

local function make_bitop(t)
	local op1 = make_bitop_uncached(t,2^1)
	local op2 = memoize(function(a)
		return memoize(function(b)
			return op1(a, b)
		end)
	end)
	return make_bitop_uncached(op2, 2^(t.n or 1))
end

bxor = make_bitop {[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0}, n=4}

-- 检查开关
function IsButtonOpen(i, num)
	local x = lshift(1,num)
	return band(i,x) ~= 0
end

-- 开关
function ButtonOpen(i, num)
	if num > 30 then return assert(nil,"--最多只能存储30个开关 err:"..num.." \n") end
	local x = lshift(1,num)
	return math.floor(bor(i,x))
end

-- 关
function ButtonClose(i, num)
	local x = lshift(1,num)
	if IsButtonOpen(i, num) then
		return math.floor(bxor(i,x))
	end
	return i
end

-- wday 为星期几 周末是1 周一是2
-- 列表时间
function GetTimeTbl(t)
	local t = t or os.time()
	return os.date("*t", t)
end

-- 获取当天0点到现在的秒数
function GetTodaySec()
	return (os.time() + 28800) % 86400
end

-- 获取当天的数值
function GetDay(t)
	t = t or os.time()
	return math.floor((t+28800) / 86400)
end

-- 获取当天的数值 指定跨天时间
function GetDayMonth(t, hour)
	t = t or os.time()
	hour = hour or 0
	return math.floor((t+28800 - (hour*3600)) / 86400)
end

function GetNextMonth(t, hour)
	t = t or os.time()
	hour = hour or 0
	local tbl = os.date("*t", t)
	tbl["month"] = tbl["month"] + 1
	tbl["day"] = 1
	tbl["hour"] = hour
	tbl["min"] = 0
	tbl["sec"] = 0
	return os.time(tbl)
end

-- 获取本周的数值
function GetWeek(t)
	t = GetDay(t)
	return math.floor((t-4) / 7)
end

--两个时刻是否同一周
function IsSameWeek(time1, time2)
	time2 = time2 or os.time()
	return GetWeek(time1) == GetWeek(time2)
end

-- 获取表的长度
function ListLen(tb)
	local num = 0
	for _ in pairs(tb) do
		num = num + 1
	end
	return num
end

-- 判断参数是否在列表内
function InList(tb, key)
	for _, v in pairs(tb) do
		if v == key then
			return true
		end
	end
	return false
end

function _GetRandItem(tb)
	local num = 0
	for _, data in pairs(tb) do
		num = num + data.weight
	end
	local randNum = math.random(num)
	for idx, data in pairs(tb) do
		if data.weight >= randNum then
			return idx
		end
		randNum = randNum - data.weight
	end
	assert(nil, string.format("[error] weight:%s randNum:%s", weight, randNum))
end

-- 随机抽取 抽奖的表，抽取数量，不重复 注意产出不能超过列表上限，可以用来产出一个打乱的列表idx
function GetRandItemIdxNoRepeat(tb, num, noWeight)
	local crtb = copyr(tb)
	local idxList = {}
	if noWeight then
		for idx, data in pairs(crtb) do
			data.weight = 1
			data.idx = idx
		end
	end
	if not num then
		num = 0
		for _ in pairs(crtb) do
			num = num + 1
		end
	end
	for i=1, num do
		if not next(crtb) then
			break
		end
		local idx = _GetRandItem(crtb)
		idxList[#idxList+1] = crtb[idx].idx
		table.remove(crtb, idx)
	end
	return idxList 
end

-- 按照概率抽取 必须有weight参数,num抽取数量 可重复
function GetRandItemIdxByWeight(tb, num, weight)
	weight = weight or 0
	if weight == 0 then
		for _, data in pairs(tb) do
			weight = weight + data.weight
		end
	end
	local list = {}
	for i=1, num do
		local randNum = math.random(weight)
		for idx, data in pairs(tb) do
			if randNum <= data.weight then
				list[#list+1] = idx
				break
			end
			randNum = randNum - data.weight
		end
	end
	return list
end

local function split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if (delimiter=='') then return false end
	local pos,arr = 0, {}
	-- for each divider found
	for st,sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

local function trim(input)
	input = string.gsub(input, "^[ \t\n\r]+", "")
	return string.gsub(input, "[ \t\n\r]+$", "")
end

local function dump_value_(v)
	if type(v) == "string" then
		v = "\"" .. v .. "\""
	end
	return tostring(v)
end

-- 打印数据 带堆栈 （要打印的参数，标题，层级
function dump(value, desciption, nesting)
	if type(nesting) ~= "number" then nesting = 10 end

	local lookupTable = {}
	local result = {}

	local traceback = split(debug.traceback("", 2), "\n")
	if netbuf then
		netbuf.trace("dump from: " .. trim(traceback[3]))
	else
		print(("dump from: " .. trim(traceback[3])))
	end

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."	"
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	dump_(value, desciption, "- ", 1)
	local str = ""
	for i, line in ipairs(result) do
		str = str..line.."\n"
	end
	if netbuf then
		netbuf.trace(str)
	else
		print(str)
	end
end

-- 字符串转表
function StrTbl (tab)
	local tp = type(tab)
	if tp ~= 'table' then
		if type(tab) == 'string' then
			return string.format('"%s"',tab)
		end
		return tostring(tab)
	end
	local tabStr = {}
	table.insert(tabStr, '{')
	for k, v in pairs(tab) do
		table.insert(tabStr, '[')
		table.insert(tabStr, StrTbl(k))
		table.insert(tabStr, '] = ')
		table.insert(tabStr, StrTbl(v))
		table.insert(tabStr, ',')
	end
	table.insert(tabStr, '}')
	return table.concat(tabStr)
end

-- 表转字符串
function TblStr(str)
	local s = string.format("return %s",str)
	return loadstring(s)()
end

-- 获取字符串长度，文字只算1位
function GetStringCharCount(str)
	local length = 0
	local i = 1
	while i <= #str do
		local curByte = string.byte(str, i)
		if curByte > 239 then
			byteCount = 4
		elseif curByte > 223 then
			byteCount = 3
		elseif curByte > 128 then
			byteCount = 2
		else
			byteCount = 1
		end
	i = i + byteCount
	length = length + 1
	end
	return length
end

-- 创建一个新的随机数生成器
function CreateRandomGenerator(seed)
	local rg = {}
	rg.seed = seed

	function rg.randomseed(s)
		rg.seed = s
	end

	function rg.random(a, b)
		rg.seed = (1703515245 * rg.seed + 12345) % 2^31
		local x = rg.seed / 2^31

		if not a then
			return x
		elseif not b then
			return a * x
		else
			return a + (b - a) * x
		end
	end
	return rg
end

function MinMax(n, minN, maxN)
	n = math.max(n, minN)
	return math.min(n, maxN)
end

function InMinMax(n, minN, maxN)
	return n >= minN and n <= maxN
end

function GetOsTime(t)
	assert(t)
	local y, m, d, h, min, s = string.match(t, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    return os.time({year=y, month=m, day=d, hour=h, min=min, sec=s})
end

init()
