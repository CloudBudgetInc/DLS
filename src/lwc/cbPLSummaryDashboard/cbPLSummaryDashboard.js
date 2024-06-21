import {api, LightningElement, track} from 'lwc';

export default class CbPLSummaryDashboard extends LightningElement {

	@api reportLines;
	@api closeFunction;
	@track readyToRender = false;


	@track groupRevenue = false;
	@track revenueCurrentPlanActualPercentDiffConfig;
	@track revenueCurrentPreviousMonthPercentDiffConfig;
	@track revenueCurrentPreviousYearPercentDiffConfig;

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
		this.readyToRender = false;
		const revenueReportLines = this.reportLines.filter(rl => rl.type === 'Revenue');
		this.revenueCurrentPlanActualPercentDiffConfig = this.getDataForRevenueChart(revenueReportLines, 'currentMonthDiffPercent', 'Plan/Actual Diff');
		this.revenueCurrentPreviousMonthPercentDiffConfig = this.getDataForRevenueChart(revenueReportLines, 'priorMonthDiffPercent', 'Current/Previous Month Diff');
		this.revenueCurrentPreviousYearPercentDiffConfig = this.getDataForRevenueChart(revenueReportLines, 'priorYearDiffPercent', 'Current/Previous Year Diff');
		this.readyToRender = true;
	};

	// Method to generate an array of colors
	generateColors = (numColors) => {
		const colors = [];
		for (let i = 0; i < numColors; i++) {
			const r = Math.floor(Math.random() * 255);
			const g = Math.floor(Math.random() * 255);
			const b = Math.floor(Math.random() * 255);
			colors.push(`rgba(${r}, ${g}, ${b}, 0.2)`);
		}
		return colors;
	};

	getDataForRevenueChart = (revenueReportLines, field, label) => {
		const revMapping = {
			'LT - COMM': 'COMM, (non)GSA, PVT',
			'LT - GSA': 'COMM, (non)GSA, PVT',
			'LT - NonGSA': 'COMM, (non)GSA, PVT',
			'LT - PVT': 'COMM, (non)GSA, PVT',
			'LT - DODA': 'LT - DODA (PS)',
			'LT - DODA PS': 'LT - DODA (PS)',
			'LT - DLI-W': 'LT - DLI-W (PS)',
			'LT - DLI-W PS': 'LT - DLI-W (PS)'
		};

		const rlObjectMap = {};
		revenueReportLines.forEach(rl => {
			if (!rl[field]) return;
			const label = revMapping[rl.label] ? revMapping[rl.label] : rl.label;
			rlObjectMap[label] = rlObjectMap[label] ? rlObjectMap[label] : 0;
			rlObjectMap[label] += rl[field] * 100;
		});

		const labels = Object.keys(rlObjectMap);
		const data = Object.values(rlObjectMap);
		const backgroundColors = this.generateColors(data.length);
		const borderColors = backgroundColors.map(color => color.replace('0.2', '1'));

		return {
			type: 'bar',
			data: {
				labels,
				datasets: [{
					label,
					data,
					backgroundColor: backgroundColors,
					borderColor: borderColors,
					borderWidth: 1
				}]
			},
			options: {
				scales: {
					y: {
						title: {
							display: true,
							text: 'Percentage'
						},
						beginAtZero: true,
						max: 100, // Ensure Y-axis goes up to 100%
						ticks: {
							callback: function (value) {
								return value + '%'; // Convert to percentage
							}
						},
						scaleLabel: {
							display: true,
							labelString: "Percentage"
						}
					}
				},
				plugins: {
					tooltip: {
						callbacks: {
							label: function (tooltipItem) {
								return tooltipItem.raw + '%'; // Show percentage in tooltip
							}
						}
					}
				}
			}
		};
	};

	closeDashboardDialog = () => {
		this.closeFunction();
	};

	toggleRevenueGrouping = () => {
		this.groupRevenue = !this.groupRevenue;
		this.readyToRender = false;
		setTimeout(() => {
			this.prepareData();
		}, 100);
	}

}