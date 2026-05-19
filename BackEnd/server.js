const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, ".env") });

const api = require('./src/api')

const PORT = process.env.PORT || 3000;

api.listen(PORT, "0.0.0.0", () => {
    console.log(`API ImperioDelivey inicializada na porta ${PORT}`)
})