import { LightningElement , api , track , wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';

export default class CustomActivityTimelineItemChild extends NavigationMixin(LightningElement) {
    @api activityData;
    userName;
    cssString;
    iconName = 'utility:chevronright';
    @api recordName;
    @api recordId;
    activityDateAsStringClass = 'slds-timeline__date';

    @wire(getRecord, { recordId: Id, fields: [UserNameFld ]})
    userDetails({error, data}) {
        if (data) {
            this.userName = data.fields.Name.value;
        } else if (error) {
            console.log(error);
        }
    }

    connectedCallback(){
        console.log('activityData',this.activityData);
        this.cssString = this.activityData.cssClass;
        if(this.activityData.activitySubType == 'Task' && this.activityData.dateFieldsWrapperInstance.activityDateAsString != 'No due date'){
            this.activityDateAsStringClass = this.activityDateAsStringClass + ' overdueRed';
        }
    }

    handleExpandOrCollapse(){
        if(this.cssString.includes('slds-is-open')){
            this.cssString = this.activityData.cssClass;
            this.iconName = 'utility:chevronright';
        }
        else {
            this.cssString = this.cssString + ' slds-is-open';
            this.iconName = 'utility:chevrondown';
        }
    }
    handleToNavigation(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
    
    get isEvent(){
        return (this.activityData.activitySubType == 'Event');
    }
    get isEmail(){
        return (this.activityData.activitySubType == 'Email');
    }
    get isLoggedInUser(){
        return (this.activityData.fromAddress == 'You');
    }
    handleNavigation(){

        //if()
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.activityData.activityId,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
}