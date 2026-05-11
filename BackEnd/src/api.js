const express = require("express");
const api = express();
const cors = require("cors");
const routers = require("./routers/routers");
const path = require("path");

api.use(cors());
api.use(express.urlencoded({ extended: false }));
api.use(express.json());
api.use("/", routers);


module.exports = api;