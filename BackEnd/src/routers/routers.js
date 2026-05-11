const express = require("express");
const router = express.Router();

const multer = require("multer");
const upload = multer({ dest: "tmp/" });

const userController = require("../Controllers/userController");
const produtosController = require("../Controllers/produtosController");


// login: registrar e logar
router.post("register", userController.register)
router.post("/login", userController.login);

// proteger rotas : 
// somente o usuario pode alterar a conta e excluir
router.put("/user", userController.update);
router.delete("/user", userController.delete);

// produtos, rotas publicas
router.get("/produtos", produtosController.getAllProdutos);
router.get("/produto/:id", produtosController.getProduto);

// criar, atualizar e remover produtos: somente funcionario
// deixar rotas privadas
router.post("/produto", upload.single("imagem"), produtosController.newProduto);
router.put("/produto/:id", upload.single("imagem"), produtosController.updateProduto);
router.delete("/produto/:id", produtosController.deleteProduto);

module.exports = router;