-- Memory & GC Stress Benchmark
-- Tests allocation patterns, table churn, and garbage collection pressure.
-- Obfuscators that generate excessive temporaries/closures will show elevated times here.

local script_start = os.clock()

print("=== Memory & GC Stress Benchmark ===")
print("Targets: allocation rate, table churn, closure heap pressure")
print("")

-- Test 1: Rapid Table Allocation & Abandonment (GC churn)
print("Test 1: Table Churn (200K alloc+abandon cycles)")
local t1_start = os.clock()
local sink = 0
for i = 1, 200000 do
    local t = {a = i, b = i * 2, c = i * 3, d = i * 4}
    sink = sink + t.a + t.d  -- prevent dead-code elimination
end
local t1_time = os.clock() - t1_start
print(string.format("  Sink: %d", sink))
print(string.format("  Time: %.4fs", t1_time))
print("")

-- Test 2: Nested Table Trees (deep allocation)
print("Test 2: Nested Table Trees (20K trees, depth 5)")
local t2_start = os.clock()
local function make_tree(depth, value)
    if depth == 0 then return {leaf = value} end
    return {
        left  = make_tree(depth - 1, value * 2),
        right = make_tree(depth - 1, value * 2 + 1),
        value = value
    }
end
local tree_sink = 0
for i = 1, 20000 do
    local tree = make_tree(5, i)
    tree_sink = tree_sink + tree.value  -- touch root only; GC cleans subtrees
end
local t2_time = os.clock() - t2_start
print(string.format("  Sink: %d", tree_sink))
print(string.format("  Time: %.4fs", t2_time))
print("")

-- Test 3: Closure Factory (heap-allocated upvalue pressure)
print("Test 3: Closure Factory (300K closures created)")
local t3_start = os.clock()
local function make_adder(n)
    return function(x) return x + n end
end
local closure_sink = 0
for i = 1, 300000 do
    local adder = make_adder(i)
    closure_sink = closure_sink + adder(1)
end
local t3_time = os.clock() - t3_start
print(string.format("  Sink: %d", closure_sink))
print(string.format("  Time: %.4fs", t3_time))
print("")

-- Test 4: Large Table Resize (rehash triggers)
print("Test 4: Large Table Resize (sequential + random keyed inserts)")
local t4_start = os.clock()
local big = {}
for i = 1, 100000 do
    big[i] = i  -- array part
end
for i = 1, 50000 do
    big["key_" .. i] = i  -- hash part
end
local resize_sink = 0
for i = 1, 100000 do resize_sink = resize_sink + big[i] end
local t4_time = os.clock() - t4_start
print(string.format("  Sink: %d", resize_sink))
print(string.format("  Time: %.4fs", t4_time))
print("")

-- Test 5: String Interning Pressure (many short unique strings)
print("Test 5: String Interning (100K unique string keys in table)")
local t5_start = os.clock()
local interned = {}
for i = 1, 100000 do
    interned["k" .. i] = i
end
local intern_sink = 0
for i = 1, 100000 do
    intern_sink = intern_sink + interned["k" .. i]
end
local t5_time = os.clock() - t5_start
print(string.format("  Sink: %d", intern_sink))
print(string.format("  Time: %.4fs", t5_time))
print("")

-- Test 6: Upvalue Mutation (shared mutable state in closures)
print("Test 6: Upvalue Mutation (500K reads+writes via closures)")
local t6_start = os.clock()
local function make_counter(init)
    local n = init
    return {
        inc = function() n = n + 1 end,
        get = function() return n end
    }
end
local counter = make_counter(0)
for i = 1, 500000 do
    counter.inc()
end
local t6_time = os.clock() - t6_start
print(string.format("  Final count: %d", counter.get()))
print(string.format("  Time: %.4fs", t6_time))
print("")

local script_total = os.clock() - script_start

print("=== Summary ===")
print(string.format("Table Churn:       %.4fs", t1_time))
print(string.format("Nested Trees:      %.4fs", t2_time))
print(string.format("Closure Factory:   %.4fs", t3_time))
print(string.format("Table Resize:      %.4fs", t4_time))
print(string.format("String Interning:  %.4fs", t5_time))
print(string.format("Upvalue Mutation:  %.4fs", t6_time))
print(string.format("---------------"))
print(string.format("TOTAL SCRIPT:      %.4fs", script_total))
print("")
print("RESULTS_CSV:" .. t1_time .. "," .. t2_time .. "," .. t3_time .. "," .. t4_time .. "," .. t5_time .. "," .. t6_time .. "," .. script_total)
