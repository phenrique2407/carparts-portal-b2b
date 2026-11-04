const test = require('node:test');
const assert = require('node:assert');
const soma = require('./soma');
test('soma', () => assert.strictEqual(soma(2, 3), 5));
