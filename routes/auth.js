const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const pool = require("../db");
require("dotenv").config();

const router = express.Router();

// Signup
router.post("/signup", async (req, res) => {
  try {
    const { name, email, password, age } = req.body;
    
    // Validate required fields
    if (!name || !email || !password || !age) {
      return res.status(400).json({ error: "All fields (name, email, password, age) are required" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      "INSERT INTO users (name, email, password, age) VALUES ($1,$2,$3,$4) RETURNING id",
      [name, email, hashedPassword, age]
    );

    const token = jwt.sign({ id: result.rows[0].id }, process.env.JWT_SECRET);
    res.json({ token, user_id: result.rows[0].id });
  } catch (error) {
    console.error("Signup error:", error);
    
    // Handle duplicate email error
    if (error.code === '23505' && error.constraint === 'users_email_unique_idx') {
      return res.status(400).json({ error: "Email already exists" });
    }
    
    // Handle database connection issues
    if (error.code === 'ECONNREFUSED' || error.message.includes('SASL')) {
      return res.status(500).json({ error: "Database connection failed. Please check your database configuration." });
    }
    
    res.status(500).json({ error: "Internal server error during signup" });
  }
});

// Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" });
    }

    const userResult = await pool.query("SELECT * FROM users WHERE email=$1", [email]);

    if (userResult.rows.length === 0) {
      return res.status(400).json({ error: "User not found" });
    }

    const user = userResult.rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(403).json({ error: "Invalid password" });
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET);
    res.json({ token, user_id: user.id });
  } catch (error) {
    console.error("Login error:", error);
    
    // Handle database connection issues
    if (error.code === 'ECONNREFUSED' || error.message.includes('SASL')) {
      return res.status(500).json({ error: "Database connection failed. Please check your database configuration." });
    }
    
    res.status(500).json({ error: "Internal server error during login" });
  }
});

module.exports = router;
