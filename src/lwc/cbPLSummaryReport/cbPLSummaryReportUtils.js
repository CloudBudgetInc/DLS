const getPriorPeriodId = (selectedPeriodId, periodSO) => {
	const currentPeriodIndex = periodSO.findIndex(p => p.value === selectedPeriodId);
	return periodSO[currentPeriodIndex - 1].value;
};

const getBYFirstPeriodId = (selectedPeriodId, periodSO) => {
	const currentPeriod = periodSO.find(p => p.value === selectedPeriodId);
	for (let i = 0; i < periodSO.length; i++) {
		if (periodSO[i].byId === currentPeriod.byId) return periodSO[i].value;
	}
};

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
		alert('Convert cube to RL Error: ' + e);
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
		return cube.cb5__CBAccount__r.Name.replace(/^\d+\s*-?\s*/, '');
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
			new ReportLineSeparator('Revenue'),
			...revenueLines,
			revenueTotal,
			new ReportLineSeparator(' '),
			new ReportLineSeparator('Direct Cost'),
			...directCostLines,
			directCostTotal,
			new ReportLineSeparator(' '),
			grossMargin,
			new ReportLineSeparator(' '),
			grossMarginPercent,
			new ReportLineSeparator(' '),
			new ReportLineSeparator('Indirect Cost'),
			...indirectCosts,
			new ReportLineSeparator(' '),
			ordinaryIncomeLoss,
			new ReportLineSeparator(' '),
			netProfit
		]
	} catch (e) {
		alert('Add subtotals and totals error: ' + e);
	}
};

const SUM_FIELDS = ['currentActual', 'currentBudget', 'priorActual', 'priorBudget', 'priorYearActual', 'priorYearBudget'];

class ReportLine {
	constructor(label, sClass) {
		this.label = label;
		this.styleClass = sClass;

		this.currentActual = 0;
		this.currentBudget = 0;

		this.priorActual = 0;
		this.priorBudget = 0;

		this.priorYearActual = 0;
		this.priorYearBudget = 0;

		this.priorYearDiffActual = 0;
		this.priorYearDiffBudget = 0;

		this.priorYearDiffPercentActual = 0;
		this.priorYearDiffPercentBudget = 0;

		this.currentYTDActual = 0;
		this.currentYTDBudget = 0;

		this.priorYTDActual = 0;
		this.priorYTDBudget = 0;
	}

	key;
	label;
	styleClass;
	type;
	formatStyle = 'currency';

	currentActual;
	currentBudget;

	priorActual;
	priorBudget;

	currentDiffActual;
	currentDiffBudget;

	currentDiffPercentActual;
	currentDiffPercentBudget;

	priorYearActual;
	priorYearBudget;

	priorYearDiffActual;
	priorYearDiffBudget;

	priorYearDiffPercentActual;
	priorYearDiffPercentBudget;

	currentYTDActual;
	currentYTDBudget;

	priorYTDActual;
	priorYTDBudget;

	sumUpLines = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] += +reportLine[f]);
		} catch (e) {
			alert('Sum Up Error : ' + e);
		}
	};

	subtractLines = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] -= +reportLine[f]);
		} catch (e) {
			alert('Subtract Error : ' + e);
		}
	};

	setPercent = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] = this[f] ? (reportLine[f] / this[f]) : 1);
		} catch (e) {
			alert('Set Percent Error : ' + e);
		}
	};

	normalizeReportLine = () => {
		this.currentDiffActual = this.currentActual - this.priorActual;
		this.currentDiffBudget = this.currentBudget - this.priorBudget;

		this.currentDiffPercentActual = this.priorActual ? this.currentActual / this.priorActual : 0;
		this.currentDiffPercentBudget = this.priorBudget ? this.currentBudget / this.priorBudget : 0;
	}
}

class ReportLineSeparator {
	constructor(label) {
		this.label = label;
	}

	label = '   ';
	styleClass = 'separator';
	normalizeReportLine = () => {
	}
}

export {getPriorPeriodId, getBYFirstPeriodId, getPriorYearPeriodId, convertCubeToReportLine, addSubLinesAndTotals}