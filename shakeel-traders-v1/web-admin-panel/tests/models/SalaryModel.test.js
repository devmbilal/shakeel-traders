'use strict';

const SalaryModel = require('../../src/models/SalaryModel');
const { query } = require('../../src/config/db');

jest.mock('../../src/config/db');

describe('SalaryModel', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getLedger', () => {
    it('should return paginated ledger entries with correct structure', async () => {
      const mockCountResult = [{ total: 15 }];
      const mockEntries = [
        {
          entry_type: 'basic_salary',
          month: 12,
          year: 2024,
          entry_date: '2024-12-01',
          amount: 50000,
          note: null
        },
        {
          entry_type: 'advance',
          month: null,
          year: null,
          entry_date: '2024-12-15',
          amount: 10000,
          note: 'Emergency advance'
        }
      ];

      query
        .mockResolvedValueOnce(mockCountResult)
        .mockResolvedValueOnce(mockEntries);

      const result = await SalaryModel.getLedger(1, 'salesman', 1, 25);

      expect(query).toHaveBeenCalledTimes(2);
      
      // Verify count query
      const [countSql, countParams] = query.mock.calls[0];
      expect(countSql).toContain('COUNT(*) as total');
      expect(countSql).toContain('UNION ALL');
      expect(countParams).toEqual([1, 'salesman', 1, 'salesman']);

      // Verify entries query
      const [entriesSql, entriesParams] = query.mock.calls[1];
      expect(entriesSql).toContain('UNION ALL');
      expect(entriesSql).toContain('ORDER BY entry_date DESC');
      expect(entriesSql).toContain('LIMIT ? OFFSET ?');
      expect(entriesParams).toEqual([1, 'salesman', 1, 'salesman', 25, 0]);

      // Verify result structure
      expect(result).toEqual({
        entries: mockEntries,
        total: 15,
        page: 1,
        limit: 25,
        pages: 1
      });
    });

    it('should calculate correct pagination metadata', async () => {
      const mockCountResult = [{ total: 100 }];
      const mockEntries = [];

      query
        .mockResolvedValueOnce(mockCountResult)
        .mockResolvedValueOnce(mockEntries);

      const result = await SalaryModel.getLedger(1, 'order_booker', 2, 25);

      expect(result.page).toBe(2);
      expect(result.limit).toBe(25);
      expect(result.total).toBe(100);
      expect(result.pages).toBe(4); // ceil(100/25)

      // Verify offset calculation
      const [, entriesParams] = query.mock.calls[1];
      expect(entriesParams[entriesParams.length - 1]).toBe(25); // offset = (2-1) * 25
    });

    it('should handle delivery_man staff type', async () => {
      const mockCountResult = [{ total: 5 }];
      const mockEntries = [];

      query
        .mockResolvedValueOnce(mockCountResult)
        .mockResolvedValueOnce(mockEntries);

      await SalaryModel.getLedger(3, 'delivery_man', 1, 25);

      const [, countParams] = query.mock.calls[0];
      expect(countParams).toEqual([3, 'delivery_man', 3, 'delivery_man']);
    });
  });

  describe('getNetBalance', () => {
    it('should return net balance as basic_salary minus total_advances_paid', async () => {
      const mockResult = [{ net_balance: 15000 }];
      query.mockResolvedValue(mockResult);

      const result = await SalaryModel.getNetBalance(1, 'salesman');

      expect(query).toHaveBeenCalledTimes(1);
      const [sql, params] = query.mock.calls[0];
      
      expect(sql).toContain('COALESCE(SUM(basic_salary), 0)');
      expect(sql).toContain('COALESCE(SUM(total_advances_paid), 0)');
      expect(sql).toContain('AS net_balance');
      expect(params).toEqual([1, 'salesman']);
      expect(result).toBe(15000);
    });

    it('should return 0 when no salary records exist', async () => {
      const mockResult = [{ net_balance: null }];
      query.mockResolvedValue(mockResult);

      const result = await SalaryModel.getNetBalance(999, 'order_booker');

      expect(result).toBe(0);
    });

    it('should handle negative balance (overpaid advances)', async () => {
      const mockResult = [{ net_balance: -5000 }];
      query.mockResolvedValue(mockResult);

      const result = await SalaryModel.getNetBalance(2, 'delivery_man');

      expect(result).toBe(-5000);
    });

    it('should return 0 when result is undefined', async () => {
      query.mockResolvedValue([]);

      const result = await SalaryModel.getNetBalance(1, 'salesman');

      expect(result).toBe(0);
    });
  });
});
