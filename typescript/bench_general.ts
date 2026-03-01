/**
 * bench_general.ts — General Computational Benchmark (TypeScript)
 *
 * Compile & run:
 *   npx ts-node bench_general.ts                  (quickest, no separate compile step)
 *   tsc bench_general.ts && node bench_general.js  (compare tsc output vs source)
 *   tsc --strict bench_general.ts                  (strict mode)
 *
 * Compare compiled output vs obfuscated builds:
 *   javascript-obfuscator, TypeScript + Terser pipeline, ts-transformer-obfuscate
 *
 * Uses process.hrtime.bigint() for sub-millisecond precision.
 * RESULTS_CSV printed at end for easy log parsing / version tracking.
 */

"use strict";

// ── types ─────────────────────────────────────────────────────────────────────

interface DataEntry {
  id:    number;
  value: number;
  name:  string;
}

interface Combatant {
  health:  number;
  attack:  number;
  defense: number;
  crit:    number;
}

// ── timing helper ─────────────────────────────────────────────────────────────
function clock(): number {
  return Number(process.hrtime.bigint()) / 1e9;
}

// ── main ─────────────────────────────────────────────────────────────────────
const scriptStart: number = clock();

console.log("=== General Computational Benchmark (TypeScript) ===");
console.log("Testing: arithmetic, Maps, strings, functions, math, generics, combat sim");
console.log();

// ── Test 1: Arithmetic (1M iterations) ───────────────────────────────────────
console.log("Test 1: Arithmetic Operations (1M iterations)");
let t1: number = clock();
let total: number = 0;
for (let i = 1; i <= 1_000_000; i++) {
  total += (i * 2) - (i / 2) + (i % 100);
}
t1 = clock() - t1;
console.log(`  Result: ${Math.trunc(total)}`);
console.log(`  Time:   ${t1.toFixed(4)}s`);
console.log();

// ── Test 2: Map Operations (100K inserts + lookups) ───────────────────────────
console.log("Test 2: Map<number, DataEntry> Operations (100K insertions + lookups)");
let t2: number = clock();
const dataMap = new Map<number, DataEntry>();
for (let i = 1; i <= 100_000; i++) {
  dataMap.set(i, { id: i, value: i * 2, name: `item_${i}` });
}
let lookupSum: number = 0;
for (let i = 1; i <= 100_000; i++) {
  lookupSum += dataMap.get(i)!.value;
}
t2 = clock() - t2;
console.log(`  Entries:    ${dataMap.size}`);
console.log(`  Lookup sum: ${lookupSum}`);
console.log(`  Time:       ${t2.toFixed(4)}s`);
console.log();

// ── Test 3: String Operations (50K template-literal cycles) ──────────────────
console.log("Test 3: String Operations (50K format cycles)");
let t3: number = clock();
let strSink: number = 0;
for (let i = 1; i <= 50_000; i++) {
  const s: string = `player_${i}_score_${String(i * 3).padStart(5, "0")}_rank_${(i / 7).toFixed(2)}`;
  strSink += s.length;
}
t3 = clock() - t3;
console.log(`  Sink: ${strSink}`);
console.log(`  Time: ${t3.toFixed(4)}s`);
console.log();

// ── Test 4: Typed Function Calls (500K calls) ─────────────────────────────────
console.log("Test 4: Typed Function Calls (500K calls)");
function testFunc(a: number, b: number, c: number): number {
  return (a + b) * c;
}
let t4: number = clock();
let funcSum: number = 0;
for (let i = 1; i <= 500_000; i++) {
  funcSum += testFunc(i, i + 1, i + 2);
}
t4 = clock() - t4;
console.log(`  Result: ${funcSum}`);
console.log(`  Time:   ${t4.toFixed(4)}s`);
console.log();

// ── Test 5: Math Library (200K iterations) ────────────────────────────────────
console.log("Test 5: Math Library Operations (200K iterations)");
let t5: number = clock();
let mathSum: number = 0;
for (let i = 1; i <= 200_000; i++) {
  mathSum += Math.floor(i / 3.7) + Math.ceil(i / 2.1) + Math.abs(-i);
}
t5 = clock() - t5;
console.log(`  Result: ${mathSum}`);
console.log(`  Time:   ${t5.toFixed(4)}s`);
console.log();

// ── Test 6: Generic Utility Functions (300K calls) ────────────────────────────
// TypeScript generics erase at runtime, but obfuscators that mangle
// type-guard logic or add runtime type checks show up here.
console.log("Test 6: Generic Clamp + Lerp (300K calls each)");
function clamp<T extends number>(value: T, min: T, max: T): T {
  return (value < min ? min : value > max ? max : value) as T;
}
function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}
let t6: number = clock();
let genericSink: number = 0;
for (let i = 1; i <= 300_000; i++) {
  genericSink += clamp(i % 200 - 50, 0, 100);
  genericSink += lerp(0, i, (i % 100) / 100);
}
t6 = clock() - t6;
console.log(`  Sink: ${genericSink}`);
console.log(`  Time: ${t6.toFixed(4)}s`);
console.log();

// ── Test 7: Typed Combat Simulation (1K battles) ─────────────────────────────
console.log("Test 7: Typed Combat Simulation (1K battles)");

function simulateCombat(): number {
  const player: Combatant = { health: 100, attack: 15, defense: 5,  crit: 0.10 };
  const enemy:  Combatant = { health:  80, attack: 12, defense: 3,  crit: 0.05 };

  function takeDamage(target: Combatant, attacker: Combatant): number {
    let dmg: number = Math.max(1, attacker.attack - target.defense);
    if (Math.random() < attacker.crit) dmg *= 2;
    target.health -= dmg;
    return dmg;
  }

  let rounds: number = 0;
  while (player.health > 0 && enemy.health > 0 && rounds < 100) {
    takeDamage(enemy, player);
    if (enemy.health > 0) takeDamage(player, enemy);
    rounds++;
  }
  return rounds;
}

let t7: number = clock();
let totalRounds: number = 0;
for (let i = 0; i < 1_000; i++) totalRounds += simulateCombat();
t7 = clock() - t7;
console.log(`  Total rounds: ${totalRounds}`);
console.log(`  Time:         ${t7.toFixed(4)}s`);
console.log();

// ── Test 8: Heavy Combat (5K battles) ────────────────────────────────────────
console.log("Test 8: Heavy Combat Load (5K battles)");
let t8: number = clock();
let heavyRounds: number = 0;
for (let i = 0; i < 5_000; i++) heavyRounds += simulateCombat();
t8 = clock() - t8;
console.log(`  Total rounds: ${heavyRounds}`);
console.log(`  Time:         ${t8.toFixed(4)}s`);
console.log();

// ── Test 9: Array Method Pipeline (1K arrays × 1K elements) ──────────────────
console.log("Test 9: Typed Array Pipeline — map/filter/reduce (1K × 1K)");
let t9: number = clock();
let pipeSink: number = 0;
for (let i = 1; i <= 1_000; i++) {
  const arr: number[] = Array.from({ length: 1_000 }, (_, j) => j * i + (j % 7));
  const result: number = arr
    .map((x: number): number => x * 2 + 1)
    .filter((x: number): boolean => x % 3 !== 0)
    .reduce((acc: number, x: number): number => acc + x, 0);
  pipeSink += result;
}
t9 = clock() - t9;
console.log(`  Sink: ${pipeSink}`);
console.log(`  Time: ${t9.toFixed(4)}s`);
console.log();

// ── Summary ───────────────────────────────────────────────────────────────────
const scriptTotal: number = clock() - scriptStart;

console.log("=== Summary ===");
console.log(`Arithmetic:      ${t1.toFixed(4)}s`);
console.log(`Map Ops:         ${t2.toFixed(4)}s`);
console.log(`Strings:         ${t3.toFixed(4)}s`);
console.log(`Typed Functions: ${t4.toFixed(4)}s`);
console.log(`Math Library:    ${t5.toFixed(4)}s`);
console.log(`Generics:        ${t6.toFixed(4)}s`);
console.log(`Combat (1K):     ${t7.toFixed(4)}s`);
console.log(`Combat (5K):     ${t8.toFixed(4)}s`);
console.log(`Array Pipeline:  ${t9.toFixed(4)}s`);
console.log("---------------");
console.log(`TOTAL SCRIPT:    ${scriptTotal.toFixed(4)}s`);
console.log();
console.log(`RESULTS_CSV:${t1},${t2},${t3},${t4},${t5},${t6},${t7},${t8},${t9},${scriptTotal}`);
