'use strict';

/**
 * requireAuth — protects all web panel routes.
 * Redirects to /login if no session user is present.
 * Attaches user to res.locals for use in all EJS views.
 */
function requireAuth(req, res, next) {
  if (!req.session || !req.session.user) {
    req.flash('error', 'Please log in to access this page.');
    return res.redirect('/login');
  }
  res.locals.user = req.session.user;
  next();
}

/**
 * requireAdmin — ensures the logged-in user has the admin role.
 * Used as an additional guard on sensitive routes.
 */
function requireAdmin(req, res, next) {
  if (!req.session.user || req.session.user.role !== 'admin') {
    return res.status(403).render('errors/error', {
      title: 'Access Denied',
      message: 'You do not have permission to access this page.',
      status: 403,
    });
  }
  next();
}

module.exports = { requireAuth, requireAdmin };
