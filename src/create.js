const yaml = require('js-yaml');


const conf = JSON.parse(fs.readFileSync('../conf.json', 'utf-8'));
let basData = fs.readFileSync(conf.dataFile);
basData = yaml.safeLoad(basData);