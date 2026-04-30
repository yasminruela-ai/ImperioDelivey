const cloudinary = require("cloudinary").v2
require("dotenv").config();

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_NAME,
  api_key: process.env.CLOUDINARY_KEY,
  api_secret: process.env.CLOUDINARY_SECRET
})

async function uploadImage(file) {
    const result = await cloudinary.uploader.upload(file, {
        folder: "produtos"
    })

    return result.secure_url
}

module.exports = {uploadImage}