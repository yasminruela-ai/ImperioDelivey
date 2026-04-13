const { adminFirebase } = require("../config/firebase");
const db = adminFirebase.firestore();

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
          saiuParaEntregaEm: null,
          entregueEm: null,
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
      const docRef = db.collection("pedidos").doc(id);
      const doc = await docRef.get();

      if (!doc.exists) {
        return { validate: false, error: "Pedido não encontrado" };
      }

      const pedido = doc.data();
      const datas = pedido.datas || {};
      const agora = new Date();

      if (status === "saiu_para_entrega" && !datas.saiuParaEntregaEm) {
        datas.saiuParaEntregaEm = agora;
      }

      if (status === "entregue" && !datas.entregueEm) {
        datas.entregueEm = agora;
        if (!datas.saiuParaEntregaEm) {
          datas.saiuParaEntregaEm = agora;
        }
      }

      await docRef.update({
        status,
        datas,
        updatedAt: agora,
      });

      return { validate: true, data: { id } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }
}

module.exports = new Pedidos();