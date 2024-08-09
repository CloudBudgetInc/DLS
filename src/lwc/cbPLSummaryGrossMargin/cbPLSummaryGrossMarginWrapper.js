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
	actualDLFringe;
	actualDLFringeIRM;
	actualDLFringeTotal;
	actualGrossMargin;
	actualGrossMarginPercent;
	actualRevenuePercent;

	budgetRevenue;
	budgetExpense;
	budgetDLFringe;
	budgetDLFringeIRM;
	budgetDLFringeTotal;
	budgetGrossMargin;
	budgetGrossMarginPercent;
	budgetRevenuePercent;

	formatStyle = 'currency';

	calculateDLFringe = (lines, totalGMReportLine, fringesMap) => {
		const {actualDLFringeIRMTotal, budgetDLFringeIRMTotal} = this.accumulateTotals(lines, totalGMReportLine, fringesMap);
		this.calculateLineFringes(lines, totalGMReportLine, fringesMap, actualDLFringeIRMTotal, budgetDLFringeIRMTotal);
	};

	accumulateTotals = (lines, totalGMReportLine, fringesMap) => {
		let actualDLFringeIRMTotal = 0;
		let budgetDLFringeIRMTotal = 0;

		lines.forEach(rl => {
			totalGMReportLine.actualRevenue += +rl.actualRevenue;
			totalGMReportLine.actualExpense += +rl.actualExpense;
			totalGMReportLine.budgetRevenue += +rl.budgetRevenue;
			totalGMReportLine.budgetExpense += +rl.budgetExpense;

			let frPercent = fringesMap[rl.label] || 0;
			let actualExpenseFringe = rl.actualExpense * frPercent;
			let budgetExpenseFringe = rl.budgetExpense * frPercent;

			actualDLFringeIRMTotal += actualExpenseFringe;
			budgetDLFringeIRMTotal += budgetExpenseFringe;

			totalGMReportLine.actualDLFringeIRM += actualExpenseFringe;
			totalGMReportLine.budgetDLFringeIRM += budgetExpenseFringe;
		});

		totalGMReportLine.actualDLFringeTotal = totalGMReportLine.actualDLFringeIRM;
		totalGMReportLine.budgetDLFringeTotal = totalGMReportLine.budgetDLFringeIRM;

		totalGMReportLine.actualRevenuePercent = 1;
		totalGMReportLine.budgetRevenuePercent = 1;

		return {actualDLFringeIRMTotal, budgetDLFringeIRMTotal};
	};

	calculateLineFringes = (lines, totalGMReportLine, fringesMap, actualDLFringeIRMTotal, budgetDLFringeIRMTotal) => {
		lines.forEach(rl => {
			rl.actualDLFringe = (totalGMReportLine.actualDLFringe / totalGMReportLine.actualExpense) * rl.actualExpense;
			rl.budgetDLFringe = (totalGMReportLine.budgetDLFringe / totalGMReportLine.budgetExpense) * rl.budgetExpense;

			let frPercent = fringesMap[rl.label] || 0;
			rl.actualDLFringeIRM = rl.actualExpense * frPercent;
			rl.budgetDLFringeIRM = rl.budgetExpense * frPercent;

			rl.actualDLFringeTotal = (rl.actualDLFringeIRM / actualDLFringeIRMTotal) * totalGMReportLine.actualDLFringeTotal;
			rl.budgetDLFringeTotal = (rl.budgetDLFringeIRM / budgetDLFringeIRMTotal) * totalGMReportLine.budgetDLFringeTotal;

			rl.actualGrossMargin = rl.actualRevenue - rl.actualExpense - rl.actualDLFringeTotal;
			rl.budgetGrossMargin = rl.budgetRevenue - rl.budgetExpense - rl.budgetDLFringeTotal;

			if (rl.actualRevenue) rl.actualGrossMarginPercent = rl.actualGrossMargin / rl.actualRevenue;
			if (rl.budgetRevenue) rl.budgetGrossMarginPercent = rl.budgetGrossMargin / rl.budgetRevenue;

			rl.actualRevenuePercent = rl.actualRevenue / totalGMReportLine.actualRevenue;
			rl.budgetRevenuePercent = rl.budgetRevenue / totalGMReportLine.budgetRevenue;

			totalGMReportLine.actualGrossMargin += rl.actualGrossMargin;
			totalGMReportLine.budgetGrossMargin += rl.budgetGrossMargin;
		});
		totalGMReportLine.actualGrossMarginPercent = totalGMReportLine.actualGrossMargin / totalGMReportLine.actualRevenue;
		totalGMReportLine.budgetGrossMarginPercent = totalGMReportLine.budgetGrossMargin / totalGMReportLine.budgetRevenue;
	};

}


export {GMReportLine}