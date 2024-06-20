import {_message} from "c/cbUtils";

let c; // context
const setExcelLibContext = _this => c = _this;

const FIRST_COLUMN_WIDTH = 40;
const NUMBER_COLUMNS_WIDTH = 14;
const CURRENCY_FORMATTER = '$#,##0_);[Red]($#,##0)';
const PERCENT_FORMATTER = "0.0%";
const HEADER_CURRENT = [
	"Label",
	"Current Month",
	"Current Budget",
	"Dollar Diff",
	"Percent Diff",
	"Notes",
	"Prior Month",
	"Dollar Diff",
	"Percent Diff",
	"Notes",
	"Prior Year",
	"Dollar Diff",
	"Percent Diff",
	"Notes"
];
const HEADER_YTD = [
	"Label",
	"YTD Current Month",
	"YTD Current Budget",
	"YTD Dollar Diff",
	"YTD Percent Diff",
	"Notes",
	"YTD Prior Year",
	"YTD Dollar Diff",
	"YTD Percent Diff",
	"Notes"
];
const ROW_STRUCTURE_CURRENT = [
	{fld: "label", formatter: "text"},
	{fld: "currentMonthActual", formatter: "currency"},
	{fld: "currentMonthBudget", formatter: "currency"},
	{fld: "currentMonthDiff", formatter: "currency"},
	{fld: "currentMonthDiffPercent", formatter: "percent"},
	{fld: "notes1", formatter: "text"},
	{fld: "priorMonthActual", formatter: "currency"},
	{fld: "priorMonthDiff", formatter: "currency"},
	{fld: "priorMonthDiffPercent", formatter: "percent"},
	{fld: "notes2", formatter: "text"},
	{fld: "priorYearActual", formatter: "currency"},
	{fld: "priorYearDiff", formatter: "currency"},
	{fld: "priorYearDiffPercent", formatter: "percent"},
	{fld: "notes3", formatter: "text"}
];
const ROW_STRUCTURE_YTD = [
	{fld: "label", formatter: "text"},
	{fld: "currentMonthActualYTD", formatter: "currency"},
	{fld: "currentMonthBudgetYTD", formatter: "currency"},
	{fld: "currentMonthDiffYTD", formatter: "currency"},
	{fld: "currentMonthDiffPercentYTD", formatter: "percent"},
	{fld: "notes1", formatter: "text"},
	{fld: "priorYearActualYTD", formatter: "currency"},
	{fld: "priorYearDiffYTD", formatter: "currency"},
	{fld: "priorYearDiffPercentYTD", formatter: "percent"},
	{fld: "notes2", formatter: "text"}
];

const downloadExcelFile = () => {
	generateAndUploadExcelFile().then((r) => null);
};

const generateAndUploadExcelFile = async () => {
	try {
		let fileName = `PL Summary Report ${c.selectedMonthName} (${c.selectedReportType})`;
		let workbook = new ExcelJS.Workbook();
		const sheet = workbook.addWorksheet(fileName, {views: [{state: "frozen", ySplit: 3, xSplit: 0}],});
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
		const headers = c.selectedPeriodMode === "current" ? HEADER_CURRENT : HEADER_YTD; /// RIGHT

		// Add CloudBudget3.0 in the top left corner and merge cells
		sheet.mergeCells("A1:B1");
		const A1Cell = sheet.getCell("A1");
		A1Cell.value = "CloudBudget3.0";
		A1Cell.font = {bold: true, color: {argb: "0000FF"}, size: 18}; // Adjust color as per the example

		// Add the second row
		const A2Cell = sheet.getCell("A2");
		A2Cell.value = c.selectedReportType === 'summary' || c.selectedReportType === 'summary+' ? "Current Vs. Prior Vs. Budget Month P&L Summary" : "Facilities";
		A2Cell.font = {bold: true, size: 18};
		A2Cell.alignment = {horizontal: "left"};
		sheet.mergeCells(2, 1, 2, headers.length); // Merge all cells in the second row

		// Add the third row for headers
		const headerRow = sheet.getRow(3);
		headers.forEach((h, i) => {
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
	const rlFields = c.selectedPeriodMode === 'current' ? ROW_STRUCTURE_CURRENT : ROW_STRUCTURE_YTD; /// RIGHT!
	c.reportLines.forEach((rl) => {
		const excelRow = sheet.getRow(rowIdx++);
		rlFields.forEach((f, i) => {
			const cell = excelRow.getCell(i + 1);
			cell.value = rl[f.fld];
			if (f.formatter === "currency") {
				cell.numFmt = CURRENCY_FORMATTER; // Example format for currency
			} else if (f.formatter === "percent") {
				cell.numFmt = PERCENT_FORMATTER; // Example format for percent
			}
			if (rl.styleClass) {
				cell.font = {bold: true};
				cell.border = {
					bottom: {style: "dotted"},
					top: {style: "dotted"},
				};
			}

			// Apply column color formatting as per the example
			if (["currentMonthDiffPercent", "currentMonthDiffPercentYTD", "notes1"].includes(f.fld)) {
				cell.fill = {
					type: "pattern",
					pattern: "solid",
					fgColor: {argb: "D3D3D3"},
				};
			} else if (["priorMonthDiffPercent", "priorYearDiffPercentYTD", "notes2"].includes(f.fld)) {
				cell.fill = {
					type: "pattern",
					pattern: "solid",
					fgColor: {argb: "ADD8E6"},
				};
			} else if (["priorYearDiffPercent", "notes3"].includes(f.fld)) {
				cell.fill = {
					type: "pattern",
					pattern: "solid",
					fgColor: {argb: "D8E8D8"},
				};
			}
		});
	});
};

export {downloadExcelFile, setExcelLibContext};
