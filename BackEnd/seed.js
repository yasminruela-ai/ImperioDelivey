const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "env") });

const { adminFirebase } = require("./src/config/firebase");
const auth = adminFirebase.auth();
const db = adminFirebase.firestore();

// ─── Dados de seed ────────────────────────────────────────────────────────────

const usuarios = [
  {
    email: "gerente@imperio.com",
    password: "Imperio@123",
    nome: "Gerente Imperio",
    telefone: "(11) 99999-0001",
    tipo: "gerente",
    endereco: {
      pais: "Brasil", estado: "SP", cidade: "São Paulo",
      bairro: "Centro", rua: "Rua das Flores", numero: "1", cep: "01001-000",
    },
  },
  {
    email: "cliente1@imperio.com",
    password: "Imperio@123",
    nome: "João Silva",
    telefone: "(11) 98888-0001",
    tipo: "cliente",
    endereco: {
      pais: "Brasil", estado: "SP", cidade: "São Paulo",
      bairro: "Vila Madalena", rua: "Rua Harmonia", numero: "42", cep: "05435-000",
    },
  },
  {
    email: "cliente2@imperio.com",
    password: "Imperio@123",
    nome: "Maria Souza",
    telefone: "(11) 97777-0002",
    tipo: "cliente",
    endereco: {
      pais: "Brasil", estado: "SP", cidade: "São Paulo",
      bairro: "Pinheiros", rua: "Rua dos Pinheiros", numero: "100", cep: "05422-000",
    },
  },
];

const produtos = [
  // Lanches
  {
    nome: "X-Burguer Clássico",
    descricao: "Pão brioche, 180g de carne bovina, queijo cheddar, alface, tomate e maionese especial.",
    valor: 28.90,
    categoria: "Lanches",
    imagem: { url: "https://placehold.co/400x300?text=X-Burguer", public_id: null },
  },
  {
    nome: "X-Bacon Duplo",
    descricao: "Dois smash burgers, bacon crocante, queijo prato, cebola caramelizada e molho bbq.",
    valor: 36.90,
    categoria: "Lanches",
    imagem: { url: "https://placehold.co/400x300?text=X-Bacon", public_id: null },
  },
  {
    nome: "Combo Frango Crispy",
    descricao: "Frango empanado crocante, queijo suíço, alface americana e molho ranch.",
    valor: 31.90,
    categoria: "Lanches",
    imagem: { url: "https://placehold.co/400x300?text=Frango+Crispy", public_id: null },
  },
  // Pizzas
  {
    nome: "Pizza Margherita",
    descricao: "Molho de tomate artesanal, mussarela de búfala, manjericão fresco. Tamanho médio (8 fatias).",
    valor: 45.00,
    categoria: "Pizzas",
    imagem: { url: "https://placehold.co/400x300?text=Pizza+Margherita", public_id: null },
  },
  {
    nome: "Pizza Calabresa",
    descricao: "Molho de tomate, mussarela, calabresa fatiada e cebola. Tamanho médio (8 fatias).",
    valor: 49.00,
    categoria: "Pizzas",
    imagem: { url: "https://placehold.co/400x300?text=Pizza+Calabresa", public_id: null },
  },
  // Porções
  {
    nome: "Batata Frita",
    descricao: "Porção de batata frita crocante temperada. Serve 2 pessoas.",
    valor: 18.00,
    categoria: "Porções",
    imagem: { url: "https://placehold.co/400x300?text=Batata+Frita", public_id: null },
  },
  {
    nome: "Onion Rings",
    descricao: "Anéis de cebola empanados e fritos. Acompanha molho barbecue.",
    valor: 22.00,
    categoria: "Porções",
    imagem: { url: "https://placehold.co/400x300?text=Onion+Rings", public_id: null },
  },
  // Bebidas
  {
    nome: "Refrigerante Lata",
    descricao: "Coca-Cola, Guaraná Antarctica ou Sprite. 350ml.",
    valor: 7.00,
    categoria: "Bebidas",
    imagem: { url: "https://placehold.co/400x300?text=Refrigerante", public_id: null },
  },
  {
    nome: "Suco Natural 500ml",
    descricao: "Laranja, Limão, Maracujá ou Abacaxi. Feito na hora.",
    valor: 12.00,
    categoria: "Bebidas",
    imagem: { url: "https://placehold.co/400x300?text=Suco+Natural", public_id: null },
  },
  {
    nome: "Milkshake 400ml",
    descricao: "Chocolate, Morango ou Baunilha. Com chantilly.",
    valor: 19.00,
    categoria: "Bebidas",
    imagem: { url: "https://placehold.co/400x300?text=Milkshake", public_id: null },
  },
  // Sobremesas
  {
    nome: "Brownie com Sorvete",
    descricao: "Brownie quentinho de chocolate com bola de sorvete de creme e calda de chocolate.",
    valor: 16.00,
    categoria: "Sobremesas",
    imagem: { url: "https://placehold.co/400x300?text=Brownie", public_id: null },
  },
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

async function criarUsuario(u) {
  try {
    // Verifica se já existe no Auth
    let uid;
    try {
      const existing = await auth.getUserByEmail(u.email);
      uid = existing.uid;
      console.log(`  [skip] Usuário já existe: ${u.email}`);
    } catch {
      const created = await auth.createUser({ email: u.email, password: u.password });
      uid = created.uid;
    }

    await db.collection("users").doc(uid).set({
      nome: u.nome,
      telefone: u.telefone,
      email: u.email,
      tipo: u.tipo,
      endereco: u.endereco,
    }, { merge: true });

    console.log(`  [ok] ${u.tipo.padEnd(7)} ${u.email}`);
    return uid;
  } catch (err) {
    console.error(`  [erro] ${u.email}: ${err.message}`);
  }
}

async function criarProduto(p) {
  try {
    // Evita duplicatas por nome
    const snap = await db.collection("produtos").where("nome", "==", p.nome).get();
    if (!snap.empty) {
      console.log(`  [skip] Produto já existe: ${p.nome}`);
      return;
    }
    const ref = db.collection("produtos").doc();
    await ref.set(p);
    console.log(`  [ok] ${p.categoria.padEnd(12)} ${p.nome}`);
  } catch (err) {
    console.error(`  [erro] ${p.nome}: ${err.message}`);
  }
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function seed() {
  console.log("\n🌱 Iniciando seed do banco de dados...\n");

  console.log("👤 Criando usuários:");
  for (const u of usuarios) {
    await criarUsuario(u);
  }

  console.log("\n🍔 Criando produtos:");
  for (const p of produtos) {
    await criarProduto(p);
  }

  console.log("\n✅ Seed concluído!\n");
  console.log("Credenciais para teste:");
  console.log("  Gerente : gerente@imperio.com  / Imperio@123");
  console.log("  Cliente1: cliente1@imperio.com / Imperio@123");
  console.log("  Cliente2: cliente2@imperio.com / Imperio@123\n");

  process.exit(0);
}

seed().catch((err) => {
  console.error("Seed falhou:", err.message);
  process.exit(1);
});
