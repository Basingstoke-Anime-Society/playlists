const fs = require('fs');
const util = require('./util');

function writePlaylist(items, filename, destinationFolder) {
    items = items.map(item => {
        item.name = item.filename.replace(/^.*[\\/]/, '').replace(/%20/g, ' ');
        let filename = util.nix2win(item.filename);
        item.filename = util.win2uri(filename, destinationFolder);
        return item;
    });

    let tracks = [];
    let vlcItems = [];
    let number = 0;
    items.forEach(item => {
        tracks.push(`
		<track>
			<location>${item.filename}</location>
			<duration>${item.duration*1000}</duration>
			<extension application="http://www.videolan.org/vlc/playlist/0">
				<vlc:id>${number}</vlc:id>
			</extension>
        </track>`);
        
        vlcItems.push(`<vlc:item tid="${number}"/>`);
        number++;
    });

    let data = `<?xml version="1.0" encoding="UTF-8"?>
    <playlist xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/" version="1">
        <title>Playlist</title>
        <trackList>
            ${tracks.join("\n")}
        </trackList>
    <extension application="http://www.videolan.org/vlc/playlist/0">
        ${vlcItems.join("\n")}
	</extension>
</playlist>`;

    fs.writeFile(filename, data, 'utf-8', (err) => {

    });
}

module.exports = {
    writePlaylist
}