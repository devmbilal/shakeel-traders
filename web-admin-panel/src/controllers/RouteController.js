'use strict';

const RouteModel = require('../models/RouteModel');
const { renderWithLayout } = require('../utils/render');

const RouteController = {
  // GET /routes
  async index(req, res) {
    try {
      const { paginate } = require('../utils/paginate');
      const page = parseInt(req.query.page) || 1;
      const total = await RouteModel.countAll();
      const pagination = paginate(total, page);
      const routes = await RouteModel.listAll({ limit: pagination.limit, offset: pagination.offset });
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
      
      renderWithLayout(req, res, 'routes/index', {
        title: 'Route Management',
        routes,
        pagination,
        queryString,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load routes.');
      res.redirect('/dashboard');
    }
  },

  // POST /routes
  async create(req, res) {
    try {
      const { name } = req.body;
      if (!name || !name.trim()) {
        req.flash('error', 'Route name is required.');
        return res.redirect('/routes');
      }
      await RouteModel.create(name.trim());
      req.flash('success', `Route "${name.trim()}" created.`);
      res.redirect('/routes');
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        req.flash('error', 'A route with that name already exists.');
      } else {
        req.flash('error', 'Failed to create route: ' + err.message);
      }
      res.redirect('/routes');
    }
  },

  // GET /routes/:id
  async detail(req, res) {
    try {
      const route = await RouteModel.findById(req.params.id);
      if (!route) {
        req.flash('error', 'Route not found.');
        return res.redirect('/routes');
      }
      const [shops, availableShops] = await Promise.all([
        RouteModel.getShopsInRoute(req.params.id),
        RouteModel.getShopsNotInRoute(req.params.id),
      ]);
      renderWithLayout(req, res, 'routes/detail', {
        title: `Route: ${route.name}`,
        route,
        shops,
        availableShops,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load route details.');
      res.redirect('/routes');
    }
  },

  // POST /routes/:id  (update name)
  async update(req, res) {
    try {
      const { name } = req.body;
      if (!name || !name.trim()) {
        req.flash('error', 'Route name is required.');
        return res.redirect('/routes/' + req.params.id);
      }
      await RouteModel.update(req.params.id, name.trim());
      req.flash('success', 'Route name updated.');
      res.redirect('/routes/' + req.params.id);
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        req.flash('error', 'A route with that name already exists.');
      } else {
        req.flash('error', 'Failed to update route: ' + err.message);
      }
      res.redirect('/routes/' + req.params.id);
    }
  },

  // POST /routes/:id/deactivate
  async deactivate(req, res) {
    try {
      const route = await RouteModel.findById(req.params.id);
      if (!route) {
        req.flash('error', 'Route not found.');
        return res.redirect('/routes');
      }
      await RouteModel.deactivate(req.params.id);
      req.flash('success', `Route "${route.name}" deactivated.`);
      res.redirect('/routes');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to deactivate route.');
      res.redirect('/routes');
    }
  },

  // POST /routes/:id/shops  (add shop to route)
  async addShop(req, res) {
    try {
      const { shop_id } = req.body;
      if (!shop_id) {
        if (req.headers['content-type']?.includes('application/json')) {
          return res.status(400).json({ error: 'Please select a shop.' });
        }
        req.flash('error', 'Please select a shop.');
        return res.redirect('/routes/' + req.params.id);
      }
      await RouteModel.addShopToRoute(req.params.id, shop_id);
      
      if (req.headers['content-type']?.includes('application/json')) {
        return res.json({ success: true });
      }
      req.flash('success', 'Shop added to route.');
      res.redirect('/routes/' + req.params.id);
    } catch (err) {
      console.error(err);
      if (req.headers['content-type']?.includes('application/json')) {
        return res.status(500).json({ error: 'Failed to add shop: ' + err.message });
      }
      req.flash('error', 'Failed to add shop: ' + err.message);
      res.redirect('/routes/' + req.params.id);
    }
  },

  // POST /routes/:id/shops/remove  (reassign shop to a different route)
  async removeShop(req, res) {
    try {
      const { shop_id, new_route_id } = req.body;
      if (!shop_id || !new_route_id) {
        req.flash('error', 'Shop and target route are required.');
        return res.redirect('/routes/' + req.params.id);
      }
      await RouteModel.addShopToRoute(new_route_id, shop_id);
      req.flash('success', 'Shop moved to the selected route.');
      res.redirect('/routes/' + req.params.id);
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to move shop: ' + err.message);
      res.redirect('/routes/' + req.params.id);
    }
  },

  // DELETE /routes/:id/shops/:shopId  (remove shop from route)
  async deleteShop(req, res) {
    try {
      const { shopId } = req.params;
      // Set shop's route_id to NULL to remove it from the route
      await RouteModel.removeShopFromRouteById(req.params.id, shopId);
      res.json({ success: true });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to remove shop: ' + err.message });
    }
  },

  // GET /routes/:id/shops/search?q=<term>  (AJAX endpoint for shop search)
  async searchShops(req, res) {
    try {
      const { q } = req.query;
      if (!q || q.trim().length < 2) {
        return res.status(400).json({ error: 'Search term must be at least 2 characters.' });
      }
      const shops = await RouteModel.searchShopsNotInRoute(req.params.id, q.trim());
      res.json(shops);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to search shops.' });
    }
  },

  // GET /routes/:id/shops/list  (AJAX endpoint for current shops in route)
  async listShops(req, res) {
    try {
      const shops = await RouteModel.getShopsInRoute(req.params.id);
      res.json(shops);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to load shops.' });
    }
  },
};

module.exports = RouteController;
