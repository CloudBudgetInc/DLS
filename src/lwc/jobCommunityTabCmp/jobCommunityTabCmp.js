import {LightningElement,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getJobData from "@salesforce/apex/JobCommunityHomePage_Ctrl.getJobDetails";

export default class JobCommunityTabCmp extends NavigationMixin(LightningElement) {
    @track jobList;
    showSpinner = false;

    connectedCallback() {
        this.showSpinner = true;
        getJobData({jobId : null}).then((result) => {
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
                    this.jobList = jobList;
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
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    navToJobDetailPage(event){
         let recordId = event.currentTarget.name;

        if(recordId){
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: "jobdetailview"
                },
                state:{
                    recordId : recordId
                }
            });
        }
    }

}