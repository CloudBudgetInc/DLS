import {_message} from "c/cbUtils";

const prepareDataForChart = (GMReportLines, var2ChartSectionMapping, renderMargin) => {
	try {
		const chartData = GMReportLines
			.filter(line => !line.label.includes('TOTAL') && line.actualRevenuePercent > 0)
			.reduce((r, {label, actualRevenuePercent, actualGrossMarginPercent}) => {
				const sectionLabel = var2ChartSectionMapping[label];
				const value = renderMargin ? actualGrossMarginPercent : actualRevenuePercent;
				r[sectionLabel] = r[sectionLabel] || { label: sectionLabel, value: 0 };
				r[sectionLabel].value += Math.round(value * 10000) / 100;
				return r;
			}, {});

		normalizePercent(chartData);
		const data = Object.values(chartData);
		const labels = data.map(item => item.label);
		const values = data.map(item => item.value);
		const colors = values.map(getRandomColor);

		return {
			type: 'pie',
			data: {
				labels,
				datasets: [{
					data: values,
					backgroundColor: colors,
					hoverBackgroundColor: colors
				}]
			},
			options: {
				responsive: true,
				maintainAspectRatio: false,
				plugins: {
					legend: {
						position: 'left',
						labels: { boxWidth: 20 }
					},
					tooltip: {
						callbacks: {
							label: ({label, raw}) => `${label}: ${(raw || 0).toFixed(2)}%`
						}
					}
				}
			}
		};
	} catch (e) {
		_message('error', `Chart Data Error: ${JSON.stringify(e)}`);
	}
};

const getRandomColor = () => '#' + Math.floor(Math.random() * 16777215).toString(16).padEnd(6, '0');

/**
 *   {"OTHER":{"label":"OTHER","value":376.79},"LT":{"label":"LT","value":293.16}}
 */
const normalizePercent = (chartData) => {
	let total = 0;
	Object.keys(chartData).forEach(key => {
		const val = chartData[key];
		total += val.value;
	});
	Object.keys(chartData).forEach(key => {
		const val = chartData[key];
		val.value =  (val.value / total) * 100;
	});
};


export {prepareDataForChart};
