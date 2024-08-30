/**
Copyright (c) 04 2024, AJR, CloudBudget, Inc
All rights reserved.
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
 * Neither the name of the CloudBudget, Inc. nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import {LightningElement, track} from 'lwc';
import getPeriodsServer from '@salesforce/apex/CBPLSummaryReportPageController.getPeriodsServer';
import getCBCubesForPeriodServer from '@salesforce/apex/CBPLSummaryReportPageController.getCBCubesForPeriodServer';
import {
	addSubLinesAndTotals,
	convertCubeToReportLine,
	getBYFirstPeriodId,
	getPriorPeriodId,
	getPriorYearPeriodId,
	setContext
} from "./cbPLSummaryReportBase";
import {_message, _parseServerError} from "c/cbUtils";
import exceljs from "@salesforce/resourceUrl/cb5__exceljs";
import {loadScript} from "lightning/platformResourceLoader";
import {downloadExcelFile, setExcelLibContext} from "./cbPLSummaryReportExcel";


export default class CBPLSummaryReport extends LightningElement {

	librariesLoaded = false;
	@track selectedPeriodId;
	@track showSpinner = true;
	@track readyToRender = false;
	@track periodSO = [];
	@track selectedReportType = 'summary';
	@track reportTypeSO = [
		{label: 'Summary', value: 'summary'},
		{label: 'Summary+', value: 'summary+'}, // + accounts
		{label: 'Facilities', value: 'facilities'}
	];
	@track selectedPeriodMode = 'current';
	@track reportPeriodModeSO = [
		{label: 'Current', value: 'current'},
		{label: 'YTD', value: 'YTD'},
	];
	@track currentMonthCubes = [];
	@track priorMonthCubes = [];
	@track priorYearCubes = [];
	@track currentMonthCubesYTD = [];
	@track priorYearCubesYTD = [];
	@track renderDashboard = false;

	get renderCurrent() {
		return this.selectedPeriodMode === 'current';
	}

	get reportLinesJSON() {
		return JSON.stringify(this.reportLines);
	}

	get pageTitle() {
		return this.selectedPeriodMode === 'current' ? 'Current Vs. Prior Vs. Budget Month P&L Summary' : 'YTD Current Vs. Prior Vs. Budget Month P&L Summary Report';
	}

	get selectedMonthName() {
		if (!this.selectedPeriodId || !this.periodSO) return 'N/A';
		return this.periodSO.find(pSO => pSO.value === this.selectedPeriodId).label;
	}

	get totalNumberOfRawData() {
		return this.currentMonthCubes.length + this.priorMonthCubes.length + this.priorYearCubes.length + this.currentMonthCubesYTD.length + this.priorYearCubesYTD.length;
	}

	@track renderDD = false;
	@track ddLabel = '';
	@track reportLines = [];

	async connectedCallback() {
		await this.analytics();
		this.applyLastSelected();
		this.renderReport();
	}

	renderedCallback() {
		if (this.librariesLoaded) return;
		this.librariesLoaded = true;
		Promise.all([loadScript(this, exceljs)]).catch(function (e) {
			_message(`error`, `BLME : Excel Backup load library ${e}`);
		});
	}

	activeTabValue = 'summaryTab';
	activateSummaryTab = () => {
		this.activeTabValue = 'summaryTab';
	};

	activateGrossMarginTab = async () => {
		if (this.selectedReportType === 'summary') return null;
		this.selectedReportType = 'summary';
		await this.renderReport();
		this.activeTabValue = 'grossMarginTab';
	};

	/**
	 * Restoring initial selected items from localeStorage
	 */
	applyLastSelected = () => {
		this.selectedPeriodId = localStorage.getItem('selectedPeriodId') ? localStorage.getItem('selectedPeriodId') : undefined;
		if (!this.selectedPeriodId) {
			this.selectedPeriodId = this.periodSO[0].value; // first run
		}
	};

	/**
	 * Method gets base analytics form the database. Periods, etc
	 */
	analytics = async () => {
		const periods = await getPeriodsServer().catch(e => _parseServerError('Get Periods Error: ', e));
		this.periodSO = periods.reduce((r, p) => {
			r.push({label: p.Name, value: p.Id, byId: p.cb5__CBBudgetYear__c});
			return r;
		}, []);
	};

	handleChangeMainFilter = async (event) => {
		this[event.target.name] = event.target.value;
		localStorage.setItem(event.target.name, event.target.value);
		this.renderReport();
	};

	/**
	 * The main method to generate the report data
	 */
	renderReport = async () => {
		if (!this.selectedPeriodId) return null;
		this.showSpinner = true;
		this.readyToRender = false;
		await this.getSourceData();
		if (this.totalNumberOfRawData === 0) {
			this.showSpinner = false;
			_message('info', 'No data for this period. Please select another period');
			return null;
		}
		this.generateSummaryReportLines();
		this.showSpinner = false;
		this.readyToRender = true;
	};

	/**
	 * Method requests needed CBCubes from the database
	 */
	getSourceData = async () => {
		const priorPeriodId = getPriorPeriodId(this.selectedPeriodId, this.periodSO);
		const BYFirstPeriodId = getBYFirstPeriodId(this.selectedPeriodId, this.periodSO);
		const priorYearPeriodId = getPriorYearPeriodId(this.selectedPeriodId, this.periodSO);
		const BYFirstPeriodPriorYearId = getBYFirstPeriodId(priorYearPeriodId, this.periodSO);
		this.currentMonthCubes = [];
		this.priorMonthCubes = [];
		this.priorYearCubes = [];
		this.currentMonthCubesYTD = [];
		this.priorYearCubesYTD = [];
		try {
			if (this.selectedPeriodMode === 'current') {
				this.currentMonthCubes = await getCBCubesForPeriodServer({startPeriodId: this.selectedPeriodId}).catch(e => _parseServerError('Get Current Month Data Error: ', e));
				this.priorMonthCubes = await getCBCubesForPeriodServer({startPeriodId: priorPeriodId}).catch(e => _parseServerError('Get Prior Month Data Error: ', e));
				this.priorYearCubes = await getCBCubesForPeriodServer({startPeriodId: priorYearPeriodId}).catch(e => _parseServerError('Get Prior Year Month Data Error: ', e));
			} else {
				this.currentMonthCubesYTD = await getCBCubesForPeriodServer({
					startPeriodId: BYFirstPeriodId,
					endPeriodId: this.selectedPeriodId
				}).catch(e => _parseServerError('Get Current Month YTD Data Error: ', e));
				console.log('Prior Year: FROM: ' + BYFirstPeriodPriorYearId + ' TO:' + priorYearPeriodId);
				this.priorYearCubesYTD = await getCBCubesForPeriodServer({
					startPeriodId: BYFirstPeriodPriorYearId,
					endPeriodId: priorYearPeriodId
				}).catch(e => _parseServerError('Get Prior Year YTD Data Error: ', e));
			}
		} catch (e) {
			this.showSpinner = false;
			_message('error', 'Get Data Error ' + e);
		}
	};

	generateSummaryReportLines = () => {
		this.reportLines = [];
		const reportLineMap = {};

		setContext(this);
		if (this.selectedPeriodMode === 'current') {
			this.currentMonthCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'currentMonthCubes'));
			this.priorMonthCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorMonthCubes'));
			this.priorYearCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorYearCubes'));
		} else {
			this.currentMonthCubesYTD.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'currentMonthCubesYTD'));
			this.priorYearCubesYTD.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorYearCubesYTD'));
		}

		const reportLines = addSubLinesAndTotals(Object.values(reportLineMap));
		reportLines.forEach(rl => rl.normalizeReportLine());
		//reportLines.forEach(rl => console.log(JSON.stringify(rl)));
		this.reportLines = reportLines;
	};

	downloadToExcel = () => {
		setExcelLibContext(this);
		downloadExcelFile();
	};

	////////// DRILL DOWN //////////

	cubeFitsConditions = (cube, params) => {
		const {label, type} = params;
		const accountName = cube.cb5__CBAccount__r.Name;
		if (this.selectedReportType === 'facilities') {
			return cube.cb5__CBVariable1__r?.Name === params.var1 && cube.cb5__CBAccount__r.Name === params.account;
		}
		if (this.selectedReportType === 'summary') {
			if (cube.CBAccountSubtype2__c === label && cube.cb5__AccSubType__c === type) return true; // for undirect expenses
			if (label === 'GSA IFF Fee') {
				if (accountName.startsWith('481')) return true;
			}
			if (label === 'Direct Fringe') {
				if (type === 'COGS' && accountName.startsWith('58')) return true;
			}
			if (cube.cb5__CBVariable2__r?.Name === label) { /// for direct expenses
				if (type === 'Revenue' && accountName.startsWith('4')) return true;
				if (type === 'COGS' && !accountName.startsWith('58') && accountName.startsWith('5')) return true
			}
		}
		return false;
	};

	showDrillDown = (event) => {
		try {
			if (this.selectedPeriodMode === 'YTD') {
				alert('Not allowed in YTD mode');
				return null;
			}
			const dataId = event.target.dataset.id;
			let params = JSON.parse(dataId);
			this.ddLabel = params.label;
			console.clear();
			console.log('Params : ' + JSON.stringify(params));
			if (!params.type) {
				_message('info', 'DrillDown is not applicable for the selected row');
				return null;
			}
			let engagedCubes = [];
			engagedCubes = this.currentMonthCubes.filter(cube => this.cubeFitsConditions(cube, params));
			const DDIDS = {};
			engagedCubes.forEach(cube => {
				if (cube.cb5__DrillDownIds__c) cube.cb5__DrillDownIds__c.split(',').forEach(id => DDIDS[id] = true);
			});
			this.ddParams = JSON.stringify(Object.keys(DDIDS));
			this.renderDD = true;
		} catch (e) {
			_message('error', 'DD Error: ' + e);
		}
	};
	closeDrillDown = () => {
		this.ddParams = [];
		this.ddLabel = [];
		this.renderDD = false;
	};
	////////// DRILL DOWN //////////


	////////// DASHBOARD //////////
	openDashboard = () => this.renderDashboard = true;
	closeDashboard = () => this.renderDashboard = false;
	////////// DASHBOARD //////////

}