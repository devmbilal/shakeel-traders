================================================================================
DATABASE SCHEMA SPECIFICATION
SHAKEEL TRADERS — DISTRIBUTION ORDER SYSTEM
Version 1.2 | April 2026
Engine: MySQL 8.x | InnoDB | utf8mb4 | utf8mb4_unicode_ci
================================================================================

LEGEND
  PK   = Primary Key
  FK   = Foreign Key
  NN   = NOT NULL
  UQ   = UNIQUE
  AI   = AUTO_INCREMENT
  (*) = Business-critical constraint / trigger note

================================================================================
GROUP A — USERS & ROLES
================================================================================

--------------------------------------------------------------------------------
TABLE: users
PURPOSE: System login users — admins, order bookers, salesmen
--------------------------------------------------------------------------------
  Column          | Type                                  | Key | Null | Default
  ----------------|---------------------------------------|-----|------|--------
  id              | INT UNSIGNED                          | PK  | NN   | AI
  full_name       | VARCHAR(100)                          |     | NN   |
  username        | VARCHAR(50)                           | UQ  | NN   |
  password_hash   | VARCHAR(255)                          |     | NN   |
  role            | ENUM('admin','order_booker','salesman')     | NN   |
  contact         | VARCHAR(20)                           |     | YES  | NULL
  is_active       | TINYINT(1)                            |     | NN   | 1
  created_at      | DATETIME                              |     | NN   | CURRENT_TIMESTAMP
  updated_at      | DATETIME                              |     | NN   | CURRENT_TIMESTAMP ON UPDATE

Constraints:
  UNIQUE KEY uq_username (username)
  INDEX idx_role (role)
  INDEX idx_is_active (is_active)

Notes:
  - Users cannot be deleted, only deactivated (is_active = 0)
  - Delivery Men are NOT in this table — they use the delivery_men table

--------------------------------------------------------------------------------
TABLE: delivery_men
PURPOSE: Physical delivery staff — no system login, admin-managed only
--------------------------------------------------------------------------------
  Column          | Type          | Key | Null | Default
  ----------------|---------------|-----|------|--------
  id              | INT UNSIGNED  | PK  | NN   | AI
  full_name       | VARCHAR(100)  |     | NN   |
  contact         | VARCHAR(20)   |     | YES  | NULL
  is_active       | TINYINT(1)    |     | NN   | 1
  created_at      | DATETIME      |     | NN   | CURRENT_TIMESTAMP

Notes:
  - No login credentials exist for delivery men
  - Referenced in salary_records with staff_type = 'delivery_man'
  - Referenced in delivery_man_collections

================================================================================
GROUP B — ROUTES & SHOPS
================================================================================

--------------------------------------------------------------------------------
TABLE: routes
PURPOSE: Named groups of shops for order booking assignment
--------------------------------------------------------------------------------
  Column          | Type          | Key | Null | Default
  ----------------|---------------|-----|------|--------
  id              | INT UNSIGNED  | PK  | NN   | AI
  name            | VARCHAR(100)  | UQ  | NN   |
  is_active       | TINYINT(1)    |     | NN   | 1
  created_at      | DATETIME      |     | NN   | CURRENT_TIMESTAMP

Constraints:
  UNIQUE KEY uq_route_name (name)

--------------------------------------------------------------------------------
TABLE: route_assignments
PURPOSE: Daily assignment of routes to order bookers — FOR ORDER BOOKING ONLY.
         Cash recovery assignment is in bill_recovery_assignments (separate table).
--------------------------------------------------------------------------------
  Column           | Type          | Key | Null | Default
  -----------------|---------------|-----|------|--------
  id               | INT UNSIGNED  | PK  | NN   | AI
  route_id         | INT UNSIGNED  | FK  | NN   |  -> routes.id
  user_id          | INT UNSIGNED  | FK  | NN   |  -> users.id (role=order_booker)
  assignment_date  | DATE          |     | NN   |
  created_at       | DATETIME      |     | NN   | CURRENT_TIMESTAMP

Constraints:
  UNIQUE KEY uq_route_date (route_id, assignment_date)
    -- Only one order booker per route per day
  INDEX idx_user_date (user_id, assignment_date)
  INDEX idx_assignment_date (assignment_date)
  FOREIGN KEY (route_id) REFERENCES routes(id)
  FOREIGN KEY (user_id) REFERENCES users(id)

--------------------------------------------------------------------------------
TABLE: shops
PURPOSE: Retail/wholesale outlets — each belongs to exactly one route
--------------------------------------------------------------------------------
  Column             | Type                          | Key | Null | Default
  -------------------|-------------------------------|-----|------|--------
  id                 | INT UNSIGNED                  | PK  | NN   | AI
  name               | VARCHAR(150)                  |     | NN   |
  owner_name         | VARCHAR(100)                  |     | YES  | NULL
  phone              | VARCHAR(20)                   |     | YES  | NULL
  address            | TEXT                          |     | YES  | NULL
  route_id           | INT UNSIGNED                  | FK  | NN   |  -> routes.id
  shop_type          | ENUM('retail','wholesale')    |     | NN   | 'retail'
  price_edit_allowed | TINYINT(1)                    |     | NN   | 0
  price_min_pct      | DECIMAL(5,2)                  |     | YES  | NULL
  price_max_pct      | DECIMAL(5,2)                  |     | YES  | NULL
  is_active          | TINYINT(1)                    |     | NN   | 1
  created_at         | DATETIME                      |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_route (route_id)
  FOREIGN KEY (route_id) REFERENCES routes(id)

Notes:
  - price_min_pct / price_max_pct: e.g. -10.00 to +5.00
  - Only relevant when price_edit_allowed = 1

================================================================================
GROUP C — PRODUCTS & WAREHOUSE STOCK
================================================================================

--------------------------------------------------------------------------------
TABLE: products
PURPOSE: Master product catalogue. SKU is the unique business identifier.
--------------------------------------------------------------------------------
  Column                  | Type           | Key | Null | Default
  ------------------------|----------------|-----|------|--------
  id                      | INT UNSIGNED   | PK  | NN   | AI
  sku_code                | VARCHAR(50)    | UQ  | NN   |   -- Unique, mandatory
  name                    | VARCHAR(150)   |     | NN   |
  brand                   | VARCHAR(100)   |     | YES  | NULL
  units_per_carton        | INT UNSIGNED   |     | NN   |
  retail_price            | DECIMAL(10,2)  |     | NN   |
  wholesale_price         | DECIMAL(10,2)  |     | NN   |
  current_stock_cartons   | INT UNSIGNED   |     | NN   | 0
  current_stock_loose     | INT UNSIGNED   |     | NN   | 0
  low_stock_threshold     | INT UNSIGNED   |     | YES  | NULL
  is_active               | TINYINT(1)     |     | NN   | 1
  created_at              | DATETIME       |     | NN   | CURRENT_TIMESTAMP
  updated_at              | DATETIME       |     | NN   | CURRENT_TIMESTAMP ON UPDATE

Constraints:
  UNIQUE KEY uq_sku (sku_code)
  INDEX idx_is_active (is_active)
  CHECK (current_stock_cartons >= 0 AND current_stock_loose >= 0)
    (*) Stock can NEVER go negative

Notes:
  - Products cannot be deleted, only deactivated (is_active = 0)

--------------------------------------------------------------------------------
TABLE: stock_movements
PURPOSE: Complete audit ledger of every warehouse stock change
--------------------------------------------------------------------------------
  Column            | Type                                | Key | Null | Default
  ------------------|-------------------------------------|-----|------|--------
  id                | INT UNSIGNED                        | PK  | NN   | AI
  product_id        | INT UNSIGNED                        | FK  | NN   |  -> products.id
  movement_type     | ENUM('receipt_supplier',            |     | NN   |
                    |      'manual_add',                  |     |      |
                    |      'bill_deduction',              |     |      |
                    |      'issuance_salesman',           |     |      |
                    |      'return_salesman',             |     |      |
                    |      'direct_sale_deduction')       |     |      |
  reference_id      | INT UNSIGNED                        |     | YES  | NULL
  reference_type    | VARCHAR(50)                         |     | YES  | NULL
  cartons_in        | INT UNSIGNED                        |     | NN   | 0
  loose_in          | INT UNSIGNED                        |     | NN   | 0
  cartons_out       | INT UNSIGNED                        |     | NN   | 0
  loose_out         | INT UNSIGNED                        |     | NN   | 0
  stock_after_cartons | INT UNSIGNED                      |     | NN   |
  stock_after_loose   | INT UNSIGNED                      |     | NN   |
  note              | TEXT                                |     | YES  | NULL
  created_by        | INT UNSIGNED                        | FK  | NN   |  -> users.id
  created_at        | DATETIME                            |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_product_date (product_id, created_at)
  INDEX idx_movement_type (movement_type)
  FOREIGN KEY (product_id) REFERENCES products(id)
  FOREIGN KEY (created_by) REFERENCES users(id)

================================================================================
GROUP D — SUPPLIER COMPANIES, ADVANCES & CLAIMS
================================================================================

--------------------------------------------------------------------------------
TABLE: supplier_companies
PURPOSE: Supplier/company master (e.g., CBL). Each has its own separate ledger.
--------------------------------------------------------------------------------
  Column                   | Type           | Key | Null | Default
  -------------------------|----------------|-----|------|--------
  id                       | INT UNSIGNED   | PK  | NN   | AI
  name                     | VARCHAR(150)   | UQ  | NN   |
  contact_person           | VARCHAR(100)   |     | YES  | NULL
  phone                    | VARCHAR(20)    |     | YES  | NULL
  current_advance_balance  | DECIMAL(12,2)  |     | NN   | 0.00
  is_active                | TINYINT(1)     |     | NN   | 1
  created_at               | DATETIME       |     | NN   | CURRENT_TIMESTAMP

Notes:
  (*) current_advance_balance is updated transactionally:
      + Increases when supplier_advance is recorded
      - Decreases when stock_receipt is recorded
      + Increases when a claim is marked as cleared

--------------------------------------------------------------------------------
TABLE: supplier_advances
PURPOSE: Payments made by Shakeel Traders to a supplier before stock receipt
--------------------------------------------------------------------------------
  Column          | Type                                    | Key | Null | Default
  ----------------|-----------------------------------------|-----|------|--------
  id              | INT UNSIGNED                            | PK  | NN   | AI
  company_id      | INT UNSIGNED                            | FK  | NN   |  -> supplier_companies.id
  amount          | DECIMAL(12,2)                           |     | NN   |
  payment_date    | DATE                                    |     | NN   |
  payment_method  | ENUM('cash','bank_transfer','cheque',   |     | NN   |
                  |      'other')                           |     |      |
  note            | TEXT                                    |     | YES  | NULL
  recorded_by     | INT UNSIGNED                            | FK  | NN   |  -> users.id
  created_at      | DATETIME                                |     | NN   | CURRENT_TIMESTAMP

Constraints:
  FOREIGN KEY (company_id) REFERENCES supplier_companies(id)
  INDEX idx_company_date (company_id, payment_date)

(*) On INSERT: supplier_companies.current_advance_balance += amount

--------------------------------------------------------------------------------
TABLE: stock_receipts
PURPOSE: Header record for a stock delivery received from a supplier
--------------------------------------------------------------------------------
  Column          | Type           | Key | Null | Default
  ----------------|----------------|-----|------|--------
  id              | INT UNSIGNED   | PK  | NN   | AI
  company_id      | INT UNSIGNED   | FK  | NN   |  -> supplier_companies.id
  receipt_date    | DATE           |     | NN   |
  total_value     | DECIMAL(12,2)  |     | NN   |
  note            | TEXT           |     | YES  | NULL
  recorded_by     | INT UNSIGNED   | FK  | NN   |  -> users.id
  created_at      | DATETIME       |     | NN   | CURRENT_TIMESTAMP

(*) On INSERT: supplier_companies.current_advance_balance -= total_value

--------------------------------------------------------------------------------
TABLE: stock_receipt_items
PURPOSE: Line items for each product in a stock receipt
--------------------------------------------------------------------------------
  Column          | Type           | Key | Null | Default
  ----------------|----------------|-----|------|--------
  id              | INT UNSIGNED   | PK  | NN   | AI
  receipt_id      | INT UNSIGNED   | FK  | NN   |  -> stock_receipts.id
  product_id      | INT UNSIGNED   | FK  | NN   |  -> products.id
  cartons         | INT UNSIGNED   |     | NN   | 0
  loose_units     | INT UNSIGNED   |     | NN   | 0
  unit_price      | DECIMAL(10,2)  |     | NN   |
  line_value      | DECIMAL(12,2)  |     | NN   |
    -- Computed: (cartons * units_per_carton + loose_units) * unit_price

Constraints:
  FOREIGN KEY (receipt_id) REFERENCES stock_receipts(id)
  FOREIGN KEY (product_id) REFERENCES products(id)

(*) On INSERT: products.current_stock_cartons and current_stock_loose incremented
(*) On INSERT: stock_movements row inserted (movement_type = 'receipt_supplier')

--------------------------------------------------------------------------------
TABLE: claims
PURPOSE: Complaint/return raised with a supplier. Products NOT added to stock.
--------------------------------------------------------------------------------
  Column          | Type                        | Key | Null | Default
  ----------------|-----------------------------|-----|------|--------
  id              | INT UNSIGNED                | PK  | NN   | AI
  company_id      | INT UNSIGNED                | FK  | NN   |  -> supplier_companies.id
  claim_date      | DATE                        |     | NN   |
  reason          | TEXT                        |     | NN   |
  claim_value     | DECIMAL(12,2)               |     | NN   |
  status          | ENUM('pending','cleared')   |     | NN   | 'pending'
  cleared_at      | DATETIME                    |     | YES  | NULL
  recorded_by     | INT UNSIGNED                | FK  | NN   |  -> users.id
  created_at      | DATETIME                    |     | NN   | CURRENT_TIMESTAMP

(*) When status changed to 'cleared':
    supplier_companies.current_advance_balance += claim_value
(*) Claimed products are NEVER added to warehouse stock

--------------------------------------------------------------------------------
TABLE: claim_items
PURPOSE: Products in a claim — record only, NO stock movement
--------------------------------------------------------------------------------
  Column          | Type           | Key | Null | Default
  ----------------|----------------|-----|------|--------
  id              | INT UNSIGNED   | PK  | NN   | AI
  claim_id        | INT UNSIGNED   | FK  | NN   |  -> claims.id
  product_id      | INT UNSIGNED   | FK  | NN   |  -> products.id
  cartons         | INT UNSIGNED   |     | NN   | 0
  loose_units     | INT UNSIGNED   |     | NN   | 0

Constraints:
  FOREIGN KEY (claim_id) REFERENCES claims(id)
  FOREIGN KEY (product_id) REFERENCES products(id)

================================================================================
GROUP E — ORDERS, BILLS & LINE ITEMS
================================================================================

--------------------------------------------------------------------------------
TABLE: orders
PURPOSE: Orders created by order bookers in the field via mobile app
--------------------------------------------------------------------------------
  Column            | Type                                           | Key | Null | Default
  ------------------|------------------------------------------------|-----|------|--------
  id                | INT UNSIGNED                                   | PK  | NN   | AI
  order_booker_id   | INT UNSIGNED                                   | FK  | NN   |  -> users.id
  shop_id           | INT UNSIGNED                                   | FK  | NN   |  -> shops.id
  route_id          | INT UNSIGNED                                   | FK  | NN   |  -> routes.id
  created_at_device | DATETIME                                       |     | NN   |   -- Device timestamp (offline)
  synced_at         | DATETIME                                       |     | YES  | NULL
  status            | ENUM('pending',                                |     | NN   | 'pending'
                    |      'stock_adjusted',                        |     |      |
                    |      'converted',                             |     |      |
                    |      'cancelled')                             |     |      |
  stock_check_note  | TEXT                                          |     | YES  | NULL
  created_at        | DATETIME                                       |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_booker_date (order_booker_id, created_at_device)
  INDEX idx_shop (shop_id)
  INDEX idx_status (status)
  FOREIGN KEY (order_booker_id) REFERENCES users(id)
  FOREIGN KEY (shop_id) REFERENCES shops(id)
  FOREIGN KEY (route_id) REFERENCES routes(id)

Notes:
  - stock_check_note populated when items removed/reduced on evening sync
  - One order per shop visit. Multiple visits = multiple orders = multiple bills.

--------------------------------------------------------------------------------
TABLE: order_items
PURPOSE: Product line items for each order
--------------------------------------------------------------------------------
  Column           | Type           | Key | Null | Default
  -----------------|----------------|-----|------|--------
  id               | INT UNSIGNED   | PK  | NN   | AI
  order_id         | INT UNSIGNED   | FK  | NN   |  -> orders.id
  product_id       | INT UNSIGNED   | FK  | NN   |  -> products.id
  ordered_cartons  | INT UNSIGNED   |     | NN   | 0   -- As entered by booker
  ordered_loose    | INT UNSIGNED   |     | NN   | 0
  final_cartons    | INT UNSIGNED   |     | NN   | 0   -- After stock adjustment
  final_loose      | INT UNSIGNED   |     | NN   | 0
  unit_price       | DECIMAL(10,2)  |     | NN   |

Constraints:
  FOREIGN KEY (order_id) REFERENCES orders(id)
  FOREIGN KEY (product_id) REFERENCES products(id)
  INDEX idx_order (order_id)

--------------------------------------------------------------------------------
TABLE: bills
PURPOSE: Financial bill records for all three sales types
--------------------------------------------------------------------------------
  Column            | Type                                      | Key | Null | Default
  ------------------|-------------------------------------------|-----|------|--------
  id                | INT UNSIGNED                              | PK  | NN   | AI
  order_id          | INT UNSIGNED                              | FK  | YES  | NULL  -> orders.id
  shop_id           | INT UNSIGNED                              | FK  | NN   |       -> shops.id
  bill_type         | ENUM('order_booker','direct_shop',        |     | NN   |
                    |      'salesman')                          |     |      |
  bill_date         | DATE                                      |     | NN   |
  bill_number       | VARCHAR(30)                               | UQ  | NN   |
  gross_amount      | DECIMAL(12,2)                             |     | NN   |
  advance_deducted  | DECIMAL(12,2)                             |     | NN   | 0.00
  net_amount        | DECIMAL(12,2)                             |     | NN   |
    -- net_amount = gross_amount - advance_deducted
  amount_paid       | DECIMAL(12,2)                             |     | NN   | 0.00
  outstanding_amount| DECIMAL(12,2)                             |     | NN   |
    -- outstanding_amount = net_amount - amount_paid
  status            | ENUM('open','partially_paid','cleared')   |     | NN   | 'open'
  created_by        | INT UNSIGNED                              | FK  | NN   |       -> users.id
  created_at        | DATETIME                                  |     | NN   | CURRENT_TIMESTAMP

Constraints:
  UNIQUE KEY uq_bill_number (bill_number)
  INDEX idx_shop_status (shop_id, status)
  INDEX idx_bill_type (bill_type)
  INDEX idx_bill_date (bill_date)
  FOREIGN KEY (order_id) REFERENCES orders(id)
  FOREIGN KEY (shop_id) REFERENCES shops(id)
  FOREIGN KEY (created_by) REFERENCES users(id)

(*) On INSERT: shop_ledger_entries row inserted (entry_type = 'bill')
(*) On INSERT: if shop has advance balance, advance_deducted populated
    and shop_advances.remaining_balance decremented accordingly

--------------------------------------------------------------------------------
TABLE: bill_items
PURPOSE: Product line items on a bill
--------------------------------------------------------------------------------
  Column          | Type           | Key | Null | Default
  ----------------|----------------|-----|------|--------
  id              | INT UNSIGNED   | PK  | NN   | AI
  bill_id         | INT UNSIGNED   | FK  | NN   |  -> bills.id
  product_id      | INT UNSIGNED   | FK  | NN   |  -> products.id
  cartons         | INT UNSIGNED   |     | NN   | 0
  loose_units     | INT UNSIGNED   |     | NN   | 0
  unit_price      | DECIMAL(10,2)  |     | NN   |
  line_total      | DECIMAL(12,2)  |     | NN   |
    -- Computed: (cartons * units_per_carton + loose_units) * unit_price

Constraints:
  FOREIGN KEY (bill_id) REFERENCES bills(id)
  FOREIGN KEY (product_id) REFERENCES products(id)
  INDEX idx_bill (bill_id)

================================================================================
GROUP F — SHOP LEDGER & ADVANCES
================================================================================

--------------------------------------------------------------------------------
TABLE: shop_ledger_entries
PURPOSE: Chronological ledger of ALL financial events for a shop.
         APPEND ONLY — no updates or deletes ever.
--------------------------------------------------------------------------------
  Column          | Type                                         | Key | Null | Default
  ----------------|----------------------------------------------|-----|------|--------
  id              | INT UNSIGNED                                 | PK  | NN   | AI
  shop_id         | INT UNSIGNED                                 | FK  | NN   |  -> shops.id
  entry_type      | ENUM('bill',                                 |     | NN   |
                  |      'payment_delivery_man',                 |     |      |
                  |      'recovery',                             |     |      |
                  |      'advance_payment',                      |     |      |
                  |      'advance_adjustment',                   |     |      |
                  |      'claim_credit')                         |     |      |
  reference_id    | INT UNSIGNED                                 |     | YES  | NULL
  reference_type  | VARCHAR(50)                                  |     | YES  | NULL
  debit           | DECIMAL(12,2)                                |     | NN   | 0.00
  credit          | DECIMAL(12,2)                                |     | NN   | 0.00
  balance_after   | DECIMAL(12,2)                                |     | NN   |
    -- Negative value = shop has credit (advance remaining)
  note            | TEXT                                         |     | YES  | NULL
  entry_date      | DATE                                         |     | NN   |
  created_at      | DATETIME                                     |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_shop_date (shop_id, entry_date)
  INDEX idx_entry_type (entry_type)
  FOREIGN KEY (shop_id) REFERENCES shops(id)

(*) This table is APPEND ONLY for audit integrity

--------------------------------------------------------------------------------
TABLE: shop_advances
PURPOSE: Advance payments made by shops before receiving goods
--------------------------------------------------------------------------------
  Column             | Type                                    | Key | Null | Default
  -------------------|------------------------------------------|-----|------|--------
  id                 | INT UNSIGNED                             | PK  | NN   | AI
  shop_id            | INT UNSIGNED                             | FK  | NN   |  -> shops.id
  amount             | DECIMAL(12,2)                            |     | NN   |
  remaining_balance  | DECIMAL(12,2)                            |     | NN   |
  advance_date       | DATE                                     |     | NN   |
  payment_method     | ENUM('cash','bank_transfer','cheque',    |     | NN   |
                     |      'other')                            |     |      |
  note               | TEXT                                     |     | YES  | NULL
  recorded_by        | INT UNSIGNED                             | FK  | NN   |  -> users.id
  created_at         | DATETIME                                 |     | NN   | CURRENT_TIMESTAMP

Constraints:
  FOREIGN KEY (shop_id) REFERENCES shops(id)
  INDEX idx_shop (shop_id)

(*) remaining_balance decremented when bills are created for this shop
(*) Only admin can record shop advances

================================================================================
GROUP G — SALESMAN ISSUANCES & RETURNS
================================================================================

--------------------------------------------------------------------------------
TABLE: salesman_issuances
PURPOSE: Morning stock issuance request from a salesman
--------------------------------------------------------------------------------
  Column          | Type                                  | Key | Null | Default
  ----------------|---------------------------------------|-----|------|--------
  id              | INT UNSIGNED                          | PK  | NN   | AI
  salesman_id     | INT UNSIGNED                          | FK  | NN   |  -> users.id (role=salesman)
  issuance_date   | DATE                                  |     | NN   |
  status          | ENUM('pending','approved','rejected') |     | NN   | 'pending'
  approved_by     | INT UNSIGNED                          | FK  | YES  | NULL  -> users.id
  approved_at     | DATETIME                              |     | YES  | NULL
  created_at      | DATETIME                              |     | NN   | CURRENT_TIMESTAMP

Constraints:
  UNIQUE KEY uq_salesman_date (salesman_id, issuance_date)
    -- One issuance per salesman per day
  FOREIGN KEY (salesman_id) REFERENCES users(id)

(*) Warehouse stock deducted ONLY after status = 'approved'

--------------------------------------------------------------------------------
TABLE: issuance_items
PURPOSE: Products in a salesman issuance request
--------------------------------------------------------------------------------
  Column          | Type           | Key | Null | Default
  ----------------|----------------|-----|------|--------
  id              | INT UNSIGNED   | PK  | NN   | AI
  issuance_id     | INT UNSIGNED   | FK  | NN   |  -> salesman_issuances.id
  product_id      | INT UNSIGNED   | FK  | NN   |  -> products.id
  cartons         | INT UNSIGNED   |     | NN   | 0
  loose_units     | INT UNSIGNED   |     | NN   | 0

Constraints:
  FOREIGN KEY (issuance_id) REFERENCES salesman_issuances(id)
  FOREIGN KEY (product_id) REFERENCES products(id)

--------------------------------------------------------------------------------
TABLE: salesman_returns
PURPOSE: Evening return submission from a salesman — one per issuance
--------------------------------------------------------------------------------
  Column                  | Type                                  | Key | Null | Default
  ------------------------|---------------------------------------|-----|------|--------
  id                      | INT UNSIGNED                          | PK  | NN   | AI
  issuance_id             | INT UNSIGNED                          | FK  | NN   |  -> salesman_issuances.id
  salesman_id             | INT UNSIGNED                          | FK  | NN   |  -> users.id
  return_date             | DATE                                  |     | NN   |
  status                  | ENUM('pending','approved','rejected') |     | NN   | 'pending'
  system_sale_value       | DECIMAL(12,2)                         |     | YES  | NULL
  admin_edited_sale_value | DECIMAL(12,2)                         |     | YES  | NULL
  final_sale_value        | DECIMAL(12,2)                         |     | YES  | NULL
    -- = admin_edited_sale_value if set, else system_sale_value
  cash_collected          | DECIMAL(12,2)                         |     | NN   | 0.00
  approved_by             | INT UNSIGNED                          | FK  | YES  | NULL  -> users.id
  approved_at             | DATETIME                              |     | YES  | NULL
  created_at              | DATETIME                              |     | NN   | CURRENT_TIMESTAMP

Constraints:
  UNIQUE KEY uq_issuance_return (issuance_id)  -- One return per issuance
  FOREIGN KEY (issuance_id) REFERENCES salesman_issuances(id)

(*) On approval: returned stock added back to products warehouse stock
(*) On approval: final_sale_value posted to centralized_cash_entries
(*) On approval: stock_movements rows inserted (movement_type = 'return_salesman')

--------------------------------------------------------------------------------
TABLE: return_items
PURPOSE: Product quantities in a salesman return
--------------------------------------------------------------------------------
  Column            | Type           | Key | Null | Default
  ------------------|----------------|-----|------|--------
  id                | INT UNSIGNED   | PK  | NN   | AI
  return_id         | INT UNSIGNED   | FK  | NN   |  -> salesman_returns.id
  product_id        | INT UNSIGNED   | FK  | NN   |  -> products.id
  returned_cartons  | INT UNSIGNED   |     | NN   | 0
  returned_loose    | INT UNSIGNED   |     | NN   | 0
  sold_cartons      | INT UNSIGNED   |     | NN   | 0   -- issued - returned
  sold_loose        | INT UNSIGNED   |     | NN   | 0
  retail_price      | DECIMAL(10,2)  |     | NN   |     -- Snapshotted at time of return
  line_sale_value   | DECIMAL(12,2)  |     | NN   | 0.00
    -- Computed: (sold_cartons * units_per_carton + sold_loose) * retail_price

Constraints:
  FOREIGN KEY (return_id) REFERENCES salesman_returns(id)
  FOREIGN KEY (product_id) REFERENCES products(id)

================================================================================
GROUP H — CASH RECOVERY
================================================================================

DESIGN NOTE:
  Cash recovery assignment is COMPLETELY DECOUPLED from route assignment.
  An order booker can have routes assigned (order booking) AND recovery bills
  assigned (cash collection) on the same day.
  bill_recovery_assignments has NO dependency on route_assignments.
  Same booker, two independent tasks.

--------------------------------------------------------------------------------
TABLE: bill_recovery_assignments
PURPOSE: Admin assigns specific outstanding bills to order bookers
         for same-day cash recovery. INDEPENDENT from route assignment.
--------------------------------------------------------------------------------
  Column                  | Type                                          | Key | Null | Default
  ------------------------|-----------------------------------------------|-----|------|--------
  id                      | INT UNSIGNED                                  | PK  | NN   | AI
  bill_id                 | INT UNSIGNED                                  | FK  | NN   |  -> bills.id
  assigned_to_booker_id   | INT UNSIGNED                                  | FK  | NN   |  -> users.id
    -- INDEPENDENT of route_assignments. Any booker can be assigned.
  assigned_date           | DATE                                          |     | NN   |
  assigned_by             | INT UNSIGNED                                  | FK  | NN   |  -> users.id (admin)
  status                  | ENUM('assigned',                              |     | NN   | 'assigned'
                          |      'partially_recovered',                   |     |      |
                          |      'fully_recovered',                       |     |      |
                          |      'returned_to_pool')                      |     |      |
  assigned_at             | DATETIME                                      |     | NN   | CURRENT_TIMESTAMP
  returned_at             | DATETIME                                      |     | YES  | NULL

Constraints:
  INDEX idx_bill (bill_id)
  INDEX idx_booker_date (assigned_to_booker_id, assigned_date)
  INDEX idx_status (status)
  INDEX idx_assigned_date (assigned_date)
  FOREIGN KEY (bill_id) REFERENCES bills(id)
  FOREIGN KEY (assigned_to_booker_id) REFERENCES users(id)
  FOREIGN KEY (assigned_by) REFERENCES users(id)

(*) MIDNIGHT CRON JOB: At 00:00 daily, all assignments from the previous
    day still in status 'assigned' or 'partially_recovered' are:
    - SET status = 'returned_to_pool'
    - SET returned_at = NOW()
    This makes them available again in the Outstanding Bills pool.

(*) A bill can only have ONE active assignment at a time
    (status != 'returned_to_pool').

(*) TIMING: Assignments downloaded by booker on their NEXT sync after
    the assignment is created. If created before morning sync →
    downloaded in morning. If created after morning sync → downloaded
    on mid-day or evening sync.

--------------------------------------------------------------------------------
TABLE: recovery_collections
PURPOSE: Actual cash collected by an order booker against an assigned bill
--------------------------------------------------------------------------------
  Column                   | Type                       | Key | Null | Default
  -------------------------|----------------------------|-----|------|--------
  id                       | INT UNSIGNED               | PK  | NN   | AI
  assignment_id            | INT UNSIGNED               | FK  | NN   |  -> bill_recovery_assignments.id
  bill_id                  | INT UNSIGNED               | FK  | NN   |  -> bills.id (denormalized)
  collected_by_booker_id   | INT UNSIGNED               | FK  | NN   |  -> users.id
  amount_collected         | DECIMAL(12,2)              |     | NN   |
  payment_method           | ENUM('cash','bank_transfer')|     | NN   |
  collected_at_device      | DATETIME                   |     | NN   |   -- Device timestamp (offline)
  synced_at                | DATETIME                   |     | YES  | NULL
  verified_by_admin_id     | INT UNSIGNED               | FK  | YES  | NULL  -> users.id
  verified_at              | DATETIME                   |     | YES  | NULL
  created_at               | DATETIME                   |     | NN   | CURRENT_TIMESTAMP

Constraints:
  FOREIGN KEY (assignment_id) REFERENCES bill_recovery_assignments(id)
  FOREIGN KEY (bill_id) REFERENCES bills(id)
  FOREIGN KEY (collected_by_booker_id) REFERENCES users(id)

(*) On admin verification:
    - bills.amount_paid += amount_collected
    - bills.outstanding_amount -= amount_collected
    - bills.status updated (partially_paid or cleared)
    - shop_ledger_entries row inserted (entry_type = 'recovery')
    - centralized_cash_entries row inserted (entry_type = 'recovery')

================================================================================
GROUP I — CENTRALIZED CASH SCREEN
================================================================================

--------------------------------------------------------------------------------
TABLE: centralized_cash_entries
PURPOSE: All cash received by the business across all three channels
--------------------------------------------------------------------------------
  Column          | Type                                              | Key | Null | Default
  ----------------|---------------------------------------------------|-----|------|--------
  id              | INT UNSIGNED                                      | PK  | NN   | AI
  entry_type      | ENUM('salesman_sale',                             |     | NN   |
                  |      'recovery',                                  |     |      |
                  |      'delivery_man_collection')                   |     |      |
  reference_id    | INT UNSIGNED                                      |     | YES  | NULL
  reference_type  | VARCHAR(50)                                       |     | YES  | NULL
  amount          | DECIMAL(12,2)                                     |     | NN   |
  cash_date       | DATE                                              |     | NN   |
  recorded_by     | INT UNSIGNED                                      | FK  | NN   |  -> users.id
  created_at      | DATETIME                                          |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_entry_type_date (entry_type, cash_date)
  FOREIGN KEY (recorded_by) REFERENCES users(id)

Notes:
  - Salesman sales posted on salesman_returns approval
  - Recovery cash posted on admin verification of recovery_collections
  - Delivery man cash posted when admin marks bill as cleared via
    delivery man settlement

--------------------------------------------------------------------------------
TABLE: delivery_man_collections
PURPOSE: Cash brought by delivery man for same-day bill settlement
--------------------------------------------------------------------------------
  Column            | Type           | Key | Null | Default
  ------------------|----------------|-----|------|--------
  id                | INT UNSIGNED   | PK  | NN   | AI
  bill_id           | INT UNSIGNED   | FK  | NN   |  -> bills.id
  delivery_man_id   | INT UNSIGNED   | FK  | NN   |  -> delivery_men.id
  amount_collected  | DECIMAL(12,2)  |     | NN   |
  collection_date   | DATE           |     | NN   |
  recorded_by       | INT UNSIGNED   | FK  | NN   |  -> users.id (admin)
  created_at        | DATETIME       |     | NN   | CURRENT_TIMESTAMP

Constraints:
  FOREIGN KEY (bill_id) REFERENCES bills(id)
  FOREIGN KEY (delivery_man_id) REFERENCES delivery_men(id)

(*) On INSERT: bills.amount_paid incremented
(*) On INSERT: if fully paid → bills.status = 'cleared'
(*) On INSERT: centralized_cash_entries row inserted
    (entry_type = 'delivery_man_collection')

================================================================================
GROUP J — STAFF SALARY MANAGEMENT
================================================================================

--------------------------------------------------------------------------------
TABLE: salary_records
PURPOSE: Monthly salary records for all staff types
         (Salesman, Order Booker, Delivery Man)
--------------------------------------------------------------------------------
  Column                | Type                                           | Key | Null | Default
  ----------------------|------------------------------------------------|-----|------|--------
  id                    | INT UNSIGNED                                   | PK  | NN   | AI
  staff_id              | INT UNSIGNED                                   |     | NN   |
    -- Polymorphic: users.id OR delivery_men.id
  staff_type            | ENUM('salesman','order_booker','delivery_man') |     | NN   |
    -- Determines which table staff_id references
  month                 | TINYINT UNSIGNED                               |     | NN   |   -- 1-12
  year                  | YEAR                                           |     | NN   |
  basic_salary          | DECIMAL(10,2)                                  |     | NN   |
  total_advances_paid   | DECIMAL(10,2)                                  |     | NN   | 0.00
  cleared_at            | DATETIME                                       |     | YES  | NULL
  cleared_by            | INT UNSIGNED                                   | FK  | YES  | NULL  -> users.id
  created_at            | DATETIME                                       |     | NN   | CURRENT_TIMESTAMP

Constraints:
  UNIQUE KEY uq_staff_month_year (staff_id, staff_type, month, year)

Notes:
  - Check staff_type to determine source table for staff_id
  - total_advances_paid is incremented when salary_advances are added

--------------------------------------------------------------------------------
TABLE: salary_advances
PURPOSE: Partial advance payments against monthly salary for any staff type
--------------------------------------------------------------------------------
  Column          | Type                                           | Key | Null | Default
  ----------------|------------------------------------------------|-----|------|--------
  id              | INT UNSIGNED                                   | PK  | NN   | AI
  staff_id        | INT UNSIGNED                                   |     | NN   |   -- Polymorphic
  staff_type      | ENUM('salesman','order_booker','delivery_man') |     | NN   |
  amount          | DECIMAL(10,2)                                  |     | NN   |
  advance_date    | DATE                                           |     | NN   |
  note            | TEXT                                           |     | YES  | NULL
  recorded_by     | INT UNSIGNED                                   | FK  | NN   |  -> users.id
  created_at      | DATETIME                                       |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_staff_date (staff_id, staff_type, advance_date)

(*) On INSERT: salary_records.total_advances_paid incremented for
    matching month/year/staff combination

================================================================================
GROUP K — EXPENSES & AUDIT LOG
================================================================================

--------------------------------------------------------------------------------
TABLE: expenses
PURPOSE: Business expenses recorded by admin
--------------------------------------------------------------------------------
  Column            | Type                                               | Key | Null | Default
  ------------------|----------------------------------------------------|-----|------|--------
  id                | INT UNSIGNED                                       | PK  | NN   | AI
  expense_type      | ENUM('fuel','daily_allowance',                     |     | NN   |
                    |      'vehicle_maintenance','office','other')       |     |      |
  amount            | DECIMAL(10,2)                                      |     | NN   |
  expense_date      | DATE                                               |     | NN   |
  related_user_id   | INT UNSIGNED                                       | FK  | YES  | NULL  -> users.id
  note              | TEXT                                               |     | YES  | NULL
  recorded_by       | INT UNSIGNED                                       | FK  | NN   |  -> users.id
  created_at        | DATETIME                                           |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_type_date (expense_type, expense_date)

--------------------------------------------------------------------------------
TABLE: audit_log
PURPOSE: Immutable record of every significant action in the system.
         APPEND ONLY — no updates or deletes permitted.
--------------------------------------------------------------------------------
  Column          | Type          | Key | Null | Default
  ----------------|---------------|-----|------|--------
  id              | INT UNSIGNED  | PK  | NN   | AI
  user_id         | INT UNSIGNED  | FK  | NN   |  -> users.id
  action          | VARCHAR(100)  |     | NN   |
    -- e.g. APPROVE_ISSUANCE, CONVERT_ORDER_TO_BILL, VERIFY_RECOVERY
  entity_type     | VARCHAR(50)   |     | NN   |
    -- Table being acted upon: salesman_issuances, bills, etc.
  entity_id       | INT UNSIGNED  |     | YES  | NULL
  old_value       | JSON          |     | YES  | NULL   -- State before action
  new_value       | JSON          |     | YES  | NULL   -- State after action
  ip_address      | VARCHAR(45)   |     | YES  | NULL
  created_at      | DATETIME      |     | NN   | CURRENT_TIMESTAMP

Constraints:
  INDEX idx_user_date (user_id, created_at)
  INDEX idx_entity (entity_type, entity_id)
  FOREIGN KEY (user_id) REFERENCES users(id)

(*) APPEND ONLY — application must never run UPDATE or DELETE on this table

================================================================================
GROUP L — SUPPORTING TABLES
================================================================================

--------------------------------------------------------------------------------
TABLE: shop_last_prices
PURPOSE: Most recent price charged to each shop per product.
         Downloaded to mobile for order booker reference.
--------------------------------------------------------------------------------
  Column          | Type           | Key | Null | Default
  ----------------|----------------|-----|------|--------
  id              | INT UNSIGNED   | PK  | NN   | AI
  shop_id         | INT UNSIGNED   | FK  | NN   |  -> shops.id
  product_id      | INT UNSIGNED   | FK  | NN   |  -> products.id
  last_price      | DECIMAL(10,2)  |     | NN   |
  updated_at      | DATETIME       |     | NN   | CURRENT_TIMESTAMP ON UPDATE

Constraints:
  UNIQUE KEY uq_shop_product (shop_id, product_id)
  FOREIGN KEY (shop_id) REFERENCES shops(id)
  FOREIGN KEY (product_id) REFERENCES products(id)

(*) Updated automatically whenever a bill is created or converted
    for this shop/product combination

--------------------------------------------------------------------------------
TABLE: company_profile
PURPOSE: Shakeel Traders' own business profile — printed on all bills
         Single-row table. Always use id = 1.
--------------------------------------------------------------------------------
  Column          | Type          | Key | Null | Default
  ----------------|---------------|-----|------|--------
  id              | INT UNSIGNED  | PK  | NN   | AI
  company_name    | VARCHAR(200)  |     | NN   |
  owner_name      | VARCHAR(100)  |     | YES  | NULL
  address         | TEXT          |     | YES  | NULL
  phone_1         | VARCHAR(20)   |     | YES  | NULL
  phone_2         | VARCHAR(20)   |     | YES  | NULL
  email           | VARCHAR(100)  |     | YES  | NULL
  gst_ntn         | VARCHAR(50)   |     | YES  | NULL
  logo_path       | VARCHAR(500)  |     | YES  | NULL
  updated_at      | DATETIME      |     | NN   | CURRENT_TIMESTAMP ON UPDATE

================================================================================
RELATIONSHIP MAP (FOREIGN KEY SUMMARY)
================================================================================

  Parent Table             | Child Table                  | Relationship
  -------------------------|------------------------------|---------------------------
  users                    | route_assignments            | users.id → user_id
  users                    | orders                       | users.id → order_booker_id
  users                    | salesman_issuances           | users.id → salesman_id
  users                    | bill_recovery_assignments    | users.id → assigned_to_booker_id
  users                    | recovery_collections         | users.id → collected_by_booker_id
  users                    | salary_records               | users.id → staff_id (salesman/order_booker)
  routes                   | route_assignments            | routes.id → route_id
  routes                   | shops                        | shops.route_id → routes.id
  shops                    | orders                       | orders.shop_id → shops.id
  shops                    | bills                        | bills.shop_id → shops.id
  shops                    | shop_ledger_entries          | shop_id → shops.id
  shops                    | shop_advances                | shop_advances.shop_id → shops.id
  shops                    | shop_last_prices             | shop_id → shops.id
  products                 | order_items                  | order_items.product_id → products.id
  products                 | bill_items                   | bill_items.product_id → products.id
  products                 | stock_receipt_items          | product_id → products.id
  products                 | issuance_items               | issuance_items.product_id → products.id
  products                 | return_items                 | return_items.product_id → products.id
  products                 | claim_items                  | claim_items.product_id → products.id
  products                 | stock_movements              | product_id → products.id
  products                 | shop_last_prices             | product_id → products.id
  supplier_companies       | supplier_advances            | company_id → supplier_companies.id
  supplier_companies       | stock_receipts               | company_id → supplier_companies.id
  supplier_companies       | claims                       | company_id → supplier_companies.id
  orders                   | order_items                  | order_items.order_id → orders.id
  orders                   | bills                        | bills.order_id → orders.id (nullable)
  bills                    | bill_items                   | bill_items.bill_id → bills.id
  bills                    | bill_recovery_assignments    | bill_id → bills.id
  bills                    | recovery_collections         | bill_id → bills.id
  bills                    | delivery_man_collections     | bill_id → bills.id
  bill_recovery_assignments| recovery_collections         | assignment_id → id
  salesman_issuances       | salesman_returns             | issuance_id → id
  salesman_issuances       | issuance_items               | issuance_id → id
  salesman_returns         | return_items                 | return_id → id
  delivery_men             | delivery_man_collections     | delivery_man_id → id
  delivery_men             | salary_records               | staff_id → id (delivery_man)
  delivery_men             | salary_advances              | staff_id → id (delivery_man)

================================================================================
CRITICAL BUSINESS LOGIC SUMMARY FOR DEVELOPERS
================================================================================

1. STOCK NEVER GOES NEGATIVE
   Enforce via: CHECK constraint on products table + application-level
   validation before any deduction. Reject the operation if stock would
   go negative.

2. STOCK DEDUCTION TIMING
   - Salesman issuance: deduct ONLY after admin approves
   - Order-to-bill conversion: deduct AT MOMENT admin converts
   - Direct shop sale: deduct IMMEDIATELY on bill creation

3. ADVANCE AUTO-DEDUCTION
   When any bill is created for a shop with remaining advance:
   auto-deduct from shop_advances.remaining_balance and set
   bills.advance_deducted accordingly.

4. SUPPLIER ADVANCE TRACKING
   - Increases: on supplier_advances INSERT
   - Decreases: on stock_receipts INSERT (by total_value)
   - Increases: on claims status → 'cleared' (by claim_value)

5. MIDNIGHT CRON JOB (CRITICAL)
   Every day at 00:00:
   UPDATE bill_recovery_assignments
   SET status = 'returned_to_pool', returned_at = NOW()
   WHERE assigned_date < CURDATE()
   AND status IN ('assigned', 'partially_recovered')

6. RECOVERY ASSIGNMENT INDEPENDENCE
   bill_recovery_assignments has NO join to route_assignments.
   They are completely independent. The same user.id can appear in
   both tables on the same date — that is correct and expected.

7. CASH FLOW TO CENTRALIZED SCREEN
   Three triggers create centralized_cash_entries:
   a. Salesman return approved → entry_type = 'salesman_sale'
   b. Recovery collection verified → entry_type = 'recovery'
   c. Delivery man collection recorded → entry_type = 'delivery_man_collection'

8. SHOP LEDGER IS APPEND ONLY
   Never UPDATE or DELETE shop_ledger_entries rows.
   Corrections must be made via compensating entries.

9. AUDIT LOG IS APPEND ONLY
   Never UPDATE or DELETE audit_log rows.

10. BILL NUMBER FORMAT
    Recommend: [TYPE_PREFIX]-[YEAR]-[MONTH]-[SEQUENCE]
    e.g. OB-2026-04-00001, DS-2026-04-00001, SM-2026-04-00001
    Ensure uniqueness across all bill types.

================================================================================
END OF DATABASE SCHEMA — SHAKEEL TRADERS DISTRIBUTION ORDER SYSTEM v1.2
================================================================================ 