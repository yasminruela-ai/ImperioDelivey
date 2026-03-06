const express = require('express')
const api = express()
const cors = require('cors')

api.use(cors())
api.use(express.urlencoded({extended: false}))
api.use(express.json())

module.exports = api