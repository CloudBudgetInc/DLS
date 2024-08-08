class GMReportLine {

	constructor(label, sClass) {
		this.label = label;
		this.styleClass = sClass;

		this.actualRevenue = 0;
		this.actualExpense = 0;

		this.budgetRevenue = 0;
		this.budgetExpense = 0;

		this.actualDLFringe = 0;
		this.budgetDLFringe = 0;
		this.actualDLFringeIRM = 0;
		this.budgetDLFringeIRM = 0;
		this.actualDLFringeTotal = 0;
		this.budgetDLFringeTotal = 0;

		this.actualGrossMargin = 0;
		this.budgetGrossMargin = 0;
		this.actualGrossMarginPercent = 0;
		this.budgetGrossMarginPercent = 0;
		this.actualRevenuePercent = 0;
		this.budgetRevenuePercent = 0;
	}

	key;
	label;
	styleClass;

	actualRevenue;
	actualExpense;
	budgetRevenue;
	budgetExpense;

	actualDLFringe;
	budgetDLFringe;
	actualDLFringeIRM;
	budgetDLFringeIRM;
	actualDLFringeTotal;
	budgetDLFringeTotal;

	actualGrossMargin;
	budgetGrossMargin;
	actualGrossMarginPercent;
	budgetGrossMarginPercent;
	actualRevenuePercent;
	budgetRevenuePercent;

	formatStyle = 'currency';

	calculateDLFringe = (lines, totalGMReportLine) => {
		const frPercent = 0.2339;

		lines.forEach(rl => {
			totalGMReportLine.actualRevenue += +rl.actualRevenue;
			totalGMReportLine.actualExpense += +rl.actualExpense;
			totalGMReportLine.budgetRevenue += +rl.budgetRevenue;
			totalGMReportLine.budgetExpense += +rl.budgetExpense;
			totalGMReportLine.actualDLFringeIRM += rl.actualExpense * frPercent;
			totalGMReportLine.budgetDLFringeIRM += rl.budgetExpense * frPercent;
		});

		totalGMReportLine.actualDLFringeTotal = totalGMReportLine.actualDLFringe;
		totalGMReportLine.budgetDLFringeTotal = totalGMReportLine.budgetDLFringe;

		lines.forEach(rl => {
			rl.actualDLFringe = (totalGMReportLine.actualDLFringe / totalGMReportLine.actualExpense) * rl.actualExpense;
			rl.budgetDLFringe = (totalGMReportLine.budgetDLFringe / totalGMReportLine.budgetExpense) * rl.budgetExpense;
			rl.actualDLFringeIRM = rl.actualExpense * frPercent;
			rl.budgetDLFringeIRM = rl.budgetExpense * frPercent;
		});

		lines.forEach(rl => {
			rl.actualDLFringeTotal = (rl.actualDLFringeIRM / totalGMReportLine.actualDLFringeIRM) * totalGMReportLine.actualDLFringeTotal;
			rl.budgetDLFringeTotal = (rl.budgetDLFringeIRM / totalGMReportLine.budgetDLFringeIRM) * totalGMReportLine.budgetDLFringeTotal;
			rl.actualGrossMargin = rl.actualRevenue - rl.actualExpense - rl.actualDLFringeTotal;
			rl.budgetGrossMargin = rl.budgetRevenue - rl.budgetExpense - rl.budgetDLFringeTotal;
			rl.actualGrossMarginPercent = rl.actualGrossMargin / rl.actualRevenue;
			rl.budgetGrossMarginPercent = rl.budgetGrossMargin / rl.budgetRevenue;
			rl.actualRevenuePercent = rl.actualRevenue / totalGMReportLine.actualRevenue;
			rl.budgetRevenuePercent = rl.budgetRevenue / totalGMReportLine.budgetRevenue;
			totalGMReportLine.actualGrossMargin += +rl.actualGrossMargin;
			totalGMReportLine.budgetGrossMargin += +rl.budgetGrossMargin;
		});
	};

}


export {GMReportLine}