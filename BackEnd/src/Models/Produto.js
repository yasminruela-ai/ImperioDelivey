const { adminFirebase } = require("../config/firebase");

const db = adminFirebase.firestore();

class Produtos {
  async new(produto) {
    try {
      const docRef = db.collection("produtos").doc();

      await docRef.set({
        nome: produto.nome,
        descricao: produto.descricao,
        valor: produto.valor,
        imagem: produto.imagem,
        categoria: produto.categoria,
      });

      return { validate: true, data: { id: docRef.id } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async get(id) {
    try {
      const doc = await db.collection("produtos").doc(id).get();

      if (!doc.exists) {
        return { validate: false, error: "Produto não encontrado" };
      }

      return {
        validate: true,
        data: {
          id: id,
          ...doc.data(),
        },
      };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async getAll() {
    try {
      const snapshot = await db.collection("produtos").get();
      const produtos = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      return { validate: true, data: produtos };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }
  async update(id, produto) {
    try {
      const docRef = db.collection("produtos").doc(id);
      const doc = await docRef.get();

      if (!doc.exists) {
        return { validate: false, error: "Produto não encontrado" };
      }

      await docRef.update({
        ...(produto.nome !== undefined && { nome: produto.nome }),
        ...(produto.descricao !== undefined && {
          descricao: produto.descricao,
        }),
        ...(produto.valor !== undefined && { valor: produto.valor }),
        ...(produto.imagem !== undefined && { imagem: produto.imagem }),
        ...(produto.categoria !== undefined && {
          categoria: produto.categoria,
        }),
      });

      return { validate: true, data: { id } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async delete(id) {
    try {
      const docRef = db.collection("produtos").doc(id);
      const doc = await docRef.get();
      if (!doc.exists) {
        return { validate: false, error: "Produto não encontrado" };
      }

      const produto = doc.data();

      if (produto.imagem && produto.imagem.public_id) {
        await cloudinary.uploader.destroy(produto.imagem.public_id);
      }

      await docRef.delete();

      return { validate: true, data: { id } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }
}

module.exports = new Produtos();
