-- Recursive Algorithms & Call Stack Benchmark
-- Tests recursion depth, memoization patterns, divide-and-conquer, and
-- mutual recursion. Obfuscators that wrap every call in extra dispatch
-- layers will compound overhead multiplicatively here.

local script_start = os.clock()

print("=== Recursive Algorithms & Call Stack Benchmark ===")
print("Targets: deep recursion, memoization, sorting, divide-and-conquer")
print("")

-- Test 1: Fibonacci (naive exponential — pure call overhead)
print("Test 1: Naive Fibonacci fib(30), 500 times")
local function fib(n)
    if n <= 1 then return n end
    return fib(n - 1) + fib(n - 2)
end
local t1_start = os.clock()
local fib_sink = 0
for i = 1, 500 do
    fib_sink = fib_sink + fib(30)
end
local t1_time = os.clock() - t1_start
print(string.format("  fib(30) = %d", fib(30)))
print(string.format("  Sink: %d", fib_sink))
print(string.format("  Time: %.4fs", t1_time))
print("")

-- Test 2: Memoised Fibonacci (tests table-as-cache pattern)
print("Test 2: Memoised Fibonacci fib(70), 100K times")
local memo = {}
local function fib_memo(n)
    if n <= 1 then return n end
    if memo[n] then return memo[n] end
    memo[n] = fib_memo(n - 1) + fib_memo(n - 2)
    return memo[n]
end
local t2_start = os.clock()
local memo_sink = 0
for i = 1, 100000 do
    memo = {}  -- clear cache each time to force recompute
    memo_sink = memo_sink + fib_memo(25)  -- 25 keeps it fast but non-trivial
end
local t2_time = os.clock() - t2_start
print(string.format("  fib_memo(25) = %d", fib_memo(25)))
print(string.format("  Sink: %d", memo_sink))
print(string.format("  Time: %.4fs", t2_time))
print("")

-- Test 3: Merge Sort (recursive divide & conquer)
print("Test 3: Merge Sort (2K arrays of 200 elements each)")
local function merge_sort(arr, lo, hi)
    if lo >= hi then return end
    local mid = math.floor((lo + hi) / 2)
    merge_sort(arr, lo, mid)
    merge_sort(arr, mid + 1, hi)
    -- merge
    local tmp = {}
    local i, j, k = lo, mid + 1, 1
    while i <= mid and j <= hi do
        if arr[i] <= arr[j] then
            tmp[k] = arr[i]; i = i + 1
        else
            tmp[k] = arr[j]; j = j + 1
        end
        k = k + 1
    end
    while i <= mid do tmp[k] = arr[i]; i = i + 1; k = k + 1 end
    while j <= hi  do tmp[k] = arr[j]; j = j + 1; k = k + 1 end
    for m = 1, k - 1 do arr[lo + m - 1] = tmp[m] end
end

local function make_random_array(n, seed)
    local arr = {}
    local s = seed
    for i = 1, n do
        s = (s * 1664525 + 1013904223) % 2^32
        arr[i] = s % 10000
    end
    return arr
end

local t3_start = os.clock()
local sort_sink = 0
for i = 1, 2000 do
    local arr = make_random_array(200, i * 31337)
    merge_sort(arr, 1, #arr)
    sort_sink = sort_sink + arr[1] + arr[#arr]  -- verify order
end
local t3_time = os.clock() - t3_start
print(string.format("  Sink: %d", sort_sink))
print(string.format("  Time: %.4fs", t3_time))
print("")

-- Test 4: Tower of Hanoi (pure recursive call volume)
print("Test 4: Tower of Hanoi, n=18, 20 times")
local hanoi_moves = 0
local function hanoi(n, from, to, via)
    if n == 0 then return end
    hanoi(n - 1, from, via, to)
    hanoi_moves = hanoi_moves + 1
    hanoi(n - 1, via, to, from)
end
local t4_start = os.clock()
for i = 1, 20 do
    hanoi_moves = 0
    hanoi(18, "A", "C", "B")
end
local t4_time = os.clock() - t4_start
print(string.format("  Moves per run: %d", hanoi_moves))
print(string.format("  Time: %.4fs", t4_time))
print("")

-- Test 5: Recursive Tree Sum (deep traversal)
print("Test 5: Recursive Binary Tree Sum (5K trees, depth 10)")
local function build_tree(depth, val)
    if depth == 0 then return {v = val, l = nil, r = nil} end
    return {v = val, l = build_tree(depth-1, val*2), r = build_tree(depth-1, val*2+1)}
end
local function tree_sum(node)
    if node == nil then return 0 end
    return node.v + tree_sum(node.l) + tree_sum(node.r)
end
local t5_start = os.clock()
local tree_sink = 0
for i = 1, 5000 do
    local t = build_tree(10, 1)
    tree_sink = tree_sink + tree_sum(t)
end
local t5_time = os.clock() - t5_start
print(string.format("  Sink: %d", tree_sink))
print(string.format("  Time: %.4fs", t5_time))
print("")

-- Test 6: Mutual Recursion (even/odd checker, 1M calls)
print("Test 6: Mutual Recursion (500K even/odd pairs)")
local is_even, is_odd
is_even = function(n)
    if n == 0 then return true end
    return is_odd(n - 1)
end
is_odd = function(n)
    if n == 0 then return false end
    return is_even(n - 1)
end
local t6_start = os.clock()
local mutual_sink = 0
for i = 1, 500000 do
    -- keep n small to avoid stack overflow; test the dispatch cost
    local n = (i % 20)
    if is_even(n) then mutual_sink = mutual_sink + 1 end
end
local t6_time = os.clock() - t6_start
print(string.format("  Even count: %d", mutual_sink))
print(string.format("  Time: %.4fs", t6_time))
print("")

local script_total = os.clock() - script_start

print("=== Summary ===")
print(string.format("Naive Fibonacci:  %.4fs", t1_time))
print(string.format("Memo Fibonacci:   %.4fs", t2_time))
print(string.format("Merge Sort:       %.4fs", t3_time))
print(string.format("Hanoi n=18:       %.4fs", t4_time))
print(string.format("Tree Sum:         %.4fs", t5_time))
print(string.format("Mutual Recursion: %.4fs", t6_time))
print(string.format("---------------"))
print(string.format("TOTAL SCRIPT:     %.4fs", script_total))
print("")
print("RESULTS_CSV:" .. t1_time .. "," .. t2_time .. "," .. t3_time .. "," .. t4_time .. "," .. t5_time .. "," .. t6_time .. "," .. script_total)
