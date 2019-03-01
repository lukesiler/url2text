const read = require('node-readability'), 
  striptags = require('striptags'), 
  puppeteer = require('puppeteer'), 
  entities = require('html-entities');

async function getText(url, callback) {
  //console.log(process.argv[2]);

  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.goto(url, {waitUntil: 'networkidle0'});
  const html = await page.content();
  // todo: use async.parallel to close browser in background while doing html processing but await conclusion of browser close
  await browser.close();

  read(html, function(err, article, meta) {
    if (err) {
      callback(err, null);
      return;
    }

    const htmlContent = article.content;
    const title = article.title;
    article.close();

    //console.log(title);
    
    //console.log("html length: " + htmlContent.length);
    const textContentWithoutTags = striptags(htmlContent);
    //console.log("text w/o tags length: " + textContentWithoutTags.length);

    const xentities = new entities.XmlEntities();
    const textContentWithoutXmlEntities = xentities.decode(textContentWithoutTags);
    //console.log("text w/o xml entities length: " + textContentWithoutXmlEntities.length);

    const hentities = new entities.AllHtmlEntities();
    const textContentWithoutHtmlEntities = hentities.decode(textContentWithoutXmlEntities);
    //console.log("text w/o html entities length: " + textContentWithoutHtmlEntities.length);

    //console.log(textContentWithoutHtmlEntities);

    const text = title + '\n' + textContentWithoutHtmlEntities;
    callback(null, text);
  });
};

module.exports.getText = getText;
