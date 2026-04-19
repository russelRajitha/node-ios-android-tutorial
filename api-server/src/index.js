const express = require('express');
const app = express();
const port = process.env.APP_PORT || 4000;
const timezone = process.env.TIME_ZONE || 'Asia/Colombo';
const moment = require('moment-timezone');
const http = require("http");
const authRoutes = require("./routes/authRoutes");
const productRoutes = require("./routes/productRoutes");
const userRoutes = require("./routes/userRoutes");
const cartRoutes = require("./routes/cartRoutes");
moment.tz.setDefault(timezone);



// Simple route to test server
app.get('/', (req, res) => {
    res.send('API Server is Running....');
});
app.use(express.json());

// Basic test route
app.get('/', (req, res) => {
    res.send('API Server is Running 🚀');
});

// Use route groups
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/user', userRoutes);
app.use('/api/cart', cartRoutes);

const server = http.createServer(app);
server.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});