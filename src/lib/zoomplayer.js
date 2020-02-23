const fs = require('fs');
const util = require('./util');

function readPlaylist(filename, callback) {
    fs.readFile(filename, 'utf16le', (err, data) => {
        // strip the BOM
        data = data.replace(/^\uFEFF/, '');

        let items = [];
        let currentItem = { filename: '', name: '', duration: 0 };
        data.split(/\n/).forEach(line => {
            line = line.trim();
            let match = false;
            if (match = line.match(/^nm=(.*)/)) {
                currentItem.filename = util.win2nix(match[1]);
            } else if (match = line.match(/^tt=(.*)/)) {
                currentItem.name = match[1];
            } else if (match = line.match(/^dr=(.*)/)) {
                currentItem.duration = parseInt(match[1]);
            } else if (line == "br!") {
                if (currentItem.name == '') {
                    name = currentItem.filename.replace(/^.*[\\/]/, '');
                    // name = name.replace(/\.(avi|mp4|mkv|mpg|wmv)$/, '');
                    currentItem.name = name;
                }
                items.push(currentItem);
                currentItem = { filename: '', name: '', duration: 0 };
            }
        });

        callback(items);
    });
}


module.exports = {
    readPlaylist
}