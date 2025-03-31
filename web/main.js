const {app, BrowserWindow} = require("electron");

const createWindow = () => {
    const win = new BrowserWindow({
        width: 800,
        height: 600
    });

    win.loadFile("index.html");
};

app.whenReady()
    .then(() => createWindow());

function handleError(code, consoleMsg) {
    console.error(`Err ${code}: ${consoleMsg}`);

    alert(`An error occurred. Please reload the page and try again.\n\nErr ${code}: ${consoleMsg}`);
    window.location.reload(); //force reload the page after the user presses ok
}
function getElementOrErr(id, code, consoleMsg) {
    let elem = document.getElementById(id);

    if(elem === null) {
        handleError(code, consoleMsg);
        return null; //should never make it here but I have it anyway
    }

    return elem;
}

function loadJSONFile(path) {
    fetch(path)
        .then((response) => response.json())
        .then((json) => console.log(json));
}
function setupField(field) {
    // console.log(reefscape2025);
}

const fieldImg = getElementOrErr("fieldImg", 0, "Failed to get fieldImg element");
let fieldData;
setupField(fieldImg);