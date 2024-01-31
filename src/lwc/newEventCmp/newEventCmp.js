import { LightningElement , api } from 'lwc';
import insertEvent from '@salesforce/apex/CustomActivityTimelineController.insertEvent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NewEventCmp extends LightningElement 
{
    @api recordId;
    eventRecord = {};
    startDate;
    selectedProject;
    showSpinner = false;
    isAllDayEvent = false;
    
    handleProjectSelection(event){
        var selectedProject = { ...event.detail.selectedRecord };
        this.eventRecord[event.detail.fieldApiName] = selectedProject.Id;
    }
    checkRequiredFieldsValidity(){
        var assignedTo = this.template.querySelector('[data-id="userLookup"]');
        var startDateTime = this.template.querySelector('[data-id="StartDateTime"]');
        var endDateTime = this.template.querySelector('[data-id="EndDateTime"]');
        console.log('startDateTime: ',startDateTime);
        console.log('endDateTime: ',endDateTime);
        var isValid = true;
        if (!assignedTo.checkValidity()) {
            isValid = false;
            assignedTo.reportValidity();
        }
        if(!startDateTime.checkValidity()){
            isValid = false;
            startDateTime.reportValidity();

        }
        if(!endDateTime.checkValidity()){
            isValid = false;
            endDateTime.reportValidity();
        }
        return isValid;
    }
    handleSave(){
        var isValid = this.checkRequiredFieldsValidity();
        this.eventRecord['WhatId'] = this.recordId;
        var eventList = [];
        eventList.push(this.eventRecord);
        if(isValid){
            this.showSpinner = true;
            insertEvent({eventRecord : JSON.stringify(eventList)})
            .then((result)=>{
                if(result == 'Success'){
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Event is created successfully',
                        variant : 'success',
                    });
                    this.showSpinner = false;
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CustomEvent('closefields',{detail : 
                        {
                            action : 'Save',
                            object : 'Event'
                        }
                    }));
                }
            }).catch((error)=>{
                console.log('error',error);
            })
        }
    }
    handleCancel(){
        this.dispatchEvent(new CustomEvent('closefields',{detail : 
            {
                action : 'Cancel',
                object : 'Event'
            }
        }));
    }
    handleFieldsChange(event){
        this.eventRecord[event.target.name] = event.target.value;
        if(event.target.name == 'IsAllDayEvent'){
            this.isAllDayEvent = event.target.checked;
            this.eventRecord[event.target.name] = event.target.checked;
        }
    }
}