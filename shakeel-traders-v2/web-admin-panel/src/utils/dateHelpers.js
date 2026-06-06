'use strict';

/**
 * Date Helper Functions for Pakistan Standard Time (PKT, UTC+5)
 * These functions ensure dates are always in Pakistan timezone
 */

/**
 * Get current date in Pakistan timezone in YYYY-MM-DD format
 * Use this for HTML date inputs and database queries
 * @returns {string} Date in YYYY-MM-DD format (e.g., "2026-06-07")
 */
function getPakistanDateString() {
  const now = new Date();
  // Get date components in Pakistan timezone
  const pktString = now.toLocaleString('en-US', { 
    timeZone: 'Asia/Karachi',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
  // Format: MM/DD/YYYY, convert to YYYY-MM-DD
  const [month, day, year] = pktString.split('/');
  return `${year}-${month}-${day}`;
}

/**
 * Get current year-month in Pakistan timezone in YYYY-MM format
 * Use this for HTML month inputs
 * @returns {string} Year-month in YYYY-MM format (e.g., "2026-06")
 */
function getPakistanYearMonth() {
  const now = new Date();
  const pktDate = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Karachi' }));
  
  const year = pktDate.getFullYear();
  const month = String(pktDate.getMonth() + 1).padStart(2, '0');
  
  return `${year}-${month}`;
}

/**
 * Get current date object in Pakistan timezone
 * @returns {Date} Date object adjusted to Pakistan timezone
 */
function getPakistanDate() {
  const now = new Date();
  return new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Karachi' }));
}

/**
 * Format a date to Pakistan locale string
 * @param {Date|string} date - Date to format
 * @param {string} format - Format type: 'short', 'long', 'full'
 * @returns {string} Formatted date string
 */
function formatPakistanDate(date, format = 'short') {
  if (!date) return '';
  
  const d = new Date(date);
  
  const options = {
    timeZone: 'Asia/Karachi',
  };
  
  switch (format) {
    case 'short':
      // e.g., "02 Jun 2026"
      options.day = '2-digit';
      options.month = 'short';
      options.year = 'numeric';
      break;
    case 'long':
      // e.g., "02 June 2026"
      options.day = '2-digit';
      options.month = 'long';
      options.year = 'numeric';
      break;
    case 'full':
      // e.g., "Tuesday, 02 June 2026"
      options.weekday = 'long';
      options.day = '2-digit';
      options.month = 'long';
      options.year = 'numeric';
      break;
    default:
      options.day = '2-digit';
      options.month = 'short';
      options.year = 'numeric';
  }
  
  return d.toLocaleDateString('en-PK', options);
}

/**
 * Convert SQL date string to display format in Pakistan timezone
 * @param {string} sqlDate - SQL date string (YYYY-MM-DD)
 * @returns {string} Formatted date string
 */
function sqlDateToDisplay(sqlDate) {
  if (!sqlDate) return '';
  return formatPakistanDate(sqlDate, 'short');
}

/**
 * Format a datetime (timestamp) to Pakistan locale with date and time
 * MySQL returns DATETIME in UTC notation, JavaScript automatically converts to local (PKT)
 * @param {Date|string} datetime - DateTime to format
 * @param {boolean} includeSeconds - Whether to include seconds (default: false)
 * @returns {string} Formatted datetime string (e.g., "07 Jun 2026, 01:14 AM")
 */
function formatPakistanDateTime(datetime, includeSeconds = false) {
  if (!datetime) return '';
  
  const d = new Date(datetime);
  
  // Use getMonth(), getDate(), etc. to get local time components
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const month = months[d.getMonth()];
  const day = String(d.getDate()).padStart(2, '0');
  const year = d.getFullYear();
  
  let hours = d.getHours();
  const minutes = String(d.getMinutes()).padStart(2, '0');
  const ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12 || 12;
  const hoursStr = String(hours).padStart(2, '0');
  
  let timeStr = `${hoursStr}:${minutes} ${ampm}`;
  if (includeSeconds) {
    const seconds = String(d.getSeconds()).padStart(2, '0');
    timeStr = `${hoursStr}:${minutes}:${seconds} ${ampm}`;
  }
  
  return `${month} ${day}, ${year}, ${timeStr}`;
}

/**
 * Format time only in Pakistan timezone
 * MySQL returns DATETIME in UTC notation, JavaScript automatically converts to local (PKT)
 * @param {Date|string} datetime - DateTime to format
 * @param {boolean} includeSeconds - Whether to include seconds (default: false)
 * @returns {string} Formatted time string (e.g., "01:14 AM")
 */
function formatPakistanTime(datetime, includeSeconds = false) {
  if (!datetime) return '';
  
  const d = new Date(datetime);
  
  // Use getHours(), getMinutes() to get local time components
  let hours = d.getHours();
  const minutes = String(d.getMinutes()).padStart(2, '0');
  const ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12 || 12;
  const hoursStr = String(hours).padStart(2, '0');
  
  if (includeSeconds) {
    const seconds = String(d.getSeconds()).padStart(2, '0');
    return `${hoursStr}:${minutes}:${seconds} ${ampm}`;
  }
  
  return `${hoursStr}:${minutes} ${ampm}`;
}

module.exports = {
  getPakistanDateString,
  getPakistanYearMonth,
  getPakistanDate,
  formatPakistanDate,
  sqlDateToDisplay,
  formatPakistanDateTime,
  formatPakistanTime,
};
