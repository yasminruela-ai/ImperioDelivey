const users = require("../Models/User");

class UserController {

  async register(req, res) {
    let user = {
      nome: req.body.nome,
      telefone: req.body.telefone,
      email: req.body.email,
      password: req.body.password,
      tipo: req.tipo,
      endereco: req.body.endereco,
    };

    const result = await users.new(user);

    result.validate
      ? res.status(201).json({ success: true, data: result.data })
      : res.status(400).json({ success: false, message: result.error });
  }

  async login(req, res) {
    const user = {
      email: req.body.email,
      password: req.body.password,
    };

    const result = await users.auth(user);

    result.validate
      ? res.status(200).json({ success: true, data: result.data })
      : res.status(401).json({ success: false, message: result.error });
  }

  async update(req, res) {
    const uid = req.user.uid;

    const user = {
      nome: req.body.nome,
      telefone: req.body.telefone,
      email: req.body.email,
      password: req.body.password,
      tipo: req.body.tipo,
      endereco: req.body.endereco,
    };

    const result = await users.update(uid, user);

    result.validate
      ? res.status(200).json({ success: true, data: result.data })
      : res.status(400).json({ success: false, message: result.error });
  }

  async delete(req, res) {
    const uid = req.user.uid;

    const result = await users.delete(uid);

    result.validate
      ? res.status(200).json({ success: true, data: result.data })
      : res.status(400).json({ success: false, message: result.error });
  }
}

module.exports = new UserController();