/**
 * Pagination utility for list views
 * 
 * @param {number} totalCount - Total number of records
 * @param {number} page - Current page number (1-indexed)
 * @param {number} limit - Records per page (default: 25)
 * @returns {object} Pagination metadata: { page, limit, total, pages, offset }
 */
function paginate(totalCount, page = 1, limit = 25) {
  const total = Math.max(0, totalCount);
  const pages = total === 0 ? 0 : Math.ceil(total / limit);
  const currentPage = Math.max(1, Math.min(page, Math.max(1, pages)));
  const offset = (currentPage - 1) * limit;

  return {
    page: currentPage,
    limit,
    total,
    pages,
    offset
  };
}

module.exports = { paginate };
