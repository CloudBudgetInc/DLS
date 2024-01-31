import { LightningElement, track, api, wire } from 'lwc';
import getActionPlansAndTestScores from '@salesforce/apex/AssessmentReport_Ctrl.getActionPlanAndTestScoreByAssessmentId';
import saveAssessmentReport from "@salesforce/apex/AssessmentReport_Ctrl.saveAssessmentReport";

export default class AssessmentReportForDli extends LightningElement {
    viewMode = true;
    @api picklistOptions;
    @track assessmentReport = {};  
    assessmentReportCpy = {};    
    viewMode = true;
    showSpinner = false;    
    activeSections = ['SPEAKING PROFICIENCY', 'LISTENING COMPREHENSION', 'READING COMPREHENSION', 'OTHER','READING','LISTENING','SPEAKING','End-of-training goal (per TO)','Current Estimated ILR Rating','Progress Towards Goal ILR Rating'];
    recordsToDelete = [];
    @track actionPlans = [];
    @track testScores = [];
    actionPlansAndTestScores;
    @track toastMsg = {show: false};
    @api showEditButton = false;
    showErrMsg = true; 
    @api studentConAssign;   

    get isAPMOReport(){
        return this.assessmentReport && (this.assessmentReport.RecordType.Name == 'APMO Progress' || this.assessmentReport.RecordType.Name == 'DEA Progress');
    }

    @api
    get assessmentReportRec() {
        return this.assessmentReport;
    }

    set assessmentReportRec(value){
        this.assessmentReport = JSON.parse(JSON.stringify(value));
        this.assessmentReportCpy = JSON.parse(JSON.stringify(value));

        this.getTestScoresAndActionPlans();
    }

    handleinputchange(event){
        
        if(event.target.dataset.type == 'number'){
            this.assessmentReport[event.target.name] = parseInt(event.target.value);
        }else{
            this.assessmentReport[event.target.name] = event.target.value;
        }
    }

    toggleMode(event){
        
        if(event.detail){
            
            this.assessmentReport = JSON.parse(JSON.stringify(this.assessmentReportCpy));            
            var actionPlansAndTestScoresCpy = JSON.parse(JSON.stringify(this.actionPlansAndTestScores));
            
            this.actionPlans = actionPlansAndTestScoresCpy.actionPlans ? actionPlansAndTestScoresCpy.actionPlans : [];
            this.testScores = actionPlansAndTestScoresCpy.testScores ? actionPlansAndTestScoresCpy.testScores : []; 
            
        }
        this.viewMode = !this.viewMode;
        this.showErrMsg = false ;
        const elements = this.template.querySelectorAll('.requiredCls');
        console.log(elements.length);
        for(let ele of elements){
            ele.classList.remove('slds-has-error');             
        }  
    }

    handleDelete(event){
        
        if(event.detail){
            this.recordsToDelete.push(event.detail);
        }
    }

    saveAssessmentReport(event){        

        var isValidScores = true;
        var isValidActionPlans = true;
        let isValidAssessmentReport = true;
        const elements = this.template.querySelectorAll('.requiredCls');
        for(let ele of elements){
            console.log(ele.name, ele.value);
            if(!ele.value && event.detail == 'Submit'){
                isValidAssessmentReport = false; 
                ele.classList.add('slds-has-error');        
            }else{
                ele.classList.remove('slds-has-error'); 
            }
        }   
        if(event.detail == 'Submit'){
            isValidScores = this.template.querySelector('c-score-table-cmp').checkValidity();
            isValidActionPlans = this.template.querySelector('c-action-plan-table-cmp').checkValidity();
        }         
        if(isValidScores && isValidActionPlans && isValidAssessmentReport){
            var scoresToUpsert = this.template.querySelector('c-score-table-cmp').getTestScores();
            var actionPlansToUpsert = this.template.querySelector('c-action-plan-table-cmp').getActionPlans();
            
            this.showSpinner = true;
            
            //Added By Dhinesh - 23-10-2020 - Change Status as Submitted to LTS when Save and Submit button clicked
            this.assessmentReport.Status__c = event.detail == 'Submit' ? 'Submitted to LTS' :  JSON.parse(JSON.stringify(this.assessmentReportCpy)).Status__c;
            if(event.detail == 'Submit' && JSON.parse(JSON.stringify(this.assessmentReportCpy)).Project_Task__r){
                this.assessmentReport.Total_Hours_Used__c = JSON.parse(JSON.stringify(this.assessmentReportCpy)).Project_Task__r.Total_Hours_Used_For_Language_Training__c;
            }

            //Modified by Dhinesh - 07/03/2023 - W-007723 update total hrs absent
            if(event.detail == 'Submit' && this.assessmentReport.RecordType.Name == 'DEA Progress' && this.studentConAssign){
                this.assessmentReport.Total_Hours_Absent__c = this.studentConAssign.Student_Hours_Absent__c;
            }

            //Added By Dhinesh - 21-06-2021 - Update Prefilled_from_Recent_Completed_Report__c as false on save
            this.assessmentReport.Prefilled_from_Recent_Completed_Report__c = this.assessmentReport.Prefilled_from_Recent_Completed_Report__c ? false : this.assessmentReport.Prefilled_from_Recent_Completed_Report__c;

            var saveChanges = {assessmentReport: this.assessmentReport, actionPlans: actionPlansToUpsert, testScores: scoresToUpsert, recordsToDelete: this.recordsToDelete};
            saveAssessmentReport({saveChangeStr : JSON.stringify(saveChanges)})
            .then(result => {
                this.showSpinner = false;
                console.log('success::>',result);
                if(result == 'success'){
                    this.viewMode = true;
                    this.showToast((event.detail == 'Submit') ? ' Your Report has been Saved and was Submitted to your LTS.' : 'Report saved successfully!', 'Success');
                    this.getTestScoresAndActionPlans();
                }else{
                    this.showToast(result, 'Error');                
                }            
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast(error, 'Error');    
                console.log('error:::>',error);
            })
        }else if(!isValidAssessmentReport){
            this.showToast('Please complete all fields before submitting to your LTS.', 'Error');
        }else{
            this.showToast('Check the errors!', 'Error');
        }
    }

    showToast(message, header) {
        this.toastMsg.show = true;
        this.toastMsg.message = message;
        this.toastMsg.header = header;
    }
 
    closeToastMsg(event){
        this.toastMsg.show = false;
    }

    closeToast(){
        this.showErrMsg = false;
    }

    get showErrorToast(){
        return this.assessmentReport.Prefilled_from_Recent_Completed_Report__c && this.showErrMsg;
    }

    getTestScoresAndActionPlans(){
        getActionPlansAndTestScores({assessmentId : this.assessmentReport.Id})
        .then( result => {
            console.log(result);
            this.actionPlansAndTestScores = result;
            this.actionPlans = result.actionPlans ? result.actionPlans : [];
            this.testScores = result.testScores ? result.testScores : [];
        })
        .catch(error => {

        })
    }
}