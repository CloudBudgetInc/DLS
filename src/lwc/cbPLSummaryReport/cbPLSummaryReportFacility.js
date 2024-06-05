//import {_message} from "c/cbUtils";
import {ReportLine} from "./cbPLSummaryReportWrapper";

const getFacilityReportLines = (reportLines) => {
	reportLines = reportLines.filter(rl => rl.var1?.includes('FSC'));
	const reportLinesByDim1 = {};
	reportLines.forEach(rl => {
		if (!rl.var1?.includes('FSC0')) return null; // no facility
		let rLines = reportLinesByDim1[rl.var1];
		if (!rLines) {
			rLines = [];
			reportLinesByDim1[rl.var1] = rLines;
		}
		rLines.push(rl);
	});
	let updatedReportLines = [];
	const facilityTotal = new ReportLine('Total Facilities', 'totalLine');
	Object.values(reportLinesByDim1).forEach(rLines => {
		const dimName = getFSCName(rLines[0].var1);
		const header = new ReportLine(dimName, 'totalLine', true);
		const groupTotal = new ReportLine('Total ' + dimName, 'totalLine');
		const splitLine = new ReportLine(' ', null, true);
		rLines.forEach(rl => groupTotal.sumUpLines(rl));
		facilityTotal.sumUpLines(groupTotal);
		updatedReportLines = [...updatedReportLines, header, ...rLines, groupTotal, splitLine];
	});
	updatedReportLines.push(facilityTotal);
	return updatedReportLines;
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