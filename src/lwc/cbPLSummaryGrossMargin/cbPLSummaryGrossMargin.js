import {api, LightningElement, track} from 'lwc';
import {_message, _parseServerError} from "c/cbUtils";
import getFringePercentServer from '@salesforce/apex/CBPLSummaryReportPageController.getFringePercentServer';
import getVar2Server from '@salesforce/apex/CBPLSummaryReportPageController.getVar2Server';
import {GMReportLine} from "./cbPLSummaryGrossMarginWrapper";
import {downloadExcelFile, setExcelLibContext} from "./cbPLSummaryGrossMarginExcel";

export default class CbPLSummaryGrossMargin extends LightningElement {

	@api selectedPeriodId;
	@api reportLines;
	@track fringesMap;
	@track GMReportLines;
	@track actualFringeTotal;
	@track budgetFringeTotal;
	@track splitLT = false;
	@track renderAllColumns = true;
	@track var2Mapping;
	sumFields = [
		'actualRevenue',
		'actualExpense',
		'actualDLFringe',
		'actualDLFringeIRM',
		'actualDLFringeTotal',
		'actualGrossMargin',
		'budgetRevenue',
		'budgetExpense',
		'budgetDLFringe',
		'budgetDLFringeIRM',
		'budgetDLFringeTotal',
		'budgetGrossMargin',
		'actualRevenuePercent',
		'budgetRevenuePercent'
	];

	async connectedCallback() {
		try {
			this.doInit();
		} catch (e) {
			_message('error', 'GM CALLBACK ERROR :  ' + JSON.stringify(e));
		}
	}

	doInit = async () => {
		this.GMReportLines = [];
		await this.getVar2Info();
		await this.getGetFringePercent().then(r => null);
		this.generateGMReportLines();
	};

	getVar2Info = async () => {
		const var2Array = await getVar2Server().catch(e => _parseServerError('Get Var2 Error: ', e));
		this.var2Mapping = var2Array.reduce((r, v2) => {
			r[v2.Name] = v2.Subtype__c ? v2.Subtype__c : '---';
			return r;
		}, {});
	};

	getGetFringePercent = async () => {
		this.fringesMap = await getFringePercentServer({periodsId: this.selectedPeriodId}).catch(e => _parseServerError('Fringe Error: ', e));
	};

	///////////
	generateGMReportLines = () => {
		try {
			this.GMReportLines = [];
			const GMReportLinesObj = {};
			const totalGMReportLine = this.createGMReportLine('TOTAL', 'totalLine');
			const isYTDMode = this.reportLines.some(rl => rl.currentMonthActualYTD > 5);
			this.processReportLines(this.reportLines, GMReportLinesObj, isYTDMode, totalGMReportLine);
			let GMReportLines = Object.values(GMReportLinesObj);
			new GMReportLine().runReportCalculations(GMReportLines, totalGMReportLine, this.fringesMap);
			if (this.splitLT) {
				GMReportLines = this.handleSplitBySubtype(GMReportLines);
			} else {
				GMReportLines.push(totalGMReportLine);
			}
			this.GMReportLines = GMReportLines;
		} catch (e) {
			_message('error', 'Get GM Report Lines Error: ' + JSON.stringify(e));
		}
	};

// 1. Initialization Helper
	createGMReportLine = (label, styleClass = '') => {
		const line = new GMReportLine(label);
		if (styleClass) line.styleClass = styleClass;
		return line;
	};

	processReportLines = (reportLines, GMReportLinesObj, isYTDMode, totalGMReportLine) => {
		reportLines.forEach(rl => {
			if (rl.label === 'Direct Fringe') {
				totalGMReportLine.actualDLFringe = isYTDMode ? rl.currentMonthActualYTD : rl.currentMonthActual;
				totalGMReportLine.budgetDLFringe = isYTDMode ? rl.currentMonthBudgetYTD : rl.currentMonthBudget;
				return;
			}
			if (rl.type !== 'Revenue' && rl.type !== 'COGS') return;

			if (!GMReportLinesObj[rl.label]) {
				GMReportLinesObj[rl.label] = new GMReportLine(rl.label);
			}

			const GMRL = GMReportLinesObj[rl.label];
			if (rl.type === 'Revenue') {
				GMRL.actualRevenue += isYTDMode ? rl.currentMonthActualYTD : rl.currentMonthActual;
				GMRL.budgetRevenue += isYTDMode ? rl.currentMonthBudgetYTD : rl.currentMonthBudget;
			} else if (rl.type === 'COGS') {
				GMRL.actualExpense += isYTDMode ? rl.currentMonthActualYTD : rl.currentMonthActual;
				GMRL.budgetExpense += isYTDMode ? rl.currentMonthBudgetYTD : rl.currentMonthBudget;
			}
		});
	};

	/**
	 * Method splits the data to LT and all another part to separate the report
	 * @param GMReportLines
	 * @return {*[]}
	 */
	handleSplitBySubtype = (GMReportLines) => {
		try {
			const uniqueSubtypes = [...new Set(Object.values(this.var2Mapping))];
			const subtypeObjectsArray = uniqueSubtypes.map(st => {
				const totalLine = this.createGMReportLine(`${st} TOTAL`, 'totalLine');
				const lines = GMReportLines.filter(rl => this.var2Mapping[rl.label] === st);
				lines.forEach(rl => this.sumFields.forEach(f => totalLine[f] += +rl[f]));
				totalLine.actualGrossMarginPercent = totalLine.actualGrossMargin / totalLine.actualRevenue;
				totalLine.budgetGrossMarginPercent = totalLine.budgetGrossMargin / totalLine.budgetRevenue;
				return {
					key: st,
					totalLine,
					lines
				};
			});
			const voidLine = {label: '-'};
			return subtypeObjectsArray.flatMap(({lines, totalLine}) => [
				...lines,
				totalLine,
				voidLine
			]);
		} catch (e) {
			_message('error', 'Splitting error ' + JSON.stringify(e));
		}
	};

	/**
	 * Method splits the data to LT and all another part to separate the report
	 * @param GMReportLines
	 * @return {*[]}
	 */
	handleSplitBySubtype2 = (GMReportLines) => {
		const LTVar2 = [];
		const otherVar2 = [];
		const LTTotalGMReportLine = this.createGMReportLine('LT TOTAL', 'totalLine');
		const otherTotalGMReportLine = this.createGMReportLine('OTHER TOTAL', 'totalLine');

		GMReportLines.forEach(rl => {
			if (rl.label.includes('LT')) {
				this.sumFields.forEach(f => LTTotalGMReportLine[f] += +rl[f]);
				LTVar2.push(rl);
			} else {
				this.sumFields.forEach(f => otherTotalGMReportLine[f] += +rl[f]);
				otherVar2.push(rl);
			}
		});
		LTTotalGMReportLine.actualGrossMarginPercent = LTTotalGMReportLine.actualGrossMargin / LTTotalGMReportLine.actualRevenue;
		LTTotalGMReportLine.budgetGrossMarginPercent = LTTotalGMReportLine.budgetGrossMargin / LTTotalGMReportLine.budgetRevenue;
		otherTotalGMReportLine.actualGrossMarginPercent = otherTotalGMReportLine.actualGrossMargin / otherTotalGMReportLine.actualRevenue;
		otherTotalGMReportLine.budgetGrossMarginPercent = otherTotalGMReportLine.budgetGrossMargin / otherTotalGMReportLine.budgetRevenue;

		return [...LTVar2, LTTotalGMReportLine, ...otherVar2, otherTotalGMReportLine];
	};
	///////////


	////////// EXCEL FUNCTIONALITY
	// This method downloads an Excel file for Gross Margin report
	downloadExcel = () => {
		setExcelLibContext(this);
		downloadExcelFile();
	};
	////////// EXCEL FUNCTIONALITY

	handleToggle = (event) => {
		this[event.target.name] = event.target.checked;
		this.doInit();
	};

}