const carrinho = require("../Models/Carrinho");

class CarrinhoController {

  async getCarrinho(req, res) {
    try {
      const uid = req.user.uid;

      const result = await carrinho.getByUser(uid);

      if (!result.validate) {
        return res.status(404).json({
          success: false,
          message: result.error,
        });
      }

      return res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  async saveCarrinho(req, res) {
    try {
      const uid = req.user.uid;

      const data = {
        tipo: req.body.tipo,
        itens: req.body.itens,
      };

      const result = await carrinho.save(uid, data);

      return result.validate
        ? res.status(200).json({ success: true, data: result.data })
        : res.status(400).json({ success: false, message: result.error });

    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  async addItem(req, res) {
    try {
      const uid = req.user.uid;

      const item = {
        produtoId: req.body.produtoId,
        nome: req.body.nome,
        descricao: req.body.descricao,
        valor: req.body.valor,
        imagem: req.body.imagem,
        categoria: req.body.categoria,
        quantidade: req.body.quantidade,
      };

      const result = await carrinho.addItem(uid, item);

      return result.validate
        ? res.status(200).json({ success: true, data: result.data })
        : res.status(400).json({ success: false, message: result.error });

    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  async removeItem(req, res) {
    try {
      const uid = req.user.uid;
      const { produtoId } = req.params;

      const result = await carrinho.removeItem(uid, produtoId);

      return result.validate
        ? res.status(200).json({ success: true, data: result.data })
        : res.status(400).json({ success: false, message: result.error });

    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  async clearCarrinho(req, res) {
    try {
      const uid = req.user.uid;

      const result = await carrinho.clear(uid);

      return result.validate
        ? res.status(200).json({ success: true, data: result.data })
        : res.status(400).json({ success: false, message: result.error });

    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
}

module.exports = new CarrinhoController();