const {app, BrowserWindow} = require("electron");

function handleHeadlessError(code, msg) {
    console.error(`Err ${code}: ${msg}`);
    app.exit(code);
}

function createWindow() {
    const win = new BrowserWindow({
        width: 1778,
        height: 1000,
        show: false
    });
    win.menuBarVisible = false;
    win.fullScreenable = false;

    win.loadFile("src/index.html")
        .then(() => win.show()) //wait to show the window until the page has loaded to prevent a flash of the default white
        .catch(() => handleHeadlessError(2, "Failed to load html file into window"));
}

app.whenReady()
    .then(() => createWindow())
    .catch(() => handleHeadlessError(1, "Failed to init app"));

app.on("window-all-closed", () => {
    if(process.platform !== "darwin")
        app.quit(); //close process when all windows are closed
});
