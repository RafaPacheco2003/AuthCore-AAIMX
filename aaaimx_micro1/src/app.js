const express = require("express");
const testRoutes = require("./routes/test.routes");

const app = express();

app.use(express.json());

app.use("/api/test", testRoutes);

app.get("/", (req, res) => {
  res.json({ name: "aaaimx_micro1", version: "1.0.0", status: "running" });
});

app.use((req, res) => {
  res.status(404).json({ error: "Ruta no encontrada" });
});

module.exports = app;
