const { GoogleGenerativeAI, SchemaType } = require('@google/generative-ai');
const { adminFirebase } = require('./config/firebase'); // reutiliza a instância já inicializada

const db = adminFirebase.firestore();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const responseSchema = {
    type: SchemaType.OBJECT,
    properties: {
        resposta_ia: {
            type: SchemaType.STRING,
            description: "A resposta em texto amigável para o cliente.",
        },
        imagem_url: {
            type: SchemaType.STRING,
            description: "Se o cliente pedir para ver um produto, coloque o link da 'imagem_url' aqui. Se não, deixe em branco.",
        },
        itens_carrinho: {
            type: SchemaType.ARRAY,
            items: {
                type: SchemaType.OBJECT,
                properties: {
                    id: { type: SchemaType.STRING },
                    quantidade: { type: SchemaType.INTEGER },
                },
            },
        },
    },
    required: ["resposta_ia", "imagem_url", "itens_carrinho"],
};

async function chatHandler(req, res) {
    try {
        const mensagemDoCliente = req.body.message;
        const carrinhoAtual = req.body.carrinho || "Carrinho vazio";

        const snapshot = await db.collection('produtos').get();

        const cardapioDinamico = [];
        snapshot.forEach(doc => {
            const d = doc.data();

            // imagem pode ser null ou objeto Cloudinary { url, public_id }
            const imagemUrl = d.imagem?.url || "";

            cardapioDinamico.push({
                id: doc.id,           // ID real do Firestore (string)
                name: d.nome,
                price: d.valor,
                description: d.descricao || "Sem descrição",
                image: imagemUrl,
            });
        });

        const model = genAI.getGenerativeModel({
            model: "gemini-2.5-flash",
            generationConfig: {
                responseMimeType: "application/json",
                responseSchema: responseSchema,
            }
        });

        const prompt = `
Você é o assistente virtual da hamburgueria "Impérios Burger".
Cardápio atualizado: ${JSON.stringify(cardapioDinamico)}
Carrinho do cliente: "${carrinhoAtual}"

Regras OBRIGATÓRIAS:
1. Seja natural. Se o cliente disser "Oi", responda com uma saudação.
2. Se o cliente pedir para ver um produto, preencha o campo "imagem_url" com o link da foto e descreva o lanche na "resposta_ia".
3. Se o cliente pedir algo novo, coloque os IDs (string) em "itens_carrinho".
4. FORMATAÇÃO VISUAL: Quando for apresentar o cardápio ou listar produtos, use a quebra de linha "\\n" para colocar cada item em uma linha separada. Use emojis de comida (🍔, 🍟, 🥤).
5. REGRA DE OURO: NUNCA mostre o campo "id" no texto da "resposta_ia". Para o cliente, mostre apenas nome, ingredientes e preço.

Mensagem do cliente: "${mensagemDoCliente}"
`;

        const result = await model.generateContent(prompt);
        const textoIA = result.response.text();
        const jsonFinal = JSON.parse(textoIA);

        res.json(jsonFinal);

    } catch (error) {
        console.error("Erro no chat IA:", error);

        if (error.message?.includes('429')) {
            return res.status(200).json({
                resposta_ia: "Ufa! Muitos clientes falando comigo ao mesmo tempo. Pode aguardar 1 minutinho e repetir?",
                imagem_url: "",
                itens_carrinho: []
            });
        }

        if (error.message?.includes('503')) {
            return res.status(200).json({
                resposta_ia: "Nossos servidores centrais estão super lotados no momento! Tente novamente em alguns segundos.",
                imagem_url: "",
                itens_carrinho: []
            });
        }

        res.status(500).json({
            resposta_ia: "Desculpe, tive um problema técnico. Pode repetir?",
            imagem_url: "",
            itens_carrinho: []
        });
    }
}

module.exports = { chatHandler };
