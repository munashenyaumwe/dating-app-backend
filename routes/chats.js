const express = require("express");
const pool = require("../db");
const auth = require("../middleware/auth");

const router = express.Router();

// Get messages
router.get("/:chatId/messages", auth, async (req, res) => {
  const result = await pool.query("SELECT * FROM messages WHERE chat_id=$1 ORDER BY created_at ASC", [req.params.chatId]);
  res.json(result.rows);
});

/** GET / - Get all user's active chats with last message info */
router.get("/", auth, async (req, res) => {
  const userId = Number(req.userId);
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });

  try {
    const { rows } = await pool.query(`
      SELECT DISTINCT
        c.id as id,
        c.match_id,
        CASE
          WHEN m.user_a_id = $1 THEN m.user_b_id
          ELSE m.user_a_id
        END as recipient_id,
        CASE
          WHEN m.user_a_id = $1 THEN u_b.name
          ELSE u_a.name
        END as recipient_name,
        CASE
          WHEN m.user_a_id = $1 THEN u_b.age
          ELSE u_a.age
        END as recipient_age,
        last_msg.content as lastMessage,
        COALESCE(last_msg.created_at, m.created_at) as timestamp,
        COALESCE(unread.count, 0) as unreadCount
      FROM chats c
      JOIN matches m ON m.id = c.match_id
      JOIN users u_a ON u_a.id = m.user_a_id
      JOIN users u_b ON u_b.id = m.user_b_id
      LEFT JOIN LATERAL (
        SELECT content, created_at
        FROM messages
        WHERE chat_id = c.id
        ORDER BY created_at DESC
        LIMIT 1
      ) last_msg ON true
      LEFT JOIN LATERAL (
        SELECT COUNT(*)::int as count
        FROM messages
        WHERE chat_id = c.id
          AND sender_id != $1
          AND read_at IS NULL
      ) unread ON true
      WHERE (m.user_a_id = $1 OR m.user_b_id = $1)
        AND m.status = 'active'
      ORDER BY COALESCE(last_msg.created_at, m.created_at) DESC;
    `, [userId]);

    // Transform to match frontend expectations
    const chats = rows.map(row => ({
      id: row.id,
      recipient: {
        id: row.recipient_id,
        name: row.recipient_name,
        age: row.recipient_age
      },
      lastMessage: row.lastmessage || "No messages yet",
      timestamp: row.timestamp,
      unreadCount: row.unreadcount || 0
    }));

    res.json(chats);
  } catch (error) {
    console.error("Error fetching chats:", error);
    res.status(500).json({ error: "Failed to fetch chats" });
  }
});

// Send message
router.post("/:chatId/messages", auth, async (req, res) => {
  const { content } = req.body;
  await pool.query(
    "INSERT INTO messages (chat_id, sender_id, content) VALUES ($1,$2,$3)",
    [req.params.chatId, req.user.id, content]
  );
  res.json({ message: "Sent" });
});

// Request photo reveal
router.post("/:matchId/photo-reveal", auth, async (req, res) => {
  await pool.query(
    "INSERT INTO photo_reveals (match_id, user_id, consent) VALUES ($1,$2,true) ON CONFLICT (match_id, user_id) DO UPDATE SET consent=true",
    [req.params.matchId, req.user.id]
  );

  const reveal = await pool.query(
    "SELECT COUNT(*) FROM photo_reveals WHERE match_id=$1 AND consent=true",
    [req.params.matchId]
  );

  if (parseInt(reveal.rows[0].count) === 2) {
    res.json({ status: "photos_revealed" });
  } else {
    res.json({ status: "waiting_for_other_user" });
  }
});

module.exports = router;
