import {LightningElement, track} from 'lwc';
import {_applyDecStyle, _message, _parseServerError} from "c/cbUtils";
import getWageReportDataServer from '@salesforce/apex/CBPLSummaryReportPageController.getWageReportDataServer';


export default class CbAverageWageReport extends LightningElement {

	@track tableIsReadyToRender = false;
	@track wageData = [];
	@track reportLines = [];
	@track message = '';
	@track ASPeriodId;
	@track showSpinner = false;

	async connectedCallback() {
		_applyDecStyle();
		try {
			this.showSpinner = true;
			this.setDefaultFilters();
			this.doInit();
		} catch (e) {
			_message('error', 'GM CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	setDefaultFilters = () => {
		const ASPeriodId = localStorage.getItem('ASPeriodId');
		if (ASPeriodId) this.ASPeriodId = ASPeriodId;
	};

	doInit = async () => {
		this.showSpinner = true;
		this.tableIsReadyToRender = false;
		this.reportLines = [];
		this.message = '';
		if (!this.ASPeriodId) {
			alert('Please select an Accounting Period to run report');
			this.showSpinner = false;
			return null;
		}
		this.wageData = await getWageReportDataServer({ASPeriodId: this.ASPeriodId}).catch(e => _parseServerError('Get Wage Data Error: ', e));
		this.wageData.forEach(wd => {
			try {
				console.log('wd : ' + JSON.stringify(wd));
				const reportLine = {
					label: wd.label,
					amount: wd.amount,
					hours: wd.hours,
					rate: wd.rate,
				};
				console.log('ReportLine : ' + JSON.stringify(reportLine));
				this.reportLines.push(reportLine);
			} catch (e) {
				_message('error', 'Iteration Error: ' + JSON.stringify(e));
			}
		});
		this.tableIsReadyToRender = true;
		this.showSpinner = false;
	};

	handleChangeMainFilter = (event) => {
		if (!event.target.value) return null;
		this.ASPeriodId = event.target.value;
		localStorage.setItem('ASPeriodId', this.ASPeriodId);
		this.doInit().then(() => null);
	}
}