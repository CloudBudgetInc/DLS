import {LightningElement,track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getJobData from "@salesforce/apex/JobCommunityHomePage_Ctrl.getJobDetails";
import FORM_FACTOR from '@salesforce/client/formFactor';


export default class JobDetailCmp extends NavigationMixin(LightningElement) {
    @track jobList = {};
    showSpinner = false;
    isLoaded = false;

    connectedCallback() {
       
        if (this.isLoaded == false) {
            this.showSpinner = true;
            let jobRecordId = this.getJobRecordId();

            if (jobRecordId) {
                getJobData({
                        jobId: jobRecordId
                    }).then((result) => {
                        let jobList = JSON.parse(JSON.stringify(result));

                        if (jobList.length > 0) {

                            jobList.forEach(job => {
                                if (job.bpats__Posted_Date__c) {
                                    let posDt = job.bpats__Posted_Date__c;
                                    let dts = posDt.split('-');

                                    if (dts.length > 0) {
                                        job.postedDate = (dts[1] + '/' + dts[2] + '/' + dts[0]);
                                    }
                                }
                            });
                            this.jobList = jobList[0];
                        }
                        this.showSpinner = false;

                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        let msg;
                        if (error.body && error.body.message) {
                            msg = error.body.message;
                        }
                        this.showToast('Error', msg, 'error');
                    });
                this.isLoaded = true;
            }
        }
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    getJobRecordId() {
        let urlString = window.location.href;
        return urlString.split("=")[1];
    }
    navigateToHome() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }
    navigateToApplication() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "job-application"
            },
            state:{
                recordId : this.getJobRecordId()
            }
        });
    }
    get ClassForPC(){
        console.log(FORM_FACTOR);
        if(FORM_FACTOR != 'Small' ){
        return 'slds-text-align_right';
        }
        return '';
    }
}