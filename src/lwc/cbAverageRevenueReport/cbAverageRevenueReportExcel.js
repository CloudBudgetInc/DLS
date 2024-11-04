import {_message} from "c/cbUtils";
import getAccPeriodNameServer from '@salesforce/apex/CBPLSummaryReportPageController.getAccPeriodNameServer';

let c; // context
const setExcelLibContext = _this => c = _this;

const FIRST_COLUMN_WIDTH = 40;
const NUMBER_COLUMNS_WIDTH = 14;
const CURRENCY_FORMATTER = '$#,##0_);[Red]($#,##0)';
const PERCENT_FORMATTER = "0.0%";
const HEADERS = [
	"Label",
	"Hourly Rate",
	"Quantity",
	"Sum",
];
const ROW_STRUCTURE = [
	{fld: "label", formatter: "text"},
	{fld: "rate", formatter: "currency"},
	{fld: "hours", formatter: "text"},
	{fld: "amount", formatter: "currency"},
];

const downloadExcelFile = () => {
	generateAndUploadExcelFile().then((r) => null);
};

let fileDescription;
const getFileDescription = async () => {
	if (!fileDescription) {
		const periodName = await getAccPeriodNameServer({accPeriodId: c.ASPeriodId});
		fileDescription = `(${c.selectedConfig} for ${periodName})`;
	}
	return fileDescription;
};

const generateAndUploadExcelFile = async () => {
	try {
		let fileName = `Average Revenue Rate ${await getFileDescription()}`;
		let workbook = new ExcelJS.Workbook();
		const sheet = workbook.addWorksheet('Average Revenue Rate', {views: [{state: "frozen", ySplit: 3, xSplit: 0}],});
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
		// Add CloudBudget3.0 in the top left corner and merge cells
		sheet.mergeCells("A1:B1");
		const A1Cell = sheet.getCell("A1");
		A1Cell.value = "CloudBudget3.0";
		A1Cell.font = {bold: true, color: {argb: "0000FF"}, size: 16}; // Adjust color as per the example

		// Add the second row
		const A2Cell = sheet.getCell("A2");
		A2Cell.value = `Average Revenue Rate ${fileDescription}`;
		A2Cell.font = {bold: true, size: 14};
		A2Cell.alignment = {horizontal: "left"};
		sheet.mergeCells(2, 1, 2, HEADERS.length); // Merge all cells in the second row

		// Add the third row for headers
		const headerRow = sheet.getRow(3);
		HEADERS.forEach((h, i) => {
			const cell = headerRow.getCell(i + 1);
			cell.value = h;
			cell.font = {bold: true};
			sheet.getColumn(i + 1).width = i === 0 ? FIRST_COLUMN_WIDTH : NUMBER_COLUMNS_WIDTH;
		});

		// Add bottom border to the header
		headerRow.eachCell(cell => {
			cell.border = {bottom: {style: "thin"},}
		});
	} catch (e) {
		_message("error", "Set Header Error : " + JSON.stringify(e));
	}
};

const setRows = (sheet) => {
	let rowIdx = 4;
	const rlFields = ROW_STRUCTURE; /// RIGHT!
	c.reportLinesGeneral.forEach((rl) => {
		try {
			const excelRow = sheet.getRow(rowIdx++);
			rlFields.forEach((f, i) => {
				const cell = excelRow.getCell(i + 1);
				cell.value = rl[f.fld];
				if (f.formatter === "currency") {
					cell.numFmt = CURRENCY_FORMATTER; // Example format for currency
				} else if (f.formatter === "percent") {
					cell.numFmt = PERCENT_FORMATTER; // Example format for percent
				}
				if (rl.lineStyleClass === 'simpleLine') {
					cell.font = {
						color: {argb: "0000FF"},
						italic: true,
						size: 9
					};
				}
			});
		} catch (e) {
			_message('error', 'AvRep Set Rows Error ' + JSON.stringify(e));
		}
	});
};

export {downloadExcelFile, setExcelLibContext};
