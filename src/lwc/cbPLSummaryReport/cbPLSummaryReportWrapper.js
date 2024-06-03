import {_message} from "c/cbUtils";

const SUM_FIELDS = ['currentMonthActual', 'currentMonthBudget', 'priorMonthActual', 'priorYearActual'];

class ReportLine {
	/**
	 * @param label label of the line
	 * @param sClass style class
	 * @param isSeparator if true no numbers needed
	 */
	constructor(label, sClass, isSeparator) {
		this.label = label;
		this.styleClass = sClass;
		this.isSeparator = isSeparator;
		if (isSeparator) return this;

		this.currentMonthActual = 0;
		this.currentMonthBudget = 0;
		this.currentMonthDiff = 0;
		this.currentMonthDiffPercent = 0;

		this.priorMonthActual = 0;
		this.priorMonthDiff = 0;
		this.priorMonthDiffPercent = 0;

		this.priorYearActual = 0;
		this.priorYearDiff = 0;
		this.priorYearDiffPercent = 0;
	}

	key;
	label;
	styleClass;
	isSeparator = false;
	type;
	account;
	var1;
	var2;
	formatStyle = 'currency';
	ddParams = 'currency';

	currentMonthActual;
	currentMonthBudget;
	currentMonthDiff;
	currentMonthDiffPercent;
	priorMonthActual;
	priorMonthDiff;
	priorMonthDiffPercent;
	priorYearActual;
	priorYearDiff;
	priorYearDiffPercent;

	sumUpLines = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] += +reportLine[f]);
		} catch (e) {
			_message('Sum Up Error : ' + e);
		}
	};

	subtractLines = (reportLine) => {
		try {
			SUM_FIELDS.forEach(f => this[f] -= +reportLine[f]);
		} catch (e) {
			_message('Subtract Error : ' + e);
		}
	};

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
		this.currentMonthDiff = this.currentMonthActual - this.currentMonthBudget;
		this.currentMonthDiffPercent = this.currentMonthBudget ? 1 - this.currentMonthBudget / this.currentMonthActual : 1;
		this.priorMonthDiff = this.currentMonthActual - this.priorMonthActual;
		this.priorMonthDiffPercent = this.priorMonthActual ? 1 - this.priorMonthActual / this.currentMonthActual : 1;
		this.priorYearDiff = this.currentMonthActual - this.priorYearActual;
		this.priorYearDiffPercent = this.priorYearActual ? 1 - this.priorYearActual / this.currentMonthActual : 1;
		this.updateDDInfo();

	};

	updateDDInfo = () => {
		this.ddParams = JSON.stringify({
			account: this.account,
			var1: this.var1,
			var2: this.var2,
			type: this.type
		});
	}
}


export {ReportLine}