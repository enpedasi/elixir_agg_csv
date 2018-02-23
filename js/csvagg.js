const fs    = require('fs')
const csvParse = require('csv-parse')
const label1 = "agg-sum-elapsed"

if (process.argv.length < 3) {
    console.error('lack argument.');
    process.exit(1);
}

console.time(label1);

let rs;
const sumMap = new Map
try {
    rs = fs.createReadStream(process.argv[2], 'utf-8');
    rs.on('error',  (err) => {
        console.error(err);
        process.exit(1);
    });
}
catch (err) {
    console.error(err);
    process.exit(1);
}

const parser = csvParse({ delimiter: ',', relax_column_count: true });
parser.on('data', (data) => {
    const key = data[1]
    sumMap.set(key, sumMap.has(key) ? sumMap.get(key) + 1 : 1)
});
parser.on('error', (err) => {
    console.error(err);
    process.exit(1);
});


parser.on('end', () => {
  console.timeEnd(label1);
  
  // show result Top 10 
  result =  Array
    .from(sumMap)
    .sort((a, b) => {
      return b[1] - a[1];
    })
  for(let i=0; i < 10; i ++) {
    console.log(result[i])
  }
})

rs.pipe(parser);


new Map(
  Array
    .from(sumMap)
    .sort((a, b) => {
      // a[0], b[0] is the key of the map
      return a[1] - b[1];
    })
)

