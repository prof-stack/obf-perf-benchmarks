-- String & Pattern Operations Benchmark
-- Tests string manipulation, pattern matching, formatting, and byte-level access.
-- Obfuscators that encode strings as byte arrays or use heavy string.gsub
-- for decryption will show disproportionate overhead on these tests.

local script_start = os.clock()

print("=== String & Pattern Operations Benchmark ===")
print("Targets: format, find, gsub, byte/char, reverse, rep, pattern match")
print("")

-- Test 1: string.format (very common in game code / logging)
print("Test 1: string.format (300K format calls)")
local t1_start = os.clock()
local fmt_sink = 0
for i = 1, 300000 do
    local s = string.format("player_%d_score_%05d_rank_%.2f", i, i * 3, i / 7.0)
    fmt_sink = fmt_sink + #s
end
local t1_time = os.clock() - t1_start
print(string.format("  Sink: %d", fmt_sink))
print(string.format("  Time: %.4fs", t1_time))
print("")

-- Test 2: string.find / string.match (pattern engine)
print("Test 2: Pattern Matching (200K find + match calls)")
local t2_start = os.clock()
local subjects = {
    "player_1023_joined_lobby",
    "enemy_unit_id_9921_dead",
    "score:999 combo:12 time:3.45",
    "ERROR: nil value at index 42",
    "item_sword_legendary_lvl80"
}
local match_sink = 0
for i = 1, 200000 do
    local s = subjects[(i % #subjects) + 1]
    local a = string.find(s, "%d+")
    local b = string.match(s, "(%a+)_(%a+)")
    match_sink = match_sink + (a or 0) + (b and #b or 0)
end
local t2_time = os.clock() - t2_start
print(string.format("  Sink: %d", match_sink))
print(string.format("  Time: %.4fs", t2_time))
print("")

-- Test 3: string.gsub (replacement engine — used heavily in obfuscation decode)
print("Test 3: string.gsub (100K replacements)")
local t3_start = os.clock()
local gsub_sink = 0
local template = "Hello [NAME], you have [COUNT] messages and [GOLD] gold."
for i = 1, 100000 do
    local s = template
        :gsub("%[NAME%]",  "Warrior_" .. (i % 100))
        :gsub("%[COUNT%]", tostring(i % 99 + 1))
        :gsub("%[GOLD%]",  tostring(i * 13 % 9999))
    gsub_sink = gsub_sink + #s
end
local t3_time = os.clock() - t3_start
print(string.format("  Sink: %d", gsub_sink))
print(string.format("  Time: %.4fs", t3_time))
print("")

-- Test 4: string.byte / string.char (byte-level encoding/decoding)
print("Test 4: Byte Encode/Decode (150K encode+decode roundtrips)")
local t4_start = os.clock()
local byte_sink = 0
local sample = "The quick brown fox jumps over the lazy dog 1234567890"
for i = 1, 150000 do
    -- encode: XOR each byte by a key
    local key = (i % 127) + 1
    local encoded = {}
    for j = 1, #sample do
        encoded[j] = string.char((string.byte(sample, j) + key) % 256)
    end
    local enc_str = table.concat(encoded)
    byte_sink = byte_sink + #enc_str
end
local t4_time = os.clock() - t4_start
print(string.format("  Sink: %d", byte_sink))
print(string.format("  Time: %.4fs", t4_time))
print("")

-- Test 5: String building via table.concat (correct pattern vs .. accumulation)
print("Test 5: table.concat Building (50K multi-part joins)")
local t5_start = os.clock()
local concat_sink = 0
local parts = {"alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta"}
for i = 1, 50000 do
    local buf = {}
    for j = 1, 8 do
        buf[j] = parts[j] .. "_" .. (i * j)
    end
    local result = table.concat(buf, "|")
    concat_sink = concat_sink + #result
end
local t5_time = os.clock() - t5_start
print(string.format("  Sink: %d", concat_sink))
print(string.format("  Time: %.4fs", t5_time))
print("")

-- Test 6: string.rep + string.reverse (bulk string ops)
print("Test 6: string.rep + string.reverse (200K ops)")
local t6_start = os.clock()
local rep_sink = 0
for i = 1, 200000 do
    local r = string.rep("ab", (i % 20) + 1)
    local v = string.reverse(r)
    rep_sink = rep_sink + #v
end
local t6_time = os.clock() - t6_start
print(string.format("  Sink: %d", rep_sink))
print(string.format("  Time: %.4fs", t6_time))
print("")

local script_total = os.clock() - script_start

print("=== Summary ===")
print(string.format("Format:           %.4fs", t1_time))
print(string.format("Pattern Match:    %.4fs", t2_time))
print(string.format("gsub Replace:     %.4fs", t3_time))
print(string.format("Byte Encode:      %.4fs", t4_time))
print(string.format("table.concat:     %.4fs", t5_time))
print(string.format("rep+reverse:      %.4fs", t6_time))
print(string.format("---------------"))
print(string.format("TOTAL SCRIPT:     %.4fs", script_total))
print("")
print("RESULTS_CSV:" .. t1_time .. "," .. t2_time .. "," .. t3_time .. "," .. t4_time .. "," .. t5_time .. "," .. t6_time .. "," .. script_total)
