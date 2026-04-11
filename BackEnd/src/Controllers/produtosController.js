const produtos = require("../Models/Produto");
const { uploadImage } = require("../config/cloudinary");

class ProdutoController {
  async newProduto(req, res) {
    try {
      let image = null;

      if (req.file) {
        image = await uploadImage(req.file.path);
      }

      const produto = {
        nome: req.body.nome,
        descricao: req.body.descricao,
        valor: req.body.valor,
        imagem: image,
        categoria: req.body.categoria,
      };

      const result = await produtos.new(produto);

      if (!result.validate) {
        return res.status(400).json({
          success: false,
          message: result.error,
        });
      }

      return res.status(201).json({
        success: true,
        message: "Produto criado com sucesso!",
        data: result.data,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  async getProduto(req, res) {
    try {
      const { id } = req.params;
      const result = await produtos.get(id);

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

  async getAllProdutos(req, res) {
    try {
      const result = await produtos.getAll();

      if (!result.validate) {
        return res.status(400).json({
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

  async updateProduto(req, res) {
    try {
      const { id } = req.params;

      let image = null;
      if (req.file) {
        image = await uploadImage(req.file.path);
      }

      const produto = {
        nome: req.body.nome,
        descricao: req.body.descricao,
        valor: req.body.valor,
        categoria: req.body.categoria,
      };

      if (image) {
        produto.imagem = image;
      }

      const result = await produtos.update(id, produto);

      if (!result.validate) {
        return res.status(404).json({
          success: false,
          message: result.error,
        });
      }

      return res.status(200).json({
        success: true,
        message: "Produto atualizado com sucesso!",
        data: result.data,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  async deleteProduto(req, res) {
    try {
      const { id } = req.params;
      const result = await produtos.delete(id);

      if (!result.validate) {
        return res.status(404).json({
          success: false,
          message: result.error,
        });
      }

      return res.status(200).json({
        success: true,
        message: "Produto deletado com sucesso!",
        data: result.data,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
}

module.exports = new ProdutoController();
