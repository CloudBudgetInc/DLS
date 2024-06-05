import {_message} from "c/cbUtils";

let c; // context
const setExcelLibContext = (_this) => {
	c = _this;
};

const FIRST_COLUMN_WIDTH = 40;
const NUMBER_COLUMNS_WIDTH = 15;
const CURRENCY_FORMATTER = '$#,##0.00';
const PERCENT_FORMATTER = '0.00%';

const downloadExcelFile = () => {
	generateAndUploadExcelFile().then(r => null);
};

const generateAndUploadExcelFile = async () => {
	try {
		let fileName = `Summary Report`;
		if (!fileName || fileName.length < 1) {
			return;
		}
		let workbook = new ExcelJS.Workbook();

		const sheet = workbook.addWorksheet('Report', {views: [{state: "frozen", ySplit: 1, xSplit: 0}]});
		setHeader(sheet);
		setRows(sheet);

		let data = await workbook.xlsx.writeBuffer();
		const blob = new Blob([data], {type: "application/octet-stream"});
		let downloadLink = document.createElement("a");
		downloadLink.href = window.URL.createObjectURL(blob);
		downloadLink.target = "_blank";
		downloadLink.download = fileName + ".xlsx";
		downloadLink.click();
	} catch (e) {
		_message("error", "Reporting Excel generateAndUploadExcelFile error: " + e);
	}
};

const setHeader = (sheet) => {
	try {
		const headers = c.selectedPeriodMode === 'current' ?
			['Label', 'Current Month', 'Current Budget', 'Dollar Diff', 'Percent Diff', 'Prior Month', 'Dollar Diff', 'Percent Diff', 'Prior Year', 'Dollar Diff', 'Percent Diff'] :
			['Label', 'YTD Current Month', 'YTD Current Budget', 'YTD Dollar Diff', 'YTD Percent Diff', 'YTD Prior Year', 'YTD Dollar Diff', 'YTD Percent Diff'];
		const headerRow = sheet.getRow(1);
		headers.forEach((h, i) => {
			const cell = headerRow.getCell(i + 1);
			cell.value = h;
			cell.font = {bold: true};
			sheet.getColumn(i + 1).width = i === 0 ? FIRST_COLUMN_WIDTH : NUMBER_COLUMNS_WIDTH;
		});
	} catch (e) {
		_message('error', 'Set Header Error : ' + JSON.stringify(e));
	}
};

const setRows = (sheet) => {
	let rowIdx = 2;
	const rlFields = c.selectedPeriodMode === 'current' ?
		[
			{"fld": "label", "formatter": "text"},
			{"fld": "currentMonthActual", "formatter": "currency"},
			{"fld": "currentMonthBudget", "formatter": "currency"},
			{"fld": "currentMonthDiff", "formatter": "currency"},
			{"fld": "currentMonthDiffPercent", "formatter": "percent"},
			{"fld": "priorMonthActual", "formatter": "currency"},
			{"fld": "priorMonthDiff", "formatter": "currency"},
			{"fld": "priorMonthDiffPercent", "formatter": "percent"},
			{"fld": "priorYearActual", "formatter": "currency"},
			{"fld": "priorYearDiff", "formatter": "currency"},
			{"fld": "priorYearDiffPercent", "formatter": "percent"}
		] :
		[
			{"fld": "label", "formatter": "text"},
			{"fld": "currentMonthActualYTD", "formatter": "currency"},
			{"fld": "currentMonthBudgetYTD", "formatter": "currency"},
			{"fld": "currentMonthDiffYTD", "formatter": "currency"},
			{"fld": "currentMonthDiffPercentYTD", "formatter": "percent"},
			{"fld": "priorYearActualYTD", "formatter": "currency"},
			{"fld": "priorYearDiffYTD", "formatter": "currency"},
			{"fld": "priorYearDiffPercentYTD", "formatter": "percent"}
		];
	c.reportLines.forEach(rl => {
		const excelRow = sheet.getRow(rowIdx++);
		rlFields.forEach((f, i) => {
			const cell = excelRow.getCell(i + 1);
			cell.value = rl[f.fld];
			if (f.formatter === 'currency') {
				cell.numFmt = CURRENCY_FORMATTER; // Example format for currency
			} else if (f.formatter === 'percent') {
				cell.numFmt = PERCENT_FORMATTER; // Example format for percent
			}
			if (rl.styleClass) cell.font = {bold: true};
		});
	});
};


export {
	downloadExcelFile, setExcelLibContext
}