import { LightningElement, api } from 'lwc';

export default class ButtonGroupForAssessmentReports extends LightningElement {
    @api viewMode = false;
    toggleMode(event){
        var isCancel = event.target.name == 'Cancel' ? true : false;                
        this.dispatchEvent(new CustomEvent('togglemode', { detail: isCancel }));
    }
    saveAssessmentReport(event){
        this.dispatchEvent(new CustomEvent('saveassessmentreport', {detail: event.target.name}));
    }

}