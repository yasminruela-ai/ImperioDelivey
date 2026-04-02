const express = require("express");
const router = express.Router();

const multer = require("multer");
const upload = multer({ dest: "tmp/" });

const userController = require("../Controllers/userController");
const produtosController = require("../Controllers/produtosController");

router.post("/user", userController.newUser);

router.post("/produto", upload.single("imagem"), produtosController.newProduto);
router.get("/produto", produtosController.getAllProdutos);
router.get("/produto/:id", produtosController.getProduto);
router.put("/produto/:id", upload.single("imagem"), produtosController.updateProduto);
router.delete("/produto/:id", produtosController.deleteProduto);

module.exports = router;