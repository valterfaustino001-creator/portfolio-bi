const fs = require('node:fs');
const path = require('node:path');
const { route } = require('./router.cjs');
const dir=__dirname;
function workflow(name) {
  const w={name,nodes:[],connections:{},active:false,settings:{executionOrder:'v1',timezone:'America/Sao_Paulo'},pinData:{}};
  const add=(name,type,parameters={},extra={})=>{
    const node={id:`node-${w.nodes.length+1}`,name,type:`n8n-nodes-base.${type}`,typeVersion:1,
      position:[(w.nodes.length%6)*260,Math.floor(w.nodes.length/6)*220],parameters,...extra};
    w.nodes.push(node);return name;
  };
  const link=(a,b,output=0)=>{
    const c=w.connections[a]??={main:[]};
    while(c.main.length<=output)c.main.push([]);
    c.main[output].push({node:b,type:'main',index:0});
  };
  const code=(name,js,each=true)=>add(name,'code',{mode:each?'runOnceForEachItem':'runOnceForAllItems',jsCode:js},{typeVersion:2});
  const pg=(name,query,params)=>add(name,'postgres',{operation:'executeQuery',query,options:{queryReplacement:params}},{typeVersion:2.6});
  const cond=(name,expression)=>add(name,'if',{conditions:{options:{caseSensitive:true,leftValue:'',typeValidation:'strict',version:2},conditions:[{id:'condition',leftValue:expression,rightValue:true,operator:{type:'boolean',operation:'true',singleValue:true}}],combinator:'and'},options:{}},{typeVersion:2.2});
  const http=(name,url,body,credential='httpHeaderAuth')=>add(name,'httpRequest',{method:'POST',url,authentication:'genericCredentialType',genericAuthType:credential,
    sendBody:true,specifyBody:'json',jsonBody:body,options:{timeout:15000,response:{response:{fullResponse:true,neverError:true,responseFormat:'json'}}}},
    {typeVersion:4.2,onError:'continueRegularOutput'});
  const sheet=(name,operation,value,filters)=>add(name,'googleSheets',{
    operation,documentId:{__rl:true,value:'PREENCHER_SPREADSHEET_ID',mode:'id'},
    sheetName:{__rl:true,value:'Contatos',mode:'name'},
    ...(value?{columns:{mappingMode:'defineBelow',value,matchingColumns:['telefone'],schema:[],attemptToConvertTypes:false,convertFieldsToString:false}}:{}),
    ...(filters?{filtersUI:{values:[{lookupColumn:'telefone',lookupValue:filters}]},options:{returnFirstMatch:true}}:{options:{}}),
  },{typeVersion:4.6,alwaysOutputData:true});
  return {w,add,link,code,pg,cond,http,sheet,save:file=>fs.writeFileSync(path.join(dir,file),JSON.stringify(w,null,2))};
}
const config={
  graph_version:'PREENCHER_VERSAO_SUPORTADA',
  phone_number_id:'PREENCHER_PHONE_NUMBER_ID',
  template:'atendimento_cliente_v1',language:'pt_BR',campaign_id:'atendimento_2026_01',
  pagamento:'PREENCHER: Pix, cartão e boleto; parcelas, juros, parcela mínima e prazos reais.',
  tracking_url:'https://SEU-ADAPTADOR.example/rastreamento',
  shipping_url:'https://SEU-ADAPTADOR.example/frete',
  vendedor_email:'PREENCHER@empresa.example',
};
// Workflow inicial: referência funcional de cadência e payload, sem agendamento automático.
{
const b=workflow('01 - Disparo WhatsApp - REFERENCIA configurar antes de ativar');
const {add,code,pg,cond,http,sheet,link}=b;
add('Iniciar manualmente','manualTrigger');
code('Configuracao',`return {json:${JSON.stringify(config)}};`);
sheet('Ler contatos','read');
code('Filtrar elegiveis',`
const truth=v=>v===true||['sim','true','1'].includes(String(v).toLowerCase());
const seen=new Set();
return $input.all().filter(i=>{
 const c=i.json; const p=String(c.telefone||'').trim().replace(/^\\+/,'');
 const eligible=/^[1-9]\\d{7,14}$/.test(p)&&!seen.has(p)&&!truth(c.opt_out)&&truth(c.opt_in)
 &&!truth(c.bot_paused)&&!['enviado','respondeu','transferido','erro'].includes(String(c.status_envio||'').trim().toLowerCase());
 seen.add(p);c.telefone=p;return eligible;
});`,false);
add('Um contato por vez','splitInBatches',{batchSize:1,options:{}},{typeVersion:3});
pg('Reservar campanha',`WITH claim AS (
INSERT INTO wa_campaigns(campaign_id,phone)
SELECT $1,$2 WHERE NOT EXISTS (
 SELECT 1 FROM wa_sessions WHERE phone=$2 AND
 (data->>'opt_out'='true' OR data->>'bot_paused'='true')
)
ON CONFLICT DO NOTHING RETURNING phone)
SELECT EXISTS(SELECT 1 FROM claim) AS claimed;`,
`={{ [ $('Configuracao').first().json.campaign_id, $json.telefone ] }}`);
cond('Reserva obtida','={{ $json.claimed }}');
sheet('Reler antes do envio','read',null,"={{ $('Um contato por vez').item.json.telefone }}");
cond('Ainda permitido',`={{ !!$json.telefone && ['sim','true','1'].includes(String($json.opt_in).toLowerCase()) && !['sim','true','1'].includes(String($json.opt_out).toLowerCase()) && !['sim','true','1'].includes(String($json.bot_paused).toLowerCase()) && !['enviado','respondeu','transferido','erro'].includes(String($json.status_envio||'').toLowerCase()) }}`);
pg('Conferir bloqueio persistente',`SELECT NOT EXISTS(SELECT 1 FROM wa_sessions WHERE phone=$1 AND (data->>'opt_out'='true' OR data->>'bot_paused'='true')) AS allowed;`,
`={{ [ $('Um contato por vez').item.json.telefone ] }}`);
cond('Banco permite','={{ $json.allowed }}');
http('Enviar template',
`={{ 'https://graph.facebook.com/'+$('Configuracao').first().json.graph_version+'/'+$('Configuracao').first().json.phone_number_id+'/messages' }}`,
`={{ {messaging_product:'whatsapp',to:$('Um contato por vez').item.json.telefone,type:'template',template:{name:$('Configuracao').first().json.template,language:{code:$('Configuracao').first().json.language},components:[{type:'body',parameters:[{type:'text',text:$('Um contato por vez').item.json.nome||'cliente'}]}]}} }}`);
code('Resultado do disparo',`
const r=$json;const id=r.body?.messages?.[0]?.id;
return {json:{telefone:$('Um contato por vez').item.json.telefone,status_envio:id?'enviado':'erro',
data_ultimo_contato:new Date().toISOString(),wamid:id||'',erro_envio:id?'':JSON.stringify(r.body?.error||r.error||r).slice(0,1000)}};`);
pg('Registrar tentativa',`UPDATE wa_campaigns SET state=$3,wamid=NULLIF($4,''),error=NULLIF($5,''),updated_at=now()
WHERE campaign_id=$1 AND phone=$2 RETURNING phone;`,
`={{ [ $('Configuracao').first().json.campaign_id,$json.telefone,$json.status_envio,$json.wamid,$json.erro_envio ] }}`);
sheet('Atualizar envio','update',{
telefone:"={{ $('Resultado do disparo').item.json.telefone }}",
status_envio:"={{ $('Resultado do disparo').item.json.status_envio }}",
data_ultimo_contato:"={{ $('Resultado do disparo').item.json.data_ultimo_contato }}",
erro_envio:"={{ $('Resultado do disparo').item.json.erro_envio }}",
wamid:"={{ $('Resultado do disparo').item.json.wamid }}",
});
add('Esperar 3 a 5 segundos','wait',{amount:'={{ 3 + Math.floor(Math.random()*3) }}',unit:'seconds'},{typeVersion:1.1,webhookId:'cadencia-whatsapp'});
link('Iniciar manualmente','Configuracao');link('Configuracao','Ler contatos');link('Ler contatos','Filtrar elegiveis');
link('Filtrar elegiveis','Um contato por vez');link('Um contato por vez','Reservar campanha',1);
link('Reservar campanha','Reserva obtida');link('Reserva obtida','Reler antes do envio');link('Reserva obtida','Esperar 3 a 5 segundos',1);
link('Reler antes do envio','Ainda permitido');link('Ainda permitido','Conferir bloqueio persistente');link('Ainda permitido','Esperar 3 a 5 segundos',1);
link('Conferir bloqueio persistente','Banco permite');link('Banco permite','Enviar template');link('Banco permite','Esperar 3 a 5 segundos',1);
link('Enviar template','Resultado do disparo');link('Resultado do disparo','Registrar tentativa');link('Registrar tentativa','Atualizar envio');
link('Atualizar envio','Esperar 3 a 5 segundos');link('Esperar 3 a 5 segundos','Um contato por vez');
b.save('01-disparo.referencia.json');
}
{
const b=workflow('02 - Atendimento WhatsApp - REFERENCIA configurar antes de ativar');
const {add,code,pg,cond,http,sheet,link}=b;
add('WhatsApp Trigger','whatsAppTrigger',{updates:['messages'],options:{}},{webhookId:'atendimento-whatsapp'});
code('Normalizar evento',`
const out=[];
for (const item of $input.all()) {
 const root=item.json.body||item.json;
 const values=root.entry?root.entry.flatMap(e=>(e.changes||[]).map(c=>c.value)):[root];
 for(const v of values) {
 for(const s of v.statuses||[]) {
  if(!s.id||!s.recipient_id)continue;
  out.push({json:{kind:'status',id:s.id,phone:String(s.recipient_id),timestamp:s.timestamp,
   status:s.status,errors:s.errors||[],phone_number_id:v.metadata?.phone_number_id}});
 }
 for(const m of v.messages||[]) {
  if(!m.id||!m.from)continue;
  out.push({json:{id:m.id,phone:String(m.from),timestamp:m.timestamp,
   text:m.interactive?.list_reply?.id||m.interactive?.button_reply?.id||m.button?.payload||m.text?.body||'',
   type:m.type,phone_number_id:v.metadata?.phone_number_id}});
 }}
}
return out;`,false);
code('Configuracao',`return {json:{...$json,config:${JSON.stringify(config)}}};`);
cond('Numero correto',"={{ $json.phone_number_id === $json.config.phone_number_id }}");
cond('Evento de entrega',"={{ $json.kind === 'status' }}");
pg('Registrar entrega',`INSERT INTO wa_delivery(wamid,status,event_at,phone,payload)
VALUES($1,$2,to_timestamp($3::double precision),$4,$5::jsonb)
ON CONFLICT DO NOTHING RETURNING *;`,
`={{ [ $json.id,$json.status,$json.timestamp,$json.phone,JSON.stringify($json) ] }}`);
cond('Entrega falhou',"={{ $json.status === 'failed' }}");
sheet('Contato da falha','read',null,"={{ $json.phone }}");
cond('Falha da mensagem atual',"={{ !!$json.telefone && $json.wamid === $('Configuracao').item.json.id }}");
sheet('Registrar falha assincrona','update',{
telefone:"={{ $json.telefone }}",
status_envio:"={{ ['transferido','respondeu'].includes($json.status_envio) ? $json.status_envio : 'erro' }}",
erro_envio:"={{ JSON.stringify($('Configuracao').item.json.errors).slice(0,1000) }}",
});
pg('Deduplicar entrada',`WITH inserted AS (
 INSERT INTO wa_events(event_id,phone,payload) VALUES($1,$2,$3::jsonb)
 ON CONFLICT DO NOTHING RETURNING event_id)
 SELECT EXISTS(SELECT 1 FROM inserted) AS fresh;`,
`={{ [ $json.id,$json.phone,JSON.stringify($json) ] }}`);
cond('Evento novo','={{ $json.fresh }}');
sheet('Buscar contato','read',null,"={{ $('Configuracao').item.json.phone }}");
pg('Carregar sessao',`SELECT COALESCE((SELECT data FROM wa_sessions WHERE phone=$1),'{}'::jsonb) AS session, $2::jsonb AS contact;`,
`={{ [ $('Configuracao').item.json.phone,JSON.stringify($json) ] }}`);
code('Decidir atendimento',`${route.toString()}\nreturn {json:route({contact:$json.contact,session:$json.session,message:$('Configuracao').item.json,config:$('Configuracao').item.json.config})};`);
// Switch por saída numérica reduz dependência de regras de UI entre versões.
add('Rotear acao','switch',{mode:'expression',numberOutputs:5,output:'={{ ({tracking:0,shipping:1,handoff:2,none:3})[$json.action] ?? 4 }}'},{typeVersion:3.2});
http('Consultar rastreamento',"={{ $('Configuracao').item.json.config.tracking_url }}",
`={{ {telefone:$json.phone,codigo_pedido:$json.order} }}`);
http('Consultar frete',"={{ $('Configuracao').item.json.config.shipping_url }}",
`={{ {telefone:$json.phone,codigo_pedido:$json.codigo_pedido,cep_destino:$json.cep} }}`);
code('Formatar rastreamento',`
const r={...$('Decidir atendimento').item.json};const b=$json.body;
const ok=$json.statusCode>=200&&$json.statusCode<300&&b?.autorizado===true&&b?.status;
r.action='text';r.text=ok?'Pedido '+r.order+': '+b.status+'. Previsão: '+(b.previsao_entrega||'ainda não informada')+'.':'Não consegui consultar esse pedido. Confira o código ou digite 4 para falar com um vendedor.';
r.text+='\\n\\nPosso ajudar em algo mais?';if(!ok)r.erro_envio='Falha na consulta de rastreamento';return {json:r};`);
code('Formatar frete',`
const r={...$('Decidir atendimento').item.json};const b=$json.body;
const options=Array.isArray(b?.opcoes)?b.opcoes.filter(o=>Number.isFinite(o.valor)&&o.valor>=0&&Number.isInteger(o.prazo_dias_uteis)&&o.prazo_dias_uteis>=0):[];
const ok=$json.statusCode>=200&&$json.statusCode<300&&options.length>0;
r.action='text';r.text=ok?options.slice(0,8).map(o=>o.servico+': '+o.valor.toLocaleString('pt-BR',{style:'currency',currency:'BRL'})+' — '+o.prazo_dias_uteis+' dias úteis').join('\\n'):'Não consegui calcular o frete. Digite 4 para falar com um vendedor.';
r.text+='\\n\\nPosso ajudar em algo mais?';if(!ok)r.erro_envio='Falha na consulta de frete';return {json:r};`);
pg('Persistir contexto',`INSERT INTO wa_sessions(phone,data) VALUES($1,$2::jsonb || '{"menu_shown":true}'::jsonb)
ON CONFLICT(phone) DO UPDATE SET data=EXCLUDED.data,updated_at=now() RETURNING data;`,
`={{ [ $json.phone,JSON.stringify($json) ] }}`);
code('Preparar registro','return {json:{...$json.data,telefone:$json.data.phone}};');
sheet('Espelhar contato','appendOrUpdate',{
telefone:'={{ $json.telefone }}',nome:'={{ $json.nome }}',codigo_pedido:'={{ $json.codigo_pedido }}',
status_envio:'={{ $json.status_envio }}',data_ultimo_contato:'={{ $json.data_ultimo_contato }}',
opt_out:'={{ $json.opt_out }}',bot_paused:'={{ $json.bot_paused }}',
});
code('Restaurar contexto',"return {json:$('Preparar registro').item.json};");
cond('Notificar vendedor','={{ $json.notify }}');
add('Email para vendedor','emailSend',{fromEmail:'PREENCHER@empresa.example',toEmail:"={{ $('Configuracao').item.json.config.vendedor_email }}",
subject:'={{ "Atendimento WhatsApp: "+$json.nome }}',emailFormat:'text',
text:'={{ "Cliente: "+$json.nome+"\\nTelefone: "+$json.phone+"\\nPedido: "+$json.codigo_pedido+"\\nBot pausado. Assumir na caixa de atendimento compartilhada." }}',options:{}},{typeVersion:2.1});
code('Contexto para envio',"return {json:$('Preparar registro').item.json};");
cond('Responder permitido',"={{ $json.action !== 'none' }}");
code('Montar mensagem',`
const r=$json;const base={messaging_product:'whatsapp',to:r.phone};
const payload=r.action==='menu'?{...base,type:'interactive',interactive:{type:'list',body:{text:r.text},action:{button:'Ver opções',sections:[{title:'Atendimento',rows:[{id:'1',title:'Rastreamento'},{id:'2',title:'Forma de pagamento'},{id:'3',title:'Calcular frete'},{id:'4',title:'Falar com vendedor'}]}]}}}:{...base,type:'text',text:{body:r.text.slice(0,4000)}};
return {json:{...r,payload}};`);
const waUrl="={{ 'https://graph.facebook.com/'+$('Configuracao').item.json.config.graph_version+'/'+$('Configuracao').item.json.config.phone_number_id+'/messages' }}";
http('Enviar resposta',waUrl,'={{ $json.payload }}');
cond('Fallback de formato',`={{ $('Montar mensagem').item.json.payload.type === 'interactive' && $json.statusCode === 400 && [100,131009].includes(Number($json.body?.error?.code)) }}`);
http('Enviar texto alternativo',waUrl,`={{ {messaging_product:'whatsapp',to:$('Montar mensagem').item.json.phone,type:'text',text:{body:$('Montar mensagem').item.json.text}} }}`);
code('Avaliar envio',`
const r={...$('Preparar registro').item.json};const id=$json.body?.messages?.[0]?.id;
r.wamid=id||'';r.send_ok=!!id;
if(!id){r.status_envio=r.bot_paused?'transferido':'erro';r.erro_envio=JSON.stringify($json.body?.error||$json.error||$json).slice(0,1000);}
r.data_ultimo_contato=new Date().toISOString();return {json:r};`);
sheet('Registrar resultado','update',{
telefone:'={{ $json.phone }}',status_envio:'={{ $json.status_envio }}',
data_ultimo_contato:'={{ $json.data_ultimo_contato }}',erro_envio:'={{ $json.erro_envio || "" }}',wamid:'={{ $json.wamid }}',
});
pg('Concluir evento',`UPDATE wa_events SET state='done',updated_at=now() WHERE event_id=$1 RETURNING event_id;`,
`={{ [ $('Configuracao').item.json.id ] }}`);
link('WhatsApp Trigger','Normalizar evento');link('Normalizar evento','Configuracao');link('Configuracao','Numero correto');
link('Numero correto','Evento de entrega');link('Evento de entrega','Registrar entrega');
link('Registrar entrega','Entrega falhou');link('Entrega falhou','Contato da falha');
link('Contato da falha','Falha da mensagem atual');link('Falha da mensagem atual','Registrar falha assincrona');
link('Evento de entrega','Deduplicar entrada',1);link('Deduplicar entrada','Evento novo');link('Evento novo','Buscar contato');
link('Buscar contato','Carregar sessao');link('Carregar sessao','Decidir atendimento');link('Decidir atendimento','Rotear acao');
link('Rotear acao','Consultar rastreamento',0);link('Consultar rastreamento','Formatar rastreamento');link('Formatar rastreamento','Persistir contexto');
link('Rotear acao','Consultar frete',1);link('Consultar frete','Formatar frete');link('Formatar frete','Persistir contexto');
for(const o of [2,3,4])link('Rotear acao','Persistir contexto',o);
link('Persistir contexto','Preparar registro');link('Preparar registro','Espelhar contato');link('Espelhar contato','Restaurar contexto');
link('Restaurar contexto','Notificar vendedor');link('Notificar vendedor','Email para vendedor');link('Email para vendedor','Contexto para envio');
link('Notificar vendedor','Contexto para envio',1);link('Contexto para envio','Responder permitido');
link('Responder permitido','Montar mensagem');link('Responder permitido','Concluir evento',1);link('Montar mensagem','Enviar resposta');
link('Enviar resposta','Fallback de formato');link('Fallback de formato','Enviar texto alternativo');link('Enviar texto alternativo','Avaliar envio');
link('Fallback de formato','Avaliar envio',1);link('Avaliar envio','Registrar resultado');link('Registrar resultado','Concluir evento');
b.save('02-atendimento.referencia.json');
}
{
const b=workflow('03 - Expirar sessoes WhatsApp');
b.add('A cada minuto','scheduleTrigger',{rule:{interval:[{field:'minutes',minutesInterval:1}]}},{typeVersion:1.2});
b.pg('Expirar apenas contexto',`UPDATE wa_sessions
SET data = (data - 'order' - 'cep') || '{"state":"ENCERRADO","expires_at":null,"menu_shown":false}'::jsonb,
updated_at=now()
WHERE NULLIF(data->>'expires_at','')::timestamptz <= now()
AND COALESCE(data->>'bot_paused','false') <> 'true'
AND COALESCE(data->>'opt_out','false') <> 'true';`,'');
b.link('A cada minuto','Expirar apenas contexto');
b.save('03-expiracao.json');
}
for(const file of fs.readdirSync(dir).filter(f=>f.endsWith('.json'))) {
 const w=JSON.parse(fs.readFileSync(path.join(dir,file),'utf8'));
 const names=new Set(w.nodes.map(n=>n.name));
 if(names.size!==w.nodes.length)throw Error('Nome duplicado');
 for(const [name,c] of Object.entries(w.connections)){
  if(!names.has(name))throw Error('Origem inexistente');
  for(const edges of c.main)for(const edge of edges)if(!names.has(edge.node))throw Error('Destino inexistente');
 }
 for(const n of w.nodes.filter(n=>n.type==='n8n-nodes-base.code'))new Function(n.parameters.jsCode);
 console.log(`${file}: ${w.nodes.length} nós; JSON, conexões e sintaxe Code válidos`);
}
