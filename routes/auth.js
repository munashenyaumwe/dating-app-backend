const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const pool = require("../db");
require("dotenv").config();

const router = express.Router();

// Signup
router.post("/signup", async (req, res) => {
  const { name, email, password, age } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);

  const result = await pool.query(
    "INSERT INTO users (name, email, password, age) VALUES ($1,$2,$3,$4) RETURNING id",
    [name, email, hashedPassword, age]
  );

  const token = jwt.sign({ id: result.rows[0].id }, process.env.JWT_SECRET);
  res.json({ token, user_id: result.rows[0].id });
});

// Login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const userResult = await pool.query("SELECT * FROM users WHERE email=$1", [email]);

  if (userResult.rows.length === 0) return res.status(400).json({ error: "User not found" });

  const user = userResult.rows[0];
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return res.status(403).json({ error: "Invalid password" });

  const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET);
  res.json({ token, user_id: user.id });
});

module.exports = router;
