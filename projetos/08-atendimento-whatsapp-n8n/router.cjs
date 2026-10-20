// Regra de negócio pura. O gerador incorpora esta função no nó Code.
function route({ contact = {}, session = {}, message = {}, config = {}, now = Date.now() }) {
  const raw = String(message.text || '').trim();
  const text = raw.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  const yes = v => v === true || ['true', 'sim', '1'].includes(String(v).toLowerCase());
  const phone = String(message.phone || contact.telefone || '');
  const expired = !session.expires_at || Date.parse(session.expires_at) <= now;
  const s = { ...session, state: expired ? 'MENU' : (session.state || 'MENU') };
  const result = {
    phone, message_id: message.id, nome: contact.nome || 'cliente',
    codigo_pedido: contact.codigo_pedido || '',
    status_envio: 'respondeu', data_ultimo_contato: new Date(now).toISOString(),
    opt_out: yes(session.opt_out) || yes(contact.opt_out),
    bot_paused: yes(session.bot_paused) || yes(contact.bot_paused) || contact.status_envio === 'transferido',
    state: s.state, expires_at: new Date(now + 30 * 60000).toISOString(),
    last_inbound_at: new Date(Number(message.timestamp || now / 1000) * 1000).toISOString(),
    action: 'text', text: '', notify: false,
  };
  const reply = (body, state = 'MAIS') => {
    result.state = state;
    result.text = body + (state === 'MAIS' ? '\n\nPosso ajudar em algo mais? Responda “sim”, escolha uma opção ou diga “não”.' : '');
    return result;
  };
  const menu = () => {
    result.state = 'MENU'; result.action = 'menu';
    result.text = `Olá, ${result.nome}! Como posso te ajudar?\n1️⃣ Rastreamento\n2️⃣ Forma de pagamento\n3️⃣ Envio / calcular o frete\n4️⃣ Falar com um vendedor`;
    return result;
  };
  // Opt-out tem prioridade inclusive sobre transferência humana.
  if (/^(sair|parar|stop|cancelar mensagens)[.! ]*$/.test(text) ||
      /(?:nao quero|nao desejo|pare de|parar de|nao me).*(?:mensage|receber|envia|contat)/.test(text)) {
    const already = result.opt_out;
    result.opt_out = true; result.state = 'ENCERRADO'; result.expires_at = null;
    result.action = already || Date.parse(result.last_inbound_at) + 24 * 3600000 <= now ? 'none' : 'text';
    result.text = 'Seu pedido foi registrado. Você não receberá mais mensagens automáticas.';
    return result;
  }
  if (result.opt_out || result.bot_paused) {
    result.action = 'none';
    result.status_envio = result.bot_paused ? 'transferido' : 'respondeu';
    return result;
  }
  if (Date.parse(result.last_inbound_at) + 24 * 3600000 <= now) {
    result.action = 'none'; result.state = 'ENCERRADO'; result.expires_at = null;
    return result; // Não responder livremente a um evento antigo.
  }
  let intent = '';
  if (text === '4' || /\b(vendedor|atendente|humano|pessoa)\b/.test(text) || text === 'vendedor') intent = 'seller';
  else if (text === '2' || /\b(pagamento|pagar|pix|cartao|boleto|parcelamento|parcelar)\b/.test(text)) intent = 'payment';
  else if (text === '3' || /\b(frete|cep|envio|entrega custa)\b/.test(text)) intent = 'shipping';
  else if (text === '1' || /\b(rastreamento|rastrear|rastreio|cade meu pedido|onde esta meu pedido)\b/.test(text)) intent = 'tracking';
  if (intent === 'seller') {
    result.bot_paused = true; result.notify = true; result.action = 'handoff';
    result.status_envio = 'transferido'; result.state = 'HUMANO'; result.expires_at = null;
    result.text = 'Vou encaminhar seu atendimento para um vendedor. Aguarde o retorno da nossa equipe.';
    return result;
  }
  // Primeira interação mostra o menu; opt-out e pedido humano continuam prioritários.
  if (!session.menu_shown || expired) return menu();
  if (intent === 'payment') {
    return reply(config.pagamento || 'As condições de pagamento ainda não foram configuradas. Digite 4 para falar com um vendedor.');
  }
  if (text === 'menu' || text === 'sim') return menu();
  if (s.state === 'MAIS' && /^(nao|obrigad[oa]|encerrar|tchau)[.! ]*$/.test(text)) {
    result.expires_at = null;
    return reply('Obrigado pelo contato! Quando precisar, envie uma nova mensagem.', 'ENCERRADO');
  }
  if (intent === 'tracking' || (s.state === 'AGUARDA_PEDIDO' && !intent)) {
    const order = intent === 'tracking' ? result.codigo_pedido : raw;
    if (!order || !/^[\p{L}\p{N}_./-]{1,64}$/u.test(String(order))) {
      return reply('Qual é o código do seu pedido?', 'AGUARDA_PEDIDO');
    }
    result.action = 'tracking'; result.order = String(order); result.state = 'MAIS';
    return result;
  }
  if (intent === 'shipping') return reply('Informe o CEP de destino, com 8 dígitos.', 'AGUARDA_CEP');
  if (s.state === 'AGUARDA_CEP' && !intent) {
    if (!/^\d{5}-?\d{3}$/.test(raw)) return reply('CEP inválido. Envie 8 dígitos, por exemplo 01001000.', 'AGUARDA_CEP');
    result.action = 'shipping'; result.cep = raw.replace('-', ''); result.state = 'MAIS';
    return result;
  }
  return menu();
}
module.exports = { route };
