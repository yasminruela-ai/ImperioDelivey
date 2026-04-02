const users = require("../Models/User");

class LoginController {
  
  async newUser(req, res) {
    
    let user = {
      nome: req.body.nome,
      telefone: req.body.telefone,
      email: req.body.email,
      tipo: "cliente",
      endereco: {
        pais: req.body.endereco.pais,
        estado: req.body.endereco.estado,
        cidade: req.body.endereco.cidade,
        bairro: req.body.endereco.bairro,
        rua: req.body.endereco.rua,
        numero: req.body.endereco.numero,
        cep: req.body.endereco.cep,
      },
    };

    let result = await users.new(user);

    result.validate
      ? res.status(201).json({ success: true, message: "Conta criada!" })
      : res.status(404).json({ success: false, message: result.error });

  }
}

module.exports = new LoginController();