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
	setShowAccounts
} from "./cbPLSummaryReportBase";
import {_message, _parseServerError} from "c/cbUtils";


export default class CBPLSummaryReport extends LightningElement {

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
	@track currentMonthCubes = [];
	@track priorMonthCubes = [];
	@track priorYearCubes = [];

	@track reportLines = [];

	async connectedCallback() {
		await this.analytics();
		this.applyLastSelected();
		this.renderReport();
	}

	/**
	 * Restoring initial selected items from localeStorage
	 */
	applyLastSelected = () => {
		this.selectedPeriodId = localStorage.getItem('selectedPeriodId') ? localStorage.getItem('selectedPeriodId') : undefined;
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
		try {
			this.currentMonthCubes = await getCBCubesForPeriodServer({startPeriodId: this.selectedPeriodId}).catch(e => _parseServerError('Get Current Month Data Error: ', e));
			this.priorMonthCubes = await getCBCubesForPeriodServer({startPeriodId: priorPeriodId}).catch(e => _parseServerError('Get Prior Month Data Error: ', e));
			this.priorYearCubes = await getCBCubesForPeriodServer({startPeriodId: priorYearPeriodId}).catch(e => _parseServerError('Get Prior Year Month Data Error: ', e));
		} catch (e) {
			this.showSpinner = false;
			_message('error', 'Get Data Error ' + e);
		}
	};

	generateSummaryReportLines = () => {
		this.reportLines = [];
		const reportLineMap = {};

		setShowAccounts(this.selectedReportType === 'summary+');
		this.currentMonthCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'currentMonthCubes'));
		this.priorMonthCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorMonthCubes'));
		this.priorYearCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorYearCubes'));

		const reportLines = addSubLinesAndTotals(Object.values(reportLineMap));
		reportLines.forEach(rl => rl.normalizeReportLine());
		this.reportLines = reportLines;
	};

	downloadToExcel = () => {
		_message('warning', 'In progress');
	};


}