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
		this.actualDLFringe2 = 0;
		this.budgetDLFringe2 = 0;

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

	actualRevenue;				// С
	actualExpense; 				// D
	actualDLFringe;				// E
	actualDLFringeIRM;			// F
	actualDLFringe2;			// G
	actualGrossMargin;			// H
	actualGrossMarginPercent;	// I
	actualRevenuePercent;		// J

	budgetRevenue;
	budgetExpense;
	budgetDLFringe;
	budgetDLFringeIRM;
	budgetDLFringe2;
	budgetGrossMargin;
	budgetGrossMarginPercent;
	budgetRevenuePercent;

	formatStyle = 'currency';

	/**
	 *
	 * @param lines source report lines
	 * @param totalGMReportLine bottom section total
	 * @param fringesMap mapping of percents
	 */
	runReportCalculations = (lines, totalGMReportLine, fringesMap) => {
		this.calculateRevenueExpenseTotals(lines, totalGMReportLine);
		this.calculateDLFringes(lines, totalGMReportLine);
		this.calculateDLFringesIRM(lines, totalGMReportLine, fringesMap);
		this.calculateDLFringe2(lines, totalGMReportLine);
		this.calculateGrossMarginAndGrossMarginPercent(lines, totalGMReportLine);
		this.calculateRevenuePercent(lines, totalGMReportLine);
	};

	calculateRevenueExpenseTotals = (lines, totalGMReportLine) => {
		lines.forEach(rl => {
			totalGMReportLine.actualRevenue += +rl.actualRevenue;
			totalGMReportLine.actualExpense += +rl.actualExpense;
			totalGMReportLine.budgetRevenue += +rl.budgetRevenue;
			totalGMReportLine.budgetExpense += +rl.budgetExpense;
		});
	};

	calculateDLFringes = (lines, totalGMReportLine) => {
		const actualDiff = totalGMReportLine.actualDLFringe / totalGMReportLine.actualExpense;
		const budgetDiff = totalGMReportLine.budgetDLFringe / totalGMReportLine.budgetExpense;
		lines.forEach(rl => {
			rl.actualDLFringe = actualDiff * rl.actualExpense;
			rl.budgetDLFringe = budgetDiff * rl.budgetExpense;
		});
	};

	calculateDLFringesIRM = (lines, totalGMReportLine, fringesMap) => {
		lines.forEach(rl => {
			let frPercent = fringesMap[rl.label] || 0;
			rl.actualDLFringeIRM = rl.actualExpense * frPercent;
			rl.budgetDLFringeIRM = rl.budgetExpense * frPercent;
			totalGMReportLine.actualDLFringeIRM += rl.actualDLFringeIRM;
			totalGMReportLine.budgetDLFringeIRM += rl.budgetDLFringeIRM;
		});
	};

	calculateDLFringe2 = (lines, totalGMReportLine) => {
		lines.forEach(rl => {
			rl.actualDLFringe2 = (rl.actualDLFringeIRM / totalGMReportLine.actualDLFringeIRM) * totalGMReportLine.actualDLFringe;
			rl.budgetDLFringe2 = (rl.budgetDLFringeIRM / totalGMReportLine.budgetDLFringeIRM) * totalGMReportLine.budgetDLFringe;
			totalGMReportLine.actualDLFringe2 += rl.actualDLFringe2;
			totalGMReportLine.budgetDLFringe2 += rl.budgetDLFringe2;
		});
	};

	calculateGrossMarginAndGrossMarginPercent = (lines, totalGMReportLine) => {
		lines.forEach(rl => {
			rl.actualGrossMargin = rl.actualRevenue - rl.actualExpense - rl.actualDLFringe2;
			rl.budgetGrossMargin = rl.budgetRevenue - rl.budgetExpense - rl.budgetDLFringe2;
			rl.actualGrossMarginPercent = rl.actualRevenue ? rl.actualGrossMargin / rl.actualRevenue : 0;
			rl.budgetGrossMarginPercent = rl.budgetRevenue ? rl.budgetGrossMargin / rl.budgetRevenue : 0;
			totalGMReportLine.actualGrossMargin += rl.actualGrossMargin;
			totalGMReportLine.budgetGrossMargin += rl.budgetGrossMargin;
		});
		totalGMReportLine.actualGrossMarginPercent = totalGMReportLine.actualGrossMargin / totalGMReportLine.actualRevenue;
		totalGMReportLine.budgetGrossMarginPercent = totalGMReportLine.budgetGrossMargin / totalGMReportLine.budgetRevenue;
	};

	calculateRevenuePercent = (lines, totalGMReportLine) => {
		lines.forEach(rl => {
			rl.actualRevenuePercent = rl.actualRevenue / totalGMReportLine.actualRevenue;
			rl.budgetRevenuePercent = rl.budgetRevenue / totalGMReportLine.budgetRevenue;
		});
		delete totalGMReportLine.actualRevenuePercent;
		delete totalGMReportLine.budgetRevenuePercent;
	};
}


export {GMReportLine}