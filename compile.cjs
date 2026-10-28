const { Compiler } = require('inkjs/dist/ink-full.js');
const fs = require('fs');
const src = fs.readFileSync(process.argv[2], 'utf8');
const t0 = performance.now();
const c = new Compiler(src);
let story;
try { story = c.Compile(); } catch (e) { console.log('EXC', e.message); }
const t1 = performance.now();
for (const e of c.errors) console.log('ERR', e);
for (const w of c.warnings) console.log('WARN', w);
if (!story) process.exit(1);
const json = story.ToJson();
fs.writeFileSync(process.argv[3], json);
console.log(`compiled in ${(t1-t0).toFixed(0)} ms, ${json.length} bytes`);
