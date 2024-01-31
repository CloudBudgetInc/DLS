import { LightningElement , track , api , wire} from 'lwc';
import getEmailTemplates from '@salesforce/apex/CustomActivityTimelineController.getEmailTemplates';
import mergeFields from '@salesforce/apex/CustomActivityTimelineController.mergeFields';

    /*const actions = [
        { 'label': 'Insert Template', 'name': 'insert_template'  , 'iconName' : 'utility:insert_template'}
    ];*/

export default class InsertEmailTemplate extends LightningElement 
{
    @api recordId;
    searchKeyWord = '';

    actions = [
        { 'label': 'Insert Template', 'name': 'insert_template'}
    ];
    header = [
        {
            'label':'Name',
            'fieldName':'Name',
            'type':'text',
            'value':'Id',
            'resizeable':true,
            'target':'_blank'
        },
        {
            'label':'Description',
            'fieldName':'Description',
            'resizeable':true,
            'type':'text'
        },
        {
            'label':'Template Folders',
            'fieldName':'FolderName',
            'resizeable':true,
            'type':'text'
        },
        { 'type': 'action', 
          'typeAttributes': { 
                    'rowActions': this.actions} 
        }

    ];

    showSpinner = true;
    @track emailTemplateList;
    htmlBody;
    error;

    //@wire (getEmailTemplates, { searchKeyWord: '$searchKeyWord' })  emailTemplateList;


    @wire(getEmailTemplates, {searchKeyWord:'$searchKeyWord'})
    wiredContacts({data, error}){
        if(data){
            this.emailTemplateList = data;
            this.error = undefined;
            console.log('emailTemplateList : ',this.emailTemplateList);
            this.showSpinner = false;
        }
        else if (error) {
            this.error = error;
            this.emailTemplateList = undefined;
            console.log('error : ',error);
            this.showSpinner = false;
        }
    }

    handleSearchChange(event){
        this.showSpinner = true;
        this.searchKeyWord = event.target.value;
    }

    handleInsertTemplateClose(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }
    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        console.log('action',action);
        console.log('action.name',action.name);
        console.log('row',row);
        console.log('row.Id',row.Id);
        console.log('row.HtmlValue',row.HtmlValue);
        console.log('row.Body',row.Body);
        this.showSpinner = true;
        var unMergedBody;
        console.log('Logic: ',row.TemplateType == 'visualforce');
        if(row.TemplateType == 'visualforce'){
            unMergedBody = row.Markup;
        }
        else{
            if(row.HtmlValue == '' || row.HtmlValue == undefined){
                unMergedBody = row.Body;    
            }
            else if(row.HtmlValue != undefined){
                unMergedBody = row.HtmlValue;
            }
        }
        this.mergeFields(unMergedBody);
    }
    mergeFields(unMergedBody){
        mergeFields({unMergedBody: unMergedBody , whoOrWhatId : this.recordId}).then(result=>{
            var mergedBody = JSON.parse(JSON.stringify(result));
            this.showSpinner = false;
            this.dispatchEvent(new CustomEvent('value',{detail : 
                {
                    richText : mergedBody
                }
            }));

        }).catch(error=>{
            console.log('body:' , error.body.message);
            console.log('error: ',error);
        });
    }
}