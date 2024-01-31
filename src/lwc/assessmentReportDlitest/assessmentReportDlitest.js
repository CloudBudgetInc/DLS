import { LightningElement, track, api } from "lwc";
import saveAssessmentReport from "@salesforce/apex/AssessmentReport_Ctrl.saveAssessmentReport";

export default class AssessmentReportDlitest extends LightningElement {
    
    @api picklistOptions = {};
    @track assessmentReport = {};
    assessmentReportCpy = {};  
    showSpinner = false;    
    viewMode = true;
    activeSections = ['READING','LISTENING','SPEAKING'];
    @track toastMsg = {show: false};
    @api showEditButton = false;
    showErrMsg = true;        

    @api
    get assessmentReportRec() {
        return this.assessmentReport;
    }

    set assessmentReportRec(value){
        this.assessmentReport = JSON.parse(JSON.stringify(value));
        this.assessmentReportCpy = JSON.parse(JSON.stringify(value));
    }    

    get isSelfAssessment(){
        return this.assessmentReport && this.assessmentReport.RecordType.Name == 'DLI-W Self-Assessment Test Report';
    }

    handleinputchange(event){
        //console.log(event.target.value, event.target.name);
        if(event.target.dataset.type == 'number'){
            this.assessmentReport[event.target.name] = parseInt(event.target.value);
        }else{
            this.assessmentReport[event.target.name] = event.target.value;
        }
    }

    toggleMode(event){
        
        if(event.detail){
            
            this.assessmentReport = JSON.parse(JSON.stringify(this.assessmentReportCpy));           
        }
        this.viewMode = !this.viewMode;
        this.showErrMsg = false;
        const elements = this.template.querySelectorAll('.requiredCls');
        for(let ele of elements){
            ele.classList.remove('slds-has-error');             
        }  
    }

    saveAssessmentReport(event){
        //console.log('save::',this.assessmentReport);
        this.showSpinner = true;
        let isValidAssessmentReport = true;
        const elements = this.template.querySelectorAll('.requiredCls');
        console.log(elements.length);
        for(let ele of elements){
            console.log(ele.name, ele.value);
            if(!ele.value && event.detail == 'Submit'){
                isValidAssessmentReport = false; 
                ele.classList.add('slds-has-error');        
            }else{
                ele.classList.remove('slds-has-error'); 
            }
        }     
        
        if(!isValidAssessmentReport){
            this.showSpinner = false;
            this.showToast('Please complete all fields before submitting to your LTS.', 'Error');
        }else{
            //Added By Dhinesh - 23-10-2020 - Change Status as Submitted to LTS when Save and Submit button clicked
            this.assessmentReport.Status__c = event.detail == 'Submit' ? 'Submitted to LTS' :  JSON.parse(JSON.stringify(this.assessmentReportCpy)).Status__c;
            if(event.detail == 'Submit' && JSON.parse(JSON.stringify(this.assessmentReportCpy)).Project_Task__r){
                this.assessmentReport.Total_Hours_Used__c = JSON.parse(JSON.stringify(this.assessmentReportCpy)).Project_Task__r.Total_Hours_Used_For_Language_Training__c;
            }
            //Added By Dhinesh - 21-06-2021 - Update Prefilled_from_Recent_Completed_Report__c as false on save
            this.assessmentReport.Prefilled_from_Recent_Completed_Report__c = this.assessmentReport.Prefilled_from_Recent_Completed_Report__c ? false : this.assessmentReport.Prefilled_from_Recent_Completed_Report__c;
            
            var saveChanges = {assessmentReport: this.assessmentReport}
            saveAssessmentReport({saveChangeStr : JSON.stringify(saveChanges)})
            .then(result => {
                this.showSpinner = false;
                if(result == 'success'){
                    this.viewMode = true;
                    this.showToast((event.detail == 'Submit') ? ' Your Report has been Saved and was Submitted to your LTS.' : 'Report saved successfully!', 'Success');
                }else{
                    console.log(result);
                    this.showToast(result, 'Error');                
                }            
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast(error, 'Error');    
                //console.log(error);
            })  
        }      
    }

    showToast(message, header) {
       this.toastMsg.show = true;
       this.toastMsg.message = message;
       this.toastMsg.header = header;
    }

    closeToast(){
        this.showErrMsg = false;
    }

    get showErrorToast(){
        return this.assessmentReport.Prefilled_from_Recent_Completed_Report__c && this.showErrMsg;
    }

    closeToastMsg(event){
        this.toastMsg.show = false;
    }    
}