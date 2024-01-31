import { LightningElement , api } from 'lwc';

export default class ActivityTimelineTabs extends LightningElement
{
    @api recordId;
    isNewTask = false;
    isNewEvent = false;
    isNewEmail = false;

    handleNewTask(){
        this.isNewTask = true;
    }
    handleNewEvent(){
        this.isNewEvent = true;
    }
    handleNewEmail(){
        this.isNewEmail = true;
    }
    handleSave(){

    }
    handleAdd(){
        this.isNewTask = true;
    }
    handleCloseFields(event){
        if(event.detail.object == 'Task'){
            this.isNewTask = false;
        }
        else if(event.detail.object == 'Event'){
            this.isNewEvent = false;
        }
        else if(event.detail.object == 'Email'){
            this.isNewEmail = false;
        }
        console.log(' event.detail : ',event.detail);
        if(event.detail.action == 'Save'){
            this.dispatchEvent(new CustomEvent('refresh'));
        }
    }
}