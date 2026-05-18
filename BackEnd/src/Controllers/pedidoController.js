const pedidos = require("../Models/Pedido");
const carrinho = require("../Models/Carrinho");

class PedidoController {

  async finalizarPedido(req, res) {
    try {
      const uid = req.user.uid;

      const carrinhoData = await carrinho.getByUser(uid);

      if (!carrinhoData.validate) {
        return res.status(400).json({
          success: false,
          message: "Carrinho vazio ou não encontrado",
        });
      }

      const itens = carrinhoData.data.itens;

      if (!itens || itens.length === 0) {
        return res.status(400).json({
          success: false,
          message: "Carrinho vazio",
        });
      }

      const pedido = {
        itens,
        enderecoEntrega: req.body.enderecoEntrega,
        formaPagamento: req.body.formaPagamento,
        observacao: req.body.observacao,
      };

      const result = await pedidos.new(uid, pedido);

      if (!result.validate) {
        return res.status(400).json({
          success: false,
          message: result.error,
        });
      }

      // limpa carrinho após finalizar
      await carrinho.clear(uid);

      return res.status(201).json({
        success: true,
        message: "Pedido realizado com sucesso!",
        data: result.data,
      });

    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  async getPedido(req, res) {
    try {
      const { id } = req.params;

      const result = await pedidos.get(id);

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

  async getMeusPedidos(req, res) {
    try {
      const uid = req.user.uid;

      const result = await pedidos.getByUser(uid);

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

  async getAllPedidos(req, res) {
    try {
      const result = await pedidos.getAll();

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

  async updateStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      if (!status) {
        return res.status(400).json({ success: false, message: "Campo 'status' é obrigatório" });
      }

      const result = await pedidos.updateStatus(id, status);

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

module.exports = new PedidoController();