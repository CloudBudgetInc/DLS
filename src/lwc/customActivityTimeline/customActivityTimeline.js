import { LightningElement , api , track } from 'lwc';
import getActivities from '@salesforce/apex/CustomActivityTimelineController.getActivities';

export default class CustomActivityTimeline extends LightningElement {

    @api recordId;
    @track activitiesWrapper;
    @track mapData;
    @track keys = [];
    recordName;
    isNillActivities = false;
    isLoaded;

    connectedCallback(){
        console.log('recordId',this.recordId);
        this.getActivities();
    }
    @api
    getActivities(){
        this.isLoaded = false;
        getActivities({recordId : this.recordId})
        .then((result)=>{
                this.isLoaded = true;
                console.log('result',JSON.parse(result));
                let activitiesWrapper = JSON.parse(result);
                this.recordName = activitiesWrapper.Name;
                this.mapData = JSON.parse(JSON.stringify(activitiesWrapper.activityWrapperWithStringMap));
                this.keys = Object.keys(this.mapData);
                console.log('Length : ',this.mapData['No Activities'].length);
                if(this.mapData['No Activities'].length == 0){
                    this.isNillActivities = true;
                }
        }).catch((error)=>{
            console.log('error',error);
        })
    }
}