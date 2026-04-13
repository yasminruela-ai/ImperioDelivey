const { adminFirebase } = require("../config/firebase");
const db = adminFirebase.firestore();

class Carrinhos {
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

  async getByUser(uid) {
    try {
      const doc = await db.collection("carrinhos").doc(uid).get();

      if (!doc.exists) {
        return { validate: false, error: "Carrinho não encontrado" };
      }

      return {
        validate: true,
        data: {
          uidUsuario: doc.id,
          ...doc.data(),
        },
      };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async save(uid, carrinho) {
    try {
      const itens = Array.isArray(carrinho.itens)
        ? carrinho.itens.map((item) => this.normalizeItem(item))
        : [];

      await db.collection("carrinhos").doc(uid).set({
        uidUsuario: uid,
        tipo: carrinho.tipo || "carrinho",
        itens,
        updatedAt: new Date(),
      });

      return { validate: true, data: { uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async addItem(uid, item) {
    try {
      const docRef = db.collection("carrinhos").doc(uid);
      const doc = await docRef.get();

      const novoItem = this.normalizeItem(item);
      let itens = [];
      let tipo = item.tipo || "carrinho";

      if (doc.exists) {
        const data = doc.data();
        itens = Array.isArray(data.itens) ? data.itens : [];
        tipo = data.tipo || tipo;

        const index = itens.findIndex(
          (i) => i.produtoId === novoItem.produtoId
        );

        if (index >= 0) {
          itens[index] = {
            ...itens[index],
            ...novoItem,
            quantidade:
              Number(itens[index].quantidade || 0) + Number(novoItem.quantidade || 1),
          };
        } else {
          itens.push(novoItem);
        }
      } else {
        itens = [novoItem];
      }

      await docRef.set(
        {
          uidUsuario: uid,
          tipo,
          itens,
          updatedAt: new Date(),
        },
        { merge: true }
      );

      return { validate: true, data: { uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async removeItem(uid, produtoId) {
    try {
      const docRef = db.collection("carrinhos").doc(uid);
      const doc = await docRef.get();

      if (!doc.exists) {
        return { validate: false, error: "Carrinho não encontrado" };
      }

      const data = doc.data();
      const itens = Array.isArray(data.itens) ? data.itens : [];

      const novosItens = itens.filter((item) => item.produtoId !== produtoId);

      await docRef.update({
        itens: novosItens,
        updatedAt: new Date(),
      });

      return { validate: true, data: { uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async clear(uid) {
    try {
      const docRef = db.collection("carrinhos").doc(uid);
      const doc = await docRef.get();

      if (!doc.exists) {
        return { validate: false, error: "Carrinho não encontrado" };
      }

      await docRef.update({
        itens: [],
        updatedAt: new Date(),
      });

      return { validate: true, data: { uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async delete(uid) {
    try {
      await db.collection("carrinhos").doc(uid).delete();
      return { validate: true, data: { uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }
}

module.exports = new Carrinhos();