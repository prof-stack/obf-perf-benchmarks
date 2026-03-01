"""
bench_general.py — General Computational Benchmark
Mirrors the structure of the Lua suite: arithmetic, dict ops, strings,
function calls, math library, and a combat simulation.
Run native vs. compiled/obfuscated (e.g. PyArmor, Cython, Nuitka) to compare.
"""

import time
import math
import random

def clock():
    return time.perf_counter()

script_start = clock()

print("=== General Computational Benchmark (Python) ===")
print("Testing: arithmetic, dicts, strings, calls, math, simulation")
print()

# ── Test 1: Arithmetic (1M iterations) ────────────────────────────────────────
print("Test 1: Arithmetic Operations (1M iterations)")
t1 = clock()
total = 0
for i in range(1, 1_000_001):
    total += (i * 2) - (i / 2) + (i % 100)
t1 = clock() - t1
print(f"  Result: {int(total)}")
print(f"  Time:   {t1:.4f}s")
print()

# ── Test 2: Dict Operations (100K insertions + lookups) ───────────────────────
print("Test 2: Dict Operations (100K insertions + lookups)")
t2 = clock()
data = {}
for i in range(1, 100_001):
    data[i] = {"id": i, "value": i * 2, "name": f"item_{i}"}
lookup_sum = 0
for i in range(1, 100_001):
    lookup_sum += data[i]["value"]
t2 = clock() - t2
print(f"  Entries:    {len(data)}")
print(f"  Lookup sum: {lookup_sum}")
print(f"  Time:       {t2:.4f}s")
print()

# ── Test 3: String Operations (50K format + join cycles) ──────────────────────
print("Test 3: String Operations (50K format cycles)")
t3 = clock()
sink = 0
for i in range(1, 50_001):
    s = f"player_{i}_score_{i*3:05d}_rank_{i/7.0:.2f}"
    sink += len(s)
t3 = clock() - t3
print(f"  Sink: {sink}")
print(f"  Time: {t3:.4f}s")
print()

# ── Test 4: Function Calls (500K calls) ───────────────────────────────────────
print("Test 4: Function Calls (500K calls)")
def test_func(a, b, c):
    return (a + b) * c

t4 = clock()
func_sum = 0
for i in range(1, 500_001):
    func_sum += test_func(i, i + 1, i + 2)
t4 = clock() - t4
print(f"  Result: {func_sum}")
print(f"  Time:   {t4:.4f}s")
print()

# ── Test 5: Math Library (200K iterations) ────────────────────────────────────
print("Test 5: Math Library Operations (200K iterations)")
t5 = clock()
math_sum = 0
for i in range(1, 200_001):
    math_sum += math.floor(i / 3.7) + math.ceil(i / 2.1) + abs(-i)
t5 = clock() - t5
print(f"  Result: {math_sum}")
print(f"  Time:   {t5:.4f}s")
print()

# ── Test 6: Combat Simulation (1K battles) ────────────────────────────────────
print("Test 6: Combat Simulation (1K battles)")

def simulate_combat():
    player = {"health": 100, "attack": 15, "defense": 5,  "crit": 0.10}
    enemy  = {"health":  80, "attack": 12, "defense": 3,  "crit": 0.05}

    def take_damage(target, attacker):
        dmg = max(1, attacker["attack"] - target["defense"])
        if random.random() < attacker["crit"]:
            dmg *= 2
        target["health"] -= dmg
        return dmg

    rounds = 0
    while player["health"] > 0 and enemy["health"] > 0 and rounds < 100:
        take_damage(enemy, player)
        if enemy["health"] > 0:
            take_damage(player, enemy)
        rounds += 1
    return rounds

t6 = clock()
total_rounds = sum(simulate_combat() for _ in range(1_000))
t6 = clock() - t6
print(f"  Total rounds: {total_rounds}")
print(f"  Time:         {t6:.4f}s")
print()

# ── Test 7: Heavy Combat (5K battles) ─────────────────────────────────────────
print("Test 7: Heavy Combat Load (5K battles)")
t7 = clock()
heavy_rounds = sum(simulate_combat() for _ in range(5_000))
t7 = clock() - t7
print(f"  Total rounds: {heavy_rounds}")
print(f"  Time:         {t7:.4f}s")
print()

# ── Summary ───────────────────────────────────────────────────────────────────
script_total = clock() - script_start

print("=== Summary ===")
print(f"Arithmetic:    {t1:.4f}s")
print(f"Dicts:         {t2:.4f}s")
print(f"Strings:       {t3:.4f}s")
print(f"Functions:     {t4:.4f}s")
print(f"Math Library:  {t5:.4f}s")
print(f"Combat (1K):   {t6:.4f}s")
print(f"Combat (5K):   {t7:.4f}s")
print("---------------")
print(f"TOTAL SCRIPT:  {script_total:.4f}s")
print()
print(f"RESULTS_CSV:{t1},{t2},{t3},{t4},{t5},{t6},{t7},{script_total}")
