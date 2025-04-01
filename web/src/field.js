import {getElementOrErr, loadJSONFile} from "./utils.js";

async function setupField() {
    fieldData = await loadJSONFile("../fields/Reefscape2025.json");
    fieldData.display = {
        zoom: 1,
        x: 0,
        y: 0
    };

    fieldImg.src = fieldData.image;
    fieldImg.style.width = `${fieldData.display.zoom * 100}%`;
    fieldImg.style.left = `${fieldData.display.x}px`;
    fieldImg.style.top = `${fieldData.display.y}px`;

    field.addEventListener("wheel", (e) => {
        fieldData.display.zoom = Math.min(Math.max(fieldData.display.zoom - e.deltaY / 1000, 0.2), 6);
        fieldImg.style.width = `${fieldData.display.zoom * 100}%`;
    }, {passive: true});
    field.addEventListener("mousedown", () => {
        function move(e) {
            fieldData.display.x += e.movementX;
            fieldData.display.y += e.movementY;
            fieldImg.style.left = `${fieldData.display.x}px`;
            fieldImg.style.top = `${fieldData.display.y}px`;
        }
        function up() {
            window.removeEventListener("mousemove", move);
            window.removeEventListener("mouseup", up);
        }

        window.addEventListener("mousemove", move);
        window.addEventListener("mouseup", up);
    });
}

const field = getElementOrErr("field", 4, "Failed to get field element");
const fieldImg = getElementOrErr("fieldImg", 3, "Failed to get fieldImg element");
let fieldData;

setupField();