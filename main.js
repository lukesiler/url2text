const u2t = require('./url2text');

(async() => {
  await u2t.getText(process.argv[2],
    function(err, text) {
      if (err) {
        console.log('error occurred');
        return;
      }
      
      console.log(text);
    }
  );
})();
