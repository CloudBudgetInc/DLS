import {api, LightningElement, track} from 'lwc';
import {prepareRevenue} from "./cbPLSummaryDashboardRevenue";

export default class CbPLSummaryDashboard extends LightningElement {

	@api reportLines;
	@api closeFunction;
	@track readyToRenderRevenue = false;

	connectedCallback() {
		try {
			console.log(this.reportLines);
			if (!this.reportLines || this.reportLines.length === 0) {
				alert('Nothing to render');
				return null;
			}
			this.reportLines = JSON.parse(this.reportLines);
			this.prepareData();
		} catch (e) {
			alert('CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	prepareData = () => {
		this.readyToRenderRevenue = false;
		prepareRevenue(this);
		this.readyToRenderRevenue = true;
	};


	closeDashboardDialog = () => {
		this.closeFunction();
	};

	///////// REVENUE PART ///////////
	@track groupRevenue = false;
	@track revenueCurrentPlanActualPercentDiffConfig;
	@track revenueCurrentPreviousMonthPercentDiffConfig;
	@track revenueCurrentPreviousYearPercentDiffConfig;
	@track revenueOptions;
	@track revenueValues;

	handleRevenueOptionsChange = (event) => {
		this.revenueValues = event.detail.value;
	};

	applyRevenueOptions = () => {
		this.readyToRenderRevenue = false;
		this.isRevenueOptionsRendered = false;
		setTimeout(() => {
			prepareRevenue(this);
			this.readyToRenderRevenue = true;
		}, 500);
	};

	invertRevenueOptions = () => {
		this.revenueValues = this.revenueOptions.filter(so => !this.revenueValues.includes(so.value)).map(so => so.value);
	};

	@track isRevenueOptionsRendered = false;
	timeoutId;

	handleMouseOverRevenue() {
		clearTimeout(this.timeoutId);
		this.isRevenueOptionsRendered = true;
	}

	handleMouseOutRevenue() {
		this.timeoutId = setTimeout(() => {
			this.isRevenueOptionsRendered = false;
		}, 1000);
	}

	///////// REVENUE PART ///////////

}