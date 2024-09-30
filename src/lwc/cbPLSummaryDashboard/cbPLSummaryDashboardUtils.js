import {_message} from "c/cbUtils";

const ACTUAL_BORDER_COLOR = 'rgba(54, 162, 235, 1)';
const ACTUAL_BACKGROUND_COLOR = 'rgba(54, 162, 235, 1)';
const BUDGET_BORDER_COLOR = 'rgba(255, 99, 132, 1)';
const BUDGET_BACKGROUND_COLOR = 'rgba(255, 99, 132, 1)';

const createDataset = (label, data, type, backgroundColor, borderColor, borderWidth, fill, tension) => ({
	label, data, type, backgroundColor, borderColor, borderWidth, fill, tension
});

export {createDataset, ACTUAL_BORDER_COLOR, ACTUAL_BACKGROUND_COLOR, BUDGET_BORDER_COLOR, BUDGET_BACKGROUND_COLOR}