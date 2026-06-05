'use strict';

const SalaryController = require('../../src/controllers/SalaryController');
const SalaryModel = require('../../src/models/SalaryModel');
const { query } = require('../../src/config/db');
const { renderWithLayout } = require('../../src/utils/render');

jest.mock('../../src/config/db');
jest.mock('../../src/models/SalaryModel');
jest.mock('../../src/utils/render');

describe('SalaryController', () => {
  let req, res;

  beforeEach(() => {
    req = {
      params: {},
      query: {},
      session: { user: { id: 1 } },
      flash: jest.fn()
    };
    res = {
      redirect: jest.fn(),
      setHeader: jest.fn(),
      end: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('ledger', () => {
    it('should render ledger view for salesman with correct data', async () => {
      req.params = { staffType: 'salesman', staffId: '5' };
      req.query = { page: '1' };

      const mockStaff = { id: 5, full_name: 'John Doe' };
      const mockLedgerData = {
        entries: [
          { entry_type: 'basic_salary', month: 12, year: 2024, entry_date: '2024-12-01', amount: 50000, note: null },
          { entry_type: 'advance', month: null, year: null, entry_date: '2024-12-15', amount: 10000, note: 'Emergency' }
        ],
        total: 2,
        page: 1,
        limit: 25,
        pages: 1
      };
      const mockNetBalance = 40000;

      query.mockResolvedValue([mockStaff]);
      SalaryModel.getLedger.mockResolvedValue(mockLedgerData);
      SalaryModel.getNetBalance.mockResolvedValue(mockNetBalance);

      await SalaryController.ledger(req, res);

      expect(query).toHaveBeenCalledWith(
        'SELECT id, full_name FROM users WHERE id = ? AND role = ?',
        ['5', 'salesman']
      );
      expect(SalaryModel.getLedger).toHaveBeenCalledWith('5', 'salesman', 1, 25);
      expect(SalaryModel.getNetBalance).toHaveBeenCalledWith('5', 'salesman');
      expect(renderWithLayout).toHaveBeenCalledWith(req, res, 'salaries/ledger', {
        title: 'Salary Ledger - John Doe',
        staff: { id: 5, full_name: 'John Doe', staffType: 'salesman' },
        entries: mockLedgerData.entries,
        netBalance: mockNetBalance,
        pagination: {
          page: 1,
          limit: 25,
          total: 2,
          pages: 1
        }
      });
    });

    it('should render ledger view for delivery_man', async () => {
      req.params = { staffType: 'delivery_man', staffId: '3' };
      req.query = { page: '2' };

      const mockStaff = { id: 3, full_name: 'Ali Khan' };
      const mockLedgerData = {
        entries: [],
        total: 50,
        page: 2,
        limit: 25,
        pages: 2
      };

      query.mockResolvedValue([mockStaff]);
      SalaryModel.getLedger.mockResolvedValue(mockLedgerData);
      SalaryModel.getNetBalance.mockResolvedValue(0);

      await SalaryController.ledger(req, res);

      expect(query).toHaveBeenCalledWith(
        'SELECT id, full_name FROM delivery_men WHERE id = ?',
        ['3']
      );
      expect(SalaryModel.getLedger).toHaveBeenCalledWith('3', 'delivery_man', 2, 25);
    });

    it('should redirect with error for invalid staff type', async () => {
      req.params = { staffType: 'invalid_type', staffId: '1' };

      await SalaryController.ledger(req, res);

      expect(req.flash).toHaveBeenCalledWith('error', 'Invalid staff type.');
      expect(res.redirect).toHaveBeenCalledWith('/salaries');
    });

    it('should redirect with error when staff not found', async () => {
      req.params = { staffType: 'salesman', staffId: '999' };

      query.mockResolvedValue([]);

      await SalaryController.ledger(req, res);

      expect(req.flash).toHaveBeenCalledWith('error', 'Staff member not found.');
      expect(res.redirect).toHaveBeenCalledWith('/salaries');
    });

    it('should default to page 1 when page query param is missing', async () => {
      req.params = { staffType: 'order_booker', staffId: '2' };
      req.query = {};

      const mockStaff = { id: 2, full_name: 'Ahmed Ali' };
      query.mockResolvedValue([mockStaff]);
      SalaryModel.getLedger.mockResolvedValue({ entries: [], total: 0, page: 1, limit: 25, pages: 0 });
      SalaryModel.getNetBalance.mockResolvedValue(0);

      await SalaryController.ledger(req, res);

      expect(SalaryModel.getLedger).toHaveBeenCalledWith('2', 'order_booker', 1, 25);
    });
  });

  describe('exportLedger', () => {
    it('should validate staff type and redirect on invalid type', async () => {
      req.params = { staffType: 'invalid', staffId: '1' };

      await SalaryController.exportLedger(req, res);

      expect(req.flash).toHaveBeenCalledWith('error', 'Invalid staff type.');
      expect(res.redirect).toHaveBeenCalledWith('/salaries');
    });

    it('should redirect when staff not found', async () => {
      req.params = { staffType: 'salesman', staffId: '999' };

      query.mockResolvedValue([]);

      await SalaryController.exportLedger(req, res);

      expect(req.flash).toHaveBeenCalledWith('error', 'Staff member not found.');
      expect(res.redirect).toHaveBeenCalledWith('/salaries');
    });
  });
});
