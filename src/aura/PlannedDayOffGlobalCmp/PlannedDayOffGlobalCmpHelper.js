({
	 searchPDORecords : function(component,event,helper) {
        
        component.set("v.plannedOffRecordType",[]);
        component.set("v.showSpinner",true);
      
        var action = component.get("c.getPlannedDaysOffInfo");
        action.setParams({ "conId":'',"proId":'',"oppId":'',"dt1":null,"dt2":null});
         action.setCallback(this, function(data) {
             var state=data.getState();
             if(state == "SUCCESS"){
                 var plannedOffJson = JSON.parse(data.getReturnValue());
                 //console.log('plannedOffJson'+JSON.stringify(plannedOffJson));
                 component.set("v.leaveType",plannedOffJson.leaveType);
                 component.set("v.typeValues",plannedOffJson.typeValues);
                 component.set("v.showSpinner",false);
                 component.set("v.plannedOffRTNameIdMap",plannedOffJson.plannedOffRTNameIdMap);
                 
             }else if(state == "ERROR"){
                 component.set("v.showSpinner",false);
                 this.showToast(component,event,helper,'error','',data.getError()[0].message,'pester','info_alt');
             }
         });
         $A.enqueueAction(action);
     },
     savePDOClick :function(component,event,helper){
        
        component.set("v.showSpinner",true);
         var plannedOffRecord = component.get("v.plannedOffdayRecord");
         var requestPDORec = component.get("v.requestPDORec");
         var parentType = component.get("v.sObjectName");
         var contactRec = component.get("v.contactRec");

         if(contactRec && contactRec.RecordType.DeveloperName == 'DLS_Employee'){
            requestPDORec.From_Date__c = plannedOffRecord.Date__c;
            requestPDORec.Contact__c = contactRec.Id;
            requestPDORec.Status__c = 'Draft';
            requestPDORec.Type__c = plannedOffRecord.Type__c;
            requestPDORec.Leave_Type__c = plannedOffRecord.Leave_Type__c;
            requestPDORec.Description__c = plannedOffRecord.Description__c;
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

            if(contactRec && contactRec.RecordType.DeveloperName == 'DLS_Employee'){
                requestPDORec.To_Date__c = endDate;
            }  
            
            for(var i = 0;i < datesArray.length;i++){
                daysArray.push({
                    Date__c : datesArray[i],
                    Description__c : plannedOffRecord.Description__c,
                    RecordTypeId : plannedOffRecord.RecordTypeId,
                    Contact__c : contactRec.Id,
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
         
         if(contactRec && contactRec.Id){
             plannedOffRecord.Contact__c = contactRec.Id;
         }
            
        daysArray.push(plannedOffRecord);
        if(contactRec && contactRec.RecordType.DeveloperName == 'DLS_Employee'){
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
            "requestOffJson":JSON.stringify(requestRecArray)
        });
        action.setCallback(this, function(data) {
            var state=data.getState();
            if(state == "SUCCESS"){
                console.log('::::',JSON.parse(data.getReturnValue()));  
                component.set("v.showSpinner",false);
                var msg = (component.get("v.actionHeaderName") == 'Planned Days Off') ? 'Planned Days Off was Created Sucessfully' : 'Planned Days Off was Updated Sucessfully';
                this.showToast(component,event,helper,'success','Success',msg,'pester','info_alt');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire()
            }
            if(state == "ERROR"){
                component.set("v.showSpinner",false); 
                this.showToast(component,event,helper,'error','',data.getError()[0].message,'pester','info_alt');
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function(component, event, helper, type, title, message, mode,key) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            key: key,
            title: title,
            type: type,
            mode: mode
        });
        toastEvent.fire();
    }
})