import { LightningElement ,api , track} from 'lwc';

export default class CustomActivityTimelineItem extends LightningElement {
    @api timelineData;
    @api recordId;
    @api recordName;
    @api mapKey;
    iconName = 'utility:chevrondown';
    isExpandOrCollapse = true;
    noActivities = false;
    noUpcomingAndOverDue = false;

    @track monthsAgo;
    @track activitiesList = [];

    connectedCallback(){
        if(this.timelineData[this.mapKey].length == 0 && this.mapKey == 'No Activities'){
            this.noActivities = true;
        }
        else if(this.timelineData[this.mapKey].length == 0 && this.mapKey == 'Upcoming & Overdue'){
            this.noUpcomingAndOverDue = true;
        }
        else{
            var map = JSON.parse(JSON.stringify(this.timelineData));
            this.monthsAgo = map[this.mapKey][0].dateFieldsWrapperInstance.monthsAgo;
            this.activitiesList = this.timelineData[this.mapKey];
        }
    }
    handleExpandOrCollapse(){
        if(this.iconName == 'utility:chevrondown'){
            this.iconName = 'utility:chevronright';
        }
        else if(this.iconName == 'utility:chevronright'){
            this.iconName = 'utility:chevrondown';
        }
        this.isExpandOrCollapse = !(this.isExpandOrCollapse);
    }
    get checkNillActivities(){
        if(this.activitiesList.length > 0){
            return true;
        }
    }
}