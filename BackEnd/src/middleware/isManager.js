const { adminFirebase } = require("../config/firebase");
const db = adminFirebase.firestore();

async function isManager(req, res, next) {
  try {
    const uid = req.user.uid;

    const userDoc = await db.collection("users").doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ success: false, message: "Usuário não encontrado" });
    }

    const user = userDoc.data();

    if (user.tipo !== "gerente") {
      return res.status(403).json({ success: false, message: "Acesso negado" });
    }

    next();
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
}

module.exports = isManager;