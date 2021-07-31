max = math.max
min = math.min
math.round = function(x) return math.floor(x + 0.5) end
clip = function(x, minimum, maximum) return min(max(x, minimum), maximum) end

-- https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
string.trim = function(s) return
  s:match '^()%s*$' and '' or s:match '^%s*(.*%S)' end

string.count = function(str, pattern)
  local ans = 0
  for _ in str.gfind(pattern) do ans = ans + 1 end
  return ans
end

string.map = function(str, map)
  local ans = ''
  for character in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
    -- print(character)
    if map[character] == nil then
      ans = ans .. character
    else
      ans = ans .. map[character]
    end
  end
  return ans
end

string.split = function(str, sep)
  if sep == nil then sep = "%s" end
  local t = {}
  for str in string.gmatch(str, "([^" .. sep .. "]+)") do table.insert(t, str) end
  return t
end

string.startsWith = function(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

string.endsWith = function(str, suffix)
  return string.sub(str, #str - string.len(suffix) + 1) == suffix
end

startsWithX = function(x) return
  function(prefix) return x:startsWith(prefix) end end

string.lpad = function(str, len, char)
  if char == nil then char = " " end
  return str .. string.rep(char, len - #str)
end

-- shallow table
table.contains = function(a, b)
  for k, v in pairs(b) do if a[k] ~= v then return false end end
  return true
end

table.value2key = function(x)
  local ans = {}
  for k, v in pairs(x) do ans[v] = k end
  return ans
end

table.select = function(mask, reference)
  local ans = {}
  for i = 1, #reference do if mask[i] then table.insert(ans, reference[i]) end end
  return ans
end

-- return true if there is an x s.t. f(x) is true
table.any = function(t, f)
  for k, v in pairs(t) do if f(v) then return true end end
end

-- return true if f(x) is all true
table.all = function(t, f)
  for _, v in pairs(t) do if not f(v) then return false end end
  return true
end

table.findv = function(t, f)
  for k, v in pairs(t) do if f(v) then return v end end
end

table.filter = function(t, f)
  local a = {}
  for _, v in pairs(t) do if f(v) then table.insert(a, v) end end
  return a
end

table.keys = function(t)
  local a = {}
  t = t or a
  for k, _ in pairs(t) do table.insert(a, k) end
  return a
end
-- a,a+1,...b
range = function(a, b)
  local t = {}
  for i = a, b do table.insert(t, i) end
  return t
end

table.includes = function(t, e)
  return table.any(t, function(x) return x == e end)
end

table.extend = function(t, e) for k, v in pairs(e) do table.insert(t, v) end end

--  in = {
--    "A" = {1,4,5,7},
--    "B" = {1,2,5,6},
--    "C" = {3,4,6,7},
--    "D" = {2,3,6,7},
--  }
-- out = { {"A","B"},...}
-- n:key, m:value O(mmn)
table.reverseIndex = function(t)
  local r = {}
  local s = {}
  for k, v in pairs(t) do for k2, v2 in pairs(v) do s[v2] = true end end
  for k, v in pairs(s) do
    r[k] = {}
    for k2, v2 in pairs(t) do
      if table.includes(v2, k) then table.insert(r[k], k2) end
    end
  end
  for k, v in pairs(r) do table.sort(v) end
  return r
end

table.find =
  function(t, f) for k, v in pairs(t) do if f(v) then return k end end end

table.shuffle = function(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

equalX = function(x) return function(y) return x == y end end

shallowCopy = function(x)
  local y = {}
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

update = function(b, x, inplace)
  local y = inplace and b or shallowCopy(b)
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

-- n: num, a: alternative element
repeat_last = function(x, n, a)
  if a == nil then a = x[#x] end
  for i = 1, n do table.insert(x, a) end
  return x
end

-- TODO: better algorithms
loop_times = function(x)
  local times, f, n
  local maxlen = 40 -- of one piece
  local maxtimes = 1 -- of same pieces
  if x == nil or #x == 0 then return 0 end
  for i = 1, maxlen do
    f = true
    n = math.floor(#x / i)
    if n <= maxtimes then break end
    for j = 1, n - 1 do
      for k = 1, i do
        if x[#x - j * i - k + 1] ~= x[#x - k + 1] then
          f = false
          break
        end
      end
      if not f then
        maxtimes = math.max(maxtimes, j)
        break
      else
        maxtimes = math.max(maxtimes, j + 1)
      end
    end
  end
  return maxtimes
end

map = function(...)
  local a = {...}
  local n = select("#", ...)
  local r = {}
  local f, x = a[1], a[2]
  local p, ur
  if n < 2 then return r end
  if n == 2 then
    n = #x
  elseif n > 2 then
    ur = true
    x = {table.unpack(a, 2, n)}
    n = n - 1
  end
  for i = 1, n do
    p = x[i]
    if type(f) == "function" then
      p = f(p)
    elseif type(f) == "table" then
      p = f[p]
    end
    r[i] = p
  end
  if ur then return table.unpack(r, 1, n) end
  return r
end

ssleep = function(x)
  if x == nil then x = 1 end
  sleep(x * 1000)
end

table.join = function(t, d)
  d = not d and ',' or d
  local a = ''
  for i = 1, #t do
    a = a .. t[i]
    if i ~= #t then a = a .. d end
  end
  return a
end

table.clear = function(x) for k, v in pairs(x) do x[k] = nil end end

removeFuncHash =
  function(x) return x:startsWith('function') and 'function' or x end

table2string = function(t)
  if type(t) == 'table' then
    return JsonEncode(t)
    --    if #t == 0 then
    --    else
    --      return table.join(map(tostring, t))
    --    end
  end
  return t
end

log_history = {}
log = function(...)
  local arg = {...}
  local l = {map(tostring, running, ' ', table.unpack(map(table2string, arg)))}
  l = map(removeFuncHash, l)
  l = map(table2string, l)
  local a = time()
  for _, v in pairs(l) do a = a .. ' ' .. v end
  if #log_history > 2000 then table.clear(log_history) end
  log_history[#log_history + 1] = a
  l = loop_times(log_history)
  if l > 1 then a = a .. " x" .. l end
  if l > 100 then stop("246") end
  print(a)
end

open = function() runApp(appid) end

stop = function(msg)
  log("stop " .. msg)
  toast("stop " .. msg)
  exit()
end

findColorAbsolute = function(color, confidence)
  confidence = confidence or 100
  -- keepScreen(true)
  for x, y, c in color:gmatch("(%d+),(%d+),(#[^|]+)") do
    -- log(x, y, c)
    if not compareColor(tonumber(x), tonumber(y), c, confidence) then
      -- if getColor(tonumber(x), tonumber(y)).hex ~= c then
      if verbose_fca then log(x, y, c) end
      -- keepScreen(false)
      return
    end
  end
  local x, y = color:match("(%d+),(%d+)")
  return {x = tonumber(x), y = tonumber(y)}
end

findOne_last_time = 0
findOne = function(x, confidence)
  if type(x) == "function" then return x() end
  -- local findOneMinInterval = 1
  -- sleep(16 - min(time() - findOne_last_time, 16))
  -- findOne_last_time = time()

  local x0 = x
  confidence = confidence or 99
  if type(x) == 'string' and not x:find(coord_delimeter) then x = point[x] end
  if type(x) == "table" then return x end
  if type(x) == "string" then
    local pos
    if rfl[x0] then
      pos = findColorAbsolute(x, confidence)
    else
      local color = shallowCopy(rfg[x0])
      table.extend(color, {x, confidence})
      -- log("findColor", color)
      pos = findColor(color, confidence)
    end
    if pos then return {pos.x, pos.y} end
  end
end

findAny = function(x) return appear(x, 0, 0) end

findAll = function(x, confidence)
  confidence = confidence or 99
  local color = shallowCopy(rfl[x] or {0, 0, screen.width, screen.height})
  table.extend(color, {point[x], confidence})
  return findColors(color)
end

-- x={2,3} "信用" func nil
tap = function(x, retry, allow_outside_game)
  if not allow_outside_game then wait_game_up() end
  screen = getScreen()
  if screen.width < screen.height then
    stop("分辨率" .. screen.width .. 'x' .. screen.height .. '非横屏')
  end
  local x0 = x
  if x == true then return true end

  if type(x) == "function" then return x() end
  if type(x) == "string" and not x:find(coord_delimeter) then
    x = point[x]
    if type(x) == "string" then
      local p = x:find(coord_delimeter)
      local q = x:find(coord_delimeter, p + 1)
      -- log(p, q)
      x = map(tonumber, {x:sub(1, p - 1), x:sub(p + 1, q - 1)})
    end
  end
  log("tap", x0, x)
  if type(x) ~= "table" then return end
  -- log('click', x[1], x[2], type(x[1]))
  click(x[1], x[2])
  -- log(399)
  if retry then return end

  -- 返回"面板"后易触发数据更新,导致操作失效
  if type(x0) == 'string' and x0:startsWith('面板') then
    wait(function()
      if not findOne("面板") then return true end
      log("retap", x0)
      tap(x0, true, allow_outside_game)
      log(352)
    end, 10)
  end
end

-- quick multiple swip, for fights
-- input distance => {x,y,x',y',time} / list of them
swipq = function(dis, disable_end_sleep, duration)
  wait_game_up()
  duration = duration or 400
  if type(dis) == "string" then dis = distance[dis] end
  if not dis then return end
  if type(dis) ~= "table" then dis = {dis} end
  log("367", dis)
  for idx, x in ipairs(dis) do
    if type(x) == 'number' then
      local left_boundary = math.round(200 * minscale)
      local right_boundary = math.round((1720 - 1920) * minscale + screen.width)
      local height = math.round(400 * minscale)
      if x == 0 then -- special wait sign
        ssleep(.4)
      elseif x == 1 then -- special quit sign
        return
      elseif x > 0 then -- magick distance map from xxzhushou to nspirit
        log(left_boundary, height, min(right_boundary, left_boundary + x * 2),
            right_boundary, duration)
        slid(left_boundary, height, min(right_boundary, left_boundary + x * 2),
             right_boundary, duration)
      elseif x < 0 then
        log(right_boundary, height, max(left_boundary, right_boundary + x * 2),
            height, duration)
        slid(right_boundary, height, max(left_boundary, right_boundary + x * 2),
             height, duration)
      end
    elseif type(x) == 'table' then
      log(table.unpack(x))
      local a, b, c, d, e = table.unpack(x)
      slid(math.round(a), math.round(b * minscale), math.round(c),
           math.round(d * minscale), e)
    else
      stop(413)
    end
    if not (disable_end_sleep and idx == #dis) then ssleep(.4) end
  end
end

zoom = function()
  if not findOne("进驻总览") then path.跳转("基建") end
  local paths = {
    {
      {
        x = math.round((1720 - 1920) * minscale + screen.width),
        y = math.round(56 * minscale),
      }, {x = screen.width // 2 - 100, y = math.round(56 * minscale)},
    }, {
      {x = 600, y = math.round(56 * minscale)},
      {x = screen.width // 2 + 100, y = math.round(56 * minscale)},
    },
  }
  -- 89,35,#313131
  -- local paths  = "1273,42,#333333|1085,36,#B5B5B5"
  local duration = 100
  gesture(paths, duration)
  -- TODO need sleep?
  sleep(400)
end

auto = function(p, fallback, timeout)
  wait_game_up()
  if type(p) == "function" then return p() end
  if type(p) ~= "table" then return true end
  while true do
    local finish = false
    local check = function()
      for k, v in pairs(p) do
        if findOne(k) then
          log(k, "=>", v)
          effective_state = k
          if tap(v) then finish = true end
          return true
        end
      end
    end
    timeout = timeout or 0
    -- if findAny({"进驻信息", "进驻信息选中"}) then timeout = 3 end
    local e = wait(check, timeout)

    -- tap true
    if finish then return true end

    -- fallback: tap false or timeout
    if not e and fallback ~= false then
      -- log("auto -> fallback")
      local x = table.findv({
        "返回确认", "活动公告返回", "签到返回", "返回",
        "返回2", "返回3", "返回4",
      }, findOne)
      if x then
        log(x)
        if x == "活动公告返回" or x == "签到返回" then
          -- deal with everyday popup
          if wait(function()
            if findOne("面板") then return true end
            tap(x)
            appear("面板", 1)
          end, 10) then return end
        elseif x == "返回确认" then
          leaving_jump = false
          if not wait(function()
            if not findOne("返回确认") then return true end
            if fallback then
              tap(fallback[x])
            else
              tap("右确认")
            end
            disappear("返回确认")
          end, 10) then return end
          if appear("进驻总览") then leaving_jump = true end

          -- wait(function()
          --   if not findOne(x) then return true end
          --   tap(fallback and fallback[x] or "右确认")
          --   disappear(x, 1)
          --   appear("进驻总览", 2)
          -- end, 10)
        else
          tap(x)
        end
      else
        -- log("no fallback sign found")
        tap(nil)

        --        tap(p.other)
        --        tap("返回")
        --        ssleep(.5)
        --        tap(p["其它"])
      end
      -- wait for fallback
      --      ssleep(.5)
    end
    -- log(495, "end of while")
  end
end

parse_time = function(x)
  if not x then return os.time() end
  return os.time({
    year = tonumber(x:sub(1, 4)),
    month = tonumber(x:sub(5, 6)),
    day = tonumber(x:sub(7, 8)),
    hour = tonumber(x:sub(9, 10)),
    min = tonumber(x:sub(11, 12)),
  })
end

-- run function / job / table of function and job
run = function(...)
  local arg = {...}
  if #arg == 1 then
    if type(arg[1]) == "function" then return arg[1]() end
    if type(arg[1]) == "table" then arg = arg[1] end
  end
  menuConfig({x = 0, y = screen.height})
  update_state()
  for _, v in ipairs(arg) do
    running = v
    if type(v) == 'function' then
      v()
    else
      auto(path[v])
    end
  end
  if not no_background_after_run then home() end
end

half_hour_cron = function(x, h)
  local m = 30
  if type(x) == "table" then
    if #x == 3 then
      x, h, m = x[1], x[2], x[3]
    else
      x, h = x[1], x[2]
    end
  end
  return {callback = function() run(x) end, hour = h, minute = m}
end

findTap = function(target)
  if type(target) == 'string' or #target == 0 then target = {target} end
  for _, v in pairs(target) do
    -- log(574, v, type(v))
    local p = findOne(v)
    if p then
      --      log("findTap:", v, p)
      tap(p)
      return v
    end
  end
end

appearTap = function(target, timeout, interval)
  if type(target) == 'string' or #target == 0 then target = {target} end
  target = appear(target, timeout, interval)
  if target then
    -- log("apperTap: ", target)
    findTap(target)
    return true
  end
end
-- {x:2,y:3} => {2,3}
xy2arr = function(t) return {t.x, t.y} end

deploy = function(x1, x2, y2, d)
  -- TODO
  local y1 = 1000
  local t = .3
  d = d or 2
  d = ({{0, -1}, {1, 0}, {0, 1}, {-1, 0}})[d]
  d = {d[1] * 500, d[2] * 500}
  swip(x1, y1, x2 - x1, y2 - y1, t, t)
  swip(x2, y2, x2 + d[1], y2 + d[2], .2)
end

-- todo: make a map ?
retreat = function(x1, y1, x2, y2)
  local t = .2
  touchDown(0, x1, y1)
  ssleep(t)
  touchUp(0, x1, y1)
  ssleep(t)
  touchDown(0, x2, y2)
  ssleep(t)
  touchUp(0, x2, y2)
end

-- wait until func success
wait = function(func, timeout, interval)
  timeout = timeout or 2
  interval = interval or 0
  -- log(timeout,interval)
  local start_time = time()
  while true do
    local ans = func()
    -- log(584,ans)
    if ans then return ans end
    if (time() - start_time) > timeout * 1000 then break end
    ssleep(interval)
  end
end

-- wait until see node / point / list of node and point
appear = function(target, timeout, interval, disappear)
  if not (type(target) == 'table' and #target > 0) then target = {target} end
  return wait(function()
    for _, v in pairs(target) do
      -- log(615, v)
      if disappear then
        if type(v) == "function" then
          return not v()
        elseif #v == 0 and not find(v) then
          return v
        elseif #v > 0 and not findOne(v) then
          return v
        end
      else
        if type(v) == "function" then
          return v()
        elseif #v == 0 and find(v) then
          return v
        elseif #v > 0 and findOne(v) then
          return v
        end
      end
    end
  end, timeout, interval)
end

disappear = function(target, timeout, interval)
  return appear(target, timeout, interval, true)
end

wait_game_up = function()
  local game = R():name(appid):path("/FrameLayout/View")
  local bilibili_login = R():id(
                           "com.hypergryph.arknights.bilibili:id/bsgamesdk_buttonLogin");
  if not find(game) then
    open()
    if not appear({game, bilibili_login}, 10, 1) then
      stop("游戏不在前台")
    end
    bilibili_login_hook()
  end
end

bilibili_login_hook = function()
  if appid ~= bppid then return end
  local login = R():id(
                  "com.hypergryph.arknights.bilibili:id/bsgamesdk_buttonLogin");
  if not find(login) then return end
  local username_inputbox = R():id(
                              "com.hypergryph.arknights.bilibili:id/bsgamesdk_edit_username_login");
  local password_inputbox = R():id(
                              "com.hypergryph.arknights.bilibili:id/bsgamesdk_edit_password_login");
  input(username_inputbox, username)
  input(password_inputbox, password)
  click(login)
  return true
end
