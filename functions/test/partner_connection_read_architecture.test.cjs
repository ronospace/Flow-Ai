const fs = require('node:fs');
const test = require('node:test');
const assert = require('node:assert/strict');

const source = fs.readFileSync(
  'src/partner_get_connection_callable.ts',
  'utf8',
);

const indexSource = fs.readFileSync(
  'src/index.ts',
  'utf8',
);

test('partner connection read requires authenticated identity', () => {
  assert.match(
    source,
    /requireAuthenticatedUid\(request\.auth\)/,
  );
});

test('partner connection read is scoped to participant ownership', () => {
  assert.match(
    source,
    /"participantUids",\s*"array-contains",\s*uid/,
  );

  assert.match(
    source,
    /ownsConnection/,
  );
});

test('partner connection callable is exported', () => {
  assert.match(
    indexSource,
    /getPartnerConnection/,
  );
});
