import {_message} from "c/cbUtils";

const SUM_FIELDS = ['currentMonthActual', 'currentMonthBudget', 'priorMonthActual', 'priorYearActual', 'currentMonthActualYTD', 'currentMonthBudgetYTD', 'priorYearActualYTD'];

class ReportLine {
	/**
	 * @param label label of the line
	 * @param sClass style class
	 * @param isSeparator if true no numbers needed
	 * @param isWrapper
	 */
	constructor(label, sClass, isSeparator, isWrapper) {
		this.label = label;
		this.styleClass = sClass;
		this.isSeparator = isSeparator;
		if (isWrapper) this.isWrapper = true;
		if (isSeparator) return this;

		this.currentMonthActual = 0;
		this.currentMonthBudget = 0;
		this.currentMonthDiff = 0;
		this.currentMonthDiffPercent = 0;
		this.currentMonthDiffPercentX100 = 0;

		this.priorMonthActual = 0;
		this.priorMonthBudget = 0;// new field
		this.priorMonthDiff = 0;
		this.priorMonthDiffPercent = 0;

		this.priorYearActual = 0;
		this.priorYearBudget = 0; // new field
		this.priorYearDiff = 0;
		this.priorYearDiffPercent = 0;

		this.currentMonthActualYTD = 0;
		this.currentMonthBudgetYTD = 0;
		this.currentMonthDiffYTD = 0;
		this.currentMonthDiffPercentYTD = 0;
		this.priorYearActualYTD = 0;
		this.priorYearDiffYTD = 0;
		this.priorYearDiffPercentYTD = 0;
	}

	key;
	label;
	styleClass;
	isSeparator = false;
	type;
	account;
	accountST2;
	var1;
	var2;
	formatStyle = 'currency';
	ddParams = 'currency';
	isWrapper = false;

	currentMonthActual;
	currentMonthBudget;
	currentMonthDiff;
	currentMonthDiffPercent;
	currentMonthDiffPercentX100;
	priorMonthActual;
	priorMonthBudget;
	priorMonthDiff;
	priorMonthDiffPercent;
	priorYearActual;
	priorYearBudget;
	priorYearDiff;
	priorYearDiffPercent;

	currentMonthActualYTD;
	currentMonthBudgetYTD;
	currentMonthDiffYTD;
	currentMonthDiffPercentYTD;
	priorYearActualYTD;
	priorYearDiffYTD;
	priorYearDiffPercentYTD;

	/**
	 * The method takes a report line and add amounts to the internal values
	 * @param reportLine
	 */
	sumUpLines = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] += +reportLine[f]);
		} catch (e) {
			_message('Sum Up Error : ' + e);
		}
	};
	/**
	 * The method takes a report line and subtract amounts from the internal values
	 * @param reportLine
	 */
	subtractLines = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] -= +reportLine[f]);
		} catch (e) {
			_message('Subtract Error : ' + e);
		}
	};
	/**
	 * The method takes a report line and calculates percents form the current amounts
	 * @param reportLine
	 */
	setPercent = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] = this[f] ? (reportLine[f] / this[f]) : 1);
		} catch (e) {
			_message('Set Percent Error : ' + e);
		}
	};

	/**
	 * Method calculates formula amounts
	 */
	normalizeReportLine = () => {
		if (this.isSeparator) return null;
		//// Current
		this.currentMonthDiff = this.currentMonthActual - this.currentMonthBudget;
		this.currentMonthDiffPercent = this.currentMonthActual ? 1 - this.currentMonthBudget / this.currentMonthActual : 1;
		this.priorMonthDiff = this.currentMonthActual - this.priorMonthActual;
		this.priorMonthDiffPercent = this.priorMonthActual ? 1 - this.priorMonthActual / this.currentMonthActual : 1;
		this.priorYearDiff = this.currentMonthActual - this.priorYearActual;
		this.priorYearDiffPercent = this.currentMonthActual ? this.priorYearDiff / this.currentMonthActual : 0;
		//// YTD
		this.currentMonthDiffYTD = this.currentMonthActualYTD - this.currentMonthBudgetYTD;
		this.currentMonthDiffPercentYTD = this.currentMonthActualYTD ? 1 - this.currentMonthBudgetYTD / this.currentMonthActualYTD : 1;
		this.priorYearDiffYTD = this.currentMonthActualYTD - this.priorYearActualYTD;
		this.priorYearDiffPercentYTD = this.priorYearActualYTD ? this.priorYearDiffYTD / this.priorYearActualYTD : 0;
		this.currentMonthDiffPercentX100 = this.currentMonthDiffPercent * 100;
		this.roundNumericFields(this);
		this.updateDDInfo();
	};

	roundNumericFields = (obj) => {
		for (let key in obj) {
			if (obj.hasOwnProperty(key)) {
				// Check if the field value is a number
				if (typeof obj[key] === 'number') {
					if (obj[key] >= 1) {
						// Round to 2 decimal places for numbers >= 1
						obj[key] = Math.round((obj[key] + Number.EPSILON) * 100) / 100;
					} else if (obj[key] < 1) {
						// Round to 4 decimal places for numbers < 1
						obj[key] = Math.round((obj[key] + Number.EPSILON) * 1000) / 1000;
					}
				}
			}
		}
	};

	updateDDInfo = () => {
		this.ddParams = JSON.stringify({
			account: this.account,
			var1: this.var1,
			var2: this.var2,
			type: this.type,
			label: this.label
		});
	}
}


export {ReportLine}