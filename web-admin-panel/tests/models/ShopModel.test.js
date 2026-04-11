'use strict';

const ShopModel = require('../../src/models/ShopModel');
const { query } = require('../../src/config/db');

jest.mock('../../src/config/db');

describe('ShopModel.listAll', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('has_outstanding filter', () => {
    it('should include SUM of outstanding_amount from bills when has_outstanding=1', async () => {
      const mockShops = [
        {
          id: 1,
          name: 'Shop A',
          route_id: 1,
          route_name: 'Route 1',
          outstanding_balance: 1500.00
        }
      ];

      query.mockResolvedValue(mockShops);

      const filters = { has_outstanding: '1' };
      const result = await ShopModel.listAll(filters, { limit: 25, offset: 0 });

      expect(query).toHaveBeenCalledTimes(1);
      const [sql, params] = query.mock.calls[0];

      // Verify the SQL includes the SUM subquery for outstanding amounts
      expect(sql).toContain('SELECT SUM(b.outstanding_amount)');
      expect(sql).toContain('FROM bills b');
      expect(sql).toContain("b.status IN ('open','partially_paid')");
      expect(sql).toContain('b.outstanding_amount > 0');
      
      // Verify the WHERE clause includes the EXISTS condition
      expect(sql).toContain('EXISTS');
      expect(sql).toContain('FROM bills b WHERE b.shop_id = s.id');

      expect(result).toEqual(mockShops);
    });

    it('should use ledger balance when has_outstanding filter is not active', async () => {
      const mockShops = [
        {
          id: 1,
          name: 'Shop A',
          route_id: 1,
          route_name: 'Route 1',
          outstanding_balance: 2000.00
        }
      ];

      query.mockResolvedValue(mockShops);

      const filters = {}; // No has_outstanding filter
      const result = await ShopModel.listAll(filters, { limit: 25, offset: 0 });

      expect(query).toHaveBeenCalledTimes(1);
      const [sql] = query.mock.calls[0];

      // Verify the SQL uses shop_ledger_entries for balance
      expect(sql).toContain('FROM shop_ledger_entries sle');
      expect(sql).toContain('sle.balance_after');
      expect(sql).toContain('ORDER BY sle.created_at DESC');

      // Should NOT contain the bills SUM subquery
      expect(sql).not.toContain('SELECT SUM(b.outstanding_amount)');

      expect(result).toEqual(mockShops);
    });

    it('should join with bills table and filter for outstanding_amount > 0', async () => {
      const mockShops = [];
      query.mockResolvedValue(mockShops);

      const filters = { has_outstanding: '1' };
      await ShopModel.listAll(filters, { limit: 25, offset: 0 });

      const [sql] = query.mock.calls[0];

      // Verify the EXISTS subquery filters correctly
      expect(sql).toContain("EXISTS (SELECT 1 FROM bills b WHERE b.shop_id = s.id AND b.status IN ('open','partially_paid') AND b.outstanding_amount > 0)");
    });

    it('should handle has_outstanding=0 filter correctly', async () => {
      const mockShops = [];
      query.mockResolvedValue(mockShops);

      const filters = { has_outstanding: '0' };
      await ShopModel.listAll(filters, { limit: 25, offset: 0 });

      const [sql] = query.mock.calls[0];

      // Verify the NOT EXISTS subquery
      expect(sql).toContain("NOT EXISTS (SELECT 1 FROM bills b WHERE b.shop_id = s.id AND b.status IN ('open','partially_paid') AND b.outstanding_amount > 0)");
      
      // Should still use ledger balance for has_outstanding=0
      expect(sql).toContain('FROM shop_ledger_entries sle');
    });

    it('should apply pagination correctly with has_outstanding filter', async () => {
      const mockShops = [];
      query.mockResolvedValue(mockShops);

      const filters = { has_outstanding: '1' };
      await ShopModel.listAll(filters, { limit: 50, offset: 25 });

      const [sql, params] = query.mock.calls[0];

      // Verify LIMIT and OFFSET are at the end of params
      expect(params[params.length - 2]).toBe(50); // limit
      expect(params[params.length - 1]).toBe(25); // offset
      expect(sql).toContain('LIMIT ? OFFSET ?');
    });
  });
});
