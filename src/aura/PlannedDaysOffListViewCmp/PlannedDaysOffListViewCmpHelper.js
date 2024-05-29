({
    getPDORecords : function(cmp,event) {
        
        cmp.set("v.showSpinner",true);
        var self = this;        
        var filterObj = cmp.get("v.filterObj");
        var projectId = cmp.get("v.selectedProject");        
        projectId = projectId == 'All' ? null : projectId;
        var strDate,endrDate;
        if(filterObj.fromDate){
            strDate = filterObj.fromDate;
        }else{
            strDate = null;
        }
        if(filterObj.toDate){
            endrDate = filterObj.toDate;
        }else{
            endrDate = null;
        }
        
        var param = {};
        param.stDate = strDate;
        param.edDate = endrDate;
        param.projectId = projectId;
        param.status = cmp.get("v.selectedStatus");
        param.recordLimit = false;
        
        const server = cmp.find('server');
        const action = cmp.get('c.getPlannedRecords');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                console.log('response::::::getPlannedRecords::::',JSON.parse(response));
                var result = JSON.parse(response);
                cmp.set("v.plannedOffRows",result.leaveInfoList);
                cmp.set("v.projectValues",result.projectValues);
                cmp.set("v.contactRec",result.contactInfo);
                cmp.set('v.communityName', result.communityName);
                self.initTableConfig(cmp, result.communityName);
                var typeValues = [];
                typeValues = result.contactInfo && result.contactInfo.RecordType.DeveloperName == 'Candidate' ? ['Instructor'] : ['Student'];
                cmp.set('v.typeValues', typeValues);
                cmp.set("v.plannedDaysMap",result.plannedDaysOffMap );
                cmp.set("v.requestOffRT",result.requestOffRTId);
                cmp.set("v.statusValues",result.statusValues);
                cmp.set("v.showSpinner",false);

                cmp.find("plannedOffTable").initialize({
                    "order":[0,'desc']
                });
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error','sticky');
            }),
            false, 
            false,
            false
        );
    },
    initTableConfig: function(cmp, communityName){
        
        var header=[            
            {
                'label':'Date',
                'name':'dateStr', 
                'type':'text',
                'truncate' : {},
                'width' : '20%',
                'sortable':true
                
            },
            {
                'label':'Description',
                'name':'description',
                'type':'text',
                'truncate' : {},
                'width' : '30%',
                'sortable':true,
                
            },
            {
                'label':'Type',
                'name':'type',
                'type':'text',
                'width' : '20%',
                'truncate' : {},
                'sortable':true
            },        
            {
                'label':'Status',
                'name':'status',
                'width' : '20%',
                'truncate' : {},
                'sortable':true
            }];
        var actionConfig = [];
        if(communityName != 'client'){
                actionConfig = [
                    {
                        "type": "image",
                        "class": "imgAction1",
                        "id": "edittask",
                        "src":$A.get("$Resource.DLS_Communties_Icons")+'/CommunityIcon/editIcon.png'
                    }, {
                        "type": "image",
                        "class": "imgAction2",
                        "id": "deltask",
                        "src":$A.get("$Resource.DLS_Communties_Icons")+'/CommunityIcon/deleteIcon.png'                        
                    }
            ];
        }
        var tableConfig = {
            
            "paginate":true,
            "searchByColumn":false,
            "searchBox":false,
            "sortable":true,
            "rowAction": actionConfig,
            "rowActionPosition":'right',
            "rowClass":"rowClass"            
        }
        
        cmp.set("v.tableconfig",tableConfig);
        cmp.set("v.plannedOffheader",header);        
    },
    showToast : function(cmp,event,message,type,title,mode){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: mode
        });
        toastEvent.fire();
    },
    createNewOffRecord : function(cmp, event){
        var offRecord = {};
        var plannedOffdayRecord = cmp.get("v.plannedOffdayRecord");
        var typeOfAction = cmp.get("v.typeOfAction");
        
        if(typeOfAction == 'edittask'){
            offRecord.Id = plannedOffdayRecord.Id;
            offRecord.Date__c = plannedOffdayRecord.Date__c;
        }else{
            offRecord.Contact__c = cmp.get("v.contactRec").Id;
            offRecord.User__c = $A.get("$SObjectType.CurrentUser.Id");
            offRecord.Status__c = 'Draft';  
            offRecord.RecordTypeId = plannedOffdayRecord.RecordTypeId;
            
            if(plannedOffdayRecord.To_Date__c && plannedOffdayRecord.To_Date__c != null){
                offRecord.From_Date__c = plannedOffdayRecord.Date__c;
                offRecord.To_Date__c = plannedOffdayRecord.To_Date__c;
            }else {
                // offRecord.Date__c = plannedOffdayRecord.Date__c;
                offRecord.From_Date__c = plannedOffdayRecord.Date__c;
            }
        }
        
        offRecord.Type__c = plannedOffdayRecord.Type__c;
        offRecord.Description__c = plannedOffdayRecord.Description__c;
        offRecord['All_Projects__c'] = (plannedOffdayRecord.Project__c == 'All' ? true : false);
        offRecord.Project__c = (plannedOffdayRecord.Project__c == 'All' ? null : plannedOffdayRecord.Project__c);        
        //console.log('::::::offRecord::::',JSON.stringify(offRecord));
        
        var daysOffArray = [];
        daysOffArray.push(offRecord);
        
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.createNewPlannedOffRecords');
        server.callServer(
            action,
            {newPlannedOffJson : JSON.stringify(daysOffArray)},
            false,
            $A.getCallback(function(response) {
                //console.log('response:::new::off::::created:',response);
                self.getPDORecords(cmp, event);
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error','sticky');
            }),
            false, 
            false,
            false
        );
    },
    
    updateEditRecords : function(cmp,event) {
        var self = this;
        var plannedDaysCmp = [],
            plannedDaysOff = [],
            plannedOffdayRecord = cmp.get('v.plannedOffdayRecord');
        cmp.set("v.showSpinner",true);
        if(!cmp.get('v.parentViewMode')){
            plannedDaysCmp.push(cmp.find("parentPlannedDaysEdit"));
            plannedDaysOff.push(plannedOffdayRecord);
        }
        
        var plannedDaysEditCmp = cmp.find("plannedDaysEdit");
        if(Array.isArray(plannedDaysEditCmp)){
            plannedDaysCmp.push(...plannedDaysEditCmp);
        }else{
            plannedDaysCmp.push(plannedDaysEditCmp);
        }
        
        var plannedOffDays = cmp.get("v.plannedOffDays");
        if(Array.isArray(plannedOffDays)){
            plannedDaysOff.push(...plannedOffDays);
        }else{
            plannedDaysOff.push(plannedOffDays);
        }
        plannedDaysOff.forEach(function(plannedOffDay) {
            if(plannedDaysOff.length == 1){
                if(plannedOffDay.requestOffRT && plannedOffDay.requestOffRT == 'Request'){
                    plannedOffDay['Id'] = plannedOffDay.Id;
                }else{
                    plannedOffDay['Id'] = plannedOffdayRecord.Id;
                }
                plannedOffDay['From_Date__c'] = plannedOffDay.Date__c;
                plannedOffDay['Date__c'] = null;
            }
            plannedOffDay['All_Projects__c'] = (plannedOffDay.Project__c == 'All' ? true : false);
            plannedOffDay.Project__c = (plannedOffDay.Project__c == 'All' ? null : plannedOffDay.Project__c);
        });
        //console.log('is array function::',Array.isArray(plannedDaysCmp));
        console.log('plannedDaysCmp::>', plannedDaysCmp.length);
        var size = 0;
        var plannedDaysSize = 0;
        if(plannedDaysCmp) {
            if(Array.isArray(plannedDaysCmp)) {
                plannedDaysCmp.forEach(function(day) {
                    if(!day.get("v.deleteMode")) {
                        size += 1;
                    }                            			
                    plannedDaysSize += 1;
                });
            }else {
                if(!plannedDaysCmp.get("v.deleteMode")){
                    size = 1;
                    plannedDaysSize = 1;                    
                }
            }
            
        }
        //console.log('size::',size);
        
        var status = '';
        
        if(size > 0 && plannedDaysSize == size) {
            status = 'Deleted';
        }else if(size > 0 && plannedDaysSize != size) {
            status = 'Deleted and Updated';
        }else{
            status = 'Updated';
        }
        var action = cmp.get("c.createNewPlannedOffRecords");
        action.setParams({newPlannedOffJson : JSON.stringify(plannedDaysOff), status : status,allowParentPlanToUpdate : cmp.get("v.allowParentPlanToUpdate"),parentPlannedDayId : cmp.get("v.currentPlannedDay")});

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                cmp.set("v.showSpinner",false);
                cmp.set("v.successTitle",'The Planned Days have been successfully '+status);
                cmp.set("v.successHeader", 'Success');
                cmp.find("editOffModel").close();
                cmp.set("v.showAddEditModel",false);
                cmp.set("v.viewMode", true);
                cmp.set("v.parentViewMode", true);
                cmp.set("v.showSaveButton", false);
        		cmp.set("v.showSuccessModel",true);
                cmp.find("successModel").open();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
        /*const server = cmp.find('server');
        const action = cmp.get('c.createNewPlannedOffRecords');
        console.log(new Date());
        server.callServer(
            action,
            {newPlannedOffJson : JSON.stringify(plannedDaysOff), status : status,allowParentPlanToUpdate : cmp.get("v.allowParentPlanToUpdate"),parentPlannedDayId : cmp.get("v.currentPlannedDay")},
            false,
            $A.getCallback(function(response) {
                console.log('response:::new::off::::created:',response,new Date());
                //console.log('status:::',status);
                cmp.set("v.showSpinner",false);
                cmp.set("v.successTitle",'The Planned Days have been successfully '+status);
                cmp.set("v.successHeader", 'Success');
                cmp.find("editOffModel").close();
                cmp.set("v.showAddEditModel",false);
                cmp.set("v.viewMode", true);
                cmp.set("v.parentViewMode", true);
                cmp.set("v.showSaveButton", false);
        		cmp.set("v.showSuccessModel",true);
                cmp.find("successModel").open();
                
                /*window.setTimeout(
                    $A.getCallback(function() {
                        self.getPDORecords(cmp, event);
                    }), 1000);
                
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error','sticky');
            }),
            false, 
            false,
            false
        );*/
    },
    
    updatePDOStatusAsDeleteHelper: function(cmp,event) {
        var offRecordArray = [];
        var plannedOffdayRecord = cmp.get("v.plannedOffdayRecord");
        
        offRecordArray.push({'Id' : plannedOffdayRecord.id,'Status__c' : 'Delete'});
        
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.updatePDOStatusAsDelete');
        server.callServer(
            action,
            {plannedOffJson : JSON.stringify(offRecordArray)},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.successHeader", 'Success'); 
                cmp.set("v.successTitle",'The Planned Days have been successfully Deleted');
                
                cmp.set("v.showDeleteModel",false);  
                
        		cmp.set("v.showSuccessModel",true);
                cmp.find("successModel").open();
                
                /*window.setTimeout(
                    $A.getCallback(function() {
                        self.getPDORecords(cmp, event);
                    }), 1000);*/
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    findPDODayDiffernceHelper: function(cmp, plannedDaysOffDate) {
        return new Promise($A.getCallback((resolve, reject) => {
            cmp.set("v.showSpinner",true);
            
            var self = this;
            const server = cmp.find('server');
            const action = cmp.get('c.getPDODaysDifference');
            server.callServer(
                action,
                {'pdoSTDt' : plannedDaysOffDate},
                false,
                $A.getCallback(function(response) {
                    cmp.set("v.showSpinner",false);
                    console.log(response);
                    var noOfDays = response;
                    resolve(noOfDays);                       
                }),
                $A.getCallback(function(errors) {
                    cmp.set("v.showSpinner",false);
                    self.showToast(cmp,event,errors[0].message,'error','Error');
                }),
                false, 
                false,
                false
            );
        }));
     }
})