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

	async connectedCallback() {
		try {
			this.doInit();

		} catch (e) {
			_message('error', 'GM CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	doInit = async () => {
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

	generateGMReportLines = () => {
		try {
			this.GMReportLines = [];
			const GMReportLinesObj = {};
			const totalGMReportLine = new GMReportLine('TOTAL');
			totalGMReportLine.styleClass = 'totalLine';
			const isYTDMode = this.reportLines.some(rl => rl.currentMonthActualYTD > 5); // true if YTD activated

			this.reportLines.forEach(rl => {
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

			const GMReportLines = Object.values(GMReportLinesObj);
			new GMReportLine().calculateDLFringe(GMReportLines, totalGMReportLine, this.fringesMap);
			GMReportLines.push(totalGMReportLine);
			this.GMReportLines = GMReportLines;
		} catch (e) {
			_message('error', 'Get GM Report Lines Error: ' + JSON.stringify(e));
		}
	};

}