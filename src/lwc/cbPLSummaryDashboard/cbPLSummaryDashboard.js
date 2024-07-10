import {api, LightningElement, track} from 'lwc';
import {prepareRevenue} from "./cbPLSummaryDashboardRevenue";
import {prepareCOGS} from "./cbPLSummaryDashboardCOGS";
import {prepareIndirect} from "./cbPLSummaryDashboardIndirect";
import {_message} from "c/cbUtils";

export default class CbPLSummaryDashboard extends LightningElement {

	@api reportLines;
	@api closeFunction;

	connectedCallback() {
		try {
			if (!this.reportLines || this.reportLines.length === 0) {
				_message('info', 'Nothing to render');
				return null;
			}
			this.reportLines = JSON.parse(this.reportLines);
			this.prepareData();
		} catch (e) {
			_message('error', 'CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	prepareData = () => {
		this.readyToRenderRevenue = false;
		prepareRevenue(this);
		prepareCOGS(this);
		prepareIndirect(this);
		this.readyToRenderRevenue = true;
	};


	closeDashboardDialog = () => {
		this.closeFunction();
	};

	///////// REVENUE PART ///////////
	@track readyToRenderRevenue = false;
	@track isRevenueOptionsRendered = false;
	@track groupRevenue = false;
	@track revenueCurrentPlanActualPercentDiffConfig;
	@track revenueCurrentPreviousMonthPercentDiffConfig;
	@track revenueCurrentPreviousYearPercentDiffConfig;
	@track revenueBudgetActualConfig;
	@track revenueOptions;
	@track revenueValues;
	timeoutId;
	handleRevenueOptionsChange = (event) => this.revenueValues = event.detail.value;
	applyRevenueOptions = () => {
		this.readyToRenderRevenue = false;
		this.isRevenueOptionsRendered = false;
		setTimeout(() => {
			prepareRevenue(this);
			this.readyToRenderRevenue = true;
		}, 500);
	};
	invertRevenueOptions = () => this.revenueValues = this.revenueOptions.filter(so => !this.revenueValues.includes(so.value)).map(so => so.value);
	allRevenueOptions = () => this.revenueValues = this.revenueOptions.map(so => so.value);

	handleMouseOverRevenue() {
		clearTimeout(this.timeoutId);
		this.isRevenueOptionsRendered = true;
	}

	handleMouseOutRevenue = () => this.timeoutId = setTimeout(() => this.isRevenueOptionsRendered = false, 1000);
	///////// REVENUE PART ///////////

	///////// COGS PART ///////////
	@track readyToRenderCOGS = false;
	@track isCOGSOptionsRendered = false;
	@track groupCOGS = false;
	@track COGSCurrentPlanActualPercentDiffConfig;
	@track COGSCurrentPreviousMonthPercentDiffConfig;
	@track COGSCurrentPreviousYearPercentDiffConfig;
	@track COGSBudgetActualConfig;
	@track COGSOptions;
	@track COGSValues;
	handleCOGSOptionsChange = (event) => this.COGSValues = event.detail.value;
	applyCOGSOptions = () => {
		this.readyToRenderCOGS = false;
		this.isCOGSOptionsRendered = false;
		setTimeout(() => {
			prepareCOGS(this);
			this.readyToRenderCOGS = true;
		}, 500);
	};
	invertCOGSOptions = () => this.COGSValues = this.COGSOptions.filter(so => !this.COGSValues.includes(so.value)).map(so => so.value);
	allCOGSOptions = () => this.COGSValues = this.COGSOptions.map(so => so.value);

	handleMouseOverCOGS() {
		clearTimeout(this.timeoutId);
		this.isCOGSOptionsRendered = true;
	}

	handleMouseOutCOGS = () => this.timeoutId = setTimeout(() => this.isCOGSOptionsRendered = false, 1000);
	///////// COGS PART ///////////

	///////// INDIRECT EXPENSES ///////////
	@track readyToRenderIndirect = false;
	@track isIndirectOptionsRendered = false;
	@track groupIndirect = false;
	@track indirectCurrentPlanActualPercentDiffConfig;
	@track indirectCurrentPreviousMonthPercentDiffConfig;
	@track indirectCurrentPreviousYearPercentDiffConfig;
	@track indirectBudgetActualConfig;
	@track indirectBudgetActualConfigChunks;
	@track indirectOptions;
	@track indirectValues;
	handleIndirectOptionsChange = (event) => this.indirectValues = event.detail.value;
	applyIndirectOptions = () => {
		this.readyToRenderIndirect = false;
		this.isIndirectOptionsRendered = false;
		setTimeout(() => {
			prepareIndirect(this);
			this.readyToRenderIndirect = true;
		}, 500);
	};
	invertIndirectOptions = () => this.indirectValues = this.indirectOptions.filter(so => !this.indirectValues.includes(so.value)).map(so => so.value);
	allIndirectOptions = () => this.indirectValues = this.indirectOptions.map(so => so.value);

	handleMouseOverIndirect() {
		clearTimeout(this.timeoutId);
		this.isIndirectOptionsRendered = true;
	}

	handleMouseOutIndirect = () => this.timeoutId = setTimeout(() => this.isIndirectOptionsRendered = false, 1000);
	///////// INDIRECT EXPENSES ///////////

}