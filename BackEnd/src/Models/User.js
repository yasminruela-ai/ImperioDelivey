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

  async delete(uid) {
    try {
      await db.collection("users").doc(uid).delete();
      await auth.deleteUser(uid);

      return { validate: true, data: { uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async update(uid, user) {
    try {
      const updateData = {
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
      };

      await db.collection("users").doc(uid).update(updateData);

      const authUpdateData = {};
      if (user.email) authUpdateData.email = user.email;
      if (user.password) authUpdateData.password = user.password;

      if (Object.keys(authUpdateData).length > 0) {
        await auth.updateUser(uid, authUpdateData);
      }

      return { validate: true, data: { uid } };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async saveFcmToken(uid, token) {
    try {
      await db.collection("users").doc(uid).update({ fcmToken: token });
      return { validate: true };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }

  async getFcmToken(uid) {
    try {
      const doc = await db.collection("users").doc(uid).get();
      if (!doc.exists) return null;
      return doc.data().fcmToken || null;
    } catch {
      return null;
    }
  }

  async auth(user) {
    try {
      const apiKey = process.env.FIREBASE_API_KEY;

      const response = await fetch(
        `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            email: user.email,
            password: user.password,
            returnSecureToken: true,
          }),
        },
      );

      const data = await response.json();

      if (!response.ok) {
        return {
          validate: false,
          error: data.error?.message || "Erro na autenticação",
        };
      }

      const userDoc = await db.collection("users").doc(data.localId).get();

      return {
        validate: true,
        data: {
          uid: data.localId,
          idToken: data.idToken,
          refreshToken: data.refreshToken,
          user: userDoc.exists ? userDoc.data() : null,
        },
      };
    } catch (error) {
      return { validate: false, error: error.message };
    }
  }
}

module.exports = new Users();
