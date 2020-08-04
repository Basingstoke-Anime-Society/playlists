#!/usr/bin/env node

const fs = require('fs');

const yaml = require('js-yaml');

// get config and data
const conf = JSON.parse(fs.readFileSync(__dirname+'/../conf.json', 'utf-8'));
let basData = fs.readFileSync(conf.dataFile);
basData = yaml.safeLoad(basData);

// get params
let year = parseInt(process.argv[2]);
let month = parseInt(process.argv[3]);
let day = parseInt(process.argv[4]);
let name = `${(""+year).padStart(4, '0')}-${(""+month).padStart(2, '0')}-${(""+day).padStart(2, '0')}`

console.log("Creating playlist:", name);