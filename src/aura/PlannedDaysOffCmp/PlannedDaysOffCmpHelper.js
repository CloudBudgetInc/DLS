({
    searchPDORecords : function(component,event,helper) {
        
        component.set("v.plannedOffRecordType",[]);
        component.set("v.showSpinner",true);
        console.log(component.get("v.selectedContact"));
        var parentId = component.get("v.recordId");
        var parentType = component.get("v.sObjectName");
        console.log(':::::parent'+parentType);
        console.log(':::::recordId'+parentId);
        var proId = '';
        var oppId = '';
        var conId ='';
        
        if(parentType == 'Contact'){
            conId = parentId;
        }else if(component.get("v.selectedContact").length > 0) {
            conId = component.get("v.selectedContact")[0].Id;
        }
        if(parentType == 'Opportunity') {
            oppId = parentId;
        }else if(parentType == 'AcctSeed__Project__c'){
            proId = parentId; 
        }
        var dt1 = null;
        var dt2 = null;
        if(component.get("v.StartDate") != null){
            dt1 = component.get("v.StartDate");
        }
        if(!component.get("v.EndDate") != null){
            dt2 = component.get("v.EndDate");
        }
        var action = component.get("c.getPlannedDaysOffInfo");
        action.setParams({ 
            "conId":conId,
            "proId":proId,
            "oppId":oppId,
            "dt1":dt1,
            "dt2":dt2
        });
        action.setCallback(this, function(data) {
            var state=data.getState();
            if(state == "SUCCESS"){
                
                var plannedOffJson = JSON.parse(data.getReturnValue());
                //console.log('plannedOffJson'+JSON.stringify(plannedOffJson));
                component.set("v.leaveType",plannedOffJson.leaveType);
                component.set("v.typeValues",plannedOffJson.typeValues);
                component.set("v.plannedOffRTNameIdMap",plannedOffJson.plannedOffRTNameIdMap);
                component.set("v.contactRec",plannedOffJson.contactRec);
                
                if(component.get("v.contactRec")){
                    if(component.get("v.selectedContact").length == 0){
                        var obj = {};
                        obj['Id'] = plannedOffJson.contactRec.Id;
                        obj['Name'] = plannedOffJson.contactRec.Name;
                        component.set("v.selectedContact",obj);
                        component.set("v.StartDate",plannedOffJson.startDate);
                    }
                }
                
                for(var key  in   component.get("v.plannedOffRTNameIdMap")){
                    if(key != 'Staff_Planned_Days_Off' && key != 'Request') {
                        component.get("v.plannedOffRecordType").push({'RecordType':key.split('_').join(' ') ,'Id':component.get("v.plannedOffRTNameIdMap")[key]});
                    }
                }
                console.log('::::::::existing:::off::::',plannedOffJson.existingOff);
                for( var i = 0 ;i < plannedOffJson.existingOff.length ;i++){
                    if(plannedOffJson.existingOff[i].RecordTypeId && plannedOffJson.existingOff[i].RecordType.DeveloperName == 'Request'){
                        var fromDate = this.dateFormatValue(plannedOffJson.existingOff[i].From_Date__c);
                        var toDate  = this.dateFormatValue(plannedOffJson.existingOff[i].To_Date__c);
                        
                        if(fromDate != null &&  toDate != null ){
                            plannedOffJson.existingOff[i].Date = fromDate +' - ' +toDate;
                        }else {
                            var date = this.dateFormatValue(plannedOffJson.existingOff[i].From_Date__c);
                            if(date != null){
                                plannedOffJson.existingOff[i].Date = date;
                            }
                        } 
                    }else {
                        var date = this.dateFormatValue(plannedOffJson.existingOff[i].Date__c);
                        if(date != null){
                            plannedOffJson.existingOff[i].Date  = date;
                        }
                    }
                }
                
                component.set("v.plannedOffRecordType",component.get("v.plannedOffRecordType"));
                component.set("v.plannedOffRows",plannedOffJson.existingOff);
                component.set("v.StartDate",plannedOffJson.startDate);
                
                if(component.get("v.isFromContactAssignment")){
                    component.set("v.showSpinner",false);
                    this.newPlannedOffDays(component,event,helper);
                }else{
                    if(component.get("v.plannedOffRows").length > 0){
                        this.displayPlannedOffDayTable(component,event,helper);
                    }else{
                        component.set("v.showSpinner",false);    
                    }
                }  
            } 
            if(state == "ERROR"){
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
                
            }
        });
        $A.enqueueAction(action);
    },
    displayPlannedOffDayTable : function(component,event,helper) {
        
        var header=[
            {
                'label':'Name',
                'name':'Name',
                'type':'reference',
                'width' : '10%',
                'truncate' : {
                    "characterLength" :30
                },
                'sortable':false,
                'value':'Id',
                'target':'_blank'
                
            },
            {
                'label':'Contact',
                'name':'Contact__r.Name', 
                'type':'reference',
                'width' : '15%',
                'sortable':false,
                'value':'Contact__c',
                'target':'_blank'
                
            }, 
            {
                'label':'Date',
                'name':'Date', 
                'type':'text',
                'width' : '15%',
                'sortable':false
                
            },
            {
                'label':'Description',
                'name':'Description__c',
                'type':'text',
                'width' : '15%',
                'sortable':false
                
            },
            {
                'label':'Type',
                'name':'Type__c',
                'type':'text',
                'width' : '10%',
                'sortable':false
                
            },
            {
                'label':'Leave Type',
                'name':'Leave_Type__c',
                'width' : '10%',
                'truncate' : {
                    "characterLength" :30
                },
                'sortable':false
            },
            {
                'label':'Status',
                'name':'Status__c',
                'width' : '15%',
                'truncate' : {
                    "characterLength" :15
                },
                'sortable':false
            }];
        
        var tableConfig = {
            
            "paginate":true,
            "searchByColumn":false,
            "searchBox":false,
            "sortable":false,
            "rowAction": [
                {
                    "type": "image",
                    "class": "imgAction2",
                    "id": "edittask",
                    "src": "/resource/1482987504000/Edit_Icon",
                    "visible":function(task){
                        return task.RecordType && task.RecordType.DeveloperName != "Request" && task.Status__c != "Delete" 
                    }
                }, {
                    "type": "image",
                    "class": "imgAction2",
                    "id": "deltask",
                    "src": "/resource/1482987503000/Delete_Icon",
                    "visible":function(task){
                        return task.RecordType && task.RecordType.DeveloperName != "Request" && task.Status__c != "Delete" ;
                    }
                }
            ],
            "rowActionPosition":'right',
            "rowClass":"rowClass",
        }
        component.set("v.tableconfig",tableConfig);
        component.set("v.plannedOffheader",header);
        component.set("v.showSpinner",false);
        component.find("plannedOffTable").initialize({'order':[]}); 
        
    },
    getCARelatedContacts:function(component,event,helper,type){
        var action = component.get("c.getRelatedContactsPDO");
        action.setParams({ 
            "parentId":component.get("v.recordId"),
            "parentType":component.get("v.sObjectName"),
            "type":type
            
        });
        action.setCallback(this, function(data) {
            var state=data.getState();
            if(state == "SUCCESS"){
                component.set("v.GetCAContacts",JSON.parse(data.getReturnValue())); 
                component.set("v.showSpinner",false);
            }else{
                if(state == "ERROR"){
                    component.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
    },
    savePDOClick :function(component,event,helper){
        
        component.set("v.showSpinner",true);
        var plannedOffRecord = component.get("v.plannedOffdayRecord");
        var requestPDORec = component.get("v.requestPDORec");
        var parentType = component.get("v.sObjectName");
        
        if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'DLS_Employee'){
            requestPDORec.From_Date__c = plannedOffRecord.Date__c;
            requestPDORec.Contact__c = plannedOffRecord.Contact__c;
            requestPDORec.Status__c = 'Draft';
            requestPDORec.Type__c = plannedOffRecord.Type__c;
            requestPDORec.Leave_Type__c = plannedOffRecord.Leave_Type__c;
            requestPDORec.Description__c = plannedOffRecord.Description__c;
            requestPDORec.Opportunity__c = plannedOffRecord.Opportunity__c;
            requestPDORec.Project__c = plannedOffRecord.Project__c;
            requestPDORec.RecordTypeId = component.get("v.plannedOffRTNameIdMap")['Request'];
        }
        
        console.log('Json',JSON.stringify(requestPDORec));
        var datesArray = []
        var daysArray = [];
        var requestRecArray = [];
        if(plannedOffRecord.To_Date__c && plannedOffRecord.To_Date__c != null){
            var startDate =  moment(plannedOffRecord.Date__c).add(1,'days');
            var endDate =  moment(plannedOffRecord.To_Date__c).format('YYYY-MM-DD');
            while(startDate.isBefore(endDate) || startDate.isSame(endDate)){
                if(moment(startDate).weekday() != 6 && moment(startDate).weekday() != 0) {
                    datesArray.push(moment(startDate).format('YYYY-MM-DD'));
                }
                startDate = moment(startDate).add(1,'days');
            }
            
            if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'DLS_Employee'){
                requestPDORec.To_Date__c = endDate;
            }  
            
            //delete requestPDORec.toDate;
            for(var i = 0;i < datesArray.length;i++){
                daysArray.push({
                    Date__c : datesArray[i],
                    Description__c : plannedOffRecord.Description__c,
                    RecordTypeId : plannedOffRecord.RecordTypeId,
                    Contact__c :plannedOffRecord.Contact__c,
                    Leave_Type__c : plannedOffRecord.Leave_Type__c,
                    Type__c : plannedOffRecord.Type__c, 
                    Status__c : plannedOffRecord.Status__c,
                    Opportunity__c :plannedOffRecord.Opportunity__c,
                    Project__c : plannedOffRecord.Project__c
                });
            }
            
        }    
        if(plannedOffRecord.To_Date__c == '' ){
            delete plannedOffRecord.To_Date__c;
            component.set("v.plannedOffdayRecord",plannedOffRecord);
        }
        daysArray.push(plannedOffRecord);
        if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'DLS_Employee'){
            requestRecArray.push(requestPDORec);
        }
        
        console.log(':::::::daysArray:::::',JSON.stringify(daysArray));
        console.log('requestPDORec',JSON.stringify(requestPDORec));
        console.log(':::::::requestRecArray:::::',JSON.stringify(requestRecArray));
        
        
        if(daysArray.length > 0) {
            var contId = '';
            if(component.get("v.contactRec")) {
                contId = component.get("v.contactRec").Id;
            } 
        }
        
        //  create_updatemethodPDO
        var action = component.get("c.create_updatemethodPDO");
        action.setParams({ 
            "plannedOffJson":JSON.stringify(daysArray),
            "contId":contId,
            "requestOffJson":JSON.stringify(requestRecArray),
            "isCancelEvents": component.get("v.isCancelEvents")
            
        });
        action.setCallback(this, function(data) {
            var state=data.getState();
            if(state == "SUCCESS"){
                console.log('::::',JSON.parse(data.getReturnValue()));  
                this.searchPDORecords(component, event, helper);
                component.set("v.displayAddEditModel",false);
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success",
                    message:(component.get("v.actionHeaderName") =='Planned Days Off')?"Planned Days Off was Created Sucessfully":'Planned Days Off was Updated Sucessfully',
                    type:"success"
                });
                toastEvent.fire();
                if(component.get("v.isFromContactAssignment")){
                    var appEvent = $A.get("e.c:reloadEvent");
                    appEvent.fire();
                }
            }
            if(state == "ERROR"){
                component.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
    dateFormatValue:function(date){
        if(date){
        return (date.split('-')[1]+'/'+date.split('-')[2]+'/'+date.split('-')[0]);
        }
    },
    newPlannedOffDays:function(component,event,helper){
        
        var parentType = component.get("v.sObjectName");
        var parentId = component.get("v.recordId");
        
        component.set("v.actionHeaderName",'Planned Days Off');
        component.set("v.plannedOffdayRecord",{});
        component.set("v.isDisplaycontactProOpp",false);
        if(parentType == "" || parentType == "Contact"){
            if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'Candidate') {
                component.get("v.plannedOffdayRecord").Type__c = 'Instructor';
                component.get("v.plannedOffdayRecord").RecordTypeId = component.get("v.plannedOffRTNameIdMap")['Instructor_Planned_Days_Off'];
            }
            if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'Student'){
                component.get("v.plannedOffdayRecord").Type__c = 'Student';
                component.get("v.plannedOffdayRecord").RecordTypeId = component.get("v.plannedOffRTNameIdMap")['Student_Planned_Days_Off'];
            }
            if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'DLS_Employee'){
                component.get("v.plannedOffdayRecord").Type__c = 'Staff';
                component.get("v.plannedOffdayRecord").RecordTypeId = component.get("v.plannedOffRTNameIdMap")['Staff_Planned_Days_Off'];
            }
        }
        if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'DLS_Employee'){
            component.get("v.plannedOffdayRecord").Status__c = 'Draft' 
        }else{
            component.get("v.plannedOffdayRecord").Status__c = 'Approved' 
        }
        if( parentType == "AcctSeed__Project__c"){
            component.get("v.plannedOffdayRecord").Project__c = parentId;
        }
        if(parentType == "Opportunity"){
            component.get("v.plannedOffdayRecord").Opportunity__c = parentId;
        }
        if(component.get("v.selectedContact").length > 0){
            component.get("v.plannedOffdayRecord").Contact__c = component.get("v.contactRec").Id;  
        }
        component.set("v.plannedOffdayRecord",component.get("v.plannedOffdayRecord"));
        console.log(JSON.stringify(component.get("v.plannedOffdayRecord")));
        component.set("v.displayAddEditModel",true);
        component.find("planOffAddEditModel").openModal();
    }
    
})