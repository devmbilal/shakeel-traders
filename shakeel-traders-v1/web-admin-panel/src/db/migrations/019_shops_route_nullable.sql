-- Migration 019: Allow shops.route_id to be NULL
-- A shop can exist without a route (unassigned) so admin can move it between routes.
ALTER TABLE shops MODIFY COLUMN route_id INT UNSIGNED NULL DEFAULT NULL;
