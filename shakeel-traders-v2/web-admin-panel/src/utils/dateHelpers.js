'use strict';

/**
 * Date Helper Functions for Pakistan Standard Time (PKT, UTC+5)
 * These functions ensure dates are always in Pakistan timezone
 */

/**
 * Get current date in Pakistan timezone in YYYY-MM-DD format
 * Use this for HTML date inputs
 * @returns {string} Date in YYYY-MM-DD format (e.g., "2026-06-02")
 */
function getPakistanDateString() {
  const now = new Date();
  // Create date in Pakistan timezone
  const pktDate = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Karachi' }));
  
  const year = pktDate.getFullYear();
  const month = String(pktDate.getMonth() + 1).padStart(2, '0');
  const day = String(pktDate.getDate()).padStart(2, '0');
  
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
 * @param {Date|string} datetime - DateTime to format
 * @param {boolean} includeSeconds - Whether to include seconds (default: false)
 * @returns {string} Formatted datetime string (e.g., "02 Jun 2026, 2:30 PM")
 */
function formatPakistanDateTime(datetime, includeSeconds = false) {
  if (!datetime) return '';
  
  const d = new Date(datetime);
  
  const dateOptions = {
    timeZone: 'Asia/Karachi',
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  };
  
  const timeOptions = {
    timeZone: 'Asia/Karachi',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  };
  
  if (includeSeconds) {
    timeOptions.second = '2-digit';
  }
  
  const datePart = d.toLocaleDateString('en-PK', dateOptions);
  const timePart = d.toLocaleTimeString('en-PK', timeOptions);
  
  return `${datePart}, ${timePart}`;
}

/**
 * Format time only in Pakistan timezone
 * @param {Date|string} datetime - DateTime to format
 * @param {boolean} includeSeconds - Whether to include seconds (default: false)
 * @returns {string} Formatted time string (e.g., "2:30 PM")
 */
function formatPakistanTime(datetime, includeSeconds = false) {
  if (!datetime) return '';
  
  const d = new Date(datetime);
  
  const options = {
    timeZone: 'Asia/Karachi',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  };
  
  if (includeSeconds) {
    options.second = '2-digit';
  }
  
  return d.toLocaleTimeString('en-PK', options);
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
