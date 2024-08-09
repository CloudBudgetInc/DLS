import {api, LightningElement, track} from 'lwc';
import {_message, _parseServerError} from "c/cbUtils";
import getFringePercentServer from '@salesforce/apex/CBPLSummaryReportPageController.getFringePercentServer';
import {GMReportLine} from "./cbPLSummaryGrossMarginWrapper";

export default class CbPLSummaryGrossMargin extends LightningElement {

	@api selectedPeriodId;
	@api reportLines;
	@track fringesMap;
	@track GMReportLines;
	@track actualFringeTotal;
	@track budgetFringeTotal;
	@track splitLT = false;
	@track renderAllColumns = true;

	async connectedCallback() {
		try {
			this.doInit();
		} catch (e) {
			_message('error', 'GM CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	doInit = async () => {
		this.GMReportLines = [];
		await this.getGetFringePercent().then(r => null);
		console.log('Gross Margin CMP');
		console.log('selectedPeriodId = ' + this.selectedPeriodId);
		console.log('reportLines = ' + JSON.stringify(this.reportLines));
		console.log('fringesMap = ' + this.fringesMap);
		this.generateGMReportLines();
		console.log('GMReportLines = ' + this.GMReportLines);
	};

	getGetFringePercent = async () => {
		this.fringesMap = await getFringePercentServer({periodsId: this.selectedPeriodId}).catch(e => _parseServerError('Fringe Error: ', e));
	};

	///////////
	generateGMReportLines = () => {
		try {
			this.GMReportLines = [];
			const GMReportLinesObj = {};
			const totalGMReportLine = this.createGMReportLine('TOTAL', 'totalLine');
			const isYTDMode = this.isYTDMode(this.reportLines);
			this.processReportLines(this.reportLines, GMReportLinesObj, isYTDMode, totalGMReportLine);
			let GMReportLines = Object.values(GMReportLinesObj);
			if (this.splitLT) {
				GMReportLines = this.handleSplitLT(GMReportLines, totalGMReportLine);
			} else {
				new GMReportLine().calculateDLFringe(GMReportLines, totalGMReportLine, this.fringesMap);
				GMReportLines.push(totalGMReportLine);
			}
			this.GMReportLines = GMReportLines;
		} catch (e) {
			_message('error', 'Get GM Report Lines Error: ' + JSON.stringify(e));
		}
	};

// 1. Initialization Helper
	createGMReportLine = (label, styleClass = '') => {
		const line = new GMReportLine(label);
		if (styleClass) line.styleClass = styleClass;
		return line;
	};

	isYTDMode = (reportLines) => reportLines.some(rl => rl.currentMonthActualYTD > 5);

	processReportLines = (reportLines, GMReportLinesObj, isYTDMode, totalGMReportLine) => {
		reportLines.forEach(rl => {
			if (rl.label === 'Direct Fringe') {
				totalGMReportLine.actualDLFringe = rl.currentMonthActual;
				totalGMReportLine.budgetDLFringe = rl.currentMonthBudget;
				return;
			}
			if (rl.type !== 'Revenue' && rl.type !== 'COGS') return;

			if (!GMReportLinesObj[rl.label]) {
				GMReportLinesObj[rl.label] = new GMReportLine(rl.label);
			}

			const GMRL = GMReportLinesObj[rl.label];
			if (rl.type === 'Revenue') {
				GMRL.actualRevenue += isYTDMode ? rl.currentMonthActualYTD : rl.currentMonthActual;
				GMRL.budgetRevenue += isYTDMode ? rl.currentMonthBudgetYTD : rl.currentMonthBudget;
			} else if (rl.type === 'COGS') {
				GMRL.actualExpense += isYTDMode ? rl.currentMonthActualYTD : rl.currentMonthActual;
				GMRL.budgetExpense += isYTDMode ? rl.currentMonthBudgetYTD : rl.currentMonthBudget;
			}
		});
	};

	/**
	 * Method splits the data to LT and all another part to separate the report
	 * @param GMReportLines
	 * @param totalGMReportLine
	 * @return {*[]}
	 */
	handleSplitLT = (GMReportLines, totalGMReportLine) => {
		const LTVar2 = [];
		const otherVar2 = [];

		GMReportLines.forEach(rl => {
			if (rl.label.includes('LT')) {
				LTVar2.push(rl);
			} else {
				otherVar2.push(rl);
			}
		});

		const LTTotalGMReportLine = this.createGMReportLine('LT TOTAL', 'totalLine');
		LTTotalGMReportLine.actualDLFringe = totalGMReportLine.actualDLFringe;
		LTTotalGMReportLine.budgetDLFringe = totalGMReportLine.budgetDLFringe;

		const otherTotalGMReportLine = this.createGMReportLine('OTHER TOTAL', 'totalLine');
		otherTotalGMReportLine.actualDLFringe = totalGMReportLine.actualDLFringe;
		otherTotalGMReportLine.budgetDLFringe = totalGMReportLine.budgetDLFringe;

		new GMReportLine().calculateDLFringe(LTVar2, LTTotalGMReportLine, this.fringesMap);
		new GMReportLine().calculateDLFringe(otherVar2, otherTotalGMReportLine, this.fringesMap);

		return [...LTVar2, LTTotalGMReportLine, ...otherVar2, otherTotalGMReportLine];
	};
	///////////

	handleToggle = (event) => {
		this[event.target.name] = event.target.checked;
		this.doInit();
	};

}