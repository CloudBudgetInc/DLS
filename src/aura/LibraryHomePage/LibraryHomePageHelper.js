({
    getFilterValues : function(cmp,event) {
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getMRFilterDetails');
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('MR::Filters:::::',result);
                
                var loanFilterValues = cmp.get("v.loanFilterValues");
                cmp.set("v.MRRecordTypeMap",result.rtIdDeveloperNameMap);
                loanFilterValues.recordTypeValues = result.recordTypeValues;
                loanFilterValues.dlsLocationValues = result.locationValues;
                
                loanFilterValues.recordTypeValues.unshift({'label':'All','value':'All'});
                loanFilterValues.recordTypeValues.push({'label':'New Library Purchase','value':'New Library Purchase'});
                
                loanFilterValues.dlsLocationValues.unshift({'label':'All','value':'All'});
                
                cmp.set("v.loanFilterValues",loanFilterValues);
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
     showToast : function(cmp,event,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
             mode: 'sticky'
        });
        toastEvent.fire();
    },
    getMaterialRequestRecords : function(cmp,event){
        var self = this;
        var param = {};
        var loanFilter = cmp.get("v.loanFilter");
        
        //For RecordType
        if(loanFilter.selectedRecordType != 'All' && loanFilter.selectedRecordType != 'New Library Purchase'){
            param.recordTypeName = cmp.get("v.MRRecordTypeMap")[loanFilter.selectedRecordType];
        }else {
            param.recordTypeName = loanFilter.selectedRecordType;
        }
        
        //For status
        param.status = loanFilter.selectedStatus;
        
        //Supervisor filter
        if(loanFilter.supervisor.length > 0 ){
            param.supervisorId = loanFilter.supervisor[0].Id;
        }else {
            param.supervisorId = null;
        }
        
        //Contact filter
        if(loanFilter.relatedContact.length > 0 ){
            param.relatedContactId = loanFilter.relatedContact[0].Id;
        }else {
            param.relatedContactId = null;
        }
        
        //location filter
        param.relatedLocationId = loanFilter.selectedLocation;
        
        const server = cmp.find('server');
        const action = cmp.get('c.materialRequestBasedonFilter');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('MR::results:::::',result.length);   
                cmp.set("v.materialRequestRecords",result);
                
                window.setTimeout(
                    $A.getCallback(function() {                        
                        	self.displayTable(cmp);
                    }),100);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    displayTable : function(cmp){
        var currentRecordType = '';
        var loanFilter = cmp.get("v.loanFilter");
        if(loanFilter.selectedRecordType != 'All' && loanFilter.selectedRecordType != 'New Library Purchase'){
            currentRecordType = cmp.get("v.MRRecordTypeMap")[loanFilter.selectedRecordType];
        }else {
            currentRecordType = loanFilter.selectedRecordType;
        }
        
        var header = [];
        var otherRTs = ['All','Material_Disposal','Material_Transfer','New Library Purchase']
        
        if(otherRTs.indexOf(currentRecordType) != -1){
            header = this.otherTableColumns(cmp);
        }else if(currentRecordType == 'Material_Loan_Request'){
            header = this.loanTableColumns(cmp);
        }else if(currentRecordType == 'Project_Materials_Request'){
            header = this.orderTableColumns(cmp);
        }
        
        var taskTableConfig = {
            "massSelect":false,
            "rowActionPosition":'right',
            'rowActionWidth':'100',
            "rowAction":[
                {
                 "label":"View More",
                 "type":"url",
                 "id":"viewMore"
                 }],
            
            "paginate":true,
            "searchByColumn":false,
            "searchBox":false,
            "sortable":true,
            
        };
        cmp.set("v.header",header);
        cmp.set("v.tableConfig",taskTableConfig); 
        if(cmp.get("v.materialRequestRecords").length > 0){
            if(otherRTs.indexOf(currentRecordType) != -1){
                cmp.find("materialTable").initialize({
                    "order":[2,'desc'],
                    "itemMenu" : [25,50],
                });  
            }else if(currentRecordType == 'Material_Loan_Request'){
                cmp.find("materialTable").initialize({
                    "order":[2,'desc'],
                    "itemMenu" : [25,50]
                });  
            }else if(currentRecordType == 'Project_Materials_Request'){
                cmp.find("materialTable").initialize({
                    "order":[5,'desc'],
                    "itemMenu" : [25,50]
                });  
            }
        }
        cmp.set("v.showSpinner",false);
    },
    otherTableColumns : function(cmp){
        var header = [
            {
                'label':'Record #',
                'name':'Name',
                'type':'reference',
                'target':'_blank',
                'value':'Id',
                'width': '200',
                'sortable':true
            },
            {
                'label':'Material Name',
                'name':'Materials_Name__r.Name', 
                'type':'reference',
                'target':'_blank',
                'value':'Materials_Name__c',
                'width': '300',
                'truncate' : {
                    "characterLength" :60
                },
                'sortable':false
            },  
            {
                'label':'Requested Date',
                'name':'CreatedDate',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'width': '200',
                'sortable':true,
            },
            {
                'label':'Status',
                'name':'Request_Status__c',
                'type':'string',
                'width': 100,
                'truncate' : {
                    "characterLength" :60
                },
                'sortable':true
            }
        ];
        return header;
    },
    loanTableColumns : function(cmp){
        var header = [
            {
                'label':'Record #',
                'name':'Name',
                'type':'reference',
                'target':'_blank',
                'value':'Id',
                'width': 100,
                'sortable':true
            },
            {
                'label':'Material Name',
                'name':'Materials_Name__r.Name', 
                'type':'reference',
                'target':'_blank',
                'width': 300,
                'value':'Materials_Name__c',
                'truncate' : {
                    "characterLength" :60
                },
                'sortable':false
            },  
            {
                'label':'Date Loaned Out',
                'name':'Date_Loaned_Out__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'width': 50,
                'sortable':true,
            },
            {
                'label':'Date Returned',
                'name':'Date_Returned__c',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'width': 50,
                'sortable':true,
            },
            {
                'label':'Status',
                'name':'Request_Status__c',
                'type':'string',
                'width': 100,
                'truncate' : {
                    "characterLength" :60
                },
                'sortable':true
            }
        ];
        return header;
    },
    orderTableColumns : function(cmp){
        var header = [
            {
                'label':'Record #',
                'name':'Name',
                'type':'reference',
                'target':'_blank',
                'value':'Id',
                'width': '150',
                'sortable':true
            },
            {
                'label':'Project Name',
                'name':'Project__r.Name', 
                'type':'reference',
                'target':'_blank',
                'value':'Project__c',
                'width': '150',
                'truncate' : {
                    "characterLength" :60
                },
                'class':'wrapTableHeader',
                'sortable':true
            },
            {
                'label':'Material Name',
                'name':'Materials_Name__r.Name', 
                'type':'reference',
                'target':'_blank',
                'value':'Materials_Name__c',
                'width': '180',
                'truncate' : {
                    "characterLength" :60
                },
                'class':'wrapTableHeader',
                'sortable':true
            }, 
            {
                'label':'Quantity',
                'name':'Qty__c',
                'type':'Number',
                'width': '150',
                'sortable':true,
            },
            {
                'label':'Request Type',
                'name':'Request_type__c',
                'type':'text',
                'width': '150',
                'class':'wrapTableHeader',
                'sortable':true,
            },
            {
                'label':'Request Date',
                'name':'CreatedDate',
                'type':'date',
                'format': 'MM/DD/YYYY',
                'width': '150',
                'class':'wrapTableHeader',
                'sortable':true
            },
            {
                'label':'Status',
                'name':'Request_Status__c',
                'type':'string',
                'width': 100,
                'truncate' : {
                    "characterLength" :60
                },
                'sortable':true
            }
        ];
        return header;
    },
    updateLoanRecord : function(cmp, event){
        var updatedRecord = cmp.get("v.materialRequestRecord");
        var records = [];
        records.push(updatedRecord);
        
        var param = {};
		param.loanJson = JSON.stringify(records);
        
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.updateLoanMRRecords');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
             	console.log('loan update::',response);
             	self.getMaterialRequestRecords(cmp);
             	cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    deleteActionCall : function(cmp, event){
        var self = this;
        
        var deleteRecord = cmp.get("v.materialRequestRecord");
        var records = [];
        records.push(deleteRecord);
        
        var param = {};
        param.deleteJson = JSON.stringify(records);
        param.objectName = 'Materials_Request__c';
        
        const server = cmp.find('server');
        const action = cmp.get('c.deleteForallObjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log('MR:::delete::',response);
             	self.getMaterialRequestRecords(cmp);
             	cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    clearTableContents : function(cmp){
        cmp.set("v.materialRequestRecords",[]);
        cmp.set("v.header",[]);
    },
    createNewMaterialRequest : function(cmp, event){
        var projectId = '';
        if(cmp.get("v.selectedProject")){
            projectId = cmp.get("v.selectedProject");
        }
        
        var materialRequestRecord = cmp.get("v.materialRequestRecord");
        
        var self = this;
        
        var param = {};
        param.loanMRId = materialRequestRecord.Id;
        param.projectId = projectId;
        
        const server = cmp.find('server');
        const action = cmp.get('c.upsertLoanMRRecords');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log(':::::::transffered::::new::project:::::',response);
             	self.getMaterialRequestRecords(cmp);
             	cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    getProjectForInstructor : function(cmp,event){
        
        var materialRequestRecord = cmp.get("v.materialRequestRecord");
        
        var self = this;
        
        var param = {};
        param.instructorId = materialRequestRecord.Contact__c;
        
        const server = cmp.find('server');
        const action = cmp.get('c.getInstructorProjects');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                //console.log(':::::::project::list:::',JSON.parse(response));
                cmp.set("v.instructorProjects",JSON.parse(response));
                
                cmp.set("v.displayProjectSelection",true);
                if(Array.isArray(cmp.find("showProjectSelection"))){
                    cmp.find("showProjectSelection")[0].open();
                }else {
                    cmp.find("showProjectSelection").open();
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    }
        
})