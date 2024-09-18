import {api, LightningElement, track} from 'lwc';
import {_message, _parseServerError} from "c/cbUtils";
import getFringePercentServer from '@salesforce/apex/CBPLSummaryReportPageController.getFringePercentServer';
import getAFSATLaborTotalServer from '@salesforce/apex/CBPLSummaryReportPageController.getAFSATLaborTotalServer';
import getVar2Server from '@salesforce/apex/CBPLSummaryReportPageController.getVar2Server';
import {GMReportLine} from "./cbPLSummaryGrossMarginWrapper";
import {downloadExcelFile, setExcelLibContext} from "./cbPLSummaryGrossMarginExcel";
import {prepareDataForChart} from "./cbPLSummaryGrossMarginChart";

export default class CbPLSummaryGrossMargin extends LightningElement {

	@api selectedPeriodId;
	@api firstPeriodId;
	@api selectedPeriodMode;
	@api reportLines;
	@track fringesMap;
	@track GMReportLines;
	@track actualFringeTotal;
	@track budgetFringeTotal;
	@track EFLSplit = true;
	@track splitLT = false;
	@track renderAllColumns = true;
	@track var2SubtypeMapping;
	@track var2ChartSectionMapping;
	@track AFSATLaborMap;
	@track renderMargin = true; // toggle renders margin or revenue percent
	sumFields = [
		'actualRevenue',
		'actualExpense',
		'actualDLFringe',
		'actualDLFringeIRM',
		'actualDLFringe2',
		'actualGrossMargin',
		'budgetRevenue',
		'budgetExpense',
		'budgetDLFringe',
		'budgetDLFringeIRM',
		'budgetDLFringe2',
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
		await this.getAFSATLaborTotal();
		await this.getVar2Info();
		await this.getGetFringePercent().then(r => null);
		this.generateGMReportLines();
		if(!this.renderAllColumns) this.generateDataForChart();
	};

	getAFSATLaborTotal = async () => {
		this.AFSATLaborMap = await getAFSATLaborTotalServer({
			startPeriodId: this.selectedPeriodMode === 'current' ? this.selectedPeriodId : this.firstPeriodId,
			endPeriodId: this.selectedPeriodId
		}).catch(e => _parseServerError('Get EFL Other Error: ', e));
	};

	getVar2Info = async () => {
		const var2Array = await getVar2Server().catch(e => _parseServerError('Get Var2 Error: ', e));
		this.var2SubtypeMapping = var2Array.reduce((r, v2) => {
			r[v2.Name] = v2.Subtype__c ? v2.Subtype__c : '---';
			return r;
		}, {});
		this.var2ChartSectionMapping = var2Array.reduce((r, v2) => {
			r[v2.Name] = v2.ChartSection__c ? v2.ChartSection__c : 'Other';
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
			let reportLines = JSON.parse(JSON.stringify(this.reportLines));
			const isYTDMode = reportLines.some(rl => rl.currentMonthActualYTD > 5);
			if (this.EFLSplit) reportLines = this.splitELFReportLine(reportLines);
			this.processReportLines(reportLines, GMReportLinesObj, isYTDMode, totalGMReportLine);
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

	/**
	 * [{"actual":46654.95,"budget":56926,"accType":"2.Expense"},{"actual":144472.34,"budget":148904,"accType":"1.Revenue"}]
	 * {"label":"LT - EFL","type":"Revenue","account":"40130 - EFL Revenue","accountST2":"Language_Training","formatStyle":"currency","ddParams":"{\"account\":\"40130 - EFL Revenue\",\"type\":\"Revenue\",\"label\":\"LT - EFL\"}","isWrapper":false,"currentMonthActual":271658.18,"currentMonthBudget":280500,"currentMonthDiff":-8841.820000000007,"currentMonthDiffPercent":-0.0325475934499746,"currentMonthDiffPercentX100":-3.25475934499746,"priorMonthActual":274597.82,"priorMonthBudget":270559,"priorMonthDiff":-2939.640000000014,"priorMonthDiffPercent":-0.010821098779355776,"priorYearActual":244622.25,"priorYearBudget":0,"priorYearDiff":27035.929999999993,"priorYearDiffPercent":0.09952186972613886,"currentMonthActualYTD":0,"currentMonthBudgetYTD":0,"currentMonthDiffYTD":0,"currentMonthDiffPercentYTD":1,"priorYearActualYTD":0,"priorYearDiffYTD":0,"priorYearDiffPercentYTD":1}
	 * @param reportLines
	 * @return {[]}
	 */
	splitELFReportLine = (reportLines) => {
		try {
			let updatedReportLines = [];
			reportLines.forEach(rl => {
				if (rl.label === 'LT - EFL') {
					try {
						const type = rl.type.includes('Revenue') ? 'Rev' : 'Exp';
						const AFSATLabor = this.AFSATLaborMap.find(m => m.accType.includes(type));
						const laborRL = JSON.parse(JSON.stringify(rl));
						const otherRL = JSON.parse(JSON.stringify(rl));
						laborRL.label = 'LT AFSAT Labor';
						otherRL.label = 'LT AFSAT ODCs';
						if (this.selectedPeriodMode === 'current') {
							laborRL.currentMonthActual = AFSATLabor.actual;
							laborRL.currentMonthBudget = AFSATLabor.budget;
							otherRL.currentMonthActual -= AFSATLabor.actual;
							otherRL.currentMonthBudget -= AFSATLabor.budget;
						} else {
							laborRL.currentMonthActualYTD = AFSATLabor.actual;
							laborRL.currentMonthBudgetYTD = AFSATLabor.budget;
							otherRL.currentMonthActualYTD -= AFSATLabor.actual;
							otherRL.currentMonthBudgetYTD -= AFSATLabor.budget;
						}

						updatedReportLines.push(laborRL);
						updatedReportLines.push(otherRL);
					} catch (e) {
						_message('error', 'ELF Iteration Error :' + JSON.stringify(e));
					}
				} else {
					updatedReportLines.push(rl);
				}
			});
			return updatedReportLines;
		} catch (e) {
			_message('error', 'Split ELF Error: ' + JSON.stringify(e));
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
			const globalTotalLine = this.createGMReportLine(`TOTAL`, 'totalLine');
			const uniqueSubtypes = [...new Set(Object.values(this.var2SubtypeMapping))];
			let subtypeObjectsArray = uniqueSubtypes.map(st => {
				const totalLine = this.createGMReportLine(`${st} TOTAL`, 'totalLine');
				const lines = GMReportLines.filter(rl => this.var2SubtypeMapping[rl.label] === st);
				lines.forEach(rl => this.sumFields.forEach(f => totalLine[f] += +rl[f]));
				totalLine.actualGrossMarginPercent = totalLine.actualGrossMargin / totalLine.actualRevenue;
				totalLine.budgetGrossMarginPercent = totalLine.budgetGrossMargin / totalLine.budgetRevenue;
				this.sumFields.forEach(f => globalTotalLine[f] += +totalLine[f]);
				globalTotalLine.actualGrossMarginPercent = globalTotalLine.actualGrossMargin / globalTotalLine.actualRevenue;
				globalTotalLine.budgetGrossMarginPercent = globalTotalLine.budgetGrossMargin / globalTotalLine.budgetRevenue;
				return {
					key: st,
					totalLine,
					lines
				};
			});
			const voidLine = {label: '-'};
			subtypeObjectsArray = subtypeObjectsArray.flatMap(({lines, totalLine}) => [
				...lines,
				totalLine,
				voidLine
			]);
			subtypeObjectsArray.push(globalTotalLine);
			return subtypeObjectsArray;
		} catch (e) {
			_message('error', 'Splitting error ' + JSON.stringify(e));
		}
	};

	@track chartData;
	@track chartIsReadyToRender = false;
	generateDataForChart = () => {
		this.chartData = prepareDataForChart(this.GMReportLines, this.var2ChartSectionMapping);
		this.chartIsReadyToRender = true;
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

	toggleRenderMarginRevenue = () => this.renderMargin = !this.renderMargin;

}