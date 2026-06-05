# Bugfix Requirements Document

## Introduction

This document addresses 6 critical UI and functionality bugs in the Shakeel Traders Distribution Order System that are affecting daily operations. The bugs span across pagination functionality, user management, search features, and CSV import capabilities. These issues are impacting user experience and operational efficiency across multiple pages in the web admin panel.

The system is a critical production ERP managing three sales channels (Order Booker Sales, Salesman Sales, Direct Shop Sales) with a Node.js + Express + EJS web admin panel and a Flutter mobile app.

---

## Bug Analysis

### Bug 1: Pagination URL Malformation

**Priority:** Critical (affects multiple pages)

#### Current Behavior (Defect)

1.1 WHEN queryString is empty and pagination controls are rendered THEN the system generates malformed URLs in the format `?&page=2`

1.2 WHEN a user clicks on pagination next/previous/page number links with malformed URLs THEN the system fails to parse the page parameter correctly and stays on the same page

1.3 WHEN pagination controls appear on any paginated page (Users, Shops, Products, Orders, Expenses, Reports) THEN clicking navigation does not change the page

#### Expected Behavior (Correct)

2.1 WHEN queryString is empty and pagination controls are rendered THEN the system SHALL generate clean URLs in the format `?page=2` without the leading `&` character

2.2 WHEN a user clicks on pagination next/previous/page number links THEN the system SHALL navigate to the correct page number

2.3 WHEN pagination controls appear on any paginated page THEN the system SHALL correctly append the page parameter to existing query strings or create a new query string

#### Unchanged Behavior (Regression Prevention)

3.1 WHEN queryString contains existing parameters and pagination is clicked THEN the system SHALL CONTINUE TO preserve all existing query parameters and append the page parameter

3.2 WHEN pagination.pages is 1 or less THEN the system SHALL CONTINUE TO not display pagination controls

3.3 WHEN pagination metadata is passed to the template THEN the system SHALL CONTINUE TO display "Page X of Y (Z records)" information correctly

---

### Bug 2: Missing User Reactivation Feature

**Priority:** High (administrative operations)

#### Current Behavior (Defect)

1.1 WHEN admin views a deactivated Order Booker or Salesman in the user list THEN the system displays no reactivation button or action

1.2 WHEN admin needs to reactivate a previously deactivated user THEN the system provides no UI mechanism to perform the reactivation

1.3 WHEN UserController is examined THEN it contains a `deactivate` method but no corresponding `activate` method

#### Expected Behavior (Correct)

2.1 WHEN admin views a deactivated Order Booker or Salesman in the user list THEN the system SHALL display a "Reactivate" or "Activate" button

2.2 WHEN admin clicks the reactivate button on a deactivated user THEN the system SHALL set the user's `is_active` column to 1 and allow the user to log in again

2.3 WHEN UserController handles reactivation THEN it SHALL include an `activate` method that updates the user status

#### Unchanged Behavior (Regression Prevention)

3.1 WHEN admin views an active user THEN the system SHALL CONTINUE TO display the "Deactivate" button

3.2 WHEN a deactivated user attempts to log in before reactivation THEN the system SHALL CONTINUE TO reject the login with an error message

3.3 WHEN admin deactivates a user THEN the system SHALL CONTINUE TO set `is_active` to 0 and prevent login

---

### Bug 3: Direct Shop Sales Dropdown Incomplete Data

**Priority:** Critical (blocking sales operations)

#### Current Behavior (Defect)

1.1 WHEN admin opens the Direct Shop Sales new bill page THEN the shop dropdown search displays only some active shops instead of all active shops

1.2 WHEN DirectSalesController loads shops using `ShopModel.listAll({ is_active: '1' })` THEN the system may be applying an unintended limit or pagination that restricts the result set

1.3 WHEN admin searches for a specific active shop in the dropdown THEN some active shops are not available for selection

#### Expected Behavior (Correct)

2.1 WHEN admin opens the Direct Shop Sales new bill page THEN the system SHALL load and display ALL active shops from the database regardless of route assignment

2.2 WHEN DirectSalesController calls ShopModel.listAll THEN it SHALL pass parameters that prevent pagination limits and retrieve the complete active shop list

2.3 WHEN admin searches in the shop dropdown THEN ALL active shops SHALL be searchable and selectable

#### Unchanged Behavior (Regression Prevention)

3.1 WHEN admin selects a shop and creates a direct sale bill THEN the system SHALL CONTINUE TO deduct stock immediately and create the bill correctly

3.2 WHEN shops are loaded on other pages with pagination THEN the system SHALL CONTINUE TO apply pagination limits as designed

3.3 WHEN a shop is deactivated THEN it SHALL CONTINUE TO not appear in the direct sales dropdown

---

### Bug 4: Stock Overview Missing Search Functionality

**Priority:** Medium (user experience)

#### Current Behavior (Defect)

1.1 WHEN admin views the Stock Overview page at `/stock` THEN the system displays all active products in a table with no search input field

1.2 WHEN admin needs to find a specific product by SKU, name, or brand THEN the system requires manual scrolling through the entire product list

1.3 WHEN the product list is large THEN finding a specific product becomes time-consuming and inefficient

#### Expected Behavior (Correct)

2.1 WHEN admin views the Stock Overview page THEN the system SHALL display an interactive search bar above the product table

2.2 WHEN admin types in the search bar THEN the system SHALL filter the product table in real-time using client-side JavaScript to match SKU code, product name, or brand

2.3 WHEN search results filter the table THEN products that do not match the search term SHALL be hidden from view

#### Unchanged Behavior (Regression Prevention)

3.1 WHEN no search term is entered THEN the system SHALL CONTINUE TO display all active products

3.2 WHEN admin clicks on a product to view movements THEN the system SHALL CONTINUE TO navigate to the stock movements page

3.3 WHEN stock levels are displayed THEN the system SHALL CONTINUE TO show current cartons and loose units accurately

---

### Bug 5: Product Management Missing Search and Context-Aware Actions

**Priority:** Medium (user experience)

#### Current Behavior (Defect)

1.1 WHEN admin views the Product Management page at `/products` THEN the system displays filter tabs (All/Active/Inactive) but no search functionality

1.2 WHEN admin needs to find a specific product by SKU, name, or brand THEN the system requires manual scrolling through filtered lists

1.3 WHEN admin views the product list THEN action buttons (activate/deactivate) are displayed based on `p.is_active` status regardless of the current filter tab

1.4 WHEN admin is viewing the "Inactive" filter tab and sees active products mixed in OR action buttons don't match the filter context THEN the UI is confusing and inconsistent

#### Expected Behavior (Correct)

2.1 WHEN admin views the Product Management page THEN the system SHALL display an interactive search bar that filters products in real-time by SKU code, product name, or brand using client-side JavaScript

2.2 WHEN admin is viewing the "Active" filter tab THEN products SHALL display a "Deactivate" button

2.3 WHEN admin is viewing the "Inactive" filter tab THEN products SHALL display an "Activate" button

2.4 WHEN admin searches while a filter tab is active THEN the search SHALL apply to the currently filtered product set

#### Unchanged Behavior (Regression Prevention)

3.1 WHEN admin clicks the All/Active/Inactive filter tabs THEN the system SHALL CONTINUE TO perform server-side filtering and reload the page

3.2 WHEN admin clicks deactivate on an active product THEN the system SHALL CONTINUE TO set `is_active` to 0 and prevent the product from being used

3.3 WHEN admin clicks activate on an inactive product THEN the system SHALL CONTINUE TO set `is_active` to 1 and make the product available

3.4 WHEN a product is activated or deactivated THEN the system SHALL CONTINUE TO retain all historical stock movement and billing records

---

### Bug 6: Shop CSV Import Missing Route Filtering

**Priority:** Low (nice-to-have enhancement)

#### Current Behavior (Defect)

1.1 WHEN admin uploads a CSV file via Shop Management import THEN the system processes all rows in the CSV regardless of route_id values

1.2 WHEN admin wants to update shops for only a specific route THEN the system requires manually preparing a CSV containing only that route's shops

1.3 WHEN a CSV contains shops from multiple routes but admin only wants to update one route THEN there is no mechanism to filter by route during import

#### Expected Behavior (Correct)

2.1 WHEN admin accesses the shop import functionality THEN the system SHALL provide two import options: "Import All Routes" (current behavior) and "Import Specific Route" (new feature)

2.2 WHEN admin selects "Import Specific Route" option THEN the system SHALL display a route dropdown selector before file upload

2.3 WHEN admin selects a target route and uploads a CSV THEN the system SHALL ONLY process rows where the CSV's `route_id` column matches the selected route_id

2.4 WHEN the import processes a CSV with route filtering THEN rows with different route_ids SHALL be ignored and a warning message SHALL be displayed showing how many rows were skipped

#### Unchanged Behavior (Regression Prevention)

3.1 WHEN admin uses "Import All Routes" option THEN the system SHALL CONTINUE TO process all rows in the CSV as it currently does

3.2 WHEN CSV import encounters errors (missing required fields, duplicate names) THEN the system SHALL CONTINUE TO collect and display error messages

3.3 WHEN shops are successfully imported THEN the system SHALL CONTINUE TO create shop records with all specified fields and enforce data validation rules

---

## Bug Condition Derivation

### Bug 1: Pagination URL Malformation

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type { queryString: String, page: Number }
  OUTPUT: boolean
  
  // Bug occurs when queryString is empty or undefined
  RETURN (X.queryString = '' OR X.queryString IS NULL)
END FUNCTION
```

**Property — Fix Checking:**
```pascal
FOR ALL X WHERE isBugCondition(X) DO
  paginationURL ← buildPaginationURL'(X)
  ASSERT paginationURL matches pattern "^\\?page=\\d+$"
  ASSERT paginationURL does NOT contain "?&"
END FOR
```

---

### Bug 2: Missing User Reactivation Feature

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type { user: User, action: String }
  OUTPUT: boolean
  
  // Bug occurs when trying to reactivate a deactivated user
  RETURN (X.user.is_active = 0 AND X.action = 'reactivate')
END FUNCTION
```

**Property — Fix Checking:**
```pascal
FOR ALL X WHERE isBugCondition(X) DO
  result ← activateUser'(X.user.id)
  user_after ← getUserById(X.user.id)
  ASSERT user_after.is_active = 1
  ASSERT result.status = 'success'
END FOR
```

---

### Bug 3: Direct Shop Sales Dropdown Incomplete Data

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type { context: String, filters: Object }
  OUTPUT: boolean
  
  // Bug occurs when loading shops for direct sales form
  RETURN (X.context = 'direct_sales_new_form' AND X.filters.is_active = '1')
END FUNCTION
```

**Property — Fix Checking:**
```pascal
FOR ALL X WHERE isBugCondition(X) DO
  shops ← loadShopsForDirectSales'(X.filters)
  all_active_shops ← countActiveShopsInDB()
  ASSERT LENGTH(shops) = all_active_shops
  ASSERT NOT shops.has_pagination_limit
END FOR
```

---

### Bug 4: Stock Overview Missing Search Functionality

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type { page: String, search_feature_exists: Boolean }
  OUTPUT: boolean
  
  // Bug occurs when viewing stock overview without search
  RETURN (X.page = '/stock' AND X.search_feature_exists = FALSE)
END FUNCTION
```

**Property — Fix Checking:**
```pascal
FOR ALL X WHERE isBugCondition(X) DO
  page_html ← renderStockOverview'()
  ASSERT page_html contains search_input_element
  ASSERT page_html contains client_side_filter_script
END FOR
```

---

### Bug 5: Product Management Missing Search and Context-Aware Actions

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type { page: String, filter: String, has_search: Boolean, actions_context_aware: Boolean }
  OUTPUT: boolean
  
  // Bug occurs on products page with missing search or non-contextual actions
  RETURN (X.page = '/products' AND (X.has_search = FALSE OR X.actions_context_aware = FALSE))
END FUNCTION
```

**Property — Fix Checking:**
```pascal
FOR ALL X WHERE isBugCondition(X) DO
  page_html ← renderProductsPage'(X.filter)
  ASSERT page_html contains search_input_element
  
  IF X.filter = 'active' THEN
    ASSERT all_action_buttons_show_deactivate
  ELSE IF X.filter = 'inactive' THEN
    ASSERT all_action_buttons_show_activate
  END IF
END FOR
```

---

### Bug 6: Shop CSV Import Missing Route Filtering

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type { import_action: String, target_route: Number, csv_has_multiple_routes: Boolean }
  OUTPUT: boolean
  
  // Bug occurs when wanting route-specific import but feature doesn't exist
  RETURN (X.import_action = 'import_specific_route' AND X.target_route IS NOT NULL AND X.csv_has_multiple_routes = TRUE)
END FUNCTION
```

**Property — Fix Checking:**
```pascal
FOR ALL X WHERE isBugCondition(X) DO
  result ← importShopsWithRouteFilter'(X.csv_file, X.target_route)
  imported_shops ← getShopsFromImportResult(result)
  
  FOR EACH shop IN imported_shops DO
    ASSERT shop.route_id = X.target_route
  END FOR
  
  ASSERT result.skipped_count > 0 IF CSV contains rows with different route_ids
END FOR
```

---

## Preservation Property

For all 6 bugs, the general preservation property ensures that non-buggy inputs continue to work as before:

```pascal
// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition(X) DO
  ASSERT F(X) = F'(X)
END FOR
```

**Specific Preservation Examples:**

- **Bug 1:** Pagination with existing query parameters continues to work correctly
- **Bug 2:** User deactivation continues to function as designed
- **Bug 3:** Shop loading on other paginated pages continues to apply limits
- **Bug 4 & 5:** Existing filter tabs and product/stock display continue to work
- **Bug 6:** "Import All Routes" option continues to process all CSV rows
