import {_message} from "c/cbUtils";

let c;

const prepareIndirect = (context) => {
	try {
		if (context) c = context;
		let indirectReportLines = c.reportLines.filter(rl => (rl.type && rl.type !== 'Revenue' && rl.type !== 'COGS'));
		indirectReportLines = groupRLByType(indirectReportLines);
		c.indirectOptions = getIndirectOptions(indirectReportLines);
		if (!c.indirectValues || c.indirectValues.length === 0) c.indirectValues = getIndirectValues(indirectReportLines);
		indirectReportLines = indirectReportLines.filter(rl => c.indirectValues.includes(rl.type));
		c.indirectCurrentPlanActualPercentDiffConfig = getDataForIndirectBudgetByVar2Chart(indirectReportLines, 'currentMonthDiffPercent', 'Plan/Actual Diff');
		c.indirectCurrentPreviousMonthPercentDiffConfig = getDataForIndirectBudgetByVar2Chart(indirectReportLines, 'priorMonthDiffPercent', 'Current/Previous Month Diff');
		c.indirectCurrentPreviousYearPercentDiffConfig = getDataForIndirectBudgetByVar2Chart(indirectReportLines, 'priorYearDiffPercent', 'Current/Previous Year Diff');
		c.indirectBudgetActualConfigChunks = getDataForIndirectBudgetActualChartChunks(indirectReportLines);

		console.log('c.indirectBudgetActualConfigChunks = ' + JSON.stringify(c.indirectBudgetActualConfigChunks));
		c.readyToRenderIndirect = true;
	} catch (e) {
		_message('error', 'Indirect Chart Error: ' + JSON.stringify(e));
	}
};

const groupRLByType = (indirectReportLines) => {
	try {
		const currencyFields = ['currentMonthActual', 'currentMonthBudget', 'priorMonthActual', 'priorMonthBudget', 'priorYearActual', 'priorYearBudget'];
		const rlObject = indirectReportLines.reduce((objMap, rl) => {
			let obj = objMap[rl.type];
			if (!obj) {
				objMap[rl.type] = rl;
			} else {
				currencyFields.forEach(f => obj[f] += +rl[f]);
			}
			return objMap;
		}, {});
		return Object.values(rlObject);
	} catch (e) {
		_message('error', 'Group by Type Error: ' + JSON.stringify(e));
	}
};

const getIndirectOptions = (indirectReportLines) => {
	return indirectReportLines.reduce((so, rl) => {
		so.push({label: rl.type, value: rl.type});
		return so;
	}, []);
};

const getIndirectValues = (indirectReportLines) => {
	return indirectReportLines.reduce((values, rl) => {
		values.push(rl.type);
		return values;
	}, []);
};

const getDataForIndirectBudgetByVar2Chart = (indirectReportLines, field, label) => {

	const labels = [];
	const data = [];
	indirectReportLines.forEach(rl => {
		labels.push(rl.type);
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

const getBudgetActualChartData = (typeArray, chartTitle) => {
	const labels = ['Current Month', 'Prior Month', 'Prior Year Month'];
	const actualData = [0, 0, 0];
	const budgetData = [0, 0, 0];
	if (!chartTitle) chartTitle = `${typeArray[0].type} Budget vs Actual`;

	typeArray.forEach(rl => {
		if(c.selectedPeriodMode === 'current') {
			actualData[0] += rl.currentMonthActual;
			actualData[1] += rl.priorMonthActual;
			actualData[2] += rl.priorYearActual;
			budgetData[0] = budgetData[1] = budgetData[2] += rl.currentMonthBudget;
		} else {
			actualData[0] += rl.currentMonthActualYTD;
			actualData[1] += rl.priorMonthActualYTD;
			actualData[2] += rl.priorYearActualYTD;
			budgetData[0] = budgetData[1] = budgetData[2] += rl.currentMonthBudgetYTD;
		}
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
					text: chartTitle
				}
			}
		}
	};
};

const getDataForIndirectBudgetActualChartChunks = (indirectReportLines) => {
	const chartDataSets = [getBudgetActualChartData(indirectReportLines, 'Indirect Total Budget vs Actual')];
	const indirectGroupedByType = indirectReportLines.reduce((arr, rl) => {
		if (!arr[rl.type]) arr[rl.type] = [];
		arr[rl.type].push(rl);
		return arr;
	}, {});
	Object.values(indirectGroupedByType).forEach(typeArray => chartDataSets.push(getBudgetActualChartData(typeArray)));
	const dataChunks = [];
	const chunkSize = 3;
	for (let i = 0; i < chartDataSets.length; i += chunkSize) dataChunks.push(chartDataSets.slice(i, i + chunkSize));
	return dataChunks;
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

export {prepareIndirect}