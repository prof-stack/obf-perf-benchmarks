/**
 * bench_general.cs — General Computational Benchmark (C#)
 *
 * Compile:  csc bench_general.cs -out:bench_general.exe   (Mono)
 *           dotnet run                                      (.NET 6+, add a .csproj)
 *           csc -optimize+ bench_general.cs                (optimised build)
 *
 * Compare native vs. obfuscated builds:
 *   ConfuserEx, Babel Obfuscator, .NET Reactor, Eazfuscator, SmartAssembly
 *
 * Uses Stopwatch (high-resolution) for all timings.
 * RESULTS_CSV printed at end for easy log parsing / version tracking.
 */

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

class Benchmark
{
    // ── helpers ───────────────────────────────────────────────────────────────
    static double Elapsed(Stopwatch sw) => sw.Elapsed.TotalSeconds;
    static readonly Random Rng = new Random(42);

    static void Main()
    {
        var scriptSw = Stopwatch.StartNew();

        Console.WriteLine("=== General Computational Benchmark (C#) ===");
        Console.WriteLine("Testing: arithmetic, dicts, strings, methods, math, combat sim");
        Console.WriteLine();

        // ── Test 1: Arithmetic (1M iterations) ───────────────────────────────
        Console.WriteLine("Test 1: Arithmetic Operations (1M iterations)");
        var sw = Stopwatch.StartNew();
        double total = 0;
        for (int i = 1; i <= 1_000_000; i++)
            total += (i * 2) - (i / 2.0) + (i % 100);
        sw.Stop();
        double t1 = Elapsed(sw);
        Console.WriteLine($"  Result: {(long)total}");
        Console.WriteLine($"  Time:   {t1:F4}s");
        Console.WriteLine();

        // ── Test 2: Dictionary Operations (100K inserts + lookups) ───────────
        Console.WriteLine("Test 2: Dictionary Operations (100K insertions + lookups)");
        sw = Stopwatch.StartNew();
        var data = new Dictionary<int, (int id, int value, string name)>(100_000);
        for (int i = 1; i <= 100_000; i++)
            data[i] = (i, i * 2, $"item_{i}");
        long lookupSum = 0;
        for (int i = 1; i <= 100_000; i++)
            lookupSum += data[i].value;
        sw.Stop();
        double t2 = Elapsed(sw);
        Console.WriteLine($"  Entries:    {data.Count}");
        Console.WriteLine($"  Lookup sum: {lookupSum}");
        Console.WriteLine($"  Time:       {t2:F4}s");
        Console.WriteLine();

        // ── Test 3: String Operations (50K format cycles) ────────────────────
        Console.WriteLine("Test 3: String Operations (50K format cycles)");
        sw = Stopwatch.StartNew();
        long strSink = 0;
        for (int i = 1; i <= 50_000; i++)
        {
            string s = $"player_{i}_score_{i * 3:D5}_rank_{i / 7.0:F2}";
            strSink += s.Length;
        }
        sw.Stop();
        double t3 = Elapsed(sw);
        Console.WriteLine($"  Sink: {strSink}");
        Console.WriteLine($"  Time: {t3:F4}s");
        Console.WriteLine();

        // ── Test 4: Method Calls (500K calls) ────────────────────────────────
        Console.WriteLine("Test 4: Method Calls (500K calls)");
        sw = Stopwatch.StartNew();
        long funcSum = 0;
        for (int i = 1; i <= 500_000; i++)
            funcSum += TestFunc(i, i + 1, i + 2);
        sw.Stop();
        double t4 = Elapsed(sw);
        Console.WriteLine($"  Result: {funcSum}");
        Console.WriteLine($"  Time:   {t4:F4}s");
        Console.WriteLine();

        // ── Test 5: Math Library (200K iterations) ───────────────────────────
        Console.WriteLine("Test 5: Math Library Operations (200K iterations)");
        sw = Stopwatch.StartNew();
        double mathSum = 0;
        for (int i = 1; i <= 200_000; i++)
            mathSum += Math.Floor(i / 3.7) + Math.Ceiling(i / 2.1) + Math.Abs(-i);
        sw.Stop();
        double t5 = Elapsed(sw);
        Console.WriteLine($"  Result: {(long)mathSum}");
        Console.WriteLine($"  Time:   {t5:F4}s");
        Console.WriteLine();

        // ── Test 6: StringBuilder (100K multi-part builds) ───────────────────
        Console.WriteLine("Test 6: StringBuilder (100K multi-part builds)");
        sw = Stopwatch.StartNew();
        var parts = new[] { "alpha", "beta", "gamma", "delta", "epsilon", "zeta" };
        long sbSink = 0;
        for (int i = 1; i <= 100_000; i++)
        {
            var sb = new StringBuilder();
            for (int j = 0; j < parts.Length; j++)
                sb.Append(parts[j]).Append('_').Append(i * (j + 1)).Append('|');
            sbSink += sb.Length;
        }
        sw.Stop();
        double t6 = Elapsed(sw);
        Console.WriteLine($"  Sink: {sbSink}");
        Console.WriteLine($"  Time: {t6:F4}s");
        Console.WriteLine();

        // ── Test 7: Combat Simulation (1K battles) ───────────────────────────
        Console.WriteLine("Test 7: Combat Simulation (1K battles)");
        sw = Stopwatch.StartNew();
        int totalRounds = 0;
        for (int i = 0; i < 1_000; i++)
            totalRounds += SimulateCombat();
        sw.Stop();
        double t7 = Elapsed(sw);
        Console.WriteLine($"  Total rounds: {totalRounds}");
        Console.WriteLine($"  Time:         {t7:F4}s");
        Console.WriteLine();

        // ── Test 8: Heavy Combat (5K battles) ────────────────────────────────
        Console.WriteLine("Test 8: Heavy Combat Load (5K battles)");
        sw = Stopwatch.StartNew();
        int heavyRounds = 0;
        for (int i = 0; i < 5_000; i++)
            heavyRounds += SimulateCombat();
        sw.Stop();
        double t8 = Elapsed(sw);
        Console.WriteLine($"  Total rounds: {heavyRounds}");
        Console.WriteLine($"  Time:         {t8:F4}s");
        Console.WriteLine();

        // ── Test 9: List Sort + LINQ (5K sorts of 500-element lists) ─────────
        Console.WriteLine("Test 9: List Sort (5K sorts of 500 elements)");
        sw = Stopwatch.StartNew();
        long sortSink = 0;
        for (int i = 1; i <= 5_000; i++)
        {
            var list = new List<int>(500);
            int seed = i * 31_337;
            for (int j = 0; j < 500; j++)
            {
                seed = unchecked(seed * 1_664_525 + 1_013_904_223);
                list.Add(Math.Abs(seed) % 10_000);
            }
            list.Sort();
            sortSink += list[0] + list[list.Count - 1];
        }
        sw.Stop();
        double t9 = Elapsed(sw);
        Console.WriteLine($"  Sink: {sortSink}");
        Console.WriteLine($"  Time: {t9:F4}s");
        Console.WriteLine();

        // ── Summary ──────────────────────────────────────────────────────────
        scriptSw.Stop();
        double scriptTotal = Elapsed(scriptSw);

        Console.WriteLine("=== Summary ===");
        Console.WriteLine($"Arithmetic:    {t1:F4}s");
        Console.WriteLine($"Dictionary:    {t2:F4}s");
        Console.WriteLine($"Strings:       {t3:F4}s");
        Console.WriteLine($"Methods:       {t4:F4}s");
        Console.WriteLine($"Math Library:  {t5:F4}s");
        Console.WriteLine($"StringBuilder: {t6:F4}s");
        Console.WriteLine($"Combat (1K):   {t7:F4}s");
        Console.WriteLine($"Combat (5K):   {t8:F4}s");
        Console.WriteLine($"List Sort:     {t9:F4}s");
        Console.WriteLine("---------------");
        Console.WriteLine($"TOTAL SCRIPT:  {scriptTotal:F4}s");
        Console.WriteLine();
        Console.WriteLine($"RESULTS_CSV:{t1},{t2},{t3},{t4},{t5},{t6},{t7},{t8},{t9},{scriptTotal}");
    }

    // ── helpers ───────────────────────────────────────────────────────────────
    static long TestFunc(long a, long b, long c) => (a + b) * c;

    static int SimulateCombat()
    {
        double playerHp = 100, playerAtk = 15, playerDef = 5, playerCrit = 0.10;
        double enemyHp  =  80, enemyAtk  = 12, enemyDef  = 3, enemyCrit  = 0.05;

        int TakeDamage(ref double targetHp, double atkAtk, double targetDef, double crit)
        {
            int dmg = Math.Max(1, (int)(atkAtk - targetDef));
            if (Rng.NextDouble() < crit) dmg *= 2;
            targetHp -= dmg;
            return dmg;
        }

        int rounds = 0;
        while (playerHp > 0 && enemyHp > 0 && rounds < 100)
        {
            TakeDamage(ref enemyHp,  playerAtk, enemyDef,  playerCrit);
            if (enemyHp > 0)
                TakeDamage(ref playerHp, enemyAtk, playerDef, enemyCrit);
            rounds++;
        }
        return rounds;
    }
}
