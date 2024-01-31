import { LightningElement, track, wire } from 'lwc';
import getFilters from '@salesforce/apex/StaffTimeEntryController.getFilterInfo';
import getProjectsByWeekrange from '@salesforce/apex/StaffTimeEntryController.getProjectsByWeekrange';
import getProjTaskAndTimeEnteredDetails from '@salesforce/apex/StaffTimeEntryController.getProjTaskAndTimeEnteredDetails';
import saveTimeEntry from '@salesforce/apex/StaffTimeEntryController.saveStaffTimeEntries';
import recallExistingTimeEntries from '@salesforce/apex/StaffTimeEntryController.recallExistingTimeEntries';
import completeTimeEntries from '@salesforce/apex/StaffTimeEntryController.completeTimeEntries';
import completeTimeEntry from '@salesforce/apex/InstructorTimeEntry_Controller.completeTCDEntries';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StaffTimeEntry extends LightningElement {
    isLoading = true;
    @track filter;
    showSaveBtn = true;
    instructorRowDetails;
    changeRange = false;
    changeDayEntry = false;
    oldValue;
    notesList = [];
    isCompleted = false;
    isSuccess = false;
    showRecallBtn;
    showCompleteBtn;
    showModal = false;
    modalBodyText;
    modalClickOn;
    modalHeader;
    @wire(getFilters)
    getFiltersInfo({ error, data }) {
        if (data) {
            this.filter = JSON.parse(data);
            console.log('filter',JSON.parse(JSON.stringify(this.filter)));
            this.isLoading = false;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }


    handleFilterChanges(event){
        let filterChange = event.detail.filterChanges;
        let oldValue = event.detail.oldValues;
        console.log('filter',filterChange);
        this.filter[filterChange.key] = filterChange.value;
        // this.instructorRowDetails = undefined;
            // if(filterChange.key == 'selectedProject'){
            //     this.handleProjectChange();
            // }else if(filterChange.key == 'selectedWeek'){
            //     this.handleWeekChange();
            // }
        if ( this.changeDayEntry) {
            this.changeRange = true;
            this.changeDayEntry = false;
            if(filterChange.key == 'selectedProject'){
                this.handleProjectChange();
            }else if(filterChange.key == 'selectedWeek'){
                this.handleWeekChange();
            }

        } else {
            this.instructorRowDetails = undefined;
            this.oldValue = oldValue;

            if(filterChange.key == 'selectedProject'){
                this.handleProjectChange();
            }else if(filterChange.key == 'selectedWeek'){
                this.handleWeekChange();
            }
        }
    }

    handleWeekChange(){
        this.isLoading = true;
        this.notesList = [];
        getProjectsByWeekrange({conId : this.filter.contactId, weekRange: this.filter.selectedWeek})
        .then(result => {
            this.isLoading = false;
            let filter = JSON.parse(JSON.stringify(this.filter));
            filter.projectAndCA = JSON.parse(result);
            this.filter = JSON.parse(JSON.stringify(filter)); 
            this.filter.selectedProject = '';
            this.showCompleteBtn = false;
            this.showRecallBtn = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.showToast(error, 'Error');    
            console.log(error);
        })        
    }

    handleProjectChange(){
        this.isLoading = true;       
        this.notesList = []; 
        let ca = this.filter.projectAndCA.projectIdWithCAMap[this.filter.selectedProject];
        getProjTaskAndTimeEnteredDetails({projectId : this.filter.selectedProject, conId : this.filter.contactId, weekRange: this.filter.selectedWeek, caStr: JSON.stringify(ca)})
        .then(result => {
            this.isLoading = false;
            console.log(JSON.parse(result));
            this.instructorRowDetails = JSON.parse(result);
            this.showCompleteBtn = this.instructorRowDetails.displayCompleteBtn;
            this.showRecallBtn = this.instructorRowDetails.displayRecallBtn;
            if (this.instructorRowDetails.notes) {
                this.notesList = this.instructorRowDetails.notes;     
                console.log('notes:::',this.notesList); 
            }
        })
        .catch(error => {
            this.isLoading = false;
            //this.showToast(error, 'Error');    
            console.log(error);
        })
    }

    get showTimeEntries(){
        return this.instructorRowDetails;
    }

    handleDayChange(event){
        let daysPerTask = event.detail,
            instructorRowDetails = JSON.parse(JSON.stringify(this.instructorRowDetails));

        instructorRowDetails.entries.forEach(function(ele, index) {
            if(ele.chargeCode1 == daysPerTask.chargeCode1){
                instructorRowDetails.entries[index] = daysPerTask;
            }
        }, instructorRowDetails.entries);
        this.instructorRowDetails = instructorRowDetails;
        console.log('ins:::',this.instructorRowDetails);
        this.changeDayEntry = true;
    }

    async handleSave() {
        this.showModal = false;
        this.isLoading = true;
        let timeCardDays = [];
        let isUpdated = false;
        this.instructorRowDetails.entries.forEach((result)=>{
            result.dayEntries.forEach((res)=>{
                if (res.dayHours &&(res.isNew|| (res.isUpdated && res.isChanged))) {
                    timeCardDays.push(res);
                    if (res.isUpdated) {
                        isUpdated = true;
                    }
                }
            })
        })
        console.log('timecard:::',timeCardDays);
        await saveTimeEntry({weekRange: this.filter.selectedWeek, conId: this.filter.contactId, timeCardDaysStr: JSON.stringify(timeCardDays), projectId: this.filter.selectedProject, actionType: null})
        .then((result) => {
            if ( result == 'success') {
                this.changeDayEntry = false;
                if( !this.isCompleted) {
                    this.isLoading = false;
                    this.isSuccess = true;
                    this.modalHeader='Success';
                    if (!isUpdated) {
                        this.modalBodyText = 'Time entries Created successfully.';
                    } else {
                        this.modalBodyText = 'Time entries Updated successfully.';
                    }
                    this.showModal = true;
                }
            }
        })
        .catch((error) => {
            this.isLoading = false;
            console.log('err',error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: error,
                variant: 'error',
        }));
        })
    }

    async handleComplete() {
        this.isCompleted = true;
        await this.handleSave();
        let completeList = [];
        this.instructorRowDetails.entries.forEach((result)=>{
            result.dayEntries.forEach((res)=>{
                if(this.isCompleted && res.dayId && (res.dayHours == 0 || res.dayHours)){
                    completeList.push(res);
                }
            })
        })
        console.log('complete list:::',completeList);
        completeTimeEntries({timeCardDaysStr:JSON.stringify(completeList),actionType:'Complete'})
        .then((result)=>{
            console.log('result:::',result);
            // completeTimeEntry({timeDayJson:JSON.stringify(completeList)})
            // .then((result)=>{
                this.isLoading = false;
                this.isSuccess = true;
                this.modalHeader='Success';
                this.modalBodyText = 'Entries Completed Succesfully';
                this.showModal = true;
            // }).catch((error)=>{
            //     this.isLoading = false;
            //     this.dispatchEvent(new ShowToastEvent({
            //         title: 'Warning',
            //         message: error,
            //         variant: 'error',
            //     }));
            // })
        })
        .catch((error)=>{
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: error,
                variant: 'error',
            }));
        })
    }

    handleRecall(){
        let daysForRecall = [];
        this.isLoading = true;
        var rowRecords = this.instructorRowDetails.entries;
        console.log('rowR:::',rowRecords);
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].dayId && (entries[j].dayHours == 0 || entries[j].dayHours)){
                    daysForRecall.push(entries[j]);
                }
            }
        }

        recallExistingTimeEntries({timeDayJson:JSON.stringify(daysForRecall),typeOfAction:'Group'})
        .then((result)=>{
            this.isLoading = false;
            this.isSuccess = true;
            this.modalHeader='Success';
            this.modalBodyText = 'Time entries are recalled successfully.';
            this.showModal = true;
        })
        .catch((error)=>{
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: error,
                variant: 'error',
            }));
        })
    }

    handlePreceedWithoutSave(){
            this.changeRange = false;
            this.changeDayEntry = false;
            this.instructorRowDetails = undefined;
    }
    handleYes(){
        this.changeRange = false;
        this.handleOldFilters();
        this.handleSave();
    }

    handleCancel(){
        this.changeRange = false;
        this.changeDayEntry = true;
        this.handleOldFilters();
    }

    handleOldFilters(){
        this.filter.selectedWeek = this.oldValue.oldWeekFilterChange.value;
        this.filter.selectedProject=this.oldValue.oldProjectFilterChange.value;
    }
    handleSaveConfirmation(){
        this.modalHeader='Confirmation';
        this.modalBodyText = 'Would you like to save the changes?';
        this.showModal = true;
        this.modalClickOn = 'Save'; 
    }
    handleClose(){
        this.showModal = false;
        if (this.isSuccess) {
            this.isSuccess = false;
            this.handleProjectChange();
        }
    }

    handleCompleteConfirmation(){
        this.modalHeader='Confirmation';
        this.modalBodyText = 'Would you like to Complete this Timesheet?';
        this.showModal = true;
        this.modalClickOn = 'Complete'; 
    }
    handleModalProceed(){
        if(this.modalClickOn =='Save') {
            this.handleSave();
        } else if (this.modalClickOn == 'Complete'){
            this.handleComplete();
        }
    }
    
}