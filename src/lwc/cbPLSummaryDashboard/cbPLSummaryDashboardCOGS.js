import {_message} from "c/cbUtils";

let c;

const prepareCOGS = (context) => {
	try {
		if (context) c = context;
		let COGSReportLines = c.reportLines.filter(rl => rl.type === 'COGS');
		c.COGSOptions = getCOGSOptions(COGSReportLines);
		if (!c.COGSValues || c.COGSValues.length === 0) c.COGSValues = getCOGSValues(COGSReportLines);
		COGSReportLines = COGSReportLines.filter(rl => c.COGSValues.includes(rl.label));
		c.COGSCurrentPlanActualPercentDiffConfig = getDataForCOGSBudgetByVar2Chart(COGSReportLines, 'currentMonthDiffPercent', 'Plan/Actual Diff');
		c.COGSCurrentPreviousMonthPercentDiffConfig = getDataForCOGSBudgetByVar2Chart(COGSReportLines, 'priorMonthDiffPercent', 'Current/Previous Month Diff');
		c.COGSCurrentPreviousYearPercentDiffConfig = getDataForCOGSBudgetByVar2Chart(COGSReportLines, 'priorYearDiffPercent', 'Current/Previous Year Diff');
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
	const labels = ['Current Month', 'Prior Month', 'Prior Year Month'];
	const actualData = [0, 0, 0];
	const budgetData = [0, 0, 0];

	COGSReportLines.forEach(rl => {
		actualData[0] += rl.currentMonthActual;
		actualData[1] += rl.priorMonthActual;
		actualData[2] += rl.priorYearActual;
		budgetData[0] = budgetData[1] = budgetData[2] += rl.currentMonthBudget;
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
					text: 'COGS Budget vs Actual'
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

const resetCOGS = () => {
	c.COGSCurrentPlanActualPercentDiffConfig = [];
	c.COGSCurrentPreviousMonthPercentDiffConfig = [];
	c.COGSCurrentPreviousYearPercentDiffConfig = [];
};

export {prepareCOGS}