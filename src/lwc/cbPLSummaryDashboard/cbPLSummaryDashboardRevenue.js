import {_message} from "c/cbUtils";
import {
	ACTUAL_BACKGROUND_COLOR,
	ACTUAL_BORDER_COLOR,
	BUDGET_BACKGROUND_COLOR,
	BUDGET_BORDER_COLOR,
	createDataset
} from "./cbPLSummaryDashboardUtils";

let c;

const prepareRevenue = (context) => {
	try {
		if (context) c = context;
		let revenueReportLines = c.reportLines.filter(rl => rl.type === 'Revenue');
		c.revenueOptions = getRevenueOptions(revenueReportLines);
		if (!c.revenueValues || c.revenueValues.length === 0) c.revenueValues = getRevenueValues(revenueReportLines);
		revenueReportLines = revenueReportLines.filter(rl => c.revenueValues.includes(rl.label));
		//c.revenueCurrentPlanActualPercentDiffConfig = getDataForRevenueBudgetByVar2Chart(revenueReportLines, 'currentMonthDiffPercent', 'Plan/Actual Diff');
		//c.revenueCurrentPreviousMonthPercentDiffConfig = getDataForRevenueBudgetByVar2Chart(revenueReportLines, 'priorMonthDiffPercent', 'Current/Previous Month Diff');
		//c.revenueCurrentPreviousYearPercentDiffConfig = getDataForRevenueBudgetByVar2Chart(revenueReportLines, 'priorYearDiffPercent', 'Current/Previous Year Diff');
		c.revenueBudgetActualConfig = getDataForRevenueBudgetActualChart(revenueReportLines);
		c.readyToRenderRevenue = true;
	} catch (e) {
		_message('error', 'Revenue Chart Error: ' + JSON.stringify(e));
	}
};

const getRevenueOptions = (revenueReportLines) => {
	return revenueReportLines.reduce((so, rl) => {
		so.push({label: rl.label, value: rl.label});
		return so;
	}, []);
};

const getRevenueValues = (revenueReportLines) => {
	return revenueReportLines.reduce((values, rl) => {
		values.push(rl.label);
		return values;
	}, []);
};

const getDataForRevenueBudgetByVar2Chart = (revenueReportLines, field, label) => {

	const labels = [];
	const data = [];
	revenueReportLines.forEach(rl => {
		labels.push(rl.label);
		data.push(rl[field] * 100);
	});

	const backgroundColors = generateColors(data.length);
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
				},
				legend: {
					display: true, // Enable the legend
					onClick: (e, legendItem) => {
						const index = legendItem.index;
						const chart = legendItem.chart;
						const meta = chart.getDatasetMeta(0);
						meta.data[index].hidden = !meta.data[index].hidden;
						chart.update();
					}
				}
			}
		}
	};
};

const getDataForRevenueBudgetActualChart = (revenueReportLines) => {
	const isCurrent = c.selectedPeriodMode === 'current';
	const labels = isCurrent
		? ['Current Month', 'Prior Month', 'Prior Year Month']
		: ['Current Month YTD', 'Prior Year Month YTD'];

	const actualData = Array(labels.length).fill(0);
	const budgetData = Array(labels.length).fill(0);

	revenueReportLines.forEach(rl => {
		if (isCurrent) {
			[actualData[0], actualData[1], actualData[2]] =
				[actualData[0] + rl.currentMonthActual, actualData[1] + rl.priorMonthActual, actualData[2] + rl.priorYearActual];
			budgetData.fill(budgetData[0] + rl.currentMonthBudget);
		} else {
			[actualData[0], actualData[1]] =
				[actualData[0] + rl.currentMonthActualYTD, actualData[1] + rl.priorYearActualYTD];
			budgetData.fill(budgetData[0] + rl.currentMonthBudgetYTD);
		}
	});

	return {
		type: 'bar',
		data: {
			labels,
			datasets: [
				createDataset('Actual', actualData, 'bar', ACTUAL_BACKGROUND_COLOR, ACTUAL_BORDER_COLOR, 1),
				createDataset('Budget', budgetData, 'line', BUDGET_BACKGROUND_COLOR, BUDGET_BORDER_COLOR, 2, false, 0)
			]
		},
		options: {
			scales: {
				y: {
					ticks: { callback: value => '$' + value },
					title: { display: true, text: 'Amount ($)' }
				}
			},
			plugins: {
				title: { display: true, text: 'Revenue Budget vs Actual' }
			}
		}
	};
};

// Method to generate an array of colors
const generateColors = (numColors) => {
	const colors = [];
	for (let i = 0; i < numColors; i++) {
		const r = Math.floor(Math.random() * 255);
		const g = Math.floor(Math.random() * 255);
		const b = Math.floor(Math.random() * 255);
		colors.push(`rgba(${r}, ${g}, ${b}, 0.2)`);
	}
	return colors;
};

const resetRevenue = () => {
	c.revenueCurrentPlanActualPercentDiffConfig = [];
	c.revenueCurrentPreviousMonthPercentDiffConfig = [];
	c.revenueCurrentPreviousYearPercentDiffConfig = [];
};

export {prepareRevenue}