let c;

const prepareRevenue = (context) => {
	if (context) c = context;
	const revenueReportLines = c.reportLines.filter(rl => rl.type === 'Revenue');
	console.log('revenueReportLines = ' + JSON.stringify(revenueReportLines));
	c.revenueOptions = getRevenueOptions(revenueReportLines);
	if (!c.revenueValues || c.revenueValues.length === 0) c.revenueValues = getRevenueValues(revenueReportLines);
	c.revenueCurrentPlanActualPercentDiffConfig = getDataForRevenueChart(revenueReportLines, 'currentMonthDiffPercent', 'Plan/Actual Diff');
	c.revenueCurrentPreviousMonthPercentDiffConfig = getDataForRevenueChart(revenueReportLines, 'priorMonthDiffPercent', 'Current/Previous Month Diff');
	c.revenueCurrentPreviousYearPercentDiffConfig = getDataForRevenueChart(revenueReportLines, 'priorYearDiffPercent', 'Current/Previous Year Diff');
	c.readyToRenderRevenue = true;
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

const getDataForRevenueChart = (revenueReportLines, field, label) => {

	const labels = [];
	const data = [];
	revenueReportLines.forEach(rl => {
		if (!rl[field] || !c.revenueValues.includes(rl.label)) return;
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