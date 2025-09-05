const express = require("express");
const pool = require("../db");
const auth = require("../middleware/auth");

const router = express.Router();

// Get profile
router.get("/:id", auth, async (req, res) => {
  const result = await pool.query("SELECT id, name, age, bio, interests, personality, photos FROM users WHERE id=$1", [req.params.id]);
  res.json(result.rows[0]);
});

// Update profile
router.put("/:id", auth, async (req, res) => {
  const { bio, interests, personality, photos } = req.body;
  await pool.query(
    "UPDATE users SET bio=$1, interests=$2, personality=$3, photos=$4 WHERE id=$5",
    [bio, interests, personality, photos, req.params.id]
  );
  res.json({ message: "Profile updated" });
});

module.exports = router;
