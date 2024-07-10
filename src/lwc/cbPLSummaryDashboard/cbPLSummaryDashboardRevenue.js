import {_message} from "c/cbUtils";

let c;

const prepareRevenue = (context) => {
	try {
		if (context) c = context;
		let revenueReportLines = c.reportLines.filter(rl => rl.type === 'Revenue');
		c.revenueOptions = getRevenueOptions(revenueReportLines);
		if (!c.revenueValues || c.revenueValues.length === 0) c.revenueValues = getRevenueValues(revenueReportLines);
		revenueReportLines = revenueReportLines.filter(rl => c.revenueValues.includes(rl.label));
		c.revenueCurrentPlanActualPercentDiffConfig = getDataForRevenueBudgetByVar2Chart(revenueReportLines, 'currentMonthDiffPercent', 'Plan/Actual Diff');
		c.revenueCurrentPreviousMonthPercentDiffConfig = getDataForRevenueBudgetByVar2Chart(revenueReportLines, 'priorMonthDiffPercent', 'Current/Previous Month Diff');
		c.revenueCurrentPreviousYearPercentDiffConfig = getDataForRevenueBudgetByVar2Chart(revenueReportLines, 'priorYearDiffPercent', 'Current/Previous Year Diff');
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
	const labels = ['Current Month', 'Prior Month', 'Prior Year Month'];
	const actualData = [0, 0, 0];
	const budgetData = [0, 0, 0];

	revenueReportLines.forEach(rl => {
		actualData[0] += rl.currentMonthActual;
		actualData[1] += rl.priorMonthActual;
		actualData[2] += rl.priorYearActual;
		budgetData[0] += rl.currentMonthBudget;
		budgetData[1] += rl.priorMonthBudget;
		budgetData[2] += rl.priorYearBudget;
	});

	const actualDataset = {
		label: 'Actual',
		data: actualData,
		backgroundColor: 'rgba(54, 162, 235, 0.2)',
		borderColor: 'rgba(54, 162, 235, 1)',
		borderWidth: 1
	};
	const budgetDataset = {
		label: 'Budget',
		data: budgetData,
		type: 'line',
		borderColor: 'rgba(255, 99, 132, 1)',
		fill: false,
		borderWidth: 2,
		tension: 0
	};

	return {
		type: 'bar',
		data: {
			labels,
			datasets: [actualDataset, budgetDataset]
		},
		options: {
			scales: {
				y: {
					ticks: {
						// Include a dollar sign in the ticks
						callback: (value, index, ticks) => {
							return '$' + value;
						}
					},
					scaleLabel: {
						display: true,
						labelString: 'Amount ($)'
					},
					title: {
						display: true,
						text: 'Amount ($)',
					}
				}
			},
			plugins: {
				title: {
					display: true,
					text: 'Revenue Budget vs Actual'
				}
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