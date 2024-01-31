import { LightningElement , api , track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
//import SldsModelCss from '@salesforce/resourceUrl/SldsModelCss';
import sldsModalIncreaseHeightWidth from '@salesforce/resourceUrl/sldsModalIncreaseHeightWidth';

import getItemsFromFolder from '@salesforce/apex/LessonPlanBoxUtil.getItemsFromFolder';
import deleteFiles from '@salesforce/apex/LessonPlanBoxUtil.deleteFilesAsync';

export default class DeleteUploadedFiles extends LightningElement {
    @api boxFolderId;
    isLoaded = false;
    isNillFiles = false;
    columns = [
        {
            label: 'File Name',
            fieldName: 'name',
            type: 'text',
        },
        {
            label: 'File Size',
            fieldName: 'size',
            type : 'text'
        },
        {
            label: 'Uploaded On',
            fieldName: 'created_at',
            type: "date-local",
            typeAttributes:{
                month: "2-digit",
                day: "2-digit"
            }
        },
    ];
    selectedIds = [];
    @track records;

    connectedCallback(){
        Promise.all([
            loadStyle(this, sldsModalIncreaseHeightWidth)
        ]).then(() => {
            console.log('Styles Loaded');
        })
        this.getFilesAndFolders();
    }
    getFilesAndFolders(){
        this.dispatchEvent(new CustomEvent('showspinner'));
        getItemsFromFolder({folder_id : this.boxFolderId}).then(result=>{
            console.log(result);
            var resultJSON = JSON.parse(result);
            var size;
            if(resultJSON.entries.length == 0){
                this.isNillFiles = true;
            }
            else if(resultJSON.entries.length > 0){
                for(let i = 0 ; i< resultJSON.entries.length;i++){
                    size = Number(resultJSON.entries[i].size) / 1048576;
                    if(size >= 1){
                        resultJSON.entries[i].size = String(String(Math.round(size * 100) / 100) + ' MB');
                    }
                    else{
                        size = Number(resultJSON.entries[i].size) / 1024;
                        resultJSON.entries[i].size = String(String(Math.round(size * 100) / 100) + ' KB');
                    }
                    
                }
                this.records = resultJSON.entries;
            }
            this.dispatchEvent(new CustomEvent('hidespinner'));
            this.isLoaded = true;
        }).catch(error=>{
            console.log('error: ',error);
            this.dispatchEvent(new CustomEvent('hidespinner'));
        })
    }
    handleSelectedRows(event){
        const selectedRows = event.detail.selectedRows;
        var selectedIds = [];
            for(let i = 0;i < selectedRows.length;i++){
                selectedIds.push(selectedRows[i].id);
            }
            this.selectedIds = selectedIds;
    }
    handleFileDelete(){
        this.dispatchEvent(new CustomEvent('showspinner'));
        for(let i = 0;i < this.selectedIds.length;i++){
            deleteFiles({fileIds : this.selectedIds}).then(result=>{
                console.log(result);
                this.dispatchEvent(new CustomEvent('closemodal'));
                this.dispatchEvent(new CustomEvent('hidespinner'));
                this.dispatchEvent(new CustomEvent('refresh'));
            }).catch(error=>{
                this.dispatchEvent(new CustomEvent('hidespinner'));
                console.log('error: ',error);
            })
        }
    }
    get isDisabled(){
        if(this.selectedIds.length == 0){
            return true;
        }
        if(this.selectedIds.length >= 1){
            return false;
        }
    }
    closeToastMsg(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}