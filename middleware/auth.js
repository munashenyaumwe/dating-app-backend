const jwt = require("jsonwebtoken");
require("dotenv").config();

function authMiddleware(req, res, next) {
  const authHeader = req.headers["authorization"];
  if (!authHeader) return res.status(401).json({ error: "No token" });

  const token = authHeader.split(" ")[1];
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Invalid token" });

    // Set both for compatibility
    req.user = user;        // For backward compatibility with existing routes
    req.userId = user.id;   // For the updated matches.js that expects req.userId

    next();
  });
}

module.exports = authMiddleware;
