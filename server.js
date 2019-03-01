const express = require('express'),
    u2t = require('./url2text'),
    bp = require('body-parser');

const httpServer = express();
const httpServerPort = process.argv[2];
const jsonparser = bp.json(limit='1kb');

httpServer.get('/alive', (req, res) => res.send(200));
httpServer.get('/ready', (req, res) => res.send(200));

httpServer.post('/text', jsonparser, (req, res) => {
    const requested_url = req.body.url;

    (async() => {
        await u2t.getText(requested_url,
          function(err, text) {
            if (err) {
              res.send(500);
              return;
            }
            
            res.send({ url: requested_url, text: text });
          }
        );
      })();

    //res.send({ url: requested_url });
});

httpServer.listen(httpServerPort, () => console.log(`Example app listening on port ${httpServerPort}!`));
