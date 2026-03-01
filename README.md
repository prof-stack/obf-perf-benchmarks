# runtime-benchmarks

A collection of performance benchmarks across multiple languages for measuring execution overhead primarily useful for comparing native/interpreted execution against obfuscated or compiled variants of the same script.

Each benchmark is self-contained and self-timing. No external dependencies, no test frameworks. Just run the script and read the output.

---

## Structure

```
/javascript
  bench_general.js        # arithmetic, objects, strings, function calls, math, combat sim
  bench_advanced.js       # class dispatch, prototype chains, closures, recursion, Map/Set, async

/typescript
  bench_general.ts        # typed arithmetic, Map<K,V>, generics, interfaces, combat sim, array pipeline

/python
  bench_general.py        # mirrors the JS general suite, dict ops, combat sim
  bench_advanced.py       # OOP, inheritance, recursion, GC churn, generators, comprehensions

/c#
  bench_general.cs        # arithmetic, Dictionary, strings, methods, math, StringBuilder, combat sim

/java
  BenchGeneral.java       # arithmetic, HashMap, strings, methods, math, StringBuilder, combat sim

/lua
  bench_general.lua       # arithmetic, tables, strings, functions, math library, combat sim
  bench_strings.lua       # format, pattern matching, gsub, byte encode/decode, concat
  bench_memory_gc.lua     # table churn, nested trees, closure factories, string interning
  bench_recursion.lua     # fibonacci, merge sort, hanoi, mutual recursion, tree traversal
  bench_oop_coroutines.lua  # __index chains, metamethods, proxy tables, coroutine resume/yield
```

---

## Running

**Node.js**
```bash
node javascript/bench_general.js
node javascript/bench_advanced.js
```

**TypeScript** (pick one)
```bash
# Option 1 — run directly, no compile step
npx ts-node typescript/bench_general.ts

# Option 2 — compile first, then compare output vs obfuscated build
tsc typescript/bench_general.ts --outDir typescript/out
node typescript/out/bench_general.js
```

**Python** (3.8+)
```bash
python python/bench_general.py
python python/bench_advanced.py
```

**C#**
```bash
# .NET 6+ (recommended)
cd csharp && dotnet run

# Mono
mcs csharp/bench_general.cs -out:bench_general.exe && mono bench_general.exe

# Optimised build
mcs -optimize+ csharp/bench_general.cs -out:bench_general.exe && mono bench_general.exe
```

**Java**
```bash
javac java/BenchGeneral.java -d java/out
java -cp java/out BenchGeneral

# With server JIT (recommended for a warm baseline)
java -server -cp java/out BenchGeneral
```

**Lua / Luau**
```bash
lua lua/bench_general.lua
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
java -cp java/out BenchGeneral   >> results/java_general_native.txt
```

---

## What it's actually for

The main use case is comparing the same script before and after obfuscation to quantify overhead. Timing is done with high-resolution internal clocks (`Stopwatch`, `System.nanoTime()`, `process.hrtime.bigint()`, `time.perf_counter()`, `os.clock()`) and starts *after* the runtime has loaded, so you're measuring script logic rather than VM startup.

Useful comparisons by language:

| Language | Common obfuscators to test against |
|---|---|
| JavaScript | javascript-obfuscator, Terser, obfuscator.io |
| TypeScript | tsc + javascript-obfuscator pipeline, ts-transformer-obfuscate |
| Python | PyArmor, Cython, Nuitka, pyminifier |
| C# | ConfuserEx, Babel Obfuscator, .NET Reactor, Eazfuscator, SmartAssembly |
| Java | ProGuard, R8, Allatori, Zelix KlassMaster, DashO |
| Lua / Luau | Luraph, Ironbrew, custom VM obfuscators |

A 1.0x–1.3x slowdown on arithmetic and function calls is generally acceptable. If string operations, dictionary lookups, or method dispatch are 3–5x slower, that points to specific instrumentation patterns worth investigating.

---

## Notes

- Results will vary between machines, OS schedulers, and runtime versions. Always compare native vs. obfuscated on the *same machine in the same session* for meaningful numbers.
- The combat simulations use unseeded RNG so round counts vary slightly between runs — the timing is still valid.
- **Java**: the JIT needs a warm-up period. For the most stable numbers, either run the benchmark twice and take the second result, or add `-server` to let the JIT compile hot paths before measuring.
- **C#**: release builds (with `-optimize+` or `dotnet build -c Release`) will be measurably faster than debug builds. Make sure you compare obfuscated code against the same build configuration.
- **TypeScript**: since generics and interfaces erase completely at compile time, `bench_general.ts` and the equivalent JS output should produce nearly identical timings when run through `tsc`. Significant divergence usually means the obfuscator is adding runtime type-checking shims.
- For JS/TS, the async test in `bench_advanced.js` wraps in an IIFE so the `RESULTS_CSV` line prints after all promises resolve. Don't bail early if output pauses briefly.

---

## Planned additions

- **Go** — compiled near-native baseline, useful for game tooling and CLI infra comparisons
- `bench_advanced` equivalents for C#, Java, and TypeScript (OOP dispatch, generics stress, async/threading overhead)

PRs welcome.
