import {api, LightningElement, track} from 'lwc';
import {_message, _parseServerError} from "c/cbUtils";
import getGetFringePercentServer from '@salesforce/apex/CBPLSummaryReportPageController.getGetFringePercentServer';
import {GMReportLine} from "./cbPLSummaryGrossMarginWrapper";

export default class CbPLSummaryGrossMargin extends LightningElement {

	@api selectedPeriodId;
	@api reportLines;
	@track fringes;
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
		console.log('Fringes = ' + this.fringes);
		this.generateGMReportLines();
		console.log('GMReportLines = ' + this.GMReportLines);

	};

	getGetFringePercent = async () => {
		this.fringes = await getGetFringePercentServer().catch(e => _parseServerError('Fringe Error: ', e));
	};

	generateGMReportLines = () => {
		try {
			this.GMReportLines = [];
			const GMReportLinesObj = {};
			const totalGMReportLine = new GMReportLine('TOTAL');
			totalGMReportLine.styleClass = 'totalLine';
			this.reportLines.forEach(rl => {
				try {
					if (rl.label === 'Direct Fringe') {
						totalGMReportLine.actualDLFringe = rl.currentMonthActual;
						totalGMReportLine.budgetDLFringe = rl.currentMonthBudget;
						return null;
					}
					if (rl.type === 'Revenue' || rl.type === 'COGS') {
						let GMRL = GMReportLinesObj[rl.label];
						if (!GMRL) {
							GMRL = new GMReportLine(rl.label);
							GMReportLinesObj[rl.label] = GMRL;
						}
						if (rl.type === 'Revenue') {
							GMRL.actualRevenue += rl.currentMonthActual;
							GMRL.budgetRevenue += rl.currentMonthBudget;
						}
						if (rl.type === 'COGS') {
							GMRL.actualExpense += rl.currentMonthActual;
							GMRL.budgetExpense += rl.currentMonthBudget;
						}
					}
				} catch (e) {
					_message('error', 'Gen GM Error : ' + JSON.stringify(e))
				}
			});
			const GMReportLines = Object.values(GMReportLinesObj);
			new GMReportLine().calculateDLFringe(GMReportLines, totalGMReportLine);
			GMReportLines.push(totalGMReportLine);
			this.GMReportLines = GMReportLines;
		} catch (e) {
			_message('error', 'Get GM Report Lines Error : ' + JSON.stringify(e));
		}
	};


}