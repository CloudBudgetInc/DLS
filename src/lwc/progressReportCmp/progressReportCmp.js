import { LightningElement, api, wire, track } from 'lwc';
import getAssessmentReport from "@salesforce/apex/AssessmentReport_Ctrl.getAssessmentReportById";
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import Assessment_Report from '@salesforce/schema/Assessment_Report__c';
export default class ProgressReportCmp extends LightningElement {
    @api
    recordId;    
    assessmentReport;
    @track picklistOptions = {};
    isAllowEdit = true;
    studentConAssign;
    
    connectedCallback(){
        if(!this.recordId){
            var params = new URL(window.location.href).searchParams;
            this.recordId = params.get('recordId');
        }
        if(this.recordId){
            getAssessmentReport({ recordId : this.recordId})
                .then(result => {
                    
                    this.assessmentReport = result.assessmentRec;  
                    this.isAllowEdit = result.isAllowEdit;
                    this.studentConAssign = result.studentCA;                  
                })
                .catch(error => {
                    console.log(error);
                });
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: Assessment_Report, recordTypeId: '$assessmentReport.RecordTypeId' })
    wiredRecord({error, data}) {
        if (error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.record = undefined;
            console.log(this.error);
        } else if (data) {
            // Process record data
            let picklistValues = data.picklistFieldValues,
            fieldAPINameWithPickListValues = {};
            for (const property in picklistValues) {
                let obj = picklistValues[property];
                let skipPicklistValues = (property == 'Current_Estimated_ILR_Rating_Listening__c'  || property == 'Current_Estimated_ILR_Rating_Reading__c' || property == 'Current_Estimated_ILR_Rating_Speaking__c') && this.assessmentReport && this.assessmentReport.Language_Training_Status__c == 'Final';
                if(obj['values']) {
                    fieldAPINameWithPickListValues[property] = [];
                    obj['values'].forEach(function(element){
                        if(!skipPicklistValues || (skipPicklistValues && !element.value.includes('/'))){
                            let picklistvalue = {};
                            picklistvalue.label = element.label;
                            picklistvalue.value = element.value;
                            
                            fieldAPINameWithPickListValues[property].push(picklistvalue);
                        }
                    });                    
                }
            }
            
            this.picklistOptions = fieldAPINameWithPickListValues;
        }
    }    

    get showLTReport(){
        return this.assessmentReport && this.picklistOptions && this.assessmentReport.RecordType.Name == 'Language Training Progress';
    }

    get showDLIReport(){
        return this.assessmentReport && this.picklistOptions && (this.assessmentReport.RecordType.Name == 'DLI-W Progress' || this.assessmentReport.RecordType.Name == 'APMO Progress' || this.assessmentReport.RecordType.Name == 'DEA Progress');
    }

    get showDLI22Report(){
        return this.assessmentReport && this.picklistOptions && this.assessmentReport.RecordType.Name == 'DLI-W Progress 2022';
    }

    get showDLITestReport(){
        return this.assessmentReport && this.picklistOptions && (this.assessmentReport.RecordType.Name == 'DLI-W Assessment by Instructor Report' || this.assessmentReport.RecordType.Name == 'DLI-W Self-Assessment Test Report');
    }

    get showTestReport(){
        return this.assessmentReport && this.picklistOptions && this.assessmentReport.RecordType.Name == 'Test Report';
    }

    get showEditButton(){
        return this.assessmentReport && ( this.assessmentReport.Status__c == 'Scheduled' || this.assessmentReport.Status__c == 'Submitted to LTS' ) && this.isAllowEdit;
    }
}