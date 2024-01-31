import { LightningElement,api,wire,track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/Lookup.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/Lookup.fetchDefaultRecord';

const DELAY = 300; // dealy apex callout timing in miliseconds 

export default class Lookup extends LightningElement {

    // public properties with initial default values 
    @api label = 'custom lookup label';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:account';
    @api sObjectApiName = 'Account';
    @api defaultRecordId = '';
    @api filter = '';
    @api required = false;
    @api fields = 'Id, Name';
    @api disabled = false;
    //@api otherFields;
    @api searchField = 'Name';
		@api fieldApiName;
    @api multiSelect = false;

    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    selectedRecord = {}; // to store selected lookup record in object formate 
    @track multipleSelectedRecords = [];
    @track selectedRecordIds = [];

   // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){
         if(this.defaultRecordId != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName })
            .then((result) => {
                if(result != null){
                    this.selectedRecord = result;
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecord = {};
            });
         }
    }

    // get showSubFields(){
    //     return this.otherFields;
    // }

    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { searchKey: '$searchKey' , searchField: '$searchField', sObjectApiName : '$sObjectApiName' , filter: '$filter', fields: '$fields' , selectedIds : '$selectedRecordIds'})
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true; 
             this.lstResult = JSON.parse(JSON.stringify(data)); 
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };
       
  // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY);
    }


    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
           }
    }

   // method to clear selected lookup record  
   @api
   handleRemove(){
    this.searchKey = '';    
    this.selectedRecord = {};
    this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
    
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');
  }

  // method to update selected record from search result 
    handelSelectedRecord(event){   
        if(this.multiSelect == false){
            var objId = event.target.getAttribute('data-recid'); // get selected record Id 
            this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
            this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
            this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
        }
        else if(this.multiSelect == true){
            var objId = event.target.getAttribute('data-recid');
            var temp = JSON.parse(JSON.stringify(this.selectedRecordIds));
            temp.push(objId);
            this.selectedRecordIds = JSON.parse(JSON.stringify(temp));
            this.multipleSelectedRecords.push(this.lstResult.find(data => data.Id === objId));
            this.selectedRecord = this.lstResult.find(data => data.Id === objId);
            this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
            const pillDiv = this.template.querySelector('.multiSelectPills');			
            pillDiv.classList.remove('slds-hide');
            pillDiv.classList.add('slds-show');
            this.searchKey = '';
            this.lookupUpdatehandler(this.multipleSelectedRecords);
        }
    }
    onRemoveSelectedItem(event){
        console.log('Id : ',event.target.name);
        console.log('Index : ',event.target.dataset.id);
        this.multipleSelectedRecords.splice(event.target.dataset.id ,1);
        this.selectedRecordIds.splice(event.target.dataset.id ,1);
        this.lookupUpdatehandler(this.multipleSelectedRecords);
    }

    /*COMMON HELPER METHOD STARTED*/

    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');

        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');

        const pillDiv = this.template.querySelector('.pillDiv');			
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');     
				
				const disableButton = this.template.querySelector('.disable-button');
				this.disabled ? disableButton.classList.add('slds-hide') : '';
    }

    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value){    
        const oEvent = new CustomEvent('lookupupdate',
            {
                'detail': {
										selectedRecord: value,
										fieldApiName : this.fieldApiName
								}
            }
        );
        this.dispatchEvent(oEvent);
    }

    @api
    checkValidity(){
        return !this.required || (this.required && this.selectedRecord && this.selectedRecord.Id);
    }

    @api 
    reportValidity(){
        let msg = "Complete this field.",
            input = this.template.querySelector('lightning-input');
        if(!this.required || (this.required && this.selectedRecord && this.selectedRecord.Id)){
            msg = '';
        }
        input.setCustomValidity(msg);
        input.reportValidity();
    }

}