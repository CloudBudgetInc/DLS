({
    getParentInfo : function(cmp, event, helper){
        
        var objName = '';
        if(cmp.get("v.sObjectName") == 'Opportunity'){
            objName = 'Opportunity';
        }else {
            objName = 'Project';
        }
        
        var action = cmp.get("c.getParentRecord");
        action.setParams({
            objectName : objName,
            parentId : cmp.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                console.log(':::::::result::::;',result);
                if(result.length > 0){
                    cmp.set("v.parentRecordType",result[0].RecordType.DeveloperName);
                    cmp.set("v.sObjectName",result[0].attributes.type);
                }
                
                if(result.length > 0 && (result[0].RecordType.DeveloperName == 'Testing_Projects' 
                                         || result[0].RecordType.DeveloperName == 'Testing_Opportunities')){
                    
                    var proIds = [];
                    proIds.push(cmp.get("v.recordId"));
                    cmp.set("v.proRecordIds",proIds);
                    cmp.set("v.activeTab","EventsTab");
                    cmp.set("v.dipslayEventTab",true);
                    cmp.set("v.showSpinner",false);
                }else {
                    cmp.set("v.activeTab","scheduleTab");
                    this.getParentTypes(cmp, event, helper);
                }
                
            } else {
                cmp.set("v.showSpinner",false);
                //console.log("::::ERROR::Status Based:::", response.getError());
                this.showToast(cmp,event,response.getError()[0].message,'error','Error');
            }
        });
        $A.enqueueAction(action);
    },
    getParentTypes : function(cmp, event, helper){
        var action = cmp.get("c.getParentType");
        action.setParams({
            parentId : cmp.get("v.recordId"),
            scheStatus : cmp.get("v.statusSelected")
        });
        action.setCallback(this, function(response){
            var status1 = response.getState();
            if(status1 == "SUCCESS") {
                var status = ['All', 'Drafted & Active'];
                var returnValue = response.getReturnValue();
                console.log('Returned value:::',returnValue);
                //cmp.set("v.parentType", returnValue.parentType);
                cmp.set("v.isProjectExist",returnValue.isProjectExist);
                cmp.set("v.projectId",returnValue.projectId);
                cmp.set("v.currentUsrProfileName",returnValue.currentUsrProfileName);
                cmp.set("v.haveDLSClassNo",returnValue.haveDLSClassNo);
                cmp.set("v.onlineRoomId", returnValue.onlineRoomId);
                cmp.set("v.isDLSOnlineProject", returnValue.isDLSOnlineProject);
                cmp.set("v.roomIdsFilterConditionForLTS", returnValue.roomIdsFilterConditionForLTS);
                //cmp.set("v.parentRecordType", returnValue.parentRecordType);
                cmp.set("v.scheduleActionPermissionMap", returnValue.scheduleActionPermissionMap);
                
                
                if(returnValue.schOpliWrap.length > 0){
                    for(var i = 0; i < returnValue.schOpliWrap.length; i++) {
                        if(returnValue.schOpliWrap[i].startDate) {
                            var stDate = new Date(returnValue.schOpliWrap[i].startDate);
                            returnValue.schOpliWrap[i].startDate = helper.addZero(cmp, event, helper, stDate.getMonth()+1)+'-'+
                                helper.addZero(cmp, event, helper, stDate.getDate())+'-'+
                                stDate.getFullYear();
                        }
                        
                        if(returnValue.schOpliWrap[i].endDate) {
                            var enDate = new Date(returnValue.schOpliWrap[i].endDate);
                            returnValue.schOpliWrap[i].endDate = helper.addZero(cmp, event, helper, enDate.getMonth()+1)+'-'+
                                helper.addZero(cmp, event, helper, enDate.getDate())+'-'+
                                enDate.getFullYear();
                        }
                        
                        if(returnValue.schOpliWrap[i].travelIn) {
                            var inDate = new Date(returnValue.schOpliWrap[i].travelIn);
                            returnValue.schOpliWrap[i].travelIn = helper.addZero(cmp, event, helper, inDate.getMonth()+1)+'-'+
                                helper.addZero(cmp, event, helper, inDate.getDate())+'-'+
                                inDate.getFullYear();
                        }
                        
                        if(returnValue.schOpliWrap[i].travelOut) {
                            var outDate = new Date(returnValue.schOpliWrap[i].travelOut);
                            returnValue.schOpliWrap[i].travelOut = helper.addZero(cmp, event, helper, outDate.getMonth()+1)+'-'+
                                helper.addZero(cmp, event, helper, outDate.getDate())+'-'+
                                outDate.getFullYear();
                        }
                        
                        returnValue.schOpliWrap[i].sch.days = helper.daysFormationFunction(cmp,returnValue.schOpliWrap[i].sch);
                    }
                }
                for(var i = 0; i < returnValue.statusValue.length; i++) {
                    
                    if(returnValue.statusValue[i] != 'Drafted') {
                        status.push(returnValue.statusValue[i]);
                    }
                }
                cmp.set("v.schStatusValue", status);
                cmp.set("v.schOpliWrap", returnValue.schOpliWrap);
                this.sortScheduleRecord(cmp);
                cmp.set("v.showSpinner",false);
            } else {
                //console.log(':::ERROR::',response.getError());
                this.showToast(cmp,event,response.getError()[0].message,'error','Error');
            }
            
        });
        $A.enqueueAction(action);
    },
    addZero : function(cmp, event, helper, dtMonVal) {
        var dtMoVal;
        if(dtMonVal != null && dtMonVal != '') {
            if(dtMonVal < 10) {
                dtMoVal = '0'+dtMonVal;
            } else {
                dtMoVal = dtMonVal;
            }
        }
        return dtMoVal;
    },
    
    getScheduleInformation : function(cmp){
        cmp.set("v.showSpinner",true);

        var action = cmp.get("c.getScheduleRecords");
        action.setParams({
            parentId : cmp.get("v.recordId"),
            schStatus : cmp.get("v.statusSelected"),
            parentType : cmp.get("v.parentType")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                for(var i = 0;i < result.length;i++){
                    result[i].sch.days = this.daysFormationFunction(cmp,result[i].sch);
                }
                cmp.set("v.schOpliWrap", result);
                this.sortScheduleRecord(cmp);
                cmp.set("v.showSpinner",false);
            } else {
                cmp.set("v.showSpinner",false);
                //console.log("::::ERROR::Status Based:::", response.getError());
                this.showToast(cmp,event,response.getError()[0].message,'error','Error');
            }
        });
        $A.enqueueAction(action);
    },
    sortScheduleRecord :  function(cmp){
        var sortAsc = true,
            field = 'startTimeMinutes',
            records = cmp.get("v.schOpliWrap");
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        
        cmp.set("v.schOpliWrap", records);
    },
    getAllActiveInstructor : function(component,event,helper){
          //console.log('In get All active Instructors');
        var action = component.get("c.getAvailableInstructors");
        action.setParams({
            projectId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set('v.instructorList',response.getReturnValue());
                component.find('prompt').toggle(); 
                console.log('Instructor list::::',response.getReturnValue());
                component.set("v.showSpinner",false);
            } else {
                component.set("v.showSpinner",false);
                //console.log("::::ERROR::Schedule Activate::::",response.getError());
                this.showToast(component,event,response.getError()[0].message,'error','Error');
            }
        });
        $A.enqueueAction(action);  
    },
    
    deleteRecord : function(component, event, helper, schedule,type){
        
        var action = component.get("c.deleteSchedule");
        var scheduleList = component.get("v.schOpliWrap");
        console.log('In delete record helper',scheduleList[schedule].sch);
        action.setParams({
            scheduleStr : JSON.stringify(scheduleList[schedule].sch),
            cancelType : type
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                //scheduleList.splice(schedule,1);
                //component.set("v.schOpliWrap",scheduleList);
                component.set("v.showSpinner",false);
                this.getScheduleInformation(component);
            } else {
                component.set("v.showSpinner",false);
                //console.log("::::ERROR::Schedule Activate::::",response.getError());
                this.showToast(component,event,response.getError()[0].message,'error','Error');
            }
        });
        $A.enqueueAction(action);  	    
    },
    editOrPlusIconclick : function(cmp,index,type){
        var scheduleList = cmp.get("v.schOpliWrap");
        console.log('::::::::::scheduleList[index]::::',scheduleList[index]);
        if(type == 'edit' || type == 'Activate'){
            cmp.set("v.scheduleId",scheduleList[index].sch.Id);
            console.log('Schedule Type::::', scheduleList[index].sch.Schedule_Type__c);
            cmp.set("v.scheduleType",scheduleList[index].sch.Schedule_Type__c);
        }else {
            cmp.set("v.scheduleId",'');
            cmp.set("v.priorScheduleId",scheduleList[index].sch.Id);
            cmp.set("v.scheduleType",type);
        }
        cmp.set("v.parentScheduleId",scheduleList[index].sch.Parent_Schedule__c);
        cmp.set("v.typeOfAction",type);
        cmp.set("v.showSpinner",false);
        cmp.set("v.showAddModel",true);
    },
    addScheduleRelatedValdiation : function(cmp,msgType){
        if(msgType == 'Product Msg') {
            cmp.set("v.validationTitle",'Warning');
            if(cmp.get("v.sObjectName") == 'Opportunity') {
                cmp.set("v.validationMsg",'Opportunity should have "Hrs" or "Days" Unit Type Product');
            }else{
                cmp.set("v.validationMsg",'Project should have "Hrs" or "Days" Unit Type Project Task');
            }
            cmp.find("validationModal").open();
        }else if(msgType == 'DLS Class Msg'){
            cmp.set("v.validationTitle",'Warning');
            cmp.set("v.validationMsg",'You have to set a DLS Class Name before creating a Schedule.');
            cmp.find("validationModal").open();
        }
        cmp.set("v.showSpinner",false);
        
    },
    sendEmailtoNotifyFEOTeam : function(component,event,helper){
        var action = component.get("c.sendMailtoNotifyFEOTeam");
        action.setParams({
            projectId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                this.showToast(component,event,'Email Notification sent successfully to FEO Team.','success','Success');
                component.set("v.showSpinner",false);
            } else {
                component.set("v.showSpinner",false);
                this.showToast(component,event,response.getError()[0].message,'error','Error');
            }
        });
        $A.enqueueAction(action);
    },
    daysFormationFunction :  function(cmp,schRec){
        var days = '';
        if(schRec.Days__c){
            days = schRec.Days__c.split(';').join('/');
        }
        return days;
    },
    showToast : function(cmp,event,message,type,title){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
})