const express = require("express");
const path = require("path");
const multer = require("multer");
const fs = require("fs");

const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");

const app = express();
const PORT = 3000;

/* -----------------------
   EJS Setup
------------------------*/
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.use(express.static("public"));

/* -----------------------
   Uploads Folder
------------------------*/
const uploadDir = path.join(__dirname, "uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

/* -----------------------
   Multer Config (Local Upload)
------------------------*/
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage });

/* -----------------------
   S3 Client (IAM Role)
------------------------*/
const s3 = new S3Client({
  region: "ap-south-1", // change if needed
});

/* -----------------------
   Routes
------------------------*/
app.get("/", (req, res) => {
  res.render("index", { message: null });
});

app.post("/upload", upload.single("file"), async (req, res) => {
  try {
    const file = req.file;

    if (!file) {
      return res.render("index", { message: "No file selected!" });
    }

    const fileStream = fs.createReadStream(file.path);

    const uploadParams = {
      Bucket: "YOUR_BUCKET_NAME",
      Key: file.filename,
      Body: fileStream,
      ContentType: file.mimetype,
    };

    await s3.send(new PutObjectCommand(uploadParams));

    res.render("index", {
      message: "File uploaded locally and to S3 successfully ✅",
    });
  } catch (error) {
    console.error(error);
    res.render("index", {
      message: "Upload failed ❌",
    });
  }
});

/* -----------------------
   Server Start
------------------------*/
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
