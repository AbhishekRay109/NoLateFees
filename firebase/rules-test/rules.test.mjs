// QA SYN-10: the security rules themselves, run in the Firebase emulator.
// Each person may only touch users/{their uid}/..., and a deleted row can't
// be brought back by a stale phone.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  collection,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-nolatefees',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
    storage: { rules: readFileSync('../storage.rules', 'utf8') },
  });
});

after(async () => env?.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
});

const item = (extra = {}) => ({
  id: 'i1',
  title: 'Car insurance',
  deleted_at: null,
  server_updated_at: serverTimestamp(),
  ...extra,
});

const alice = () => env.authenticatedContext('alice').firestore();
const bob = () => env.authenticatedContext('bob').firestore();
const anon = () => env.unauthenticatedContext().firestore();

async function seed(path, data) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), { ...data, server_updated_at: new Date() });
  });
}

describe('Firestore rules', () => {
  test('a signed-in user can create, read, update and delete their own rows', async () => {
    const db = alice();
    const d = doc(db, 'users/alice/items/i1');
    await assertSucceeds(setDoc(d, item()));
    await assertSucceeds(getDoc(d));
    await assertSucceeds(updateDoc(d, { title: 'Bike insurance', server_updated_at: serverTimestamp() }));
    await assertSucceeds(getDocs(collection(db, 'users/alice/items')));
    await assertSucceeds(deleteDoc(d));
  });

  test('every synced table is writable', async () => {
    for (const table of ['profiles', 'family_members', 'categories', 'items', 'renewals', 'attachments']) {
      await assertSucceeds(setDoc(doc(alice(), `users/alice/${table}/x`), item()));
    }
  });

  test('unknown tables are refused', async () => {
    await assertFails(setDoc(doc(alice(), 'users/alice/secrets/x'), item()));
  });

  test('signed-out access is refused', async () => {
    await seed('users/alice/items/i1', item());
    await assertFails(getDoc(doc(anon(), 'users/alice/items/i1')));
    await assertFails(setDoc(doc(anon(), 'users/alice/items/i2'), item()));
    await assertFails(getDocs(collection(anon(), 'users/alice/items')));
  });

  test("one user can't read, list, write or delete another user's rows", async () => {
    await seed('users/alice/items/i1', item());
    await assertFails(getDoc(doc(bob(), 'users/alice/items/i1')));
    await assertFails(getDocs(collection(bob(), 'users/alice/items')));
    await assertFails(setDoc(doc(bob(), 'users/alice/items/i2'), item()));
    await assertFails(updateDoc(doc(bob(), 'users/alice/items/i1'), { title: 'x', server_updated_at: serverTimestamp() }));
    await assertFails(deleteDoc(doc(bob(), 'users/alice/items/i1')));
  });

  test('nothing outside users/{uid} is reachable', async () => {
    await assertFails(setDoc(doc(alice(), 'items/i1'), item()));
    await assertFails(getDocs(collection(alice(), 'users')));
  });

  test('writes must carry the server timestamp (no faked sync cursor)', async () => {
    await assertFails(setDoc(doc(alice(), 'users/alice/items/i1'), item({ server_updated_at: new Date(0) })));
    await assertFails(setDoc(doc(alice(), 'users/alice/items/i1'), { id: 'i1', title: 'x' }));
    await seed('users/alice/items/i1', item());
    await assertFails(updateDoc(doc(alice(), 'users/alice/items/i1'), { title: 'x' }));
  });

  test('a deleted row cannot be undeleted, but can stay deleted', async () => {
    await seed('users/alice/items/i1', item({ deleted_at: '2026-10-01T00:00:00Z' }));
    const d = doc(alice(), 'users/alice/items/i1');
    await assertFails(updateDoc(d, { deleted_at: null, server_updated_at: serverTimestamp() }));
    await assertSucceeds(updateDoc(d, { title: 'still gone', server_updated_at: serverTimestamp() }));
  });
});

describe('Storage rules', () => {
  const file = (ctx, path) => ref(ctx.storage(), path);
  const bytes = (n) => new Uint8Array(n);

  test('a user can upload, read and delete their own attachment', async () => {
    const ctx = env.authenticatedContext('alice');
    const r = file(ctx, 'users/alice/attachments/i1/a.pdf');
    await assertSucceeds(uploadBytes(r, bytes(1024), { contentType: 'application/pdf' }));
    await assertSucceeds(getBytes(r));
    await assertSucceeds(deleteObject(r));
  });

  test('files over 10 MB are refused', async () => {
    const ctx = env.authenticatedContext('alice');
    await assertFails(uploadBytes(file(ctx, 'users/alice/attachments/i1/big.pdf'), bytes(10 * 1024 * 1024 + 1)));
  });

  test("other users and signed-out visitors can't touch someone's files", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await uploadBytes(file(ctx, 'users/alice/attachments/i1/a.pdf'), bytes(10));
    });
    const bobCtx = env.authenticatedContext('bob');
    const anonCtx = env.unauthenticatedContext();
    await assertFails(getBytes(file(bobCtx, 'users/alice/attachments/i1/a.pdf')));
    await assertFails(deleteObject(file(bobCtx, 'users/alice/attachments/i1/a.pdf')));
    await assertFails(uploadBytes(file(bobCtx, 'users/alice/attachments/i1/b.pdf'), bytes(10)));
    await assertFails(getBytes(file(anonCtx, 'users/alice/attachments/i1/a.pdf')));
  });

  test('nothing outside users/{uid}/attachments is writable', async () => {
    const ctx = env.authenticatedContext('alice');
    await assertFails(uploadBytes(file(ctx, 'users/alice/other/x.pdf'), bytes(10)));
    await assertFails(uploadBytes(file(ctx, 'public/x.pdf'), bytes(10)));
  });
});
