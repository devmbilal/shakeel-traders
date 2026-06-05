'use strict';

const AuditModel = require('../models/AuditModel');

/**
 * auditLog — middleware factory for logging mutating actions.
 *
 * Usage in routes:
 *   router.post('/something', auditLog('ACTION_NAME', 'entity_type'), controller.handler);
 *
 * The middleware wraps res.json and res.redirect to detect successful responses
 * and writes an audit_log entry after the response is sent.
 *
 * For fine-grained control (e.g. capturing old/new values), controllers can call
 * AuditModel.insertLog() directly within a transaction.
 */
function auditLog(action, entityType) {
  return (req, res, next) => {
    // Store original methods
    const originalJson     = res.json.bind(res);
    const originalRedirect = res.redirect.bind(res);

    const writeLog = async (entityId = null) => {
      if (!req.session || !req.session.user) return;
      try {
        await AuditModel.insertLog({
          userId:     req.session.user.id,
          action,
          entityType,
          entityId:   entityId || req.params.id || null,
          ipAddress:  req.ip,
        });
      } catch (err) {
        // Audit log failure must never break the main flow
        console.error('Audit log write failed:', err.message);
      }
    };

    // Intercept JSON responses (API-style)
    res.json = function (body) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        writeLog(body && body.id);
      }
      return originalJson(body);
    };

    // Intercept redirects (form-style)
    res.redirect = function (...args) {
      writeLog();
      return originalRedirect(...args);
    };

    next();
  };
}

module.exports = auditLog;
