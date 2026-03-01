/**
 * BenchGeneral.java — General Computational Benchmark (Java)
 *
 * Compile:  javac BenchGeneral.java
 * Run:      java BenchGeneral
 * Optimised: java -server -XX:+OptimizeStringConcat BenchGeneral
 *
 * Compare native vs. obfuscated builds:
 *   ProGuard, R8, Allatori, Zelix KlassMaster, DashO
 *
 * Uses System.nanoTime() for all timings.
 * RESULTS_CSV printed at end for easy log parsing / version tracking.
 */

import java.util.*;

public class BenchGeneral {

    private static final Random RNG = new Random(42);

    // ── entry point ───────────────────────────────────────────────────────────
    public static void main(String[] args) {
        long scriptStart = System.nanoTime();

        System.out.println("=== General Computational Benchmark (Java) ===");
        System.out.println("Testing: arithmetic, hashmaps, strings, methods, math, combat sim");
        System.out.println();

        // ── Test 1: Arithmetic (1M iterations) ───────────────────────────────
        System.out.println("Test 1: Arithmetic Operations (1M iterations)");
        long t1s = System.nanoTime();
        double total = 0;
        for (int i = 1; i <= 1_000_000; i++)
            total += (i * 2) - (i / 2.0) + (i % 100);
        double t1 = ns(System.nanoTime() - t1s);
        System.out.printf("  Result: %d%n", (long) total);
        System.out.printf("  Time:   %.4fs%n", t1);
        System.out.println();

        // ── Test 2: HashMap Operations (100K inserts + lookups) ──────────────
        System.out.println("Test 2: HashMap Operations (100K insertions + lookups)");
        long t2s = System.nanoTime();
        Map<Integer, int[]> data = new HashMap<>(150_000);
        for (int i = 1; i <= 100_000; i++)
            data.put(i, new int[]{i, i * 2});
        long lookupSum = 0;
        for (int i = 1; i <= 100_000; i++)
            lookupSum += data.get(i)[1];
        double t2 = ns(System.nanoTime() - t2s);
        System.out.printf("  Entries:    %d%n", data.size());
        System.out.printf("  Lookup sum: %d%n", lookupSum);
        System.out.printf("  Time:       %.4fs%n", t2);
        System.out.println();

        // ── Test 3: String Operations (50K format cycles) ────────────────────
        System.out.println("Test 3: String Operations (50K format cycles)");
        long t3s = System.nanoTime();
        long strSink = 0;
        for (int i = 1; i <= 50_000; i++) {
            String s = String.format("player_%d_score_%05d_rank_%.2f", i, i * 3, i / 7.0);
            strSink += s.length();
        }
        double t3 = ns(System.nanoTime() - t3s);
        System.out.printf("  Sink: %d%n", strSink);
        System.out.printf("  Time: %.4fs%n", t3);
        System.out.println();

        // ── Test 4: Method Calls (500K calls) ────────────────────────────────
        System.out.println("Test 4: Method Calls (500K calls)");
        long t4s = System.nanoTime();
        long funcSum = 0;
        for (int i = 1; i <= 500_000; i++)
            funcSum += testFunc(i, i + 1, i + 2);
        double t4 = ns(System.nanoTime() - t4s);
        System.out.printf("  Result: %d%n", funcSum);
        System.out.printf("  Time:   %.4fs%n", t4);
        System.out.println();

        // ── Test 5: Math Library (200K iterations) ───────────────────────────
        System.out.println("Test 5: Math Library Operations (200K iterations)");
        long t5s = System.nanoTime();
        double mathSum = 0;
        for (int i = 1; i <= 200_000; i++)
            mathSum += Math.floor(i / 3.7) + Math.ceil(i / 2.1) + Math.abs(-i);
        double t5 = ns(System.nanoTime() - t5s);
        System.out.printf("  Result: %d%n", (long) mathSum);
        System.out.printf("  Time:   %.4fs%n", t5);
        System.out.println();

        // ── Test 6: StringBuilder (100K multi-part builds) ───────────────────
        System.out.println("Test 6: StringBuilder (100K multi-part builds)");
        long t6s = System.nanoTime();
        String[] parts = {"alpha", "beta", "gamma", "delta", "epsilon", "zeta"};
        long sbSink = 0;
        for (int i = 1; i <= 100_000; i++) {
            StringBuilder sb = new StringBuilder();
            for (int j = 0; j < parts.length; j++)
                sb.append(parts[j]).append('_').append(i * (j + 1)).append('|');
            sbSink += sb.length();
        }
        double t6 = ns(System.nanoTime() - t6s);
        System.out.printf("  Sink: %d%n", sbSink);
        System.out.printf("  Time: %.4fs%n", t6);
        System.out.println();

        // ── Test 7: Combat Simulation (1K battles) ───────────────────────────
        System.out.println("Test 7: Combat Simulation (1K battles)");
        long t7s = System.nanoTime();
        int totalRounds = 0;
        for (int i = 0; i < 1_000; i++)
            totalRounds += simulateCombat();
        double t7 = ns(System.nanoTime() - t7s);
        System.out.printf("  Total rounds: %d%n", totalRounds);
        System.out.printf("  Time:         %.4fs%n", t7);
        System.out.println();

        // ── Test 8: Heavy Combat (5K battles) ────────────────────────────────
        System.out.println("Test 8: Heavy Combat Load (5K battles)");
        long t8s = System.nanoTime();
        int heavyRounds = 0;
        for (int i = 0; i < 5_000; i++)
            heavyRounds += simulateCombat();
        double t8 = ns(System.nanoTime() - t8s);
        System.out.printf("  Total rounds: %d%n", heavyRounds);
        System.out.printf("  Time:         %.4fs%n", t8);
        System.out.println();

        // ── Test 9: ArrayList Sort (5K sorts of 500 elements) ────────────────
        System.out.println("Test 9: ArrayList Sort (5K sorts of 500 elements)");
        long t9s = System.nanoTime();
        long sortSink = 0;
        for (int i = 1; i <= 5_000; i++) {
            List<Integer> list = new ArrayList<>(500);
            int seed = i * 31_337;
            for (int j = 0; j < 500; j++) {
                seed = seed * 1_664_525 + 1_013_904_223;
                list.add(Math.abs(seed) % 10_000);
            }
            Collections.sort(list);
            sortSink += list.get(0) + list.get(list.size() - 1);
        }
        double t9 = ns(System.nanoTime() - t9s);
        System.out.printf("  Sink: %d%n", sortSink);
        System.out.printf("  Time: %.4fs%n", t9);
        System.out.println();

        // ── Summary ──────────────────────────────────────────────────────────
        double scriptTotal = ns(System.nanoTime() - scriptStart);

        System.out.println("=== Summary ===");
        System.out.printf("Arithmetic:    %.4fs%n", t1);
        System.out.printf("HashMap:       %.4fs%n", t2);
        System.out.printf("Strings:       %.4fs%n", t3);
        System.out.printf("Methods:       %.4fs%n", t4);
        System.out.printf("Math Library:  %.4fs%n", t5);
        System.out.printf("StringBuilder: %.4fs%n", t6);
        System.out.printf("Combat (1K):   %.4fs%n", t7);
        System.out.printf("Combat (5K):   %.4fs%n", t8);
        System.out.printf("ArrayList Sort:%.4fs%n", t9);
        System.out.println("---------------");
        System.out.printf("TOTAL SCRIPT:  %.4fs%n", scriptTotal);
        System.out.println();
        System.out.printf("RESULTS_CSV:%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f%n",
                t1, t2, t3, t4, t5, t6, t7, t8, t9, scriptTotal);
    }

    // ── helpers ───────────────────────────────────────────────────────────────
    static double ns(long nanos) { return nanos / 1_000_000_000.0; }

    static long testFunc(long a, long b, long c) { return (a + b) * c; }

    static int simulateCombat() {
        double[] player = {100, 15, 5,  0.10}; // hp, atk, def, crit
        double[] enemy  = { 80, 12, 3,  0.05};

        int rounds = 0;
        while (player[0] > 0 && enemy[0] > 0 && rounds < 100) {
            enemy[0]  -= damage(player[1], enemy[2],  player[3]);
            if (enemy[0] > 0)
                player[0] -= damage(enemy[1],  player[2], enemy[3]);
            rounds++;
        }
        return rounds;
    }

    static double damage(double atk, double def, double crit) {
        int dmg = Math.max(1, (int)(atk - def));
        if (RNG.nextDouble() < crit) dmg *= 2;
        return dmg;
    }
}
