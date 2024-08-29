//import {_message} from "c/cbUtils";
import {ReportLine} from "./cbPLSummaryReportWrapper";

const TOTAL_LINE_CSS = 'totalLine';
const S_TOTAL_LINE_CSS = 'subTotalLine';

const getFacilityReportLines = reportLines => {
	reportLines = reportLines.filter(rl => rl.var1?.includes('FSC'));
	const reportLinesByDim1 = {}; // key is rl.var1
	reportLines.forEach(rl => {
		if (!rl.var1?.includes('FSC0')) return null; // no facility
		if(rl.label.startsWith('6')) return null;
		let rLines = reportLinesByDim1[rl.var1];
		if (!rLines) {
			rLines = [];
			reportLinesByDim1[rl.var1] = rLines;
		}
		rLines.push(rl);
	});
	let updatedReportLines = [];
	const facilityTotal = new ReportLine('Total Facilities', TOTAL_LINE_CSS); // global total line
	Object.values(reportLinesByDim1).forEach(rLines => {
		const dimName = getFSCName(rLines[0].var1);
		const header = new ReportLine(dimName, TOTAL_LINE_CSS, true);
		const groupTotal = new ReportLine(`Total ${dimName}`, TOTAL_LINE_CSS);
		const splitLine = new ReportLine(' ', null, true);
		rLines.forEach(rl => console.log(JSON.stringify(rl)));
		rLines.forEach(rl => groupTotal.sumUpLines(rl));
		facilityTotal.sumUpLines(groupTotal);
		rLines = addAccountST2Subtotals(rLines);
		updatedReportLines = [...updatedReportLines, header, ...rLines, groupTotal, splitLine];
	});
	updatedReportLines.push(facilityTotal);
	return updatedReportLines;
};

/**
 * Additional method to make subgroups by SubAccount 2
 */
const addAccountST2Subtotals = (rLines) => {
	const ST2Object = {};
	rLines.forEach(rl => {
		let rlGroup = ST2Object[rl.accountST2];
		if(!rlGroup) {
			rlGroup = [];
			ST2Object[rl.accountST2] = rlGroup;
		}
		rlGroup.push(rl);
	});

	Object.keys(ST2Object).forEach(key => {
		const rlGroup = ST2Object[key];
		const accST2Total = new ReportLine(`Total ${key}`, S_TOTAL_LINE_CSS);
		rlGroup.forEach(rl => accST2Total.sumUpLines(rl));
		rlGroup.push(accST2Total);
	});
	let r = [];
	Object.values(ST2Object).forEach(rlGroup => {
		r = [...r, ...rlGroup];
	});
	return r;

};

const getFSCName = (dim1) => {
	switch (dim1) {
		case 'FSC0HRN':
			return 'Herndon';
		case 'FSC0MD':
			return "Maryland";
		case 'FSC0ARL':
			return 'Arlington ';
		default:
			return 'Other'
	}
};


export {
	getFacilityReportLines
}