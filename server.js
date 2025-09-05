const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
require("dotenv").config();

const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "OK", port: process.env.PORT || 5001 });
});

// Routes
app.use("/auth", require("./routes/auth"));
app.use("/users", require("./routes/users"));
app.use("/matches", require("./routes/matches"));
app.use("/chats", require("./routes/chats"));

// Socket.IO setup
const io = new Server(server, {
  cors: {
    origin: "*", // later restrict to your app domain
  }
});

// Track connected users
const onlineUsers = new Map();

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("join", (userId) => {
    onlineUsers.set(userId, socket.id);
    console.log(`User ${userId} joined with socket ${socket.id}`);
  });

  socket.on("send_message", (msg) => {
    const { chatId, senderId, recipientId, content } = msg;
    const recipientSocket = onlineUsers.get(recipientId);

    // Emit to recipient in real time
    if (recipientSocket) {
      io.to(recipientSocket).emit("receive_message", {
        chatId,
        senderId,
        content,
        timestamp: new Date(),
      });
    }
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
    [...onlineUsers.entries()].forEach(([uid, sid]) => {
      if (sid === socket.id) onlineUsers.delete(uid);
    });
  });
});

const PORT = process.env.PORT || 5001;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
