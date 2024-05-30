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

const convertCubeToReportLine = (cube, reportLineMap, dataType) => {
	try {
		const key = getRLKey(cube);
		let reportLine = reportLineMap[key];
		if (!reportLine) {
			reportLine = new ReportLine(key);
			reportLine.type = cube.cb5__CBAccount__r.cb5__CBAccountType__r.Name;
			reportLineMap[key] = reportLine;
		}
		populateNumbers(cube, reportLine, dataType);
	} catch (e) {
		_message('error', 'Convert cube to RL Error: ' + e);
	}
};

const dataMappings = {
	'currentMonthCubes': ['currentActual', 'currentBudget'],
	'priorMonthCubes': ['priorActual', 'priorBudget'],
	'priorYearCubes': ['priorYearActual', 'priorYearBudget'],
	'currentYTDCubes': ['currentYTDActual', 'currentYTDBudget'],
	'priorYTDCubes': ['priorYTDActual', 'priorYTDBudget']
};

const populateNumbers = (cube, reportLine, dataType) => {
	if (dataMappings[dataType]) {
		const [actualField, budgetField] = dataMappings[dataType];
		reportLine[actualField] += +cube.cb5__Actual__c;
		reportLine[budgetField] += +cube.cb5__Budget__c;
	}
};

const getRLKey = (cube) => {
	if (cube.cb5__CBAccount__r.cb5__CBAccountType__r.Name.includes('Rev')) {
		return cube.cb5__CBVariable2__r?.Name.replace(/^\d+\s*-?\s*/, '');
	} else if (cube.CBAccountSubtype2__c.includes('Direct')) {
		return 'Direct Cost';
	} else if (cube.CBAccountSubtype2__c.includes('Fringe')) {
		return 'Fringe';
	} else {
		if (cube.cb5__CBDivision__r.Name === 'Revenue') {
			return cube.cb5__CBVariable2__r?.Name
		} else {
			return cube.cb5__CBDivision__r.Name;
		}
	}
};

const addSubLinesAndTotals = (reportLines) => {
	try {
		const revenueTotal = new ReportLine('Revenue Total', 'totalLine');
		const expenseTotal = new ReportLine('Expense Total', 'totalLine');
		const directCostTotal = new ReportLine('Direct Cost Total', 'totalLine');
		const indirectCostTotal = new ReportLine('Indirect Cost Total', 'totalLine');
		const grossMargin = new ReportLine('Gross Margin', 'totalLine');
		const grossMarginPercent = new ReportLine('Gross %', 'totalLine');
		const ordinaryIncomeLoss = new ReportLine('Ordinary Income/Loss', 'totalLine');
		const netProfit = new ReportLine('Net Profit', 'totalLine');

		const revenueLines = [];
		const directCostLines = [];
		const indirectCosts = [];

		reportLines.forEach(rl => {
			if (rl.type.includes('Rev')) {
				revenueTotal.sumUpLines(rl);
				revenueLines.push(rl);
			} else {
				expenseTotal.sumUpLines(rl);
				if (rl.label === 'Direct Cost' || rl.label === 'Fringe') {
					directCostTotal.sumUpLines(rl);
					directCostLines.push(rl);
				} else {
					indirectCosts.push(rl);
					indirectCostTotal.sumUpLines(rl);
				}
			}
		});

		grossMargin.sumUpLines(revenueTotal);
		grossMargin.subtractLines(directCostTotal);
		grossMarginPercent.sumUpLines(revenueTotal);
		grossMarginPercent.setPercent(grossMargin);
		grossMarginPercent.formatStyle = 'percent';
		grossMarginPercent.styleClass = 'green';
		ordinaryIncomeLoss.sumUpLines(grossMargin);
		ordinaryIncomeLoss.subtractLines(indirectCostTotal);
		netProfit.sumUpLines(revenueTotal);
		netProfit.setPercent(ordinaryIncomeLoss);
		netProfit.formatStyle = 'percent';

		return [
			new ReportLine('Revenue', 'totalLine', true),
			...revenueLines,
			revenueTotal,
			new ReportLine(' ', null, true),
			new ReportLine('Direct Cost'),
			...directCostLines,
			directCostTotal,
			new ReportLine(' ', null, true),
			grossMargin,
			new ReportLine(' ', null, true),
			grossMarginPercent,
			new ReportLine(' ', null, true),
			new ReportLine('Indirect Cost'),
			...indirectCosts,
			new ReportLine(' ', null, true),
			ordinaryIncomeLoss,
			new ReportLine(' ', null, true),
			netProfit
		]
	} catch (e) {
		_message('error', 'Add subtotals and totals error: ' + e);
	}
};


export {getPriorPeriodId, getBYFirstPeriodId, getPriorYearPeriodId, convertCubeToReportLine, addSubLinesAndTotals}