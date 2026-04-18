'use strict';

const RouteModel = require('../models/RouteModel');
const UserModel  = require('../models/UserModel');
const { mysqlToday } = require('../utils/dateHelper');
const { renderWithLayout } = require('../utils/render');

const RouteAssignmentController = {
  async index(req, res) {
    try {
      const today = await mysqlToday();
      const [orderBookers, routes, todayAssignments] = await Promise.all([
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
        RouteModel.getAssignmentsByDate(today),
      ]);
      renderWithLayout(req, res, 'route-assignments/index', {
        title: 'Route Assignment',
        orderBookers,
        routes: routes.filter(r => r.is_active),
        todayAssignments,
        today,
        activeTab: req.query.tab || 'assign',
        byDateAssignments: [],
        byBookerAssignments: [],
        selectedDate: today,
        selectedBookerId: null,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load route assignments.');
      res.redirect('/dashboard');
    }
  },

  async create(req, res) {
    try {
      const { user_id, assignment_date, route_ids } = req.body;
      const ids = Array.isArray(route_ids) ? route_ids : (route_ids ? [route_ids] : []);
      if (!user_id || !assignment_date || ids.length === 0) {
        req.flash('error', 'Please select an order booker, date, and at least one route.');
        return res.redirect('/route-assignments');
      }
      const errors = [];
      for (const routeId of ids) {
        try {
          await RouteModel.createAssignment(routeId, user_id, assignment_date);
        } catch (e) {
          if (e.code === 'ER_DUP_ENTRY') {
            errors.push(`Route already assigned on ${assignment_date}.`);
          } else { throw e; }
        }
      }
      if (errors.length > 0) { req.flash('error', errors.join(' ')); }
      else { req.flash('success', `${ids.length} route(s) assigned successfully.`); }
      res.redirect('/route-assignments');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to create assignment: ' + err.message);
      res.redirect('/route-assignments');
    }
  },

  async byDate(req, res) {
    try {
      const today = await mysqlToday();
      const date = req.query.date || today;
      const [orderBookers, routes, byDateAssignments, todayAssignments] = await Promise.all([
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
        RouteModel.getAssignmentsByDate(date),
        RouteModel.getAssignmentsByDate(today),
      ]);
      renderWithLayout(req, res, 'route-assignments/index', {
        title: 'Route Assignment',
        orderBookers,
        routes: routes.filter(r => r.is_active),
        todayAssignments,
        today,
        activeTab: 'by_date',
        byDateAssignments,
        byBookerAssignments: [],
        selectedDate: date,
        selectedBookerId: null,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load assignments.');
      res.redirect('/route-assignments');
    }
  },

  async byBooker(req, res) {
    try {
      const today = await mysqlToday();
      const userId = req.query.userId || null;
      const [orderBookers, routes, todayAssignments] = await Promise.all([
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
        RouteModel.getAssignmentsByDate(today),
      ]);
      let byBookerAssignments = [];
      if (userId) { byBookerAssignments = await RouteModel.getAssignmentsByBooker(userId); }
      renderWithLayout(req, res, 'route-assignments/index', {
        title: 'Route Assignment',
        orderBookers,
        routes: routes.filter(r => r.is_active),
        todayAssignments,
        today,
        activeTab: 'by_booker',
        byDateAssignments: [],
        byBookerAssignments,
        selectedDate: today,
        selectedBookerId: userId,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load assignments.');
      res.redirect('/route-assignments');
    }
  },

  async deleteAssignment(req, res) {
    try {
      const assignmentId = req.params.id;
      const force = req.query.force === '1';
      const orderCount = await RouteModel.countOrdersForAssignment(assignmentId);
      if (orderCount > 0 && !force) {
        req.flash('warning', `This assignment has ${orderCount} order(s). Add ?force=1 to delete anyway.`);
        return res.redirect('/route-assignments');
      }
      await RouteModel.deleteAssignment(assignmentId);
      req.flash('success', 'Assignment deleted.');
      res.redirect('/route-assignments');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to delete assignment: ' + err.message);
      res.redirect('/route-assignments');
    }
  },

  async edit(req, res) {
    try {
      const [assignment, orderBookers, routes] = await Promise.all([
        RouteModel.findAssignmentById(req.params.id),
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
      ]);
      if (!assignment) { req.flash('error', 'Assignment not found.'); return res.redirect('/route-assignments'); }
      renderWithLayout(req, res, 'route-assignments/edit', {
        title: 'Edit Route Assignment', assignment, orderBookers,
        routes: routes.filter(r => r.is_active),
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load assignment: ' + err.message);
      res.redirect('/route-assignments');
    }
  },

  async update(req, res) {
    try {
      const { user_id, assignment_date, route_id } = req.body;
      if (!user_id || !assignment_date || !route_id) {
        req.flash('error', 'Please provide order booker, date, and route.');
        return res.redirect(`/route-assignments/${req.params.id}/edit`);
      }
      await RouteModel.updateAssignment(req.params.id, { route_id, user_id, assignment_date });
      req.flash('success', 'Assignment updated successfully.');
      res.redirect('/route-assignments');
    } catch (err) {
      console.error(err);
      if (err.code === 'ER_DUP_ENTRY') {
        req.flash('error', 'This route is already assigned to this booker on this date.');
      } else {
        req.flash('error', 'Failed to update assignment: ' + err.message);
      }
      res.redirect(`/route-assignments/${req.params.id}/edit`);
    }
  },
};

module.exports = RouteAssignmentController;
