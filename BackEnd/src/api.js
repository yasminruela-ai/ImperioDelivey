const express = require("express");
const api = express();
const cors = require("cors");
const routers = require("./routers/routers");
const path = require("path");


api.use(cors());
api.use(express.urlencoded({ extended: false }));
api.use(express.json());
api.use("/", routers);
api.use("/tester", express.static(path.join(__dirname, "../../Docs/API/")));


module.exports = api;