import {_message} from "c/cbUtils";

let c; // context
const setExcelLibContext = _this => c = _this;

const FIRST_COLUMN_WIDTH = 40;
const NUMBER_COLUMNS_WIDTH = 14;
const CURRENCY_FORMATTER = '$#,##0_);[Red]($#,##0)';
const PERCENT_FORMATTER = "0.0%";
const HEADER_CURRENT = [
	"Customer",
	"Revenue",
	"DL Expense",
	"DL Fringe",
	"DL Fringe IRM",
	"DL Fringe",
	"Gross Margin",
	"% Gross Margin",
	"% Revenue",
	"---",
	"Revenue",
	"DL Expense",
	"DL Fringe",
	"DL Fringe IRM",
	"DL Fringe",
	"Gross Margin",
	"% Gross Margin",
	"% Revenue"
];

const ROW_STRUCTURE = [
	{fld: "label", formatter: "text"},
	{fld: "actualRevenue", formatter: "currency"},
	{fld: "actualExpense", formatter: "currency"},
	{fld: "actualDLFringe", formatter: "currency"},
	{fld: "actualDLFringeIRM", formatter: "currency"},
	{fld: "actualDLFringeTotal", formatter: "currency"},
	{fld: "actualGrossMargin", formatter: "currency"},
	{fld: "actualGrossMarginPercent", formatter: "percent"},
	{fld: "actualRevenuePercent", formatter: "percent"},
	{fld: "space", formatter: "text"},
	{fld: "budgetRevenue", formatter: "currency"},
	{fld: "budgetExpense", formatter: "currency"},
	{fld: "budgetDLFringe", formatter: "currency"},
	{fld: "budgetDLFringeIRM", formatter: "currency"},
	{fld: "budgetDLFringeTotal", formatter: "currency"},
	{fld: "budgetGrossMargin", formatter: "currency"},
	{fld: "budgetGrossMarginPercent", formatter: "percent"},
	{fld: "budgetRevenuePercent", formatter: "percent"}
];

const downloadExcelFile = () => {
	generateAndUploadExcelFile().then((r) => null);
};

const generateAndUploadExcelFile = async () => {
	try {
		let fileName = `Gross Margin Report`;
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
		const headers = HEADER_CURRENT; /// RIGHT

		// Add CloudBudget3.0 in the top left corner and merge cells
		sheet.mergeCells("A1:B1");
		const A1Cell = sheet.getCell("A1");
		A1Cell.value = "CloudBudget3.0";
		A1Cell.font = {bold: true, color: {argb: "0000FF"}, size: 18}; // Adjust color as per the example

		// Add the second row
		const A2Cell = sheet.getCell("A2");
		A2Cell.value = "Gross Margin Report";
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
	c.GMReportLines.forEach((rl) => {
		const excelRow = sheet.getRow(rowIdx++);
		ROW_STRUCTURE.forEach((f, i) => {
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
