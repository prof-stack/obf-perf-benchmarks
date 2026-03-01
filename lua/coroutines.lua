-- OOP, Metatables & Coroutine Benchmark
-- Tests __index chains, operator overloading, method dispatch,
-- and coroutine resume/yield overhead.
-- Obfuscators that wrap metamethods or rename globals heavily will show
-- measurable overhead on metatable lookups and coroutine scheduling.

local script_start = os.clock()

print("=== OOP, Metatables & Coroutine Benchmark ===")
print("Targets: __index chains, metamethods, method dispatch, coroutine resume/yield")
print("")

-- Test 1: Simple OOP with __index method dispatch
print("Test 1: OOP Method Dispatch (500K calls via __index)")
local Animal = {}
Animal.__index = Animal

function Animal.new(name, hp, atk)
    return setmetatable({name=name, hp=hp, atk=atk, xp=0}, Animal)
end
function Animal:attack(other)
    local dmg = math.max(1, self.atk - math.floor(other.hp * 0.05))
    other.hp = other.hp - dmg
    self.xp = self.xp + dmg
    return dmg
end
function Animal:is_alive() return self.hp > 0 end

local t1_start = os.clock()
local dmg_sink = 0
local a = Animal.new("Wolf", 999999, 10)
local b = Animal.new("Sheep", 999999, 1)
for i = 1, 500000 do
    dmg_sink = dmg_sink + a:attack(b)
end
local t1_time = os.clock() - t1_start
print(string.format("  Damage dealt: %d", dmg_sink))
print(string.format("  Time: %.4fs", t1_time))
print("")

-- Test 2: Inheritance chain (__index of __index)
print("Test 2: 3-Level Inheritance Chain (300K method calls)")
local Base = {}
Base.__index = Base
function Base.new(v) return setmetatable({value=v}, Base) end
function Base:get() return self.value end

local Mid = setmetatable({}, {__index = Base})
Mid.__index = Mid
function Mid.new(v, m) local o = Base.new(v); o.mult=m; return setmetatable(o, Mid) end
function Mid:scaled() return self:get() * self.mult end

local Top = setmetatable({}, {__index = Mid})
Top.__index = Top
function Top.new(v, m, s)
    local o = Mid.new(v, m); o.shift=s; return setmetatable(o, Top)
end
function Top:final() return self:scaled() + self.shift end

local t2_start = os.clock()
local chain_sink = 0
local obj = Top.new(3, 7, 2)
for i = 1, 300000 do
    chain_sink = chain_sink + obj:final()
end
local t2_time = os.clock() - t2_start
print(string.format("  Sink: %d", chain_sink))
print(string.format("  Time: %.4fs", t2_time))
print("")

-- Test 3: Operator Overloading (__add, __mul, __eq, __tostring)
print("Test 3: Metamethod Operators (200K vec2 add+mul operations)")
local Vec2 = {}
Vec2.__index = Vec2
Vec2.__add = function(a, b) return Vec2.new(a.x+b.x, a.y+b.y) end
Vec2.__mul = function(a, s)
    if type(s) == "number" then return Vec2.new(a.x*s, a.y*s) end
    return a.x*s.x + a.y*s.y  -- dot product
end
Vec2.__eq  = function(a, b) return a.x==b.x and a.y==b.y end
function Vec2.new(x, y) return setmetatable({x=x, y=y}, Vec2) end
function Vec2:length() return math.sqrt(self.x*self.x + self.y*self.y) end

local t3_start = os.clock()
local vec_sink = 0
local v = Vec2.new(1, 2)
local u = Vec2.new(3, 4)
for i = 1, 200000 do
    local w = (v + u) * (i % 10 + 1)
    vec_sink = vec_sink + w.x + w.y
end
local t3_time = os.clock() - t3_start
print(string.format("  Sink: %d", vec_sink))
print(string.format("  Time: %.4fs", t3_time))
print("")

-- Test 4: __newindex + __index (proxy table pattern)
print("Test 4: Proxy Table via __newindex/__index (200K reads + 200K writes)")
local function make_proxy(storage)
    local proxy = {}
    local mt = {
        __index    = function(_, k) return storage[k] end,
        __newindex = function(_, k, v)
            storage[k] = v * 2  -- transform on write
        end
    }
    return setmetatable(proxy, mt)
end
local t4_start = os.clock()
local store = {}
local p = make_proxy(store)
for i = 1, 200000 do
    p[i] = i  -- triggers __newindex
end
local proxy_sink = 0
for i = 1, 200000 do
    proxy_sink = proxy_sink + p[i]  -- triggers __index
end
local t4_time = os.clock() - t4_start
print(string.format("  Sink: %d", proxy_sink))
print(string.format("  Time: %.4fs", t4_time))
print("")

-- Test 5: Coroutine Producer/Consumer (resume/yield round-trips)
print("Test 5: Coroutine Producer/Consumer (300K resume/yield pairs)")
local function producer(n)
    for i = 1, n do
        coroutine.yield(i * 3 - 1)
    end
end

local t5_start = os.clock()
local co_sink = 0
-- Batch into chunks so coroutine creation overhead is amortised
local BATCH = 10000
local ROUNDS = 30
for r = 1, ROUNDS do
    local co = coroutine.create(producer)
    coroutine.resume(co, BATCH)  -- pass n
    while true do
        local ok, val = coroutine.resume(co)
        if not ok or val == nil then break end
        co_sink = co_sink + val
    end
end
local t5_time = os.clock() - t5_start
print(string.format("  Sink: %d", co_sink))
print(string.format("  Time: %.4fs", t5_time))
print("")

-- Test 6: Coroutine as State Machine (many short-lived coroutines)
print("Test 6: Short-Lived Coroutines (100K coroutine create+run+collect)")
local function tiny_co(a, b)
    local s = a + b
    coroutine.yield(s)
    coroutine.yield(s * 2)
    return s * 3
end
local t6_start = os.clock()
local co_sm_sink = 0
for i = 1, 100000 do
    local co = coroutine.create(tiny_co)
    local _, v1 = coroutine.resume(co, i, i+1)
    local _, v2 = coroutine.resume(co)
    local _, v3 = coroutine.resume(co)
    co_sm_sink = co_sm_sink + (v1 or 0) + (v2 or 0) + (v3 or 0)
end
local t6_time = os.clock() - t6_start
print(string.format("  Sink: %d", co_sm_sink))
print(string.format("  Time: %.4fs", t6_time))
print("")

local script_total = os.clock() - script_start

print("=== Summary ===")
print(string.format("OOP Dispatch:     %.4fs", t1_time))
print(string.format("Inherit Chain:    %.4fs", t2_time))
print(string.format("Op Overload:      %.4fs", t3_time))
print(string.format("Proxy Table:      %.4fs", t4_time))
print(string.format("Co Producer:      %.4fs", t5_time))
print(string.format("Co State Machine: %.4fs", t6_time))
print(string.format("---------------"))
print(string.format("TOTAL SCRIPT:     %.4fs", script_total))
print("")
print("RESULTS_CSV:" .. t1_time .. "," .. t2_time .. "," .. t3_time .. "," .. t4_time .. "," .. t5_time .. "," .. t6_time .. "," .. script_total)
