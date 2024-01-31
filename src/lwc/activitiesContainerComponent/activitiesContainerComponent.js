import { LightningElement , api } from 'lwc';

export default class ActivitiesContainerComponent extends LightningElement 
{
    @api recordId;
    
    handleRefresh(){
        this.template.querySelector('c-custom-activity-timeline').getActivities();
    }
}