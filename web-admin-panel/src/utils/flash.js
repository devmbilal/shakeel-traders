'use strict';

/**
 * Flash message helpers.
 * connect-flash is already wired in app.js.
 * These helpers are for convenience in controllers.
 */

function flashSuccess(req, message) {
  req.flash('success', message);
}

function flashError(req, message) {
  req.flash('error', message);
}

function flashInfo(req, message) {
  req.flash('info', message);
}

module.exports = { flashSuccess, flashError, flashInfo };
