import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";

import Assessment_Object from "@salesforce/schema/Assessment_Report__c";

const FIELDS = [
  "Assessment_Report__c.RecordTypeId"
];

export default class ProgressReportDetailHeader extends LightningElement {
    @api recordId;
    @track recordTypeMap;
    @track assessmentRec;
    @track recordTypeId;

    @wire(getObjectInfo, { objectApiName: Assessment_Object })
    handleResult({ error, data }) {
        if (data) {
        
            this.recordTypeMap = data.recordTypeInfos;
        
        }
        if (error) {
        // handle error
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = "Unknown error";
            if (Array.isArray(error.body)) {
                message = error.body.map((e) => e.message).join(", ");
            } else if (typeof error.body.message === "string") {
                message = error.body.message;
            }
            console.log(message);
        } else if (data) {
            this.assessmentRec = data;
            this.recordTypeId = this.assessmentRec.fields.RecordTypeId.value;            
        }
    }

    get showLTReport(){
        var recordTypeName = '';
        if( this.recordTypeMap && this.recordTypeId){
            recordTypeName = this.recordTypeMap[this.recordTypeId].name;
        }
        console.log(recordTypeName);
        return recordTypeName != '' && recordTypeName == 'Language Training Progress';
    }

    get showDLIReport(){
        var recordTypeName = '';
        if( this.recordTypeMap && this.recordTypeId){
            recordTypeName = this.recordTypeMap[this.recordTypeId].name;
        }
        return recordTypeName != '' && (recordTypeName == 'DLI-W Progress' || recordTypeName == 'APMO Progress' || recordTypeName == 'DEA Progress' || recordTypeName == 'DLI-W Progress 2022');
    }

    get showDLITest(){
        var recordTypeName = '';
        if( this.recordTypeMap && this.recordTypeId){
            recordTypeName = this.recordTypeMap[this.recordTypeId].name;
        }
        return recordTypeName != '' && (recordTypeName == 'DLI-W Assessment by Instructor Report' || recordTypeName == 'DLI-W Self-Assessment Test Report');
    }

    get showTestReport(){
        var recordTypeName = '';
        if( this.recordTypeMap && this.recordTypeId){
            recordTypeName = this.recordTypeMap[this.recordTypeId].name;
        }
        return recordTypeName != '' && recordTypeName == 'Test Report';
    }

    back(){
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }
}