import {_message} from "c/cbUtils";
import {ReportLine} from "./cbPLSummaryReportWrapper";
import {getFacilityReportLines} from "./cbPLSummaryReportFacility";

let c; // context
const setContext = (_this) => c = _this;
const includeAccounts = () => c.selectedReportType === 'summary+' || c.selectedReportType === 'facilities';
const includeVar1 = () => c.selectedReportType === 'facilities';

/**
 * @param selectedPeriodId
 * @param periodSO
 * @return previous period Id
 */
const getPriorPeriodId = (selectedPeriodId, periodSO) => {
	try {
		const currentPeriodIndex = periodSO.findIndex(p => p.value === selectedPeriodId);
		return periodSO[currentPeriodIndex + 1].value;
	} catch (e) {
		return selectedPeriodId;
	}
};
/**
 * @param selectedPeriodId
 * @param periodSO
 * @return the first period of the budget year
 */
const getBYFirstPeriodId = (selectedPeriodId, periodSO) => {
	const currentPeriod = periodSO.find(p => p.value === selectedPeriodId);
	for (let i = periodSO.length - 1; i >= 0; i--) {
		if (periodSO[i].byId === currentPeriod.byId) return periodSO[i].value;
	}
};
/**
 * @param selectedPeriodId
 * @param periodSO
 * @return CB PeriodId of the previous budget year. One year back
 */
const getPriorYearPeriodId = (selectedPeriodId, periodSO) => {
	try {
		const currentPeriodIndex = periodSO.findIndex(p => p.value === selectedPeriodId);
		return periodSO[currentPeriodIndex + 12].value;
	} catch (e) {
		return selectedPeriodId;
	}
};

/**
 *
 * @param cube source cube
 * @param reportLineMap object where key is RLKey, value is reportLine
 * @param dataType currentMonthCubes || priorMonthCubes || priorYearCubes || currentMonthCubesYTD || priorYearCubesYTD
 */
const convertCubeToReportLine = (cube, reportLineMap, dataType) => {
	try {
		const {label, type, account, var1, var2, accountST2} = getLabelAndType(cube);
		let key = label + type + (includeAccounts() ? account : '') + (includeVar1() ? var1 : '');
		let reportLine = reportLineMap[key];
		if (!reportLine) {
			let rowLabel = label;
			if (includeAccounts()) rowLabel = label + ' (' + account + ')';
			if (includeVar1()) rowLabel = account;
			reportLine = new ReportLine(rowLabel);
			reportLine.type = type;
			reportLine.account = account;
			reportLine.var1 = var1;
			reportLine.var2 = var2;
			reportLine.accountST2 = accountST2;
			reportLineMap[key] = reportLine;
		}
		populateNumbers(cube, reportLine, dataType);
	} catch (e) {
		_message('error', 'Convert cube to RL Error: ' + e);
	}
};

const dataMappings = {
	'currentMonthCubes': ['currentMonthActual', 'currentMonthBudget'],
	'priorMonthCubes': ['priorMonthActual', 'priorMonthBudget'],
	'priorYearCubes': ['priorYearActual', 'priorYearBudget'],
	//// YTD
	'currentMonthCubesYTD': ['currentMonthActualYTD', 'currentMonthBudgetYTD'],
	'priorYearCubesYTD': ['priorYearActualYTD', null],
};

const populateNumbers = (cube, reportLine, dataType) => {
	if (dataMappings[dataType]) {
		const [actualField, budgetField] = dataMappings[dataType];
		reportLine[actualField] += +cube.Actual_Inverted__c;
		if (budgetField) reportLine[budgetField] += +cube.cb5__Budget__c;
	}
};

/**
 * The main method to split data between sections
 */
const getLabelAndType = (cube) => {
	if (cube.cb5__CBAccount__r.Name.startsWith('481')) {
		return {label: 'GSA IFF Fee', type: 'Revenue', account: cube.cb5__CBAccount__r.Name};
	}
	if (cube.cb5__CBAccount__r.Name.startsWith('58')) {
		return {label: 'Direct Fringe', type: 'COGS', account: cube.cb5__CBAccount__r.Name};
	}
	if (cube.cb5__CBVariable2__c) {
		if (cube.cb5__CBAccount__r.Name.startsWith('4')) {
			return {
				label: cube.cb5__CBVariable2__r.Name,
				type: 'Revenue',
				account: cube.cb5__CBAccount__r.Name,
				accountST2: cube.CBAccountSubtype2__c
			};
		}
		if (cube.cb5__CBAccount__r.Name.startsWith('5')) {
			return {
				label: cube.cb5__CBVariable2__r.Name,
				type: 'COGS',
				account: cube.cb5__CBAccount__r.Name,
				accountST2: cube.CBAccountSubtype2__c
			};
		}
	}
	if (cube.CBAccountSubtype2__c === 'Non-Operating Other Income') {
		return {label: cube.CBAccountSubtype2__c, type: 'Other Income', account: cube.cb5__CBAccount__r.Name};
	}
	if (cube.CBAccountSubtype2__c === 'Non-Operating Other Expenses') {
		return {label: cube.CBAccountSubtype2__c, type: 'Other Expense', account: cube.cb5__CBAccount__r.Name};
	}
	const subTypes = [
		'Fringes',
		'Overhead',
		'Facilities',
		'EESC',
		'General & Administrative',
		'Other Income',
		'Other Expense'
	];
	if (subTypes.includes(cube.cb5__AccSubType__c)) {
		return {
			label: cube.CBAccountSubtype2__c,
			type: cube.cb5__AccSubType__c,
			accountST2: cube.CBAccountSubtype2__c,
			account: cube.cb5__CBAccount__r.Name,
			var1: cube.cb5__CBVariable1__r?.Name,
			var2: cube.cb5__CBVariable2__r?.Name
		};
	}
	return {label: 'Other', type: 'Other'};
};

const addSubLinesAndTotals = (reportLines) => {
	try {

		if (c.selectedReportType === 'facilities') {
			return getFacilityReportLines(reportLines);
		}

		const revenueTotal = new ReportLine('Total Revenue', 'totalLine');
		const COGSTotal = new ReportLine('Total Cost of Goods Sold', 'totalLine');
		const grossMargin = new ReportLine('Gross Margin', 'totalLine');
		const grossMarginPercent = new ReportLine('Gross %', 'totalLine');

		const fringeTotal = new ReportLine('Total Indirect Fringes', 'totalLine2');
		const overheadTotal = new ReportLine('Total Overhead', 'totalLine2');
		const facilitiesTotal = new ReportLine('Total Facilities', 'totalLine2');
		const eescTotal = new ReportLine('Total EE Support Center', 'totalLine2');
		const GATotal = new ReportLine('Total General & Administration', 'totalLine2');

		const indirectExpenseTotal = new ReportLine('Total Indirect Expense', 'totalLine');
		const netOrdinaryTotal = new ReportLine('Net Ordinary Income', 'totalLine');
		const nonOperatingIncomeTotal = new ReportLine('Non-Operating Income');
		const nonOperatingExpenseTotal = new ReportLine('Non-Operating Expenses');
		const nonOperatingOtherIncomeExpenseTotal = new ReportLine('Total Non-Operating Other Income & Expense', 'totalLine');
		const netProfit = new ReportLine('Net Profit', 'totalLine');
		const netIncomePercent = new ReportLine('Net Profit %', 'totalLine');

		let revenueLines = [];
		let COGSLines = [];
		let fringeLines = [];
		let overheadLines = [];
		let facilitiesLines = [];
		let eescLines = [];
		let GALines = [];

		const sectionType = {
			'Revenue': {total: revenueTotal, lines: revenueLines},
			'COGS': {total: COGSTotal, lines: COGSLines},
			'Fringes': {total: fringeTotal, lines: fringeLines},
			'Overhead': {total: overheadTotal, lines: overheadLines},
			'Facilities': {total: facilitiesTotal, lines: facilitiesLines},
			'EESC': {total: eescTotal, lines: eescLines},
			'General & Administrative': {total: GATotal, lines: GALines},
			'Other Income': {total: nonOperatingIncomeTotal},
			'Other Expense': {total: nonOperatingExpenseTotal},
		};

		reportLines.forEach(rl => {
			const section = sectionType[rl.type];
			if (section) {
				section.total.sumUpLines(rl);
				if (section.lines) section.lines.push(rl);
			}
		});
		sortReportLines([revenueLines, COGSLines, fringeLines, overheadLines, facilitiesLines, eescLines, GALines]);
		if (includeAccounts()) { // add subtype totals for the Summary+ mode only
			revenueLines = addSubtypeTotals(revenueLines, 'GSA IFF Fee');
			COGSLines = addSubtypeTotals(COGSLines, 'Direct Fringe');
			fringeLines = addSubtypeTotals(fringeLines, 'Other');
			overheadLines = addSubtypeTotals(overheadLines, 'Other');
			facilitiesLines = addSubtypeTotals(facilitiesLines, 'Other');
			eescLines = addSubtypeTotals(eescLines, 'Other');
			GALines = addSubtypeTotals(GALines, 'Other');
		}

		grossMargin.sumUpLines(revenueTotal);
		grossMargin.subtractLines(COGSTotal);
		grossMarginPercent.sumUpLines(revenueTotal);
		grossMarginPercent.setPercent(grossMargin);
		grossMarginPercent.formatStyle = 'percent';
		grossMarginPercent.styleClass = 'green';
		[fringeTotal, overheadTotal, facilitiesTotal, eescTotal, GATotal].forEach(rl => indirectExpenseTotal.sumUpLines(rl));
		netOrdinaryTotal.sumUpLines(revenueTotal);
		netOrdinaryTotal.subtractLines(COGSTotal);
		netOrdinaryTotal.subtractLines(indirectExpenseTotal);
		nonOperatingOtherIncomeExpenseTotal.sumUpLines(nonOperatingIncomeTotal);
		nonOperatingOtherIncomeExpenseTotal.subtractLines(nonOperatingExpenseTotal);
		netProfit.sumUpLines(netOrdinaryTotal);
		netProfit.sumUpLines(nonOperatingOtherIncomeExpenseTotal);

		netIncomePercent.formatStyle = 'percent';
		netIncomePercent.styleClass = 'green';
		netIncomePercent.sumUpLines(revenueTotal);
		netIncomePercent.setPercent(netProfit);

		const split = () => new ReportLine(' ', null, true);
		const addHeader = (label, isWrapper) => new ReportLine(label, 'totalLine', true, isWrapper);
		return [
			addHeader('Revenue', true),
			...revenueLines,
			revenueTotal,

			split(),
			addHeader('Cost of Goods Sold'),
			...COGSLines,
			COGSTotal,

			split(),
			grossMargin,
			split(),
			grossMarginPercent,

			split(),
			addHeader('Indirect Expense'),
			addHeader('Indirect Fringes'),
			...fringeLines,
			fringeTotal,

			split(),
			addHeader('Overhead'),
			...overheadLines,
			overheadTotal,

			split(),
			addHeader('Facilities'),
			...facilitiesLines,
			facilitiesTotal,

			split(),
			addHeader('EE Support Center'),
			...eescLines,
			eescTotal,

			split(),
			addHeader('General & Administration'),
			...GALines,
			GATotal,
			indirectExpenseTotal,

			split(),
			netOrdinaryTotal,

			split(),
			addHeader('Non-Operating Other Income & Expense'),
			nonOperatingIncomeTotal,
			nonOperatingExpenseTotal,
			nonOperatingOtherIncomeExpenseTotal,
			split(),

			netProfit,
			netIncomePercent
		]
	} catch (e) {
		_message('error', 'Add subtotals and totals error: ' + e);
		this.showSpinner = false;
	}
};

const addSubtypeTotals = (rLines, defaultTitle) => {
	if (!rLines) return rLines;
	const subtypeMap = {};
	const subtypeTotalRLMap = {};

	rLines.forEach(rl => {
		if (!rl.accountST2) rl.accountST2 = defaultTitle;
		let stGroup = subtypeMap[rl.accountST2];
		if (!stGroup) {
			stGroup = [];
			subtypeMap[rl.accountST2] = stGroup;
			subtypeTotalRLMap[rl.accountST2] = new ReportLine(`Total ${rl.accountST2}`, 'subTotalLine');
		}
		const totalLine = subtypeTotalRLMap[rl.accountST2];
		totalLine.sumUpLines(rl);
		stGroup.push(rl);
	});
	let r = [];
	Object.keys(subtypeMap).forEach(key => {
		const stGroup = subtypeMap[key];
		const totalLine = subtypeTotalRLMap[key];
		r = [...r, ...stGroup, totalLine];
	});
	return r;
};

const sortReportLines = (reportLineSections) => {
	const specialLabels = ["Direct Fringe", "GSA IFF Fee"];
	const isSpecial = label => specialLabels.some(specialLabel => label && label.includes(specialLabel));
	const sortSection = (section) => {
		section.sort((a, b) => {
			const aIsSpecial = isSpecial(a.label);
			const bIsSpecial = isSpecial(b.label);
			if (aIsSpecial && !bIsSpecial) {
				return 1; // a is special, move it to the end
			}
			if (!aIsSpecial && bIsSpecial) {
				return -1; // b is special, move it to the end
			}
			if (a.label < b.label) {
				return -1;
			}
			if (a.label > b.label) {
				return 1;
			}
			return 0;
		});
	};
	reportLineSections.forEach(sortSection);
};

export {
	getPriorPeriodId,
	getBYFirstPeriodId,
	getPriorYearPeriodId,
	convertCubeToReportLine,
	addSubLinesAndTotals,
	setContext
}