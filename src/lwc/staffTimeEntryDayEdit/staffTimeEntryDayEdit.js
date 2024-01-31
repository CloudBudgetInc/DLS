import { LightningElement, api } from 'lwc';
import timeEntryUtil from 'c/timeEntryUtil';

export default class StaffTimeEntryDayEdit extends LightningElement {
    @api editModal;
    @api comment;
    dayHours;
    comments;
    isOk;
    isComments;
    originalHours;
    isChanged = false;

    connectedCallback() {
        this.originalHours  = this.editModal.day.dayHours;
        let existingComments = this.editModal.day.comments;
        if (this.comment) {
            this.comments = this.comment;
        } else if(existingComments) {
            this.comment = existingComments;
            this.comments = existingComments;
        }
    }
    handleChange(e){
        e.target.setCustomValidity('');
        const { value , name } = e.target;
        let isValid = timeEntryUtil.validateTimeValue(value);
        if (isValid) {
            this.dayHours = value;
            this.isOk = true;
        } else if(name == "Comments") {
            this.comments = value;
        } else if ( value.length > 0 ) {
            e.target.setCustomValidity('Allowed decimal values are 00, 25, 50, 75');
            this.isOk = false;
        }
        e.target.reportValidity();
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleOk() {
        let textArea = this.template.querySelector('lightning-textarea');
        let input = this.template.querySelector('lightning-input');
        textArea.setCustomValidity('');
        textArea.reportValidity();
        input.setCustomValidity('');
        input.reportValidity();
        if (this.dayHours >= 0 && this.isOk == true && this.comments.length > 0 && this.originalHours != this.dayHours && input.checkValidity()) { 
            this.isChanged = true;
            this.dispatchEvent(new CustomEvent('ok',{detail: {value: this.dayHours, name: this.editModal.day.dateVal, comments: this.comments,isChanged: this.isChanged, chargeCode: this.editModal.day.chargeCode}}));
            this.handleCancel();
        } else if (!this.comments || !this.dayHours || this.originalHours === this.dayHours) {
            if(!this.dayHours || this.originalHours === this.dayHours ) {
                console.log('oh',this.originalHours);
                console.log('dh',this.dayHours);
                input.setCustomValidity('Please Change the value');
                input.reportValidity();
            } else if (!this.comments > 0) {
                textArea.setCustomValidity('Complete this field.');
                textArea.reportValidity();
            }
        }
    }
    handleDelete(){
        this.dispatchEvent(new CustomEvent('delete',{detail:{name: this.editModal.day.dateVal}}));

    }
}