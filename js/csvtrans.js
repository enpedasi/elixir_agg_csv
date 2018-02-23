const fs    = require('fs')
const csv = require('csv');
const csvParse = require('csv-parse')

const errorHandling = (err) => { console.log(err); };

const rs = fs.createReadStream(process.argv[2], 'utf-8');
const parser = csvParse({ delimiter: ',', relax_column_count: true });
const outputFile = fs.createWriteStream('output.csv');


rs.pipe(parser)
  .on('error', errorHandling)  
  .pipe(csv.stringify({header: false, quotedString: true}))
  .on('error', errorHandling)
  .pipe(outputFile)
  .on('error', errorHandling)
  ;

