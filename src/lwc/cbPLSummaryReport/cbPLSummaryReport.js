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
import getPeriodsServer from '@salesforce/apex/CBDashboardReportPageController.getPeriodsServer';
import getCBCubesForPeriodServer from '@salesforce/apex/CBDashboardReportPageController.getCBCubesForPeriodServer';
import {
	addSubLinesAndTotals,
	convertCubeToReportLine,
	getBYFirstPeriodId,
	getPriorPeriodId,
	getPriorYearPeriodId
} from "./cbPLSummaryReportUtils";


export default class CBPLSummaryReport extends LightningElement {

	@track selectedPeriodId;
	@track selectedType = 'actual';
	@track showSpinner = false;
	@track readyToRender = false;
	@track periodSO = [];
	@track typeSO = [
		{label: 'Actual', value: 'actual'},
		{label: 'Budget', value: 'budget'},
		{label: 'Both', value: 'both'}
	];
	@track currentMonthCubes = [];
	@track priorMonthCubes = [];
	@track priorYearCubes = [];
	@track currentYTDCubes = [];
	@track priorYTDCubes = [];

	@track reportLines = [];

	get renderActual() {
		return this.selectedType === 'actual' || this.selectedType === 'both';
	}

	get renderBudget() {
		return this.selectedType === 'budget' || this.selectedType === 'both';
	}

	async connectedCallback() {
		await this.analytics();
	}

	analytics = async () => {
		const periods = await getPeriodsServer().catch(e => alert('ERROR ' + e));
		this.periodSO = periods.reduce((r, p) => {
			r.push({label: p.Name, value: p.Id, byId: p.cb5__CBBudgetYear__c});
			return r;
		}, []);
	};

	handleChangePeriod = async (event) => {
		this[event.target.name] = event.target.value;
		this.renderReport();
	};

	handleChangeType = async (event) => {
		this[event.target.name] = event.target.value;
		this.renderReport();
	};

	renderReport = async () => {
		await this.getSourceData();
		this.generateReportLines();
	};

	getSourceData = async () => {
		this.readyToRender = false;
		const priorPeriodId = getPriorPeriodId(this.selectedPeriodId, this.periodSO);
		const BYFirstPeriodId = getBYFirstPeriodId(this.selectedPeriodId, this.periodSO);
		const priorYearPeriodId = getPriorYearPeriodId(this.selectedPeriodId, this.periodSO);
		const priorBYFirstPeriodId = getBYFirstPeriodId(priorYearPeriodId, this.periodSO);
		console.log('Current Period Id: ' + this.selectedPeriodId);
		console.log('Prior Period Id: ' + priorPeriodId);
		console.log('Current YTD Period Id: ' + BYFirstPeriodId);
		console.log('Prior Year Period Id: ' + priorYearPeriodId);
		try {
			this.currentMonthCubes = await getCBCubesForPeriodServer({startPeriodId: this.selectedPeriodId});
			this.priorMonthCubes = await getCBCubesForPeriodServer({startPeriodId: priorPeriodId});
			this.currentYTDCubes = await getCBCubesForPeriodServer({
				startPeriodId: BYFirstPeriodId,
				endPeriodId: this.selectedPeriodId
			});
			this.priorYearCubes = await getCBCubesForPeriodServer({startPeriodId: priorYearPeriodId});
			this.priorYTDCubes = await getCBCubesForPeriodServer({
				startPeriodId: priorBYFirstPeriodId,
				endPeriodId: priorYearPeriodId
			});

			console.log('Current YTD Month Data Received : ' + this.currentYTDCubes.length);
		} catch (e) {
			alert('Get Data Error ' + e);
		}
	};

	generateReportLines = () => {
		this.readyToRender = false;
		this.reportLines = [];
		const reportLineMap = {};

		this.currentMonthCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'currentMonthCubes'));
		this.priorMonthCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorMonthCubes'));
		this.currentYTDCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'currentYTDCubes'));
		this.priorYearCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorYearCubes'));
		this.priorYTDCubes.forEach(cube => convertCubeToReportLine(cube, reportLineMap, 'priorYTDCubes'));

		const reportLines = addSubLinesAndTotals(Object.values(reportLineMap));
		reportLines.forEach(rl => rl.normalizeReportLine());
		this.reportLines = reportLines;
		this.readyToRender = true;
	};

	downloadToExcel = () => {
		alert('In progress');
	}


}