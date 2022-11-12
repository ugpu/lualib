------ some lua common api
------ how use?
------ only: require "util.lua"
------ example: util.nowstr()
local strsub = string.sub
local strbyte = string.byte
local strchar = string.char
local json = require "json"
local xml = require "LuaXML"

require "tostring"
local util = {}


-- 一one day sec
local ONE_DAY_SEC = 86400
-- one week sec
local ONE_WEEK_SEC = 604800
-- two week sec
local TWO_WEEKS_SEC = 1209600
local TIME_ZONE_OFFSET = os.time() - os.time(os.date("!*t"))

util.ONE_DAY_SEC = ONE_DAY_SEC
util.ONE_WEEK_SEC = ONE_WEEK_SEC
util.TWO_WEEKS_SEC = TWO_WEEKS_SEC


-- split string 
--s : string
--sep: split sep
function util.split(s, sep)
    local sep = sep or " "
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields+1]=c end)
    return fields
end

--format utc time
function util.nowstr(now)
    return os.date("%Y-%m-%d %H:%M:%S", now or os.time())
end


--next day surplus sec

function util.getNextDayInterval()
    local now_tab = os.date("*t")
    now_tab.hour = 0
    now_tab.min = 0
    now_tab.sec = 0
    return ONE_DAY_SEC - (os.time() - os.time(now_tab))
end

--format example c for sprintf
function util.strformat(s, ...)
    local pattern = "%%[%d%%]"

    local t = {...}
    return string.gsub(s, pattern, function (s1)
        if s1 == "%%" then
            return "%"
        else
            local p = tonumber(s1:sub(2)) + 1
            return t[p]
        end
    end)
end


-- get today or any time begin time
function util.getDayBeginTime(timestamp)
    timestamp = timestamp or os.time()
    local nowTab = os.date("*t", tonumber(timestamp))
    nowTab.hour = 0
    nowTab.min = 0
    nowTab.sec = 0

    local todayBegin = os.time(nowTab)
    return todayBegin
end


function util.getDayEndTime(timestamp)
    timestamp = timestamp or os.time()
    local nowTab = os.date("*t", tonumber(timestamp))
    nowTab.hour = 24
    nowTab.min = 0
    nowTab.sec = 0

    local todayEnd = os.time(nowTab)
    return todayEnd
end


-- diff days eq sec
function util.getDaysDiff(timestamp, startstamp)
    return (util.getDayBeginTime(startstamp) - util.getDayBeginTime(timestamp)) / ONE_DAY_SEC
end


-- diff is same day?
function util.is_same_day(t1, t2)
    if not(t1 and t2) then return end

    local tt1 = os.date("*t", tonumber(t1))
    local tt2 = os.date("*t", tonumber(t2))

    return (tt1.year == tt2.year and 
           tt1.month == tt2.month and 
           tt1.day == tt2.day)
end

--gen uuuid
function util.uuid_gen(timeGen, rand_id, seqid)
    seqid = seqid or 1
    rand_id = rand_id or 1
    local t_shift = 1451577600   -- offset value
    local generator = function()
        local ts = timeGen()
        if not ts then
            return nil
        end
        if (not ts[1]) or (not ts[2]) then
            return nil
        end

        seqid = seqid + 1
        if seqid > 1023 then
            seqid = 1
        end

        local timeVal = (tonumber(ts[1]) - t_shift)*1000 + math.floor(tonumber(ts[2])/1000)
        local id = (timeVal << 22) + (rand_id << 10) + seqid
        return id
    end
    return generator
end


function util.urlencode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function util.urldecode(s)
    s = string.gsub(s, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
    return string.gsub(s, "+", " ")
end

--random from table any value
--table format: values { 1, x1, x2, x3} weights:{10%, 20%, 30%}, sum_weight: 10+20+30 === total weight
function util.run_roulette(values, weights, sum_weight, allow_empty)
    assert(#values == #weights, "value and weight not equal" )
    if not sum_weight then return end
    if sum_weight == 0 then
        if not allow_empty then
            return 1, values[1]
        else
            return 0, nil
        end
    end

    local tmp_weight = math.random() * sum_weight
    local weight = 0
    for k, v in ipairs(weights) do
        weight = weight + v
        if tmp_weight <= weight then
            return k, values[k]
        end
    end
    if not allow_empty then
        return 1, values[1]
    else
        return 0, nil
    end
end

--random  sort array
function util.random_array(arr)
    local temp, index
    for i=1,#arr-1 do
        index = math.random(i, #arr)
        if i ~= index then
            temp = arr[index]
            arr[index] = arr[i]
            arr[i] = temp
        end
    end
end


function util.random_numstr(len)
    local set = "0123456789"
    len = len or 10
    if len > 100 then len = 100 end

    local slen = utf8.len(set)
    local res = {}
    local p
    for i = 1, len do 
        p = math.random(1,slen)
        res[#res+1] = string.sub(set, p, p)
    end

    return table.concat(res, '')
end


function util.is_same_hour(t1, t2)
    assert(t1, "#1 required")
    return os.date("%Y%m%d%H", t1) == os.date("%Y%m%d%H", t2)
end

function util.random_str(len,lower_case)
    local set = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


    if lower_case then
        set = "abcdefghijklmnopqrstuvwxyz"
    end

    len = len or 10
    if len > 500 then len = 500 end

    local slen = utf8.len(set)
    local res = {}
    local p
    for i = 1, len do 
        p = math.random(1,slen)
        res[#res+1] = string.sub(set, p, p)
    end

    return table.concat(res, '')
end


local phone_mac = {
    
    [133]=1,[149]=1,[153]=1,[173]=1,[177]=1,[180]=1,[181]=1, [189]=1,[190]=1,
    [191]=1,[199]=1,
    -
    [130]=1,[131]=1,[132]=1,[145]=1,[155]=1,[156]=1,[166]=1,[171]=1,[175]=1,
    [176]=1,[185]=1,[186]=1,[196]=1,
   
    [134]=1,[135]=1,[136]=1,[137]=1,[138]=1,[139]=1,[147]=1,[150]=1,[151]=1,
    [152]=1,[157]=1,[158]=1,[159]=1,[172]=1,[178]=1,[182]=1,[183]=1,[184]=1,
    [187]=1,[188]=1,[197]=1,[198]=1,
   
    [192]=1,
 
    [170] = 1,
}
--check valid phonenubmer
function util.validate_phonenumber(num)
    if type(num) ~= "string" then return end
    if utf8.len(num) ~= 11 then return end
    local mac, other = string.match(num, "(%d%d%d)(%d%d%d%d%d%d%d%d)")
    mac,other = tonumber(mac), tonumber(other)
    if not (mac and other) then return end
    if not phone_mac[mac] then return end

    return true
end


function util.check_include_chinese_and_number_and_letter(s)
    local k = 1
    local a1,a2,a3,a4
    while true do
        if k > #s then
            if k == 1 then
                return false
            else
                return true
            end
        end
        local c = string.byte(s,k)
        if not c then
            return false
        end
        if c<192 then
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then -- 小写和大写英文字母 数字
                k = k + 1
            else
                return false
            end
        elseif c<224 then
            return false
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then
                        a1 = 184
                    elseif c == 233 then
                        a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if not(c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4) then-- 不是汉字
                        return false
                    end
                else
                    return false
                end
            else
                return false
            end
            k = k + 3
        else
            return false
        end
    end
end

--swap key & value
function util.inversemap(t)
    local r = {}
    for k, v in pairs(t) do
        r[v] = k
    end
    return r
end


function util.reverse_array(list)
    local i, j = 1, #(list)
    while i < j do
        list[i], list[j] = list[j], list[i]
        i = i + 1
        j = j -1
    end
    return list
end


return util
