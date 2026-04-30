const { GoogleGenerativeAI, SchemaType } = require('@google/generative-ai');
const { adminFirebase } = require('./config/firebase');

const db    = adminFirebase.firestore();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// ─── Cache do cardápio (evita Firestore a cada mensagem) ──────────────────────
let _cache   = null;
let _cacheAt = 0;
const CACHE_TTL = 5 * 60 * 1000; // 5 minutos

async function getCardapio() {
  if (_cache && Date.now() - _cacheAt < CACHE_TTL) return _cache;
  const snap = await db.collection('produtos').get();
  _cache = snap.docs.map(doc => {
    const d = doc.data();
    return {
      id:       doc.id,
      nome:     d.nome        || '',
      preco:    d.valor       || 0,
      categoria: d.categoria  || '',
      imagem:   d.imagem?.url || '',
    };
  });
  _cacheAt = Date.now();
  return _cache;
}

// ─── Schema de resposta ───────────────────────────────────────────────────────
const schema = {
  type: SchemaType.OBJECT,
  properties: {
    resposta: {
      type: SchemaType.STRING,
      description: 'Resposta curta e amigável. Nunca inclua IDs.',
    },
    itens: {
      type: SchemaType.ARRAY,
      description: 'Produtos a adicionar ao carrinho.',
      items: {
        type: SchemaType.OBJECT,
        properties: {
          id:         { type: SchemaType.STRING },
          quantidade: { type: SchemaType.INTEGER },
        },
        required: ['id', 'quantidade'],
      },
    },
  },
  required: ['resposta', 'itens'],
};

// ─── Extrai JSON mesmo quando o modelo inclui texto antes/depois ──────────────
function extrairJson(texto) {
  try { return JSON.parse(texto); } catch {}
  const inicio = texto.indexOf('{');
  const fim    = texto.lastIndexOf('}');
  if (inicio !== -1 && fim > inicio) {
    return JSON.parse(texto.slice(inicio, fim + 1));
  }
  throw new Error(`JSON não encontrado na resposta: ${texto.slice(0, 80)}`);
}

// ─── Constrói a mensagem de sistema (breve — não inclui o cardápio) ───────────
const SYSTEM = `Você é o atendente virtual do "Impérios Delivery".
Responda em português, de forma direta e simpática.
Máximo 3 linhas por resposta, exceto ao listar o cardápio.
NUNCA revele IDs técnicos no texto.
Para listar produtos use: "• Nome — R$ x,xx".
Se o cliente pedir um item disponível, inclua-o em "itens" com o ID exato.
Se pedir algo que não existe, sugira a alternativa mais próxima.`;

// ─── Constrói mensagem inicial que apresenta o cardápio ao modelo ─────────────
// O cardápio vai na 1ª troca do histórico (não no system) para evitar
// que o modelo confunda contexto de sistema com conteúdo do usuário.
function buildCardapioTurn(cardapio) {
  const linhas = cardapio
    .map(p => `${p.id} | ${p.nome} | R$${Number(p.preco).toFixed(2)} | ${p.categoria}`)
    .join('\n');

  return {
    user:  `[CARDÁPIO ATUAL]\n${linhas}\n[USE ESSES IDs ao preencher itens_carrinho]`,
    model: '{"resposta":"Cardápio carregado! Pronto para atender.","itens":[]}',
  };
}

// ─── Handler ──────────────────────────────────────────────────────────────────
async function chatHandler(req, res) {
  const mensagem  = (req.body.message  || '').trim();
  const carrinho  = (req.body.carrinho || '').trim();
  const historico = Array.isArray(req.body.historico) ? req.body.historico : [];

  if (!mensagem) {
    return res.status(400).json({ error: 'Mensagem vazia.' });
  }

  try {
    const cardapio = await getCardapio();

    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      systemInstruction: SYSTEM,
      generationConfig: {
        responseMimeType: 'application/json',
        responseSchema:   schema,
        temperature:      0.5,
        maxOutputTokens:  400,
      },
    });

    // 1ª entrada do histórico: cardápio como contexto fixo
    const cardapioTurn = buildCardapioTurn(cardapio);

    // Histórico da conversa (máximo 5 trocas anteriores)
    const ultimas = historico.slice(-5);

    const history = [
      // Turno do cardápio (sempre o primeiro)
      { role: 'user',  parts: [{ text: cardapioTurn.user  }] },
      { role: 'model', parts: [{ text: cardapioTurn.model }] },
      // Histórico real da conversa
      ...ultimas.flatMap(t => [
        { role: 'user',  parts: [{ text: t.user }] },
        { role: 'model', parts: [{ text: JSON.stringify({ resposta: t.assistant, itens: [] }) }] },
      ]),
    ];

    const chat = model.startChat({ history });

    // Adiciona estado compacto do carrinho apenas se relevante
    const msgFinal = carrinho && carrinho !== 'O carrinho está vazio.'
      ? `[Carrinho: ${carrinho}]\n${mensagem}`
      : mensagem;

    const result = await chat.sendMessage(msgFinal);
    const parsed = extrairJson(result.response.text());

    const itens = (parsed.itens || []).filter(i => i.id && i.quantidade > 0);

    // Resolve imagem do 1º item sugerido — a IA não precisa saber as URLs
    let imagemUrl = '';
    if (itens.length > 0) {
      const prod = cardapio.find(p => p.id === itens[0].id);
      if (prod?.imagem) imagemUrl = prod.imagem;
    }

    return res.json({
      resposta_ia:    parsed.resposta,
      imagem_url:     imagemUrl,
      itens_carrinho: itens,
    });

  } catch (err) {
    console.error('[IA]', err.message);

    if (err.status === 429 || err.message?.includes('429')) {
      return res.status(200).json({
        resposta_ia:    'Muitos pedidos simultâneos! Tente novamente em instantes. 😅',
        imagem_url:     '',
        itens_carrinho: [],
      });
    }

    return res.status(200).json({
      resposta_ia:    'Tive um problema técnico. Pode repetir o pedido?',
      imagem_url:     '',
      itens_carrinho: [],
    });
  }
}

function invalidarCache() {
  _cache   = null;
  _cacheAt = 0;
}

module.exports = { chatHandler, invalidarCache };
