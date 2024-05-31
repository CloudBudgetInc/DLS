import {_message} from "c/cbUtils";
import {ReportLine} from "./cbPLSummaryReportWrapper";

/**
 * @param selectedPeriodId
 * @param periodSO
 * @return previous period Id
 */
const getPriorPeriodId = (selectedPeriodId, periodSO) => {
	const currentPeriodIndex = periodSO.findIndex(p => p.value === selectedPeriodId);
	return periodSO[currentPeriodIndex - 1].value;
};
/**
 * @param selectedPeriodId
 * @param periodSO
 * @return the first period of the budget year
 */
const getBYFirstPeriodId = (selectedPeriodId, periodSO) => {
	const currentPeriod = periodSO.find(p => p.value === selectedPeriodId);
	for (let i = 0; i < periodSO.length; i++) {
		if (periodSO[i].byId === currentPeriod.byId) return periodSO[i].value;
	}
};
/**
 * @param selectedPeriodId
 * @param periodSO
 * @return CB PeriodId of the previous budget year. One year back
 */
const getPriorYearPeriodId = (selectedPeriodId, periodSO) => {
	const currentPeriodIndex = periodSO.findIndex(p => p.value === selectedPeriodId);
	return periodSO[currentPeriodIndex - 12].value;
};

/**
 *
 * @param cube source cube
 * @param reportLineMap object where key is RLKey, value is reportLine
 * @param dataType
 */
const convertCubeToReportLine = (cube, reportLineMap, dataType) => {
	try {
		const {label, type} = getLabelAndType(cube);
		const key = label + type;
		let reportLine = reportLineMap[key];
		if (!reportLine) {
			reportLine = new ReportLine(label);
			reportLine.type = type;
			reportLineMap[key] = reportLine;
		}
		populateNumbers(cube, reportLine, dataType);
	} catch (e) {
		_message('error', 'Convert cube to RL Error: ' + e);
	}
};

const dataMappings = {
	'currentMonthCubes': ['currentMonthActual', 'currentMonthBudget'],
	'priorMonthCubes': ['priorMonthActual', null],
	'priorYearCubes': ['priorYearActual', null]
};

const populateNumbers = (cube, reportLine, dataType) => {
	if (dataMappings[dataType]) {
		const [actualField, budgetField] = dataMappings[dataType];
		reportLine[actualField] += +cube.cb5__Actual__c;
		if (budgetField) reportLine[budgetField] += +cube.cb5__Budget__c;
	}
};

/**
 * The main method to split data between sections
 */
const getLabelAndType = (cube) => {
	if (cube.cb5__CBVariable2__c) {
		if (cube.cb5__CBAccount__r.Name.startsWith('4')) {
			return {label: cube.cb5__CBVariable2__r.Name, type: 'Revenue'};
		}
		if (cube.cb5__CBAccount__r.Name.startsWith('5')) {
			return {label: cube.cb5__CBVariable2__r.Name, type: 'COGS'};
		}
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
		return {label: cube.CBAccountSubtype2__c, type: cube.cb5__AccSubType__c};
	}
	return {label: 'Other', type: 'Other'};
};

const addSubLinesAndTotals = (reportLines) => {
	try {
		const revenueTotal = new ReportLine('Total Revenue', 'totalLine');
		const COGSTotal = new ReportLine('Total Cost of Goods Sold', 'totalLine');
		const grossMargin = new ReportLine('Gross Margin', 'totalLine');
		const grossMarginPercent = new ReportLine('Gross %', 'totalLine');
		const fringeTotal = new ReportLine('Total Indirect Fringes', 'totalLine');
		const overheadTotal = new ReportLine('Total Overhead', 'totalLine');
		const facilitiesTotal = new ReportLine('Total Facilities', 'totalLine');
		const eescTotal = new ReportLine('Total EE Support Center', 'totalLine');
		const GATotal = new ReportLine('Total General & Administration', 'totalLine');
		const indirectExpenseTotal = new ReportLine('Total Indirect Expense', 'totalLine');
		const netOrdinaryTotal = new ReportLine('Net Ordinary Income', 'totalLine');
		const nonOperatingIncomeTotal = new ReportLine('Non-Operating Income');
		const nonOperatingExpenseTotal = new ReportLine('Non-Operating Expenses');
		const nonOperatingOtherIncomeExpenseTotal = new ReportLine('Total Non-Operating Other Income & Expense', 'totalLine');
		const netProfit = new ReportLine('Net Profit', 'totalLine');

		const revenueLines = [];
		const COGSLines = [];
		const fringeLines = [];
		const overheadLines = [];
		const facilitiesLines = [];
		const eescLines = [];
		const GALines = [];

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

		grossMargin.sumUpLines(revenueTotal);
		grossMargin.subtractLines(COGSTotal);
		grossMarginPercent.sumUpLines(revenueTotal);
		grossMarginPercent.setPercent(grossMargin);
		grossMarginPercent.formatStyle = 'percent';
		grossMarginPercent.styleClass = 'green';
		[fringeTotal, overheadTotal, facilitiesTotal, eescTotal, GATotal].forEach(rl => indirectExpenseTotal.sumUpLines(rl));
		netOrdinaryTotal.sumUpLines(grossMargin);
		netOrdinaryTotal.subtractLines(indirectExpenseTotal);
		nonOperatingOtherIncomeExpenseTotal.sumUpLines(nonOperatingIncomeTotal);
		nonOperatingOtherIncomeExpenseTotal.subtractLines(nonOperatingExpenseTotal);
		netProfit.sumUpLines(netOrdinaryTotal);
		netProfit.sumUpLines(nonOperatingOtherIncomeExpenseTotal);

		const split = () => new ReportLine(' ', null, true);
		const addHeader = (label) => new ReportLine(label, 'totalLine', true);
		return [
			addHeader('Revenue'),
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

			netProfit
		]
	} catch (e) {
		_message('error', 'Add subtotals and totals error: ' + e);
	}
};


export {getPriorPeriodId, getBYFirstPeriodId, getPriorYearPeriodId, convertCubeToReportLine, addSubLinesAndTotals}