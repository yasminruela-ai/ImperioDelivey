const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI, SchemaType } = require('@google/generative-ai');
require('dotenv').config();

const admin = require("firebase-admin");
const serviceAccount = require("../firebase-key.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const api = express();

api.use(cors());
api.use(express.urlencoded({ extended: false }));
api.use(express.json());

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
            description: "Se o cliente pedir para ver um produto, coloque o link da 'image' aqui. Se não, deixe em branco.",
        },
        itens_carrinho: {
            type: SchemaType.ARRAY,
            items: {
                type: SchemaType.OBJECT,
                properties: {
                    id: { type: SchemaType.INTEGER },
                    quantidade: { type: SchemaType.INTEGER },
                },
            },
        },
    },
    required: ["resposta_ia", "imagem_url", "itens_carrinho"],
};

api.post('/api/chat', async (req, res) => {
    try {
        const mensagemDoCliente = req.body.message;
        const carrinhoAtual = req.body.carrinho || "Carrinho vazio";

        const produtosRef = db.collection('produtos');
        const snapshot = await produtosRef.get();

        let cardapioDinamico = [];
        snapshot.forEach(doc => {
            cardapioDinamico.push({
                id: doc.data().id,
                name: doc.data().name,
                price: doc.data().price,
                description: doc.data().description || "Sem descrição",
                image: doc.data().image || ""
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
    3. Se o cliente pedir algo novo, coloque os IDs em "itens_carrinho".
    4. FORMATAÇÃO VISUAL: Quando for apresentar o cardápio ou listar produtos, você é OBRIGADO a usar a quebra de linha "\\n" para colocar cada item em uma linha separada. Use emojis de comida (🍔, 🍟, 🥤) para deixar a leitura agradável.
    5. REGRA DE OURO: NUNCA mostre o campo "id" no texto da "resposta_ia". O ID é uma informação confidencial apenas para o sistema. Para o cliente, mostre apenas o nome do lanche, os ingredientes e o preço.

    Mensagem do cliente: "${mensagemDoCliente}"
    `;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const textoIA = response.text();

        const jsonFinal = JSON.parse(textoIA);
        res.json(jsonFinal);

    } catch (error) {
        console.error("Erro detalhado no servidor:", error);

        // Mapeando Erro 429 (Limite da sua cota/chave)
        if (error.message && error.message.includes('429')) {
            return res.status(200).json({
                resposta_ia: "Ufa! Muitos clientes falando comigo ao mesmo tempo. Pode aguardar 1 minutinho e repetir?",
                imagem_url: "",
                itens_carrinho: []
            });
        }

        // --- NOVO: Mapeando Erro 503 (Servidores do Google sobrecarregados) ---
        if (error.message && error.message.includes('503')) {
            return res.status(200).json({
                resposta_ia: "Nossos servidores centrais estão super lotados no momento! Pode tentar me pedir a foto novamente daqui a alguns segundos?",
                imagem_url: "",
                itens_carrinho: []
            });
        }

        // Se for qualquer outro erro (500)
        res.status(500).json({
            resposta_ia: "Desculpe, tive um problema técnico. Pode repetir?",
            imagem_url: "",
            itens_carrinho: []
        });
    }
});

module.exports = api;