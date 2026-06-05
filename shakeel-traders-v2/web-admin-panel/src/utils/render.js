'use strict';

/**
 * renderWithLayout — renders a view inside the main layout.
 * Automatically injects currentPath for nav active-state highlighting.
 *
 * Usage in controllers:
 *   renderWithLayout(req, res, 'dashboard/index', { title: 'Dashboard', data });
 */
function renderWithLayout(req, res, view, locals = {}) {
  const ejs = require('ejs');
  const path = require('path');
  const viewsDir = path.join(__dirname, '../views');

  // Render the inner view to a string
  ejs.renderFile(
    path.join(viewsDir, view + '.ejs'),
    { ...res.locals, ...locals, currentPath: req.path },
    { cache: false }, // Disable EJS caching
    (err, body) => {
      if (err) {
        console.error('View render error:', err);
        return res.status(500).send('View render error: ' + err.message);
      }

      // Render the layout with the body injected
      res.render('layout/main', {
        ...res.locals,
        ...locals,
        body,
        currentPath: req.originalUrl.split('?')[0],
      });
    }
  );
}

module.exports = { renderWithLayout };
