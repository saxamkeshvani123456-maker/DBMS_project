import{test}from'node:test';import assert from'node:assert/strict';import request from'supertest';import jwt from'jsonwebtoken';import app from'../src/index.js';import{rowsToXml}from'../src/services/xml.js';
process.env.JWT_SECRET??='campusconnect-unit-test-secret';
test('health route does not need Oracle',async()=>{const r=await request(app).get('/api/health');assert.equal(r.status,200);assert.equal(r.body.status,'ok')});
test('admin API requires authentication',async()=>{const r=await request(app).get('/api/admin/users');assert.equal(r.status,401)});
test('student token cannot access admin endpoints',async()=>{const token=jwt.sign({id:3,role:'STUDENT'},process.env.JWT_SECRET);const r=await request(app).get('/api/admin/users').set('Authorization',`Bearer ${token}`);assert.equal(r.status,403)});
test('event registration requires authentication',async()=>{const r=await request(app).post('/api/events/1/register');assert.equal(r.status,401)});
test('unknown DBMS query scenario is rejected without SQL execution',async()=>{const token=jwt.sign({id:3,role:'STUDENT'},process.env.JWT_SECRET);const r=await request(app).get('/api/lab/scenario/SELECT-1').set('Authorization',`Bearer ${token}`);assert.equal(r.status,404);assert.match(r.body.error,/Unknown query/)});
test('XML serialization escapes markup and represents null values',()=>{const xml=rowsToXml([{TITLE:'A < B & C',DESCRIPTION:null}], 'Rows');assert.match(xml,/A &lt; B &amp; C/);assert.match(xml,/<DESCRIPTION xsi:nil="true"\/>/);assert.match(xml,/xmlns:xsi=/)});
