({
	doInit : function(cmp, event, helper) {
        var tableColumns = [
                              {
                                "label": "Item Id",
                                "name": "item_id",
                                "type": "string"
                              },
                              {
                                "label": "Item Name",
                                "name": "item_name",
                                "type": "url",
                                "enableCellClickEvt": true
                              },
                              {
                                "label": "Item Type",
                                "name": "item_type",
                                "type": "string",
                                "width": 103
                              },
                              /*{
                                "label": "ItemName-Size",
                                "name": "itemname_size",
                                "type": "string"
                              },*/
                              {
                                "label": "File Type",
                                "name": "file_type",
                                "type": "string",
                                "width": 100
                              },
                              {
                                "label": "Size(Bytes)",
                                "name": "size",
                                "type": "number",
                                "width": 140
                              },
                              {
                                "label": "Folder Name",
                                "name": "folder_name",
                                "type": "url",
                                "enableCellClickEvt": true,
                                "width": 130
                              },
                              {
                                "label": "Owner Login",
                                "name": "owner_login",
                                "type": "string"
                              },
                              {
                                "label": "Created At",
                                "name": "created_at",
                                "type": "datetime",
                                "format":'MM/DD/YYYY HH:mm'
                              }
                          ];
                cmp.set("v.tableColumns", tableColumns);

                //Configuration data for the table to enable actions in the table
                var tableConfig = {
                  massSelect: true,
                  globalAction: [
                      /*{
                          "label":"Exclude from Duplicate",
                          "type":"button",
                          "id":"excldueFiles",
                          "class":"slds-button slds-button--neutral"
                      }*/
                  ],
                  rowAction:[                      
                      {
                          "type":"image",                          
                          "visible":function(row){                              
                              return row.salesforce_id && row.salesforce_id != '';
                          },
                          "label":"",
                          "src":$A.get('$Resource.Salesforce_Icon'),
                          "id":"relatedRecord"                          
                      }
                  ],
                  rowActionWidth: 80,
                  rowActionPosition:"right",                 
                  paginate: true,
                  searchBox: false
                };
    			cmp.set("v.tableConfig", tableConfig);
		helper.getFileDetail(cmp, event, helper);
        helper.getBaseURL(cmp, event, helper);        
	},
    tabActionHandler: function(cmp, event, helper){
        var actionId = event.getParam('actionId');
        var row = event.getParam("row");
        
        if(actionId == "relatedRecord"){
            var path = cmp.get("v.baseUrl") + '/'+row.salesforce_id;
            window.open(path, "_blank");
        }
             
    },
    tabCellHandler: function(cmp, event, helper){
        var fieldApiName = event.getParam("fieldApiName");
        var row = event.getParam("row");
        var path = 'https://app.box.com'
        
        if (fieldApiName == "item_name") {
            path += row.item_type == 'File' ? '/file/' : '/folder/';
            path += row.item_id;
            window.open(path, "_blank");
        }else if(fieldApiName == "folder_name"){
            path += '/folder/' + row.parent_id
            window.open(path, "_blank");
        }             
    },
    massSelectHandler: function(cmp, event, helper){
        
        var selectedRows = cmp.find("fileDuplicatesTable").get("v.selectedRows"),
            userDetails = cmp.get("v.userDetails");
        
        if(selectedRows.length > 0){
            for(var i=0; i < selectedRows.length; i++){
                selectedRows[i]['is_not_duplicate'] = true;
                selectedRows[i]['excluded_by'] = userDetails.Name;
                selectedRows[i]['excluded_by_username'] = userDetails.Email;
            }
            console.log(selectedRows);
            cmp.set("v.selectedRows", selectedRows);
            cmp.find("confirmationModal").open();               
        }else{
            helper.showToast(cmp, 'No files are selected to Exclude from Duplicate', 'Error');
        }       
    },
    cancelBtnClk: function(cmp, event, helper){
        cmp.find("confirmationModal").close(); 
    },
    confirmBtnClick: function(cmp, event, helper){
        cmp.find("confirmationModal").open();               
        helper.excludeFromDuplicates(cmp, cmp.get("v.selectedRows"));
    },
    okayBtnClick: function(cmp, event, helper){
        
        cmp.find("toastModal").close();
        var toast = cmp.get("v.toast");
        if(toast && toast.header == 'Success'){
        	window.close() ;
        }
    }
})