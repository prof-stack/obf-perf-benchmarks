-- Comprehensive Performance Benchmark
-- This script measures its own performance internally
-- Can be run native or obfuscated to compare execution characteristics

-- IMPORTANT: Start timing INSIDE the script (not VM warm-up)
local script_start = os.clock()

print("=== Comprehensive Performance Benchmark ===")
print("Testing computational overhead in obfuscated vs native execution")
print("")

-- Test 1: Simple Arithmetic (computational baseline)
print("Test 1: Arithmetic Operations (1M iterations)")
local arith_start = os.clock()
local sum = 0
for i = 1, 1000000 do
    sum = sum + (i * 2) - (i / 2) + (i % 100)
end
local arith_time = os.clock() - arith_start
print(string.format("  Result: %d", sum))
print(string.format("  Time: %.4fs", arith_time))
print("")

-- Test 2: Table Operations (common game pattern)
print("Test 2: Table Operations (100K insertions + lookups)")
local table_start = os.clock()
local data = {}
for i = 1, 100000 do
    data[i] = {id = i, value = i * 2, name = "item_" .. i}
end
local lookup_sum = 0
for i = 1, 100000 do
    lookup_sum = lookup_sum + data[i].value
end
local table_time = os.clock() - table_start
print(string.format("  Entries: %d", #data))
print(string.format("  Lookup sum: %d", lookup_sum))
print(string.format("  Time: %.4fs", table_time))
print("")

-- Test 3: String Operations (string encryption overhead test)
print("Test 3: String Operations (50K concatenations)")
local string_start = os.clock()
local str = ""
for i = 1, 50000 do
    str = "value_" .. i .. "_suffix"
    -- Force string creation, don't accumulate to avoid memory issues
    local len = #str
end
local string_time = os.clock() - string_start
print(string.format("  Final string length: %d", #str))
print(string.format("  Time: %.4fs", string_time))
print("")

-- Test 4: Function Calls (dispatch overhead test)
print("Test 4: Function Calls (500K calls)")
local function test_func(a, b, c)
    return (a + b) * c
end

local func_start = os.clock()
local func_sum = 0
for i = 1, 500000 do
    func_sum = func_sum + test_func(i, i+1, i+2)
end
local func_time = os.clock() - func_start
print(string.format("  Result: %d", func_sum))
print(string.format("  Time: %.4fs", func_time))
print("")

-- Test 5: Math Library (DBSEG constant overhead test)
print("Test 5: Math Library Operations (200K iterations)")
local math_start = os.clock()
local math_sum = 0
for i = 1, 200000 do
    math_sum = math_sum + math.floor(i / 3.7) + math.ceil(i / 2.1) + math.abs(-i)
end
local math_time = os.clock() - math_start
print(string.format("  Result: %d", math_sum))
print(string.format("  Time: %.4fs", math_time))
print("")

-- Test 6: Combat Simulation (real-world game logic - 1K iterations)
print("Test 6: Combat Simulation (1K battles)")
local combat_start = os.clock()

local function simulate_combat()
    local player = {health = 100, attack = 15, defense = 5, crit_chance = 0.1}
    local enemy = {health = 80, attack = 12, defense = 3, crit_chance = 0.05}

    local function take_damage(target, attacker)
        local damage = math.max(1, attacker.attack - target.defense)
        if math.random() < attacker.crit_chance then
            damage = damage * 2
        end
        target.health = target.health - damage
        return damage
    end

    local rounds = 0
    while player.health > 0 and enemy.health > 0 and rounds < 100 do
        take_damage(enemy, player)
        if enemy.health > 0 then
            take_damage(player, enemy)
        end
        rounds = rounds + 1
    end

    return rounds
end

local total_rounds = 0
for i = 1, 1000 do
    total_rounds = total_rounds + simulate_combat()
end
local combat_time = os.clock() - combat_start
print(string.format("  Total rounds: %d", total_rounds))
print(string.format("  Time: %.4fs", combat_time))
print("")

-- Test 7: Heavy Iteration (5K iterations of combat)
print("Test 7: Heavy Combat Load (5K battles)")
local heavy_start = os.clock()
local heavy_rounds = 0
for i = 1, 5000 do
    heavy_rounds = heavy_rounds + simulate_combat()
end
local heavy_time = os.clock() - heavy_start
print(string.format("  Total rounds: %d", heavy_rounds))
print(string.format("  Time: %.4fs", heavy_time))
print("")

-- Total script execution time
local script_end = os.clock()
local script_total = script_end - script_start

print("=== Summary ===")
print(string.format("Arithmetic:      %.4fs", arith_time))
print(string.format("Tables:          %.4fs", table_time))
print(string.format("Strings:         %.4fs", string_time))
print(string.format("Functions:       %.4fs", func_time))
print(string.format("Math Library:    %.4fs", math_time))
print(string.format("Combat (1K):     %.4fs", combat_time))
print(string.format("Combat (5K):     %.4fs", heavy_time))
print(string.format("---------------"))
print(string.format("TOTAL SCRIPT:    %.4fs", script_total))
print("")

-- Output as CSV for storing and parsing for version tracking
print("RESULTS_CSV:" .. arith_time .. "," .. table_time .. "," .. string_time .. "," .. func_time .. "," .. math_time .. "," .. combat_time .. "," .. heavy_time .. "," .. script_total)
