const ping = (req, res) => {
  res.json({
    message: "pong",
    timestamp: new Date().toISOString(),
    status: "ok",
  });
};

const greet = (req, res) => {
  const { name } = req.params;
  res.json({
    message: `Hola, ${name || "mundo"}!`,
    timestamp: new Date().toISOString(),
  });
};

const echo = (req, res) => {
  const body = req.body;
  if (!body || Object.keys(body).length === 0) {
    return res.status(400).json({ error: "El body está vacío" });
  }
  res.json({ received: body });
};

module.exports = { ping, greet, echo };
