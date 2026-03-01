# runtime-benchmarks

A collection of performance benchmarks across multiple languages for measuring execution overhead primarily useful for comparing native/interpreted execution against obfuscated or compiled variants of the same script.

Each benchmark is self-contained and self-timing. No external dependencies, no test frameworks. Just run the script and read the output.

---

## Structure

```
/javascript
  bench_general.js      # arithmetic, objects, strings, function calls, math, combat sim
  bench_advanced.js     # class dispatch, prototype chains, closures, recursion, Map/Set, async

/python
  bench_general.py      # mirrors the JS general suite, dict ops, combat sim
  bench_advanced.py     # OOP, inheritance, recursion, GC churn, generators, comprehensions

/lua
  bench_general.lua     # arithmetic, tables, strings, functions, math library, combat sim
  bench_strings.lua     # format, pattern matching, gsub, byte encode/decode, concat
  bench_memory_gc.lua   # table churn, nested trees, closure factories, string interning
  bench_recursion.lua   # fibonacci, merge sort, hanoi, mutual recursion, tree traversal
  bench_oop_coroutines.lua  # __index chains, metamethods, proxy tables, coroutine resume/yield
```

---

## Running

**Node.js**
```bash
node javascript/bench_general.js
node javascript/bench_advanced.js
```

**Python** (3.8+)
```bash
python python/bench_general.py
python python/bench_advanced.py
```

**Lua / Luau**
```bash
lua lua/bench_general.lua
# or with a Luau runtime:
luau lua/bench_general.lua
```

---

## Output format

Every script prints per-test timings and ends with a `RESULTS_CSV:` line for easy parsing and version tracking:

```
RESULTS_CSV:0.0412,0.1823,0.0751,0.2204,...,0.9341
```

Fields are in the same order as the tests printed above them. The last value is always the total script wall time.

Redirect to a file if you want to store results:
```bash
node javascript/bench_advanced.js >> results/js_advanced_native.txt
```

---

## What it's actually for

The main use case is comparing the same script before and after obfuscation to quantify overhead. Timing is done with high-resolution internal clocks (`os.clock()`, `time.perf_counter()`, `process.hrtime.bigint()`) and starts *after* the runtime has loaded, so you're measuring the script logic rather than VM startup.

Useful comparisons:
- native vs. [PyArmor](https://pyarmor.readthedocs.io/) / Cython / Nuitka (Python)
- native vs. [javascript-obfuscator](https://github.com/javascript-obfuscator/javascript-obfuscator) / Terser (JavaScript)
- native vs. Luraph / Ironbrew / custom VM obfuscators (Lua/Luau)

A 1.0x–1.3x slowdown on arithmetic and function calls is generally fine. If string operations or metatable lookups are 3–5x slower, that points to specific instrumentation patterns worth investigating.

---

## Planned languages

- **C#** — for Unity/Godot workflows and .NET obfuscators (ConfuserEx, Babel, .NET Reactor)
- **Java** — ProGuard/R8, useful for Android and Minecraft modding contexts
- **TypeScript** — `tsc` output vs obfuscated builds, natural extension of the JS folder
- **Go** — compiled near-native baseline, increasingly common in game tooling

PRs welcome.

---

## Notes

- Results will vary between machines, OS schedulers, and runtime versions. Always compare native vs. obfuscated on the *same machine in the same session* to get meaningful numbers.
- The combat simulations use `math.random()` / `random.random()` which are not seeded, so round counts will vary slightly between runs — the timing is still valid.
- For JS, the async test in `bench_advanced.js` wraps in an IIFE so the `RESULTS_CSV` line prints after all promises resolve. Don't bail early if you see output pause briefly.
