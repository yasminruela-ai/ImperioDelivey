const { adminFirebase } = require("../config/firebase");
const db = adminFirebase.firestore();

const STATUS_VALIDOS = ["pendente", "aceito", "em_preparo", "saiu_para_entrega", "entregue", "cancelado"];

const TRANSICOES_VALIDAS = {
  pendente:           ["aceito", "cancelado"],
  aceito:             ["em_preparo", "cancelado"],
  em_preparo:         ["saiu_para_entrega", "cancelado"],
  saiu_para_entrega:  ["entregue"],
  entregue:           [],
  cancelado:          [],
};

class Pedidos {
  normalizeItem(item) {
    return {
      produtoId: item.produtoId,
      nome: item.nome,
      descricao: item.descricao,
      valor: item.valor,
      imagem: item.imagem,
      categoria: item.categoria,
      quantidade: item.quantidade ? Number(item.quantidade) : 1,
    };
  }

  calcularTotal(itens) {
    return itens.reduce((total, item) => {
      const valor = Number(item.valor) || 0;
      const quantidade = Number(item.quantidade) || 1;
      return total + valor * quantidade;
    }, 0);
  }

  async new(uid, pedido) {
    try {
      const itens = Array.isArray(pedido.itens)
        ? pedido.itens.map((item) => this.normalizeItem(item))
        : [];

      const docRef = db.collection("pedidos").doc();

      await docRef.set({
        uidUsuario: uid,
        status: pedido.status || "pendente",
        total: pedido.total !== undefined ? Number(pedido.total) : this.calcularTotal(itens),
        itens,
        enderecoEntrega: pedido.enderecoEntrega || null,
        formaPagamento: pedido.formaPagamento || null,
        observacao: pedido.observacao || "",
        datas: {
          realizadoEm: new Date(),
          aceitoEm: null,
          emPreparoEm: null,
          saiuParaEntregaEm: null,
          entregueEm: null,
          canceladoEm: null,
        },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      return { validate: true, data: { id: docRef.id } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async get(id) {
    try {
      const doc = await db.collection("pedidos").doc(id).get();

      if (!doc.exists) {
        return { validate: false, error: "Pedido não encontrado" };
      }

      return {
        validate: true,
        data: {
          id: doc.id,
          ...doc.data(),
        },
      };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async getAll() {
    try {
      const snapshot = await db.collection("pedidos").get();

      const pedidos = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      return { validate: true, data: pedidos };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async getByUser(uid) {
    try {
      const snapshot = await db
        .collection("pedidos")
        .where("uidUsuario", "==", uid)
        .get();

      const pedidos = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      return { validate: true, data: pedidos };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async updateStatus(id, status) {
    try {
      if (!STATUS_VALIDOS.includes(status)) {
        return { validate: false, error: `Status inválido. Valores aceitos: ${STATUS_VALIDOS.join(", ")}` };
      }

      const docRef = db.collection("pedidos").doc(id);
      const doc = await docRef.get();

      if (!doc.exists) {
        return { validate: false, error: "Pedido não encontrado" };
      }

      const pedido = doc.data();
      const statusAtual = pedido.status;

      if (!TRANSICOES_VALIDAS[statusAtual]?.includes(status)) {
        return {
          validate: false,
          error: `Transição inválida: '${statusAtual}' → '${status}'. Permitidas: ${TRANSICOES_VALIDAS[statusAtual]?.join(", ") || "nenhuma"}`,
        };
      }

      const datas = pedido.datas || {};
      const agora = new Date();

      const timestampMap = {
        aceito:            "aceitoEm",
        em_preparo:        "emPreparoEm",
        saiu_para_entrega: "saiuParaEntregaEm",
        entregue:          "entregueEm",
        cancelado:         "canceladoEm",
      };

      const campoData = timestampMap[status];
      if (campoData && !datas[campoData]) {
        datas[campoData] = agora;
      }

      await docRef.update({
        status,
        datas,
        updatedAt: agora,
      });

      return { validate: true, data: { id, uidUsuario: pedido.uidUsuario } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async updateErpVendaId(id, erpVendaId) {
    try {
      await db.collection("pedidos").doc(id).update({ erpVendaId });
      return { validate: true };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }
}

module.exports = new Pedidos();