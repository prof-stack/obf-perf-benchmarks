/**
 * bench_general.js — General Computational Benchmark (JavaScript)
 * Run with: node bench_general.js
 * Compare native vs obfuscated (javascript-obfuscator, obfuscator.io, etc.)
 * Uses process.hrtime.bigint() for sub-millisecond precision.
 */

"use strict";

function clock() {
  return Number(process.hrtime.bigint()) / 1e9; // seconds as float
}

const scriptStart = clock();

console.log("=== General Computational Benchmark (JavaScript) ===");
console.log("Testing: arithmetic, objects, strings, calls, math, simulation");
console.log();

// ── Test 1: Arithmetic (1M iterations) ───────────────────────────────────────
console.log("Test 1: Arithmetic Operations (1M iterations)");
let t1 = clock();
let total = 0;
for (let i = 1; i <= 1_000_000; i++) {
  total += (i * 2) - (i / 2) + (i % 100);
}
t1 = clock() - t1;
console.log(`  Result: ${Math.trunc(total)}`);
console.log(`  Time:   ${t1.toFixed(4)}s`);
console.log();

// ── Test 2: Object / Map Operations (100K inserts + lookups) ─────────────────
console.log("Test 2: Object Operations (100K insertions + lookups)");
let t2 = clock();
const data = {};
for (let i = 1; i <= 100_000; i++) {
  data[i] = { id: i, value: i * 2, name: `item_${i}` };
}
let lookupSum = 0;
for (let i = 1; i <= 100_000; i++) {
  lookupSum += data[i].value;
}
t2 = clock() - t2;
console.log(`  Entries:    ${Object.keys(data).length}`);
console.log(`  Lookup sum: ${lookupSum}`);
console.log(`  Time:       ${t2.toFixed(4)}s`);
console.log();

// ── Test 3: String Operations (50K template-literal cycles) ──────────────────
console.log("Test 3: String Operations (50K format cycles)");
let t3 = clock();
let strSink = 0;
for (let i = 1; i <= 50_000; i++) {
  const s = `player_${i}_score_${String(i * 3).padStart(5, "0")}_rank_${(i / 7).toFixed(2)}`;
  strSink += s.length;
}
t3 = clock() - t3;
console.log(`  Sink: ${strSink}`);
console.log(`  Time: ${t3.toFixed(4)}s`);
console.log();

// ── Test 4: Function Calls (500K calls) ──────────────────────────────────────
console.log("Test 4: Function Calls (500K calls)");
function testFunc(a, b, c) { return (a + b) * c; }

let t4 = clock();
let funcSum = 0;
for (let i = 1; i <= 500_000; i++) {
  funcSum += testFunc(i, i + 1, i + 2);
}
t4 = clock() - t4;
console.log(`  Result: ${funcSum}`);
console.log(`  Time:   ${t4.toFixed(4)}s`);
console.log();

// ── Test 5: Math Library (200K iterations) ───────────────────────────────────
console.log("Test 5: Math Library Operations (200K iterations)");
let t5 = clock();
let mathSum = 0;
for (let i = 1; i <= 200_000; i++) {
  mathSum += Math.floor(i / 3.7) + Math.ceil(i / 2.1) + Math.abs(-i);
}
t5 = clock() - t5;
console.log(`  Result: ${mathSum}`);
console.log(`  Time:   ${t5.toFixed(4)}s`);
console.log();

// ── Test 6: Combat Simulation (1K battles) ───────────────────────────────────
console.log("Test 6: Combat Simulation (1K battles)");

function simulateCombat() {
  const player = { health: 100, attack: 15, defense: 5,  crit: 0.10 };
  const enemy  = { health:  80, attack: 12, defense: 3,  crit: 0.05 };

  function takeDamage(target, attacker) {
    let dmg = Math.max(1, attacker.attack - target.defense);
    if (Math.random() < attacker.crit) dmg *= 2;
    target.health -= dmg;
    return dmg;
  }

  let rounds = 0;
  while (player.health > 0 && enemy.health > 0 && rounds < 100) {
    takeDamage(enemy, player);
    if (enemy.health > 0) takeDamage(player, enemy);
    rounds++;
  }
  return rounds;
}

let t6 = clock();
let totalRounds = 0;
for (let i = 0; i < 1_000; i++) totalRounds += simulateCombat();
t6 = clock() - t6;
console.log(`  Total rounds: ${totalRounds}`);
console.log(`  Time:         ${t6.toFixed(4)}s`);
console.log();

// ── Test 7: Heavy Combat (5K battles) ────────────────────────────────────────
console.log("Test 7: Heavy Combat Load (5K battles)");
let t7 = clock();
let heavyRounds = 0;
for (let i = 0; i < 5_000; i++) heavyRounds += simulateCombat();
t7 = clock() - t7;
console.log(`  Total rounds: ${heavyRounds}`);
console.log(`  Time:         ${t7.toFixed(4)}s`);
console.log();

// ── Summary ───────────────────────────────────────────────────────────────────
const scriptTotal = clock() - scriptStart;

console.log("=== Summary ===");
console.log(`Arithmetic:    ${t1.toFixed(4)}s`);
console.log(`Objects:       ${t2.toFixed(4)}s`);
console.log(`Strings:       ${t3.toFixed(4)}s`);
console.log(`Functions:     ${t4.toFixed(4)}s`);
console.log(`Math Library:  ${t5.toFixed(4)}s`);
console.log(`Combat (1K):   ${t6.toFixed(4)}s`);
console.log(`Combat (5K):   ${t7.toFixed(4)}s`);
console.log("---------------");
console.log(`TOTAL SCRIPT:  ${scriptTotal.toFixed(4)}s`);
console.log();
console.log(`RESULTS_CSV:${t1},${t2},${t3},${t4},${t5},${t6},${t7},${scriptTotal}`);
