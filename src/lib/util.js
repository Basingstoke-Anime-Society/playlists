const path = require('path');

function win2nix(str) {
    str = str.replace(/ /g, '\ ');
    str = str.replace(/\\/g, '/');
    str = str.replace(/^([a-zA-Z]):/, (path, drive) => `/mnt/${drive.toLowerCase()}`);
    return str;
}

function nix2win(str) {
    str = str.replace(/\/mnt\/([a-zA-Z])\//, (path, drive) => `${drive.toUpperCase()}:\\`);
    str = str.replace('\\ ', ' ');
    str = str.replace(/\//g, '\\');
    return str;
}

function win2uri(str, relativeTo = false) {
    str = str.replace(/\\/g, '/');
    str = str.replace(/ /g, '%20');
    str = `file://${str}`;

    if (relativeTo) {
        relativeTo = win2uri(relativeTo);
        if (str.startsWith(relativeTo)) {
            str = str.replace(relativeTo, '');
            str = str.replace(/^\//g, '');
            return './'+str;
        }
    }

    return str;
}

function countDigits(number) {
    number = ""+number;
    return number.length;
}

function padDigits(number, digits) {
    let padding = "0".repeat(digits);
    number = padding+number;
    return number.substring(number.length - digits);
}

function transformPath(filename, baseFolders, destinationFolder, unspace = false, flattenFolders = false, number = 0, ndigits = 0) {
    for (var i = 0; i < baseFolders.length; i++) {
        let base = baseFolders[i];
        if (filename.startsWith(base)) {
            let partialPath = filename.replace(base, '');

            if (unspace) {
                partialPath = partialPath.replace(/ /g, '_');
            }

            if (flattenFolders) {
                let filename = path.basename(partialPath);
                let prefix = padDigits(number, ndigits);
                partialPath = prefix+" "+filename;
                console.log(`${filename} => ${partialPath}`);
            }

            return destinationFolder+"/"+partialPath;
        }
    }

    console.log("Cannot transform:", filename);
    return filename;
}

module.exports = {
    transformPath,
    countDigits,
    padDigits,
    win2nix,
    nix2win,
    win2uri,
}