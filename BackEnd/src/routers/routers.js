const express = require("express");
const router = express.Router();

const multer = require("multer");
const upload = multer({ dest: "tmp/" });

const userController = require("../Controllers/userController");
const produtosController = require("../Controllers/produtosController");
const carrinhoController = require("../Controllers/carrinhoController");
const pedidoController = require("../Controllers/pedidoController");

const authMiddleware = require("../middleware/authMiddleware");
const isManager = require("../middleware/isManager");
const { chatHandler } = require("../ia");


router.get("/", (req, res) => {
  res.json({ status: "ok", message: "API ImperioDelivey online" });
});

router.post("/register", (req, res, next) => {
  req.tipo = "cliente";
  next();
}, userController.register);

router.post("/funcionario", authMiddleware, isManager, (req, res, next) => {
  req.tipo = "funcionario";
  next();
}, userController.register);

router.post("/login", userController.login);

router.put("/user", authMiddleware, userController.update);
router.delete("/user", authMiddleware, userController.delete);
router.post("/user/fcm-token", authMiddleware, userController.saveFcmToken);


router.get("/produto", produtosController.getAllProdutos);
router.get("/produto/:id", produtosController.getProduto);

router.post("/produto", authMiddleware, isManager, upload.single("imagem"), produtosController.newProduto);
router.put("/produto/:id", authMiddleware, isManager, upload.single("imagem"), produtosController.updateProduto);
router.delete("/produto/:id", authMiddleware, isManager, produtosController.deleteProduto);

router.get("/carrinho", authMiddleware, carrinhoController.getCarrinho);

router.post("/carrinho", authMiddleware, carrinhoController.saveCarrinho);

router.post("/carrinho/item", authMiddleware, carrinhoController.addItem);

router.delete("/carrinho/item/:produtoId", authMiddleware, carrinhoController.removeItem);

router.delete("/carrinho", authMiddleware, carrinhoController.clearCarrinho);

router.post("/pedido", authMiddleware, pedidoController.finalizarPedido);

router.get("/pedido/me", authMiddleware, pedidoController.getMeusPedidos);

router.get("/pedido/:id", authMiddleware, pedidoController.getPedido);

router.get("/pedidos", authMiddleware, isManager, pedidoController.getAllPedidos);

router.put("/pedido/:id/status", authMiddleware, isManager, pedidoController.updateStatus);

router.post("/chat", chatHandler);

module.exports = router;