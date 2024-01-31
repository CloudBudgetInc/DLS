import { LightningElement, api, track } from 'lwc';
import timeEntryUtil from 'c/timeEntryUtil';
import inputAlignment from '@salesforce/resourceUrl/InputAlignment';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class StaffTimeEntryPerTask extends LightningElement {
    
    hours;
    @track _day;    
    // editClass = false;
    @api 
    get day(){
        return this._day;
    }
    set day(value){
        this._day = JSON.parse(JSON.stringify(value));        
        this._day.totalHours = parseFloat(this._day.totalHours);
    }
    @track editModal = {show: false};

    @track comment;
    // get inputClass(){
    //     return this.editClass === true ? 'input-yellow' : 'input-green';
    // }

    connectedCallback(){
    
        loadStyle(this, inputAlignment)
        .then(() => {
            console.log('load');
        });
    }
    handleHrsChange(event){
        let dayEntries = JSON.parse(JSON.stringify(this._day.dayEntries)),
            totHrs = 0;
        console.log(timeEntryUtil.validateTimeValue);
        event.target.setCustomValidity('');
        event.target.reportValidity();
        //console.log('target'+event.currentTarget);
        const { name, value } = event.currentTarget
        let hasError = timeEntryUtil.validateTimeValue(value);
        for(let dayEntry of dayEntries){
            if(dayEntry.dateVal === name){                
                if(hasError) {
                    dayEntry.dayHours = parseFloat(value); 
                    if (dayEntry.status == 'Unposted') {
                        dayEntry.status = 'Draft';
                        dayEntry['isChanged'] = true;
                        dayEntry.isUpdated = true;
                    }
                } else if (value.length > 0){
                    event.target.setCustomValidity('Allowed decimal values are 00, 25, 50, 75');
                    event.target.reportValidity();
                    break;
                }
            }  
            if(dayEntry.dayHours) 
                totHrs += parseFloat(dayEntry.dayHours);        
        }
        if(hasError) {
            console.log(totHrs);
            this._day.dayEntries = dayEntries;
            this._day.totalHours = parseFloat(totHrs);
            this.dispatchEvent(new CustomEvent('daychange', { detail: this._day }));
        }

    }

    handleEdit(event) {
        let dayEntries = JSON.parse(JSON.stringify(this._day.dayEntries)),
            modalAtt = {title: this._day.chargeCode1, show: true};

        for(let dayEntry of dayEntries){
            if(dayEntry.dateVal === event.currentTarget.dataset.name){
                modalAtt.title += ' - ' + dayEntry.displayDate;
                modalAtt.day = dayEntry;
            }
        }
        this.editModal = modalAtt;
        console.log('edit:::',this.editModal);
    }

    handleEditChange(event) {
        this._day.dayEntries["isChanged"] = false;
        let dayEntries = JSON.parse(JSON.stringify(this._day.dayEntries)),
        totHrs = 0;
        const { name, value, comments, isChanged, chargeCode} = event.detail;
        this.comment = comments;
        for(let dayEntry of dayEntries){
            if(dayEntry.dateVal === name){                
                dayEntry.dayHours = parseFloat(value); 
                dayEntry.comments = comments;
                dayEntry.isChanged = isChanged;
                dayEntry.isHrsDisabled = false;
                dayEntry.showEditIcon = false;
            }  
            if(dayEntry.dayHours)
                totHrs += parseFloat(dayEntry.dayHours);        
        }
        const editClass = this.template.querySelector(`lightning-input[data-name="${name}"][data-chargecode="${chargeCode}"]`);
        if (!editClass.classList.contains('edited')) {
            editClass.classList.add('edited');
        }
        this._day.dayEntries = dayEntries;
        this._day.totalHours = parseFloat(totHrs);
        this.dispatchEvent(new CustomEvent('daychange', { detail: this._day }));
    }

    handleDelete(event) {
        this._day.dayEntries["isChanged"] = false;
        let dayEntries = JSON.parse(JSON.stringify(this._day.dayEntries)),
        totHrs = 0;
        const { name} = event.detail;
        for(let dayEntry of dayEntries){
            if(dayEntry.dateVal === name){                
                dayEntry.dayHours = '0.00'; 
                dayEntry.comments = null;
                dayEntry.isChanged = true;
                dayEntry.status = 'Unposted';
                dayEntry.isHrsDisabled = false;
                dayEntry.isUpdated = true;
                dayEntry.showEditIcon = false;
                dayEntry.isUnposted = true;

            }  
            if(dayEntry.dayHours)
                totHrs += parseFloat(dayEntry.dayHours);        
        }
        console.log('ady::::::::',dayEntries);
        this._day.dayEntries = dayEntries;
        this._day.totalHours = parseFloat(totHrs);
        this.dispatchEvent(new CustomEvent('daychange', { detail: this._day }));
        this.handleCancel();
        this.handleSave();
    }


    handleCancel() {
        this.editModal= {show: false};
    }

    @api
    handleSave() {
        let timeCardDay = [];
        this._day.dayEntries.forEach(e=> {
            if ((e.dayHours !== "" && e.isNew) || (e.dayHours != null && e.isUpdated && e.isChanged)) {
                timeCardDay.push(e);
            }
        })
        return timeCardDay;
    }

    handleAfterEditClick(event){
        if (event.target.classList.contains('edited')) {
            this.handleEdit(event);
        }
    }

}