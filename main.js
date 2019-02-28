const read = require('node-readability'), 
  striptags = require('striptags'), 
  puppeteer = require('puppeteer'), 
  xml_entities = require('html-entities').XmlEntities, 
  html_entities = require('html-entities').AllHtmlEntities;

(async() => {
  console.log(process.argv[2]);

  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.goto(process.argv[2], {waitUntil: 'networkidle0'});
  const html = await page.content();
  // todo: use promise to close browser in background while doing html processing but await conclusion of browser close
  await browser.close();

  read(html, function(err, article, meta) {
    const htmlContent = article.content;
    const title = article.title;
    article.close();

    console.log(title);
    
    //console.log("html length: " + htmlContent.length);
    const textContentWithoutTags = striptags(htmlContent);
    //console.log("text w/o tags length: " + textContentWithoutTags.length);

    const xentities = new xml_entities();
    const textContentWithoutXmlEntities = xentities.decode(textContentWithoutTags);
    //console.log("text w/o xml entities length: " + textContentWithoutXmlEntities.length);

    const hentities = new html_entities();
    const textContentWithoutHtmlEntities = hentities.decode(textContentWithoutXmlEntities);
    //console.log("text w/o html entities length: " + textContentWithoutHtmlEntities.length);

    console.log(textContentWithoutHtmlEntities);
  });
})();
