const HelpController = {
  /**
   * Display user guide page (English)
   */
  userGuide: (req, res) => {
    res.render('help/user-guide', {
      title: 'User Guide',
      user: req.session.user
    });
  },

  /**
   * Display user guide page (Urdu)
   */
  userGuideUrdu: (req, res) => {
    res.render('help/user-guide-urdu', {
      title: 'صارف گائیڈ',
      user: req.session.user
    });
  }
};

module.exports = HelpController;
