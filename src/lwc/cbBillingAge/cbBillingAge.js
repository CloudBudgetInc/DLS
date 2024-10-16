import {LightningElement, track} from 'lwc';
import {_applyDecStyle, _message, _parseServerError} from "c/cbUtils";
import getBillingAgingHistoryDataServer
	from '@salesforce/apex/CBPLSummaryReportPageController.getBillingAgingHistoryDataServer';


export default class CbBillingAge extends LightningElement {

	@track tableIsReadyToRender = false;
	@track billHistories = [];
	@track reportLines = [];
	@track message = '';
	@track ASPeriodId;
	ages = ['0-Current', '1-30 Days', '31-60 Days', '61-90 Days', 'Over 90 Days', 'Total'];

	async connectedCallback() {
		_applyDecStyle();
		try {
			this.setDefaultFilters();
			this.doInit();
		} catch (e) {
			_message('error', 'GM CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	setDefaultFilters = () => {
		const ASPeriodId = localStorage.getItem('ASPeriodId');
		if(ASPeriodId) this.ASPeriodId = ASPeriodId;
	};

	doInit = async () => {
		this.tableIsReadyToRender = false;
		this.reportLines = [];
		this.message = '';
		if(!this.ASPeriodId) {
			alert('Please select an Accounting Period to run report');
			return null;
		}
		this.billHistories = await getBillingAgingHistoryDataServer({ASPeriodId: this.ASPeriodId}).catch(e => _parseServerError('Get billHistories Error: ', e));
		let tableDataObject = {};
		this.billHistories.forEach(b => {
			try {
				const age = b.AcctSeed__Age__c;
				const value = b.AcctSeed__Amount__c;
				let rLine = tableDataObject[b.AcctSeed__Billing__r.AcctSeed__Customer__r.Name];
				if (!rLine) {
					rLine = {};
					this.ages.forEach(a => rLine[a] = {val: 0, formatting: 'currency'});
					rLine['Total'].styleClass = 'total';
					tableDataObject[b.AcctSeed__Billing__r.AcctSeed__Customer__r.Name] = rLine;
				}
				rLine[age].val += +(value.toFixed(0));
				rLine['Total'].val += +(value.toFixed(0));
			} catch (e) {
				_message('error', 'Iteration Error: ' + JSON.stringify(e));
			}
		});

		Object.keys(tableDataObject).forEach(key => {
			let rLine = tableDataObject[key];
			this.reportLines.push({label: key, values: Object.values(rLine)});
		});
		this.addBottomTotalAndPercentLine();

		this.tableIsReadyToRender = true;
	};

	addBottomTotalAndPercentLine = () => {
		if (!this.reportLines || this.reportLines.length === 0) return null;
		try {
			const bottomTotalLine = JSON.parse(JSON.stringify(this.reportLines[0]));
			const bottomPercentLine = JSON.parse(JSON.stringify(this.reportLines[0]));
			bottomTotalLine.label = 'Total';
			bottomPercentLine.label = 'Percent';
			bottomTotalLine.lineStyleClass = 'totalLine';
			bottomTotalLine.lineStyleClass = 'totalLine';
			bottomTotalLine.values.forEach(item => {
				item.styleClass = 'total totalLine';
				item.val = 0;
			});
			this.reportLines.forEach(rl => {
				rl.values.forEach((item, idx) => bottomTotalLine.values[idx].val += item.val)
			});

			const globalTotal = bottomTotalLine.values[bottomTotalLine.values.length - 1].val;
			bottomTotalLine.values.forEach((item, idx) => {
				bottomPercentLine.values[idx].val = (item.val / globalTotal);
				bottomPercentLine.values[idx].formatting = 'percent';
			});
			this.reportLines.push(bottomTotalLine);
			this.reportLines.push(bottomPercentLine);
			this.message = (bottomPercentLine.values[0].val * 100 + bottomPercentLine.values[1].val * 100).toFixed(1) + '% of our AR is 60 days or earlier '
		} catch (e) {
			_message('error', 'Add Total Lines Error : ' + e);
		}

	};

	handleChangeMainFilter = (event) => {
		if (!event.target.value) return null;
		this.ASPeriodId = event.target.value;
		localStorage.setItem('ASPeriodId', this.ASPeriodId);
		this.doInit().then(() => null);
	}
}