import { LightningElement, api, track } from 'lwc';
import{ loadStyle } from 'lightning/platformResourceLoader';
import calendar from '@salesforce/resourceUrl/calendar';

export default class ActionPlanTableCmp extends LightningElement {
        
    @api viewMode;
    @track transformedActionPlanRecords = [];
    @api assessmentReportId;
    showErrMsg = false;

    get showErrMsgOnValidation(){
        return !this.viewMode && this.showErrMsg;
    }

    get isActionPlanAvailable(){
        return this.transformedActionPlanRecords && this.transformedActionPlanRecords.length > 0;
    }

    connectedCallback(){
        Promise.all([
            loadStyle(this, calendar)
        ])
    }
    @api
    get actionPlanRecords(){
        return this.actionPlanRecords;
    }

    set actionPlanRecords(value){
        var actionPlanRecordsCpy = [];
        if(value, value.length > 0){
            var valueCpy = JSON.parse(JSON.stringify(value));
            valueCpy.forEach(
                function(actionPlan, index){
                    
                    actionPlan.customId = 'actionPlan'+index;
                    actionPlanRecordsCpy.push(actionPlan);
                }
            );
            this.transformedActionPlanRecords = actionPlanRecordsCpy;
        }else{
            this.transformedActionPlanRecords = [];
        }
    }
    
    handleInputChange(event){
        var id = event.target.dataset.id,
            value = event.target.type == 'number' ? parseInt(event.target.value) : event.target.value;
        
        this.transformedActionPlanRecords.forEach(
            function(actionPlan, index){
                if(actionPlan.customId == id){
                    actionPlan[event.target.name] = value;
                }
            }
        );
    }

    addActionPlan(event){ 
        this.showErrMsg = false;     
        const newactionPlan = {customId:'actionPlan'+this.transformedActionPlanRecords.length + 1, Assessment_Report__c: this.assessmentReportId};
        this.transformedActionPlanRecords = [...this.transformedActionPlanRecords, newactionPlan];
         
    }

    deleteActionPlan(event){
        var index = event.target.dataset.index;
        
        var deleteActionPlan = this.transformedActionPlanRecords[index];
        if(deleteActionPlan.Id){
            this.dispatchEvent(new CustomEvent('delete', { detail : deleteActionPlan.Id}));
        }

        this.transformedActionPlanRecords.splice(parseInt(index), 1);
    }

    @api
    checkValidity() {
        
        let allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        
        allValid = this.transformedActionPlanRecords && this.transformedActionPlanRecords.length > 0;
        if(this.transformedActionPlanRecords && this.transformedActionPlanRecords.length < 1){
            this.showErrMsg = true;
        }
        return allValid;
    }

    @api
    getActionPlans(){
        var actionPlanRecordsToUpsert = JSON.parse(JSON.stringify(this.transformedActionPlanRecords));
        actionPlanRecordsToUpsert.forEach(
            function(score, index){
                delete score.customId;
            }
        );
        return actionPlanRecordsToUpsert;
    }
}