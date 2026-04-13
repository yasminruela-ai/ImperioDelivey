const { adminFirebase } = require("../config/firebase");
const auth = adminFirebase.auth();

async function authMiddleware(req, res, next) {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    if (!token) {
      return res.status(401).json({ success: false, message: "Token não fornecido" });
    }

    const decoded = await auth.verifyIdToken(token);

    req.user = decoded; // uid, email, etc

    next();
  } catch (error) {
    return res.status(401).json({ success: false, message: "Token inválido" });
  }
}

module.exports = authMiddleware;