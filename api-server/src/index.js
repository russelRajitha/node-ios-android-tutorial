const express = require('express');
const path = require('path');
const app = express();
const port = process.env.APP_PORT || 4000;
const timezone = process.env.TIME_ZONE || 'Asia/Colombo';
const moment = require('moment-timezone');
const http = require("http");
const authRoutes = require("./routes/authRoutes");
const productRoutes = require("./routes/productRoutes");
const userRoutes = require("./routes/userRoutes");
const cartRoutes = require("./routes/cartRoutes");
const productCategoryRoutes = require("./routes/productCategoryRoutes");
const orderRoutes = require("./routes/orderRoutes");
const adminRoutes = require("./routes/adminRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const deviceTokenRoutes = require("./routes/deviceTokenRoutes");
moment.tz.setDefault(timezone);



// Simple route to test server
app.get('/', (req, res) => {
    res.send('API Server is Running....');
});
app.use(express.json());
app.use('/assets', express.static(path.join(__dirname, '../assets')));

// Basic test route
app.get('/', (req, res) => {
    res.send('API Server is Running 🚀');
});

// Use route groups
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/user', userRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/product-categories', productCategoryRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/device-tokens', deviceTokenRoutes);

const server = http.createServer(app);
server.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});