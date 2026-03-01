"""
bench_advanced.py — Advanced Python Benchmark
Tests OOP dispatch, recursion, memory/GC pressure, generator pipelines,
comprehensions, and lambda/closure overhead.
Run native vs. obfuscated (PyArmor, etc.) to isolate instrumentation costs.
"""

import time
import math
import sys

def clock():
    return time.perf_counter()

script_start = clock()
sys.setrecursionlimit(50_000)

print("=== Advanced Benchmark (Python) ===")
print("Testing: OOP, recursion, memory churn, generators, comprehensions, closures")
print()

# ── Test 1: OOP Method Dispatch ───────────────────────────────────────────────
print("Test 1: OOP Method Dispatch (500K calls)")

class Animal:
    __slots__ = ("name", "hp", "atk", "xp")

    def __init__(self, name, hp, atk):
        self.name = name
        self.hp   = hp
        self.atk  = atk
        self.xp   = 0

    def attack(self, other):
        dmg = max(1, self.atk - int(other.hp * 0.05))
        other.hp -= dmg
        self.xp  += dmg
        return dmg

t1 = clock()
wolf  = Animal("Wolf",  999_999, 10)
sheep = Animal("Sheep", 999_999,  1)
dmg_sink = 0
for _ in range(500_000):
    dmg_sink += wolf.attack(sheep)
t1 = clock() - t1
print(f"  Damage: {dmg_sink}")
print(f"  Time:   {t1:.4f}s")
print()

# ── Test 2: Inheritance Chain (3 levels) ──────────────────────────────────────
print("Test 2: 3-Level Inheritance Chain (300K calls)")

class Base:
    def __init__(self, v):    self.value = v
    def get(self):            return self.value

class Mid(Base):
    def __init__(self, v, m): super().__init__(v); self.mult = m
    def scaled(self):         return self.get() * self.mult

class Top(Mid):
    def __init__(self, v, m, s): super().__init__(v, m); self.shift = s
    def final(self):             return self.scaled() + self.shift

t2 = clock()
obj = Top(3, 7, 2)
chain_sink = 0
for _ in range(300_000):
    chain_sink += obj.final()
t2 = clock() - t2
print(f"  Sink: {chain_sink}")
print(f"  Time: {t2:.4f}s")
print()

# ── Test 3: Recursive Fibonacci (naive) ───────────────────────────────────────
print("Test 3: Naive Fibonacci fib(30), 300 times")

def fib(n):
    if n <= 1: return n
    return fib(n - 1) + fib(n - 2)

t3 = clock()
fib_sink = sum(fib(30) for _ in range(300))
t3 = clock() - t3
print(f"  fib(30) = {fib(30)}")
print(f"  Sink:    {fib_sink}")
print(f"  Time:    {t3:.4f}s")
print()

# ── Test 4: Memory Churn (alloc + GC) ─────────────────────────────────────────
print("Test 4: Dict Churn (200K alloc+abandon cycles)")
t4 = clock()
churn_sink = 0
for i in range(1, 200_001):
    d = {"a": i, "b": i * 2, "c": i * 3, "d": i * 4}
    churn_sink += d["a"] + d["d"]
t4 = clock() - t4
print(f"  Sink: {churn_sink}")
print(f"  Time: {t4:.4f}s")
print()

# ── Test 5: List Comprehensions vs Loops ──────────────────────────────────────
print("Test 5: List Comprehensions (1K lists of 1K elements each)")
t5 = clock()
comp_sink = 0
for i in range(1, 1_001):
    lst = [j * i + (j % 7) for j in range(1_000)]
    comp_sink += lst[0] + lst[-1]
t5 = clock() - t5
print(f"  Sink: {comp_sink}")
print(f"  Time: {t5:.4f}s")
print()

# ── Test 6: Generator Pipeline ────────────────────────────────────────────────
print("Test 6: Generator Pipeline (500K items through 3-stage pipeline)")

def source(n):
    for i in range(1, n + 1):
        yield i

def stage_filter(it):
    for x in it:
        if x % 3 != 0:
            yield x

def stage_transform(it):
    for x in it:
        yield x * x - x + 1

t6 = clock()
pipeline = stage_transform(stage_filter(source(500_000)))
gen_sink = sum(pipeline)
t6 = clock() - t6
print(f"  Sink: {gen_sink}")
print(f"  Time: {t6:.4f}s")
print()

# ── Test 7: Closure / Lambda Overhead ─────────────────────────────────────────
print("Test 7: Closure Factory (300K closures created + called)")

def make_adder(n):
    return lambda x: x + n

t7 = clock()
closure_sink = 0
for i in range(1, 300_001):
    adder = make_adder(i)
    closure_sink += adder(1)
t7 = clock() - t7
print(f"  Sink: {closure_sink}")
print(f"  Time: {t7:.4f}s")
print()

# ── Test 8: Merge Sort (2K arrays × 200 elements) ─────────────────────────────
print("Test 8: Merge Sort (2K arrays of 200 elements)")

def merge_sort(arr):
    if len(arr) <= 1:
        return arr
    mid = len(arr) // 2
    left  = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    result, i, j = [], 0, 0
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i]); i += 1
        else:
            result.append(right[j]); j += 1
    result.extend(left[i:]); result.extend(right[j:])
    return result

def lcg(seed):
    s = seed
    while True:
        s = (s * 1_664_525 + 1_013_904_223) & 0xFFFFFFFF
        yield s % 10_000

t8 = clock()
sort_sink = 0
for i in range(1, 2_001):
    gen = lcg(i * 31_337)
    arr = [next(gen) for _ in range(200)]
    sorted_arr = merge_sort(arr)
    sort_sink += sorted_arr[0] + sorted_arr[-1]
t8 = clock() - t8
print(f"  Sink: {sort_sink}")
print(f"  Time: {t8:.4f}s")
print()

# ── Summary ───────────────────────────────────────────────────────────────────
script_total = clock() - script_start

print("=== Summary ===")
print(f"OOP Dispatch:   {t1:.4f}s")
print(f"Inherit Chain:  {t2:.4f}s")
print(f"Fibonacci:      {t3:.4f}s")
print(f"Dict Churn:     {t4:.4f}s")
print(f"Comprehensions: {t5:.4f}s")
print(f"Generator Pipe: {t6:.4f}s")
print(f"Closures:       {t7:.4f}s")
print(f"Merge Sort:     {t8:.4f}s")
print("---------------")
print(f"TOTAL SCRIPT:   {script_total:.4f}s")
print()
print(f"RESULTS_CSV:{t1},{t2},{t3},{t4},{t5},{t6},{t7},{t8},{script_total}")
