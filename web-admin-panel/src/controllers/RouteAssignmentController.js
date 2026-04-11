'use strict';

const RouteModel = require('../models/RouteModel');
const UserModel  = require('../models/UserModel');
const { renderWithLayout } = require('../utils/render');

function todayStr() {
  return new Date().toISOString().slice(0, 10);
}

const RouteAssignmentController = {
  // GET /route-assignments
  async index(req, res) {
    try {
      const today = todayStr();
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

  // POST /route-assignments
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
          } else {
            throw e;
          }
        }
      }

      if (errors.length > 0) {
        req.flash('error', errors.join(' '));
      } else {
        req.flash('success', `${ids.length} route(s) assigned successfully.`);
      }
      res.redirect('/route-assignments');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to create assignment: ' + err.message);
      res.redirect('/route-assignments');
    }
  },

  // GET /route-assignments/by-date?date=YYYY-MM-DD
  async byDate(req, res) {
    try {
      const date = req.query.date || todayStr();
      const [orderBookers, routes, byDateAssignments, todayAssignments] = await Promise.all([
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
        RouteModel.getAssignmentsByDate(date),
        RouteModel.getAssignmentsByDate(todayStr()),
      ]);

      renderWithLayout(req, res, 'route-assignments/index', {
        title: 'Route Assignment',
        orderBookers,
        routes: routes.filter(r => r.is_active),
        todayAssignments,
        today: todayStr(),
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

  // GET /route-assignments/by-booker?userId=
  async byBooker(req, res) {
    try {
      const userId = req.query.userId || null;
      const [orderBookers, routes, todayAssignments] = await Promise.all([
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
        RouteModel.getAssignmentsByDate(todayStr()),
      ]);

      let byBookerAssignments = [];
      if (userId) {
        byBookerAssignments = await RouteModel.getAssignmentsByBooker(userId);
      }

      renderWithLayout(req, res, 'route-assignments/index', {
        title: 'Route Assignment',
        orderBookers,
        routes: routes.filter(r => r.is_active),
        todayAssignments,
        today: todayStr(),
        activeTab: 'by_booker',
        byDateAssignments: [],
        byBookerAssignments,
        selectedDate: todayStr(),
        selectedBookerId: userId,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load assignments.');
      res.redirect('/route-assignments');
    }
  },
  // POST /route-assignments/:id/delete
  async deleteAssignment(req, res) {
    try {
      const assignmentId = req.params.id;
      const force = req.query.force === '1';

      // Check if there are orders associated with this assignment
      const orderCount = await RouteModel.countOrdersForAssignment(assignmentId);

      if (orderCount > 0 && !force) {
        req.flash('warning', `This assignment has ${orderCount} order(s) associated with it. Add ?force=1 to the URL to delete anyway.`);
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

  // GET /route-assignments/:id/edit
  async edit(req, res) {
    try {
      const assignmentId = req.params.id;
      const [assignment, orderBookers, routes] = await Promise.all([
        RouteModel.findAssignmentById(assignmentId),
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
      ]);

      if (!assignment) {
        req.flash('error', 'Assignment not found.');
        return res.redirect('/route-assignments');
      }

      renderWithLayout(req, res, 'route-assignments/edit', {
        title: 'Edit Route Assignment',
        assignment,
        orderBookers,
        routes: routes.filter(r => r.is_active),
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load assignment: ' + err.message);
      res.redirect('/route-assignments');
    }
  },

  // POST /route-assignments/:id/edit
  async update(req, res) {
    try {
      const assignmentId = req.params.id;
      const { user_id, assignment_date, route_id } = req.body;

      // Validate required fields
      if (!user_id || !assignment_date || !route_id) {
        req.flash('error', 'Please provide order booker, date, and route.');
        return res.redirect(`/route-assignments/${assignmentId}/edit`);
      }

      // Update the assignment
      await RouteModel.updateAssignment(assignmentId, {
        route_id,
        user_id,
        assignment_date,
      });

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
