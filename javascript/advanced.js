/**
 * bench_advanced.js — Advanced JavaScript Benchmark
 * Run with: node bench_advanced.js
 * Tests: prototype/class dispatch, closure factories, recursion,
 *        Map/Set vs plain objects, array methods, and Promise overhead.
 * Compare native vs obfuscated builds to isolate instrumentation costs.
 */

"use strict";

function clock() {
  return Number(process.hrtime.bigint()) / 1e9;
}

const scriptStart = clock();

console.log("=== Advanced Benchmark (JavaScript) ===");
console.log("Testing: class dispatch, prototype chains, closures, recursion, Map/Set, array methods, async");
console.log();

// ── Test 1: Class Method Dispatch (500K calls) ────────────────────────────────
console.log("Test 1: Class Method Dispatch (500K calls)");

class Animal {
  constructor(name, hp, atk) {
    this.name = name;
    this.hp   = hp;
    this.atk  = atk;
    this.xp   = 0;
  }
  attack(other) {
    const dmg = Math.max(1, this.atk - Math.floor(other.hp * 0.05));
    other.hp -= dmg;
    this.xp  += dmg;
    return dmg;
  }
}

let t1 = clock();
const wolf  = new Animal("Wolf",  999_999, 10);
const sheep = new Animal("Sheep", 999_999,  1);
let dmgSink = 0;
for (let i = 0; i < 500_000; i++) dmgSink += wolf.attack(sheep);
t1 = clock() - t1;
console.log(`  Damage: ${dmgSink}`);
console.log(`  Time:   ${t1.toFixed(4)}s`);
console.log();

// ── Test 2: Prototype Inheritance Chain (3 levels, 300K calls) ────────────────
console.log("Test 2: 3-Level Prototype Chain (300K calls)");

class Base {
  constructor(v)      { this.value = v; }
  get()               { return this.value; }
}
class Mid extends Base {
  constructor(v, m)   { super(v); this.mult = m; }
  scaled()            { return this.get() * this.mult; }
}
class Top extends Mid {
  constructor(v, m, s){ super(v, m); this.shift = s; }
  final()             { return this.scaled() + this.shift; }
}

let t2 = clock();
const obj = new Top(3, 7, 2);
let chainSink = 0;
for (let i = 0; i < 300_000; i++) chainSink += obj.final();
t2 = clock() - t2;
console.log(`  Sink: ${chainSink}`);
console.log(`  Time: ${t2.toFixed(4)}s`);
console.log();

// ── Test 3: Closure Factory (300K closures created + called) ─────────────────
console.log("Test 3: Closure Factory (300K closures)");

function makeAdder(n) { return x => x + n; }

let t3 = clock();
let closureSink = 0;
for (let i = 1; i <= 300_000; i++) {
  const adder = makeAdder(i);
  closureSink += adder(1);
}
t3 = clock() - t3;
console.log(`  Sink: ${closureSink}`);
console.log(`  Time: ${t3.toFixed(4)}s`);
console.log();

// ── Test 4: Recursive Fibonacci (naive, 300 times) ───────────────────────────
console.log("Test 4: Naive Fibonacci fib(30), 300 times");

function fib(n) { return n <= 1 ? n : fib(n - 1) + fib(n - 2); }

let t4 = clock();
let fibSink = 0;
for (let i = 0; i < 300; i++) fibSink += fib(30);
t4 = clock() - t4;
console.log(`  fib(30) = ${fib(30)}`);
console.log(`  Sink:    ${fibSink}`);
console.log(`  Time:    ${t4.toFixed(4)}s`);
console.log();

// ── Test 5: Map vs Object (100K inserts + reads each) ────────────────────────
console.log("Test 5: Map vs Plain Object (100K ops each)");

let t5 = clock();
// Map
const map = new Map();
for (let i = 1; i <= 100_000; i++) map.set(`key_${i}`, i * 3);
let mapSink = 0;
for (let i = 1; i <= 100_000; i++) mapSink += map.get(`key_${i}`);
// Plain object
const pobj = Object.create(null);
for (let i = 1; i <= 100_000; i++) pobj[`key_${i}`] = i * 3;
let pobjSink = 0;
for (let i = 1; i <= 100_000; i++) pobjSink += pobj[`key_${i}`];
t5 = clock() - t5;
console.log(`  Map sink:  ${mapSink}`);
console.log(`  Obj sink:  ${pobjSink}`);
console.log(`  Time:      ${t5.toFixed(4)}s`);
console.log();

// ── Test 6: Array Method Pipeline (map → filter → reduce, 1K × 1K arrays) ────
console.log("Test 6: Array Method Pipeline (1K arrays × 1K elements)");

let t6 = clock();
let pipeSink = 0;
for (let i = 1; i <= 1_000; i++) {
  const arr = Array.from({ length: 1_000 }, (_, j) => j * i + (j % 7));
  const result = arr
    .map(x => x * 2 + 1)
    .filter(x => x % 3 !== 0)
    .reduce((acc, x) => acc + x, 0);
  pipeSink += result;
}
t6 = clock() - t6;
console.log(`  Sink: ${pipeSink}`);
console.log(`  Time: ${t6.toFixed(4)}s`);
console.log();

// ── Test 7: Set Operations (union / intersection, 10K rounds) ─────────────────
console.log("Test 7: Set Union & Intersection (10K rounds)");

let t7 = clock();
let setSink = 0;
for (let i = 1; i <= 10_000; i++) {
  const a = new Set(Array.from({ length: 100 }, (_, j) => (j * i) % 200));
  const b = new Set(Array.from({ length: 100 }, (_, j) => (j * (i + 1)) % 200));
  // union size
  const union = new Set([...a, ...b]);
  // intersection size
  let inter = 0;
  for (const v of a) if (b.has(v)) inter++;
  setSink += union.size + inter;
}
t7 = clock() - t7;
console.log(`  Sink: ${setSink}`);
console.log(`  Time: ${t7.toFixed(4)}s`);
console.log();

// ── Test 8: Async/Promise Overhead (100K resolved promises) ──────────────────
console.log("Test 8: Promise Overhead (100K sequential awaits)");

async function runPromises() {
  let promiseSink = 0;
  const t8start = clock();
  for (let i = 1; i <= 100_000; i++) {
    const v = await Promise.resolve(i * 2);
    promiseSink += v;
  }
  const t8 = clock() - t8start;
  console.log(`  Sink: ${promiseSink}`);
  console.log(`  Time: ${t8.toFixed(4)}s`);
  console.log();
  return t8;
}

// Run everything async so Test 8 can use await
(async () => {
  const t8 = await runPromises();
  const scriptTotal = clock() - scriptStart;

  console.log("=== Summary ===");
  console.log(`Class Dispatch:   ${t1.toFixed(4)}s`);
  console.log(`Prototype Chain:  ${t2.toFixed(4)}s`);
  console.log(`Closure Factory:  ${t3.toFixed(4)}s`);
  console.log(`Fibonacci:        ${t4.toFixed(4)}s`);
  console.log(`Map vs Object:    ${t5.toFixed(4)}s`);
  console.log(`Array Pipeline:   ${t6.toFixed(4)}s`);
  console.log(`Set Ops:          ${t7.toFixed(4)}s`);
  console.log(`Promise Overhead: ${t8.toFixed(4)}s`);
  console.log("---------------");
  console.log(`TOTAL SCRIPT:     ${scriptTotal.toFixed(4)}s`);
  console.log();
  console.log(`RESULTS_CSV:${t1},${t2},${t3},${t4},${t5},${t6},${t7},${t8},${scriptTotal}`);
})();
