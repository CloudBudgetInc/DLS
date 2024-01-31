import { LightningElement, api, track } from 'lwc';
import{ loadStyle } from 'lightning/platformResourceLoader';
import calendar from '@salesforce/resourceUrl/calendar';
import getAllPicklistValues from "@salesforce/apex/CommonUtil.getAllPickListValuesByObject";

export default class ScoreTableCmp extends LightningElement {
       
    @api viewMode;
    @track transformedScoreRecords = [];
    @api assessmentReportId;
    picklistValues = {};
    showErrMsg = false;

    get showErrMsgOnValidation(){
        return !this.viewMode && this.showErrMsg;
    }

    get isScoreAvailable(){
        return this.transformedScoreRecords && this.transformedScoreRecords.length > 0;
    }

    connectedCallback(){
        Promise.all([
            loadStyle(this, calendar)
        ])
        this.getPicklistValues();
    }

    @api
    get scoreRecords(){
        return this.scoreRecords;
    }

    set scoreRecords(value){
        
        var scoreRecordsCpy = [];
        
        if(value, value.length > 0){
            var valueCpy = JSON.parse(JSON.stringify(value));
            valueCpy.forEach(
                function(score, index){
                    
                    score.customId = 'score'+index;
                    scoreRecordsCpy.push(score);
                }
            );
            this.transformedScoreRecords = scoreRecordsCpy;
        }else{
            this.transformedScoreRecords = [];
        }
    }

    handleInputChange(event){
        var id = event.target.dataset.id,
            value = event.target.type == 'number' ? parseInt(event.target.value) : event.target.value;
            
        this.transformedScoreRecords.forEach(
            function(score, index){
                if(score.customId == id){
                    score[event.target.name] = value;
                }
            }
        );        
    }

    addScore(event){ 
        this.showErrMsg = false;     
        const newScore = {customId:'score'+this.transformedScoreRecords.length + 1, Assessment_Report__c: this.assessmentReportId};
        this.transformedScoreRecords = [...this.transformedScoreRecords, newScore];        
    }

    deleteScore(event){
        var index = event.target.dataset.index;
        
        var deleteScore = this.transformedScoreRecords[index];
        if(deleteScore.Id){
            this.dispatchEvent(new CustomEvent('delete', { detail : deleteScore.Id}));
        }

        this.transformedScoreRecords.splice(parseInt(index), 1);
    }

    @api
    checkValidity() {
        
        let allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if(this.template.querySelector('lightning-combobox')){                
            this.template.querySelector('lightning-combobox').reportValidity();        
            allValid = allValid && this.template.querySelector('lightning-combobox').checkValidity();  
        } 
        allValid =  this.transformedScoreRecords && this.transformedScoreRecords.length > 0;  
        if(this.transformedScoreRecords && this.transformedScoreRecords.length < 1){
            this.showErrMsg = true;
        }
        return allValid;
    }

    @api
    getTestScores(){
        var scoreRecordsToUpsert = JSON.parse(JSON.stringify(this.transformedScoreRecords));
        scoreRecordsToUpsert.forEach(
            function(score, index){
                delete score.customId;
            }
        );
        return scoreRecordsToUpsert;
    }

    getPicklistValues(){

        getAllPicklistValues({ objName: 'Test_Score__c'})
            .then(result => {
                
                this.picklistValues = JSON.parse(result);                         
            })
            .catch(error => {
                console.log(error);
            });
    }
}