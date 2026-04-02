const { adminFirebase } = require("../config/firebase");
const auth = adminFirebase.auth();
const db = adminFirebase.firestore();

class Users {
  
  async new(user) {
    try {
      const userAuth = await auth.createUser({
        email: user.email,
        password: user.password,
      });
      await db
        .collection("users")
        .doc(userAuth.uid)
        .set({
          nome: user.nome,
          telefone: user.telefone,
          email: user.email,
          tipo: user.tipo,
          endereco: {
            pais: user.endereco.pais,
            estado: user.endereco.estado,
            cidade: user.endereco.cidade,
            bairro: user.endereco.bairro,
            rua: user.endereco.rua,
            numero: user.endereco.numero,
            cep: user.endereco.cep,
          },
        });
      return { validate: true, data: { uid: userAuth.uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }
}
module.exports = new Users();