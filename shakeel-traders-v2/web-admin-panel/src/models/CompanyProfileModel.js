'use strict';

const { query } = require('../config/db');

const CompanyProfileModel = {
  async getProfile() {
    const rows = await query('SELECT * FROM company_profile WHERE id = 1 LIMIT 1');
    return rows[0] || null;
  },

  async upsertProfile(data) {
    const sql = `
      INSERT INTO company_profile
        (id, company_name, owner_name, address, phone_1, phone_2, email, gst_ntn, sales_tax, cnic, logo_path)
      VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        company_name = VALUES(company_name),
        owner_name   = VALUES(owner_name),
        address      = VALUES(address),
        phone_1      = VALUES(phone_1),
        phone_2      = VALUES(phone_2),
        email        = VALUES(email),
        gst_ntn      = VALUES(gst_ntn),
        sales_tax    = VALUES(sales_tax),
        cnic         = VALUES(cnic),
        logo_path    = COALESCE(VALUES(logo_path), logo_path)
    `;
    await query(sql, [
      data.company_name,
      data.owner_name   || null,
      data.address      || null,
      data.phone_1      || null,
      data.phone_2      || null,
      data.email        || null,
      data.gst_ntn      || null,
      data.sales_tax    || null,
      data.cnic         || null,
      data.logo_path    || null,
    ]);
  },
};

module.exports = CompanyProfileModel;
