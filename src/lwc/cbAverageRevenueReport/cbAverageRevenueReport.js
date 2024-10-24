import {LightningElement, track} from 'lwc';
import {_applyDecStyle, _message, _parseServerError} from "c/cbUtils";
import getGSAReportingJEServer from '@salesforce/apex/CBPLSummaryReportPageController.getGSAReportingJEServer';
import getReportConfigsServer from '@salesforce/apex/CBPLSummaryReportPageController.getReportConfigsServer';
import getProjectMapServer from '@salesforce/apex/CBPLSummaryReportPageController.getProjectMapServer';


export default class CbAverageRevenueReport extends LightningElement {

	@track tableIsReadyToRender = false;
	@track configs = [];
	@track configSO = [];
	@track projectMap;
	@track selectedConfig;
	@track revenueData = [];
	@track reportLinesGeneral = [];
	@track message = '';
	@track ASPeriodId;
	@track onlyTotals = true;
	@track showSpinner = false;

	async connectedCallback() {
		_applyDecStyle();
		try {
			this.showSpinner = true;
			await this.getProjectMap();
			await this.getReportConfigs();
			this.setDefaultFilters();
			this.doInit();
		} catch (e) {
			_message('error', 'GM CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	getProjectMap = async () => {
		this.projectMap = await getProjectMapServer();
	};

	getReportConfigs = async () => {
		this.configs = await getReportConfigsServer().catch(e => _parseServerError('Get Configs Error: ', e));
		this.selectedConfig = this.configs[0].Name;
		this.configs.forEach(c => {
			this.configSO.push({label: c.Name, value: c.Name});
		});
	};

	setDefaultFilters = () => {
		const ASPeriodId = localStorage.getItem('ASPeriodId');
		if (ASPeriodId) this.ASPeriodId = ASPeriodId;
	};

	doInit = async () => {
		this.showSpinner = true;
		this.tableIsReadyToRender = false;
		this.reportLinesGeneral = [];
		this.message = '';
		if (!this.ASPeriodId) {
			alert('Please select an Accounting Period to run report');
			return null;
		}
		this.revenueData = await getGSAReportingJEServer({ASPeriodId: this.ASPeriodId}).catch(e => _parseServerError('Get Revenue Data Error: ', e));
		console.log('this.revenueData  = ' + JSON.stringify(this.revenueData));
		this.processRevenueData();
		if (this.onlyTotals) {
			this.reportLinesGeneral = this.reportLinesGeneral.filter(rl => rl.lineStyleClass);
		}
		this.tableIsReadyToRender = true;
		this.showSpinner = false;
	};

	processRevenueData = () => {
		console.log(' processRevenueData ');
		let config = this.configs.find(c => c.Name === this.selectedConfig);
		console.log('config = ' + JSON.stringify(config));
		try {
			config = JSON.parse(config.cb5__Details__c);
		} catch (e) {
			_message('error', 'Configuration Conversion Error : ' + e);
		}
		console.log('config = ' + JSON.stringify(config));
		const groupByContract = config.groupByContract;
		this.reportLinesGeneral = [];
		const reportLinesObject = {};
		this.revenueData.forEach(rl => {
			if(rl.var2Name === 'LT - DLI-W PS') {
				console.log('RL :' + rl.var1Name);
			}
			if (this.reportLineIsOutOfFilter(rl, config)) {
				console.log('OMITED: ' + JSON.stringify(rl));
				return null;
			}
			if (rl.contractNo) rl.contractNo = rl.contractNo.slice(0, 13);
			const key = groupByContract ? rl.contractNo : rl.var2Name;
			rl.label = key;
			rl.title = 'Var2:"' + rl.var2Name + '"  Var1:"' + rl.var1Name + '"  Acc:"' + rl.accountName + (rl.contractNo ? '"  Contract:"' + rl.contractNo : '"') + '"  Project:"' + this.projectMap[rl.projectId] + '"';
			let rowArray = reportLinesObject[key];
			if (!rowArray) {
				rowArray = [];
				reportLinesObject[key] = rowArray;
			}
			rowArray.push(rl);
		});
		Object.values(reportLinesObject).forEach(rowArray => {
			let totalAmount = 0;
			let totalHours = 0;
			let grossTotalHours = 0;
			let label = '';
			rowArray.forEach(line => {
				totalAmount += +line.amount;
				totalHours += +line.hours;
				grossTotalHours += line.amount * line.hours;
				label = line.label;
				this.reportLinesGeneral.push(line);
			});
			const averageRow = {
				label,
				amount: totalAmount,
				rate: grossTotalHours / totalAmount,
				hours: totalHours,
				lineStyleClass: 'total'
			};
			this.reportLinesGeneral.push(averageRow);
		});
	};

	/**
	 * The method takes function configuration and filter data by this config
	 */
	reportLineIsOutOfFilter = (rl, config) => {
		const {var2Name, var1Name, accountName, var2NameEqual, var1NameEqual, accountNameEqual} = config;
		const isOutOfFilter = (filterArray, value, isEqual) => {
			if (filterArray && filterArray.length > 0) {
				return isEqual ? !filterArray.includes(value) : filterArray.includes(value);
			}
			return false;
		};
		if (isOutOfFilter(var2Name, rl.var2Name, var2NameEqual)) return true;
		if (isOutOfFilter(var1Name, rl.var1Name, var1NameEqual)) return true;
		if (isOutOfFilter(accountName, rl.accountName, accountNameEqual)) return true;
		return false;
	};

	handleChangeMainFilter = (event) => {
		if (!event.target.value) return null;
		if (event.target.name === 'ASPeriodId') {
			this.ASPeriodId = event.target.value;
			localStorage.setItem('ASPeriodId', this.ASPeriodId);
		}
		if (event.target.name === 'selectedConfig') {
			this.selectedConfig = event.target.value;
		}
		this.doInit().then(() => null);
	};

	toggleTotals = () => {
		this.onlyTotals = !this.onlyTotals;
		this.doInit();
	}
}