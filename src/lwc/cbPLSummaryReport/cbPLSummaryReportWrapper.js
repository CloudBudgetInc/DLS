import {_message} from "c/cbUtils";

const SUM_FIELDS = ['currentActual', 'currentBudget', 'priorActual', 'priorBudget', 'priorYearActual', 'priorYearBudget'];

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
	isSeparator = false;
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
		this.currentDiffActual = this.currentActual - this.priorActual;
		this.currentDiffBudget = this.currentBudget - this.priorBudget;

		this.currentDiffPercentActual = this.priorActual ? this.currentActual / this.priorActual : 0;
		this.currentDiffPercentBudget = this.priorBudget ? this.currentBudget / this.priorBudget : 0;
	}
}

export {ReportLine}