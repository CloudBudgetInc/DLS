import {LightningElement,track,wire} from 'lwc';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import createJobAndContacts from "@salesforce/apex/JobCommunityHomePage_Ctrl.createJobAndContacts";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';

import PREFERED_FIELD from '@salesforce/schema/Contact.Preferred_Phone__c';
import GENDER_FIELD from '@salesforce/schema/Contact.GenderIdentity';
import RACE_FIELD from '@salesforce/schema/Contact.Race__c';
import VETERAN_FIELD from '@salesforce/schema/Contact.Veteran__c';
import DISABLED_FIELD from '@salesforce/schema/Contact.Disabled__c';
import NATIVElANGUAGE_FIELD from '@salesforce/schema/Contact.Language_1__c';
import HOW_DID_YOU_HEAR_FIELD from '@salesforce/schema/Contact.How_did_you_hear_about_us_ATS__c';
import Country_State_Key from '@salesforce/label/c.Country_State_Picklist_Key';


const MAX_FILE_SIZE = 1572864;

export default class JobApplicationCmp extends NavigationMixin(LightningElement) {
    @track countryPicklistValues;
    @track statePicklistValues;
    currentvalue = '1';
    showSpinner = false;
    showState = false;
    @track nativeLanguagePicklistValues = [];
    @track countryOptions = [];
    @track stateOptions = [];
    @track selectedCountry = '';
    @track selectedState = '';
    @track selectedCountryCode;
    @track selectedStateCode;
    @track filesDetails = [];
    @track toastMsg = {show: false};
    @track filesDetails = [];
    @track contactRec = {};
    @track progressPathValidated = {
        'isValidPersonalInfo': false,
        'isValidFileUpload': false,
        'isValidQuestion': false,
        'isValidEmployment': false
    };

    @wire(getObjectInfo, {
        objectApiName: CONTACT_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PREFERED_FIELD
    })
    PMcontactOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: HOW_DID_YOU_HEAR_FIELD
    })
    ReferenceOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: GENDER_FIELD
    })
    genderPicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: RACE_FIELD
    })
    racePicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: VETERAN_FIELD
    })
    veteranPicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: DISABLED_FIELD
    })
    disabledPicklistValues;

  
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: NATIVElANGUAGE_FIELD
    })
    wiredNativePicklist({error,data }) {
        if (error) {
            console.error('Error on Native language picklist:', error);
        } else if (data) {
            console.log(JSON.parse(JSON.stringify(data.values)));
            let nativeLangPicklistVal = (JSON.parse(JSON.stringify(data.values)));
            if (nativeLangPicklistVal.length > 0) {
                let getNAoption = [];
                let getNAoptionIndex = nativeLangPicklistVal.findIndex(a => a.label === 'N/A');
                if (getNAoptionIndex >= 0) {
                    console.log(nativeLangPicklistVal[getNAoptionIndex]);
                    getNAoption = nativeLangPicklistVal.splice(getNAoptionIndex, 1);

                }
                if (getNAoption && getNAoption.length > 0) {
                    nativeLangPicklistVal.unshift(...getNAoption)
                    this.nativeLanguagePicklistValues = nativeLangPicklistVal;
                    console.log(JSON.parse(JSON.stringify(this.nativeLanguagePicklistValues)));
                }
            }
        }
    };

    connectedCallback() {
        console.log(JSON.parse(JSON.stringify(this.objectInfo)));
        this.fetchCountries();
    }

    getJobRecordId() {
        let urlString = window.location.href;
        return urlString.split("=")[1];
    }

    pathHandler(event) {
        let valid = false;
        let currentSelectedValue = parseInt(this.currentvalue);
        let newSelectedValue = parseInt(event.currentTarget.value);

        if (currentSelectedValue > newSelectedValue) {
            this.inputValidations('Path');
            valid = true;
        } else {
            valid = true;
            if (currentSelectedValue == 2) {
                if (this.filesDetails.length > 0) {
                    for (let i = 0; i < this.filesDetails.length; i++) {
                        if (this.filesDetails[i].isResumetype) {
                            this.progressPathValidated.isValidFileUpload = true;
                        }
                    }
                }
            } else {
                this.inputValidations('Path');
            }

            for (let i = currentSelectedValue; i < newSelectedValue; i++) {
                if (valid) {
                    if (i == 1) {
                        valid = this.progressPathValidated.isValidPersonalInfo;
                    } else if (i == 2) {
                        valid = this.progressPathValidated.isValidFileUpload;
                    } else if (i == 3) {
                        valid = this.progressPathValidated.isValidQuestion;
                    } else if (i == 4) {
                        valid = this.progressPathValidated.isValidEmployment;
                    }
                }
            }

        }

        if (valid) {
            let targetValue = event.currentTarget.value;
            let selectedvalue = event.currentTarget.label;
            this.currentvalue = targetValue;
            this.selectedvalue = selectedvalue;
        }
    }
    get showSubmitButton() {
        return this.currentvalue == '4';
    }
    get showBackButton() {
        return this.currentvalue != '1';
    }

    inputValidations(buttonType) {
        let currentSelectedValue = parseInt(this.currentvalue);
        let valid1 = true;

        if (currentSelectedValue == 1 || currentSelectedValue == 3 || currentSelectedValue == 4) {

            if (currentSelectedValue == 1) {
                let email = this.template.querySelector('[data-id="txtEmailAddress"]');
                const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

                let emailVal = email.value;
                if (email.label == 'Email Address') {
                    this.contactRec.Email = email.value;
                }
                if (emailVal.match(emailRegex)) {
                    email.setCustomValidity("");
                } else {
                    valid1 = false;
                    email.setCustomValidity("Please enter valid email");
                }
                if (buttonType == 'Next') {
                    email.reportValidity();
                }
            }

            [...this.template.querySelectorAll('[data-id="personId"]')].forEach(input => {

                if (buttonType == 'Next') {
                    input.reportValidity();
                }
                let inputValid = input.checkValidity();

                if (input.label == 'First Name') {
                    this.contactRec.FirstName = input.value;
                } else if (input.label == 'Last Name') {
                    this.contactRec.LastName = input.value;
                } else if (input.label == 'Postal Code') {
                    this.contactRec.MailingPostalCode = input.value;
                } else if (input.label == 'City') {
                    this.contactRec.MailingCity = input.value;
                } else if (input.label == 'Street') {
                    this.contactRec.MailingStreet = input.value;
                } else if (input.label == 'How did you hear about us') {
                    this.contactRec.How_did_you_hear_about_us_ATS__c = input.value;
                } else if (input.label == 'Mobile Phone') {
                    this.contactRec.MobilePhone = input.value;
                } else if (input.label == 'Preferred Method of Contact') {
                    this.contactRec.Preferred_Phone__c = input.value;
                } else if (input.label == 'Availability') {
                    this.contactRec.Availability__c = input.value;
                } else if (input.label == 'Native Language') {
                    this.contactRec.Language_1__c = input.value;
                } else if (input.label == 'Gender') {
                    this.contactRec.GenderIdentity = input.value;
                } else if (input.label == 'Race') {
                    this.contactRec.Race__c = input.value;
                } else if (input.label == 'Veteran') {
                    this.contactRec.Veteran__c = input.value;
                } else if (input.label == 'Disabled') {
                    this.contactRec.Disabled__c = input.value;
                } else if (input.label == 'Country') {
                    this.contactRec.MailingCountry = this.selectedCountry;
                } else if (input.label == 'State') {
                    this.contactRec.MailingState = this.selectedState;
                }

                if (!inputValid) {
                    valid1 = false;
                }
            });
        }

        if (currentSelectedValue == 1) {
            this.progressPathValidated.isValidPersonalInfo = valid1;
        } else if (currentSelectedValue == 3) {
            this.progressPathValidated.isValidQuestion = valid1;
        } else if (currentSelectedValue == 4) {
            this.progressPathValidated.isValidEmployment = valid1;
        }

        return valid1;
    }

    formNextClick() {
        let currentSelectedValue = parseInt(this.currentvalue);
        let valid1 = false;

        if (currentSelectedValue == 1 || currentSelectedValue == 3) {
            valid1 = this.inputValidations('Next');
        } else if (currentSelectedValue == 2) {
            if (this.filesDetails.length > 0) {
                for (let i = 0; i < this.filesDetails.length; i++) {
                    if (this.filesDetails[i].isResumetype) {
                        valid1 = true;
                    }
                }
            }

            if (!valid1) {
                this.showToast('Please upload a required resume to proceed further', '', 'Error');
            }
            this.progressPathValidated.isValidFileUpload = valid1;
        }

        if (valid1) {
            this.currentvalue = (currentSelectedValue + 1).toString();
        }
    }
    formBackClick() {
        let currentSelectedValue = parseInt(this.currentvalue);
        this.inputValidations('Back');
        this.currentvalue = (currentSelectedValue - 1).toString();
    }
    get showPersonInfo() {
        return this.currentvalue == '1';
    }
    get showResumePage() {
        return this.currentvalue == '2';
    }
    get showEmpQuestionPage() {
        return this.currentvalue == '3';
    }
    get showOppEmployPage() {
        return this.currentvalue == '4';
    }
    fetchCountries() {
        fetch('https://api.countrystatecity.in/v1/countries', {
                method: "GET",
                headers: {
                    'X-CSCAPI-KEY': Country_State_Key
                }
            })
            .then((response) => {

                return response.json();
            })
            .then((data) => {
                const countries = data.map((country) => ({
                    label: country.name,
                    value: country.iso2
                }));

                let unitedStateCountry = [];
                let unitedStateIndex = countries.findIndex(a => a.label === 'United States');
                if (unitedStateIndex >= 0) {
                    unitedStateCountry = countries.splice(unitedStateIndex, 1);

                }
                this.countryOptions = countries.sort((a, b) => a.label < b.label ? -1 : 1);
                if (unitedStateCountry && unitedStateCountry.length > 0) {
                    this.countryOptions.unshift(...unitedStateCountry);
                }

            }) // Set the country picklist values
            .catch((error) => {
                // Handle country data fetch error
                console.error('Error fetching countries:', error);
            });
    }

    async fetchStates(countryCode) {
        this.showSpinner = true;

        fetch('https://api.countrystatecity.in/v1/countries/' + countryCode + '/states', {
                method: "GET",
                headers: {
                    'X-CSCAPI-KEY': Country_State_Key
                }
            })
            .then((response) => {
                return response.json();
            })
            .then((data) => {
                const states = data.map((states) => ({
                    label: states.name,
                    value: states.iso2
                }));
                this.stateOptions = states.sort((a, b) => a.label < b.label ? -1 : 1);
                if(this.stateOptions.length > 0){
                    this.showState = true;
                }
                this.showSpinner = false;
            }) // Set the country picklist values
            .catch((error) => {
                // Handle country data fetch error
                console.error('Error fetching States:', error);
                this.showSpinner = false;

            });
    }
    // On Country Change
    handleCountryChange(event) {
        this.showState = false;
        this.selectedStateCode = '';

        const filteredCountry = this.countryOptions.filter(x => x.value === event.detail.value);
        if (filteredCountry.length > 0) {
            this.selectedCountry = filteredCountry[0].label;
        }
        this.selectedCountryCode = event.detail.value;
        this.fetchStates(this.selectedCountryCode);
    }
    // On State Change
    handleStateChange(event) {
        const filteredState = this.stateOptions.filter(x => x.value === event.detail.value);

        if (filteredState.length > 0) {
            this.selectedState = filteredState[0].label;
        }
        this.selectedStateCode = event.detail.value;
    }
    //navigateToPreviousPage
    navigateToPreviousPage() {
        history.back();
    }
    //Create Contact and Applicant records in salesforce along with file opload in box folder
    submitApplicationPage() {
        this.inputValidations('Path');
        this.showSpinner = true;
        let conList = [];
        conList.push(this.contactRec);

        console.log(JSON.parse(JSON.stringify(conList)));
        console.log(JSON.parse(JSON.stringify(this.filesDetails)));
        createJobAndContacts({
                conJSON: JSON.stringify(conList),
                fileUploadInfoJSON: JSON.stringify(this.filesDetails),
                jobId: this.getJobRecordId()
            })
            .then((result) => {
                console.log(result);
                this.showSpinner = false;
                this.toastMsg.show = true;
                this.toastMsg.message = 'Thank you for your application. We will be in touch with you soon';
                this.toastMsg.header = 'Success';
            })
            .catch((error) => {
                this.showSpinner = false;
                let msg;
                console.log(error);
                console.log(error.body.pageErrors);
                if (error.body && error.body.message) {
                    msg = error.body.message;
                } else if ((error.body && error.body.pageErrors && (error.body.pageErrors).length > 0)) {
                    msg = (error.body.pageErrors)[0].message;
                } else {
                    msg = error;
                }
                this.showToast('Error', msg, 'error');

            });
    }
    // Show the Toast information
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    closeToastMsg() {
        this.toastMsg.show = false;
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }
    // Handle the File Selections
    handleFileSelection(event) {
        var selectedFilesSize = 0;
        var fileType = event.target.name;

        for (let i = 0; i < event.target.files.length; i++) {
            selectedFilesSize += event.target.files[i].size;
        }
        if (selectedFilesSize > MAX_FILE_SIZE) {
            this.showToast('Size of files should not exceed 1.5 MB', 'Error');
        } else {
            for (let i = 0; i < event.target.files.length; i++) {
                const file = event.target.files[i];
                let reader = new FileReader();
                let flag = 0;
                let totalFilesSize = 0;
                if (file.size > MAX_FILE_SIZE) {
                    this.showToast('Size of files should not exceed 1.5 MB', 'Error');
                    flag = 2;
                }
                reader.onload = () => {
                    let base64 = reader.result.split(',')[1];
                    for (let j = 0; j < this.filesDetails.length; j++) {
                        totalFilesSize += this.filesDetails[j].size;
                        if (this.filesDetails[j].fileName == file.name) {
                            flag = 1;
                            this.showToast('File with the same name already exists . Please choose another file', 'Error');
                        }
                    }
                    if (totalFilesSize + file.size > MAX_FILE_SIZE) {
                        this.showToast('Size of files should not exceed 1.5 MB', 'Error');
                        flag = 2;
                    }
                    if (flag == 0) {
                        let fileInfo = {
                            'fileName': file.name,
                            'base64': base64,
                            'size': file.size,
                            'isResumetype': false,
                            'isCoverType': false,
                            'isRefType': false
                        };
                        if (fileType === 'Resume') {
                            fileInfo.isResumetype = true;
                        }
                        if (fileType === 'Cover Letter') {
                            fileInfo.isCoverType = true;
                        }
                        if (fileType === 'Ref Letter') {
                            fileInfo.isRefType = true;
                        }
                        this.filesDetails.push(fileInfo);
                    }
                };
                reader.readAsDataURL(file);
            }
        }
    }
    handleFileRemove(event) {
        let currentIndex = parseInt(event.target.name);
        if (this.filesDetails.length > 0) {
            this.filesDetails.splice(currentIndex, 1);
        }
    }
}