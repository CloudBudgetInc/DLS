import {_message} from "c/cbUtils";

const prepareDataForChart = (GMReportLines, var2ChartSectionMapping, renderMargin) => {
	try {
		const chartData = GMReportLines
			.filter(({ label, actualRevenuePercent }) => label.includes('TOTAL') && label !== 'TOTAL' && actualRevenuePercent > 0)
			.reduce((result, { label, actualRevenuePercent, actualGrossMarginPercent }) => {
				const value = ((renderMargin ? actualGrossMarginPercent : actualRevenuePercent) * 100).toFixed(2);
				result[label] = { label, value };
				return result;
			}, {});

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

export {prepareDataForChart};
