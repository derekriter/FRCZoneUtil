export function handleError(code, msg) {
    console.error(`Err ${code}: ${msg}`);

    alert(`An error occurred. Please restart the program and try again.\n\nErr ${code}: ${msg}`);
    window.close(); //force close window
}
export function getElementOrErr(id, code, consoleMsg) {
    let elem = document.getElementById(id);

    if(elem === null) {
        handleError(code, consoleMsg);
        return null; //should never make it here but I have it anyway
    }

    return elem;
}
export function loadJSONFile(path) {
    return fetch(path)
        .then((response) => {
            if(!response.ok)
                throw new Error(`HTTP Error, failed to load json file. Status: ${response.status}`);

            return response.json();
        })
        .catch((err) => console.error(err));
}