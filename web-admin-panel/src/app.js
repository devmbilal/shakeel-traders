'use strict';

require('dotenv').config();
const express = require('express');
const path    = require('path');
const fs      = require('fs');
const methodOverride = require('method-override');
const flash          = require('connect-flash');
const sessionMiddleware = require('./config/session');

// Ensure required upload directories exist
fs.mkdirSync(path.join(__dirname, 'public/uploads/logos'), { recursive: true });

const app = express();

// ─── View Engine ─────────────────────────────────────────────────────────────
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
// Disable view caching in development
if (process.env.NODE_ENV !== 'production') {
  app.set('view cache', false);
}

// ─── Static Files ─────────────────────────────────────────────────────────────
app.use(express.static(path.join(__dirname, 'public')));

// ─── Body Parsing ─────────────────────────────────────────────────────────────
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// ─── Method Override (for PUT/DELETE via forms) ───────────────────────────────
app.use(methodOverride('_method'));

// ─── Session ──────────────────────────────────────────────────────────────────
app.use(sessionMiddleware);

// ─── Flash Messages ───────────────────────────────────────────────────────────
app.use(flash());

// ─── Global Locals ────────────────────────────────────────────────────────────
app.use((req, res, next) => {
  res.locals.user = req.session.user || null;
  res.locals.success = req.flash('success');
  res.locals.error = req.flash('error');
  res.locals.info = req.flash('info');
  next();
});

// ─── Routes ───────────────────────────────────────────────────────────────────
const authRoutes = require('./routes/web/auth');
app.use('/', authRoutes);

// Mobile API routes (JWT-authenticated, no session) — must be before requireAuth
app.use('/api/auth',  require('./routes/api/auth'));
app.use('/api/sync',  require('./routes/api/sync'));

// Auth middleware applied to all web routes below
const { requireAuth } = require('./middleware/auth');
app.use(requireAuth);

// Search API (requires authentication)
app.use('/', require('./routes/web/search'));

app.use('/dashboard',         require('./routes/web/dashboard'));
app.use('/company-profile',   require('./routes/web/companyProfile'));
app.use('/users',             require('./routes/web/users'));
app.use('/routes',            require('./routes/web/routes'));
app.use('/route-assignments', require('./routes/web/routeAssignments'));
app.use('/shops',             require('./routes/web/shops'));
app.use('/products',          require('./routes/web/products'));
app.use('/stock',             require('./routes/web/stock'));
app.use('/orders',            require('./routes/web/orders'));
app.use('/direct-sales',      require('./routes/web/directSales'));
app.use('/cash-recovery',     require('./routes/web/cashRecovery'));
app.use('/suppliers',         require('./routes/web/suppliers'));
app.use('/centralized-cash',  require('./routes/web/centralizedCash'));
app.use('/salaries',          require('./routes/web/salaries'));
app.use('/expenses',          require('./routes/web/expenses'));
app.use('/reports',           require('./routes/web/reports'));
app.use('/backup',            require('./routes/web/backup'));
app.use('/audit-log',         require('./routes/web/auditLog'));
app.use('/settings',          require('./routes/web/settings'));



// ─── Root redirect ────────────────────────────────────────────────────────────
app.get('/', (req, res) => res.redirect('/dashboard'));

// ─── 404 Handler ──────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).render('errors/404', { title: 'Page Not Found' });
});

// ─── Error Handler ────────────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err.stack);
  const status = err.status || 500;
  res.status(status).render('errors/error', {
    title: 'Error',
    message: err.message || 'Internal Server Error',
    status,
  });
});

// ─── Start Server ─────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Shakeel Traders Admin Panel running on http://localhost:${PORT}`);
});

// ─── Cron Jobs ────────────────────────────────────────────────────────────────
require('./config/cron');

module.exports = app;
