const fs = require('fs');
const util = require('./util');

function writePlaylist(items, filename, destinationFolder) {
    items = items.map(item => {
        item.name = item.filename.replace(/^.*[\\/]/, '').replace(/%20/g, ' ');
        let filename = item.filename.replace(/%20/g, ' ');
        if (filename.startsWith(destinationFolder)) {
            filename = filename.replace(destinationFolder, '');
            filename = filename.replace(/^\//g, '');
        }
        if (filename.startsWith('./')) {
            filename = filename.replace('./', '');
        }
        item.filename = filename;
        return item;
    });

    let data = ["#EXTM3U"];
    items.forEach(item => {
        data.push(`#EXTINF:${item.duration},${item.name}`);
        data.push(item.filename);
        data.push("");
    });

    data = data.join('\n');

    fs.writeFile(filename, data, 'utf-8', (err) => {

    });
}

module.exports = {
    writePlaylist
}