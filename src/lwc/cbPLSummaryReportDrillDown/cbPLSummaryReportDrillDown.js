import {api, LightningElement, track} from 'lwc';
import getDDRecordsServer from '@salesforce/apex/CBPLSummaryReportPageController.getDDRecordsServer';
import {_parseServerError} from "c/cbUtils";

export default class CbPLSummaryReportDrillDown extends LightningElement {
	@api ddParams;
	@api closeFunction;
	@track ddResult = {BLAmounts: [], ASCubes: []};

	async connectedCallback() {
		await this.loadSourceData();
	}

	loadSourceData = async () => {
		const ddResult = await getDDRecordsServer({ddIds: JSON.parse(this.ddParams)}).catch(e => _parseServerError('Get DD Info EError', e));

		const budgetTotal = {cb5__CBBudgetLine__r: {Name: 'TOTAL'}, cb5__Value__c: 0, styleClass: 'total'};
		ddResult.BLAmounts.forEach(a => {
			a.link = '/' + a.cb5__CBBudgetLine__c;
			budgetTotal.cb5__Value__c += +a.cb5__Value__c;
		});
		ddResult.BLAmounts.push(budgetTotal);

		const actualTotal = {Name: 'TOTAL', AcctSeed__MTD_Actual_P_L__c: 0, styleClass: 'total'};
		ddResult.accSeedCubes.forEach(a => {
			a.link = '/' + a.Id;
			actualTotal.AcctSeed__MTD_Actual_P_L__c += +a.AcctSeed__MTD_Actual_P_L__c;
		});
		ddResult.accSeedCubes.push(actualTotal);

		this.ddResult = ddResult;
	};

	closeDD = () => {
		this.closeFunction();
	}
}