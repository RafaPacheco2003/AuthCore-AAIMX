const { Router } = require("express");
const { ping, greet, echo } = require("../controllers/test.controller");

const router = Router();

router.get("/ping", ping);
router.get("/greet/:name", greet);
router.post("/echo", echo);

module.exports = router;
