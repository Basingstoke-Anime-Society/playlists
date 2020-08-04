#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const zoomPlayer = require('./lib/zoomplayer.js');
const vlc = require('./lib/vlc.js');
const m3u = require('./lib/m3u.js');

const util = require('./lib/util.js');
const conf = JSON.parse(fs.readFileSync(__dirname+'/../conf.json', 'utf-8'));


function parseDate(str) {
    let match = str.match(/([0-9]{4}) ([0-9]{2}) ([0-9]{2})/);

    let date = new Date();
    date.setFullYear(match[1]);
    date.setMonth(match[2] - 1);
    date.setDate(match[3]);
    return date;
}

function copyFile(shortFileName, originFile, destinationFile) {
    let destDir = path.dirname(destinationFile);
    fs.mkdir(destDir, { recursive: true }, (err) => {
        if (err) {
            console.log(`Error creating folder ${destDir}`, err);
        } else {
            fs.stat(originFile, (err, originStats) => {
                fs.stat(destinationFile, (err, destinationStats) => {
                    if (err || originStats.size != destinationStats.size) {
                        console.log(`Copying ${shortFileName}`);
                        fs.copyFile(originFile, destinationFile, (err) => {
                            if (err) {
                                console.log(`Error copying ${originFile} to ${destinationFile}`, err);
                            }
                        });
                    }
                });
            });
        }
    });
}


// find playlists to back up

fs.readdir(path.normalize(conf.sourceFolder), { encoding: 'utf-8', withFileTypes: true }, (err, files) => {
    if (err) {
        console.log("ERROR", err);
        return;
    }

    let now = new Date(Date.now());

    files.forEach(playlistFile => {
        if (playlistFile.isDirectory() || !playlistFile.isFile()) {
            return;
        }
        
        let playlistFilename = path.normalize(conf.sourceFolder+'/'+playlistFile.name);

        if (playlistFile.name.match(/\.zpl$/)) {
            let playlistName = playlistFile.name.replace(/\.zpl$/, '');
            let playlistDate = parseDate(playlistName);
            if (playlistDate < now) {
                return;
            }

            zoomPlayer.readPlaylist(playlistFilename, (items) => {
                console.log("\n\nPLAYLIST:", playlistName);
                let destinationFolder = conf.destinationFolder+'/'+playlistName;

                let ndigits = util.countDigits(items.length);
                console.log(`${items.length} items: ${ndigits} digits`);
                let n = 1;

                items = items.map(item => {
                    let destinationFile = util.transformPath(item.filename, conf.baseFolders, destinationFolder, conf.unspace, conf.flattenFolders, n++, ndigits);
                    let shortName = destinationFile.replace(destinationFolder, '').replace(/^\//, '');
                    let destinationItem = {
                        filename: destinationFile,
                        name: item.name,
                        duration: item.duration,
                    };
                    copyFile(shortName, item.filename, destinationFile);
                    return destinationItem;
                });

                // let destinationPlaylist = conf.destinationFolder+'/'+playlistName+'.xspf';
                // console.log(`Writing playlist: ${destinationPlaylist}`);
                // vlc.writePlaylist(items, destinationPlaylist, destinationFolder);
                
                // destinationPlaylist = conf.destinationFolder+'/'+playlistName+'.m3u8';
                // console.log(`Writing playlist: ${destinationPlaylist}`);
                // m3u.writePlaylist(items, destinationPlaylist, destinationFolder);
            });
        }
    });
});

