import {_message} from "c/cbUtils";
import {
	ACTUAL_BACKGROUND_COLOR,
	ACTUAL_BORDER_COLOR,
	BUDGET_BACKGROUND_COLOR,
	BUDGET_BORDER_COLOR,
	createDataset
} from "./cbPLSummaryDashboardUtils";

let c;

const prepareCOGS = (context) => {
	try {
		if (context) c = context;
		let COGSReportLines = c.reportLines.filter(rl => rl.type === 'COGS');
		c.COGSOptions = getCOGSOptions(COGSReportLines);
		if (!c.COGSValues || c.COGSValues.length === 0) c.COGSValues = getCOGSValues(COGSReportLines);
		COGSReportLines = COGSReportLines.filter(rl => c.COGSValues.includes(rl.label));
		//c.COGSCurrentPlanActualPercentDiffConfig = getDataForCOGSBudgetByVar2Chart(COGSReportLines, 'currentMonthDiffPercent', 'Plan/Actual Diff');
		//c.COGSCurrentPreviousMonthPercentDiffConfig = getDataForCOGSBudgetByVar2Chart(COGSReportLines, 'priorMonthDiffPercent', 'Current/Previous Month Diff');
		//c.COGSCurrentPreviousYearPercentDiffConfig = getDataForCOGSBudgetByVar2Chart(COGSReportLines, 'priorYearDiffPercent', 'Current/Previous Year Diff');
		c.COGSBudgetActualConfig = getDataForCOGSBudgetActualChart(COGSReportLines);
		console.log('c.COGSBudgetActualConfig = ' + JSON.stringify(c.COGSBudgetActualConfig));
		c.readyToRenderCOGS = true;
	} catch (e) {
		_message('error', 'COGS Chart Error: ' + JSON.stringify(e));
	}
};

const getCOGSOptions = (COGSReportLines) => {
	return COGSReportLines.reduce((so, rl) => {
		so.push({label: rl.label, value: rl.label});
		return so;
	}, []);
};

const getCOGSValues = (COGSReportLines) => {
	return COGSReportLines.reduce((values, rl) => {
		values.push(rl.label);
		return values;
	}, []);
};

const getDataForCOGSBudgetByVar2Chart = (COGSReportLines, field, label) => {

	const labels = [];
	const data = [];
	COGSReportLines.forEach(rl => {
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

const getDataForCOGSBudgetActualChart = (COGSReportLines) => {
	const isCurrent = c.selectedPeriodMode === 'current';
	const labels = isCurrent
		? ['Current Month', 'Prior Month', 'Prior Year Month']
		: ['Current Month YTD', 'Prior Year Month YTD'];

	const actualData = Array(labels.length).fill(0);
	const budgetData = Array(labels.length).fill(0);

	COGSReportLines.forEach(rl => {
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

const resetCOGS = () => {
	c.COGSCurrentPlanActualPercentDiffConfig = [];
	c.COGSCurrentPreviousMonthPercentDiffConfig = [];
	c.COGSCurrentPreviousYearPercentDiffConfig = [];
};

export {prepareCOGS}