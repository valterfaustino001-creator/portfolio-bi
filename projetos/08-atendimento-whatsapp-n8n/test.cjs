const assert = require('node:assert/strict');
const { route } = require('./router.cjs');
const now = Date.parse('2026-10-20T15:00:00Z');
const base = {now, contact: {nome:'Ana', telefone:'5511999999999', codigo_pedido:'PED123'},
  session: {menu_shown:true,state:'MENU',expires_at:'2026-10-20T15:20:00Z'},
  config:{pagamento:'Pix, cartão e boleto. Condições de teste.'}};
const run = (text, changes = {}) => route({...base,...changes,message:{text,phone:'5511999999999',timestamp:now/1000,id:'m1'}});
assert.equal(run('oi',{session:{}}).action,'menu');
assert.equal(run('2').state,'MAIS');
assert.match(run('aceita pix?').text,/Pix/);
assert.equal(run('1').order,'PED123');
assert.equal(run('1',{contact:{}}).state,'AGUARDA_PEDIDO');
assert.equal(run('4').bot_paused,true);
assert.equal(run('parar',{session:{...base.session,bot_paused:true}}).opt_out,true);
assert.equal(run('oi',{session:{...base.session,opt_out:true}}).action,'none');
assert.equal(run('oi',{session:{...base.session,bot_paused:true,expires_at:null}}).action,'none');
assert.equal(run('oi',{session:{...base.session,expires_at:'2026-10-20T14:00:00Z'}}).action,'menu');
assert.equal(run('sim',{session:{...base.session,opt_out:true}}).action,'none');
assert.equal(run('nao quero receber mensagens').opt_out,true);
const cepSession={...base.session,state:'AGUARDA_CEP'};
assert.equal(run('01001-000',{session:cepSession}).cep,'01001000');
assert.equal(run('abc01001000',{session:cepSession}).state,'AGUARDA_CEP');
assert.equal(run('123',{session:cepSession}).action,'text');
assert.equal(run('nao',{session:{...base.session,state:'MAIS'}}).state,'ENCERRADO');
assert.equal(route({...base,message:{text:'oi',timestamp:now/1000-86401}}).action,'none');
assert.equal(route({...base,message:{text:'parar',timestamp:now/1000-86401}}).action,'none');
assert.equal(route({...base,message:{text:'parar',timestamp:now/1000-86401}}).opt_out,true);
console.log('19 verificações de regras de conversa passaram.');
