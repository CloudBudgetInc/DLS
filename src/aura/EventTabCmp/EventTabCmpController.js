({
    doinit : function(cmp, event, helper) {
        let recTypeName = cmp.get("v.parenRecordTypeName");
        
        if(recTypeName == 'Testing_Projects' 
           || recTypeName == 'Testing_Opportunities'){
            
            cmp.set("v.statusSelected","All");
        }else {
            cmp.set("v.statusSelected","Scheduled");
        }
        
        let projRecTypeForProjTaskRequiredValidation = ['Testing_Projects','DLI_W_LT_Projects','Language_Training_Projects','DODA_Projects'];
        cmp.set('v.isProjTaskRequired',projRecTypeForProjTaskRequiredValidation.indexOf(recTypeName) != -1);
        
        var proIds = cmp.get("v.proRecordIds");
        if(proIds.length > 0) {
            var proIdStr = '';
            for(var i = 0; i < proIds.length; i++) {
                if(proIdStr == '') {
                    proIdStr = proIds[i];
                } else {
                    proIdStr += ', '+proIds[i];
                }
            }
            cmp.set("v.proIdString", proIdStr);
        }
        
        cmp.set("v.showSpinner",true);
        //console.log('::::proIds::::',cmp.get("v.proRecordIds"));
        //console.log('::::statusSelected::::',cmp.get("v.statusSelected"));
        var action = cmp.get("c.getEventRecordsInitial");
        action.setParams({
            projId : cmp.get("v.proRecordIds"),
            eveStatus : cmp.get("v.statusSelected")
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(':::::::result:::::::',result);
                var startDate = cmp.get("v.previousWeekStDate");
                var endDate = cmp.get("v.nextWeekEnDate");
                cmp.set("v.sObjectName",result.parentType);
                cmp.set("v.projectExist",result.projectExist);
                cmp.set('v.eventsIdsHasLP',result.eventsIdsHasLP);
                
                var header = [
                    {
                        'label':'Name',
                        'name':'Name',
                        'type':'reference',
                        'value':'Id',
                        'resizeable':true,
                        'target':'_blank'
                    },
                    {
                        'label':'Date',
                        'name':'Date__c',
                        'type':'date',
                        'format':'MM-DD-YYYY'
                    },
                    {
                        'label':'Status',
                        'name':'Status__c',
                        'type':'text'
                    },
                    {
                        'label':'Instructor',
                        'name':'Instructor__r.Name',
                        'type':'reference',
                        'value':'Instructor__c',
                        'target':'_blank'
                    },
                    {
                        'label': 'PROJECT TASK',
                        'name': 'Project_Task__r.Name',
                        'type': 'reference',
                        'value': 'Project_Task__c',
                        'sortable': true,
                        'target': '_blank',
                        'truncate': {
                            "characterLength": 40,
                        },
                        'width': '20%'
                    },
                    {
                        'label':'Room',
                        'name':'Room__r.Name',
                        'type':'reference',
                        'value':'Room__c',
                        'target':'_blank'
                    },
                    {
                        'label':'Start Time',
                        'name':'Start_Time__c',
                        'type':'text'
                    },
                    {
                        'label':'End Time',
                        'name':'End_Time__c',
                        'type':'text'
                    },
                    {
                        'label':'Time Zone',
                        'name':'Timezone__c',
                        'type':'text'
                    }
                ];
                
                var tableConfig = {};
                
                
                if(cmp.get("v.parenRecordTypeName") == 'Testing_Projects' || cmp.get("v.parenRecordTypeName") == 'Testing_Opportunities'){
                    tableConfig = {
                        searchBox: false,
                        searchByColumn: false,
                        paginate: false,
                        sortable: false,
                        "massSelect":true,
                        "showRowSelect":function (row) { return (row.Status__c == 'Scheduled' || row.Status__c == 'Draft')},
                        "rowActionPosition":"right",
                        "rowActionWidth":"70",
                        "rowAction":[
                            {
                                "type": "image",
                                "class": "imgAction1",
                                "id":"updateEventBtn",
                                "src":'/resource/Edit_Icon',
                                "visible":function(event){
                                    return (event.Status__c == "Scheduled" || event.Status__c == "Draft")
                                }
                            },
                            {
                                "type": "image",
                                "class": "imgAction2",
                                "id": "openzoommeeting",
                                "src":'/resource/zoom_logo',
                                "visible": function(task){
                                    return (task.Meeting_URL__c && task.Date__c >= moment().format('YYYY-MM-DD'));
                                }
                            },
                            {
                                "type": "image",
                                "class": "imgAction2",
                                "id": "lessonPlan",
                                "src": $A.get('$Resource.lessonPlan'),
                                "visible": function(event){
                                    var eventsIdsHasLP = cmp.get('v.eventsIdsHasLP');                                    
                                    return (eventsIdsHasLP.indexOf(event.Id) != -1); 
                                }
                            }
                        ]
                    };
                }else {
                    tableConfig = {
                        "massSelect":true,
                        "showRowSelect":function (row) { return (row.Status__c == 'Scheduled' || row.Status__c == 'Draft')},
                        "rowActionPosition":"right",
                        "rowActionWidth":"70",
                        "rowAction":[
                            {
                                "type": "image",
                                "class": "imgAction1",
                                "id":"updateEventBtn",
                                "src":'/resource/Edit_Icon',
                                "visible":function(event){
                                    return (event.Status__c == "Scheduled" || event.Status__c == "Draft")
                                }
                            },
                            {
                                "type": "image",
                                "class": "imgAction2",
                                "id": "openzoommeeting",
                                "src":'/resource/zoom_logo',
                                "visible": function(task){
                                    
                                    return (task.Meeting_URL__c && task.Date__c >= moment().format('YYYY-MM-DD'));
                                }
                            },
                            {
                                "type": "image",
                                "class": "imgAction2",
                                "id": "lessonPlan",
                                "src": $A.get('$Resource.lessonPlan'),
                                "visible": function(event){
                                    var eventsIdsHasLP = cmp.get('v.eventsIdsHasLP');  
                                    return (eventsIdsHasLP.indexOf(event.Id) != -1); 
                                }
                            }                            
                        ]
                    };
                }
                
                if(cmp.get("v.sObjectName") != "Opportunity") {
                	cmp.set("v.eventTableConfig",tableConfig);
                } else {
                    cmp.set("v.eventTableConfig",{});
                }
                cmp.set("v.eventList", result.eveList);
                cmp.set("v.header",header);
                
                if(!startDate) {	
                    cmp.set("v.previousWeekStDate", result.startDate);
                } else {
                    cmp.set("v.previousWeekStDate", startDate);
                }
                if(!endDate) {	
                    cmp.set("v.nextWeekEnDate", result.endDate);
                } else {
                    cmp.set("v.nextWeekEnDate", endDate);
                }
                
                var pickListValues = {};
                pickListValues.status = result.statusValue;
                pickListValues.startTime = result.startTimeValue;
                pickListValues.endTime = result.endTimeValue;
                
                cmp.set("v.eventpickListValues", pickListValues);
                cmp.set("v.currentUserProfile",result.profileName);
                cmp.set("v.allowRoomEdit",result.allowRoomEdit);
                cmp.set("v.parentOralExamDate",result.parentOralExamDate);
                cmp.set("v.parentOralExamTime",result.parentOralExamTime);
                cmp.set("v.defaultCostRate", result.defaultCostRate);
                cmp.set("v.parentRecordType", result.parentRecordType);
                cmp.set("v.caRecord", result.caRecord);
                
                if(result.projTaskIdMap){
                    var projectTaskMap = [];
                    for(var key in result.projTaskIdMap){
                        projectTaskMap.push({'label': result.projTaskIdMap[key], 'value':key});
                    }
                    cmp.set("v.proTaskOptions", projectTaskMap);
                }
                
                var time = result.startTimeValue;
                var timeList = [];
                
                for(var i = 0;i < time.length;i++){
                    timeList.push({'label':time[i],'value':time[i],'temp':helper.convertTime(cmp,time[i])});
                }
                
                cmp.set("v.startTimeList",timeList);
                cmp.set("v.endTimeList",timeList);  
                
                var eventObj = {};
                
                if(cmp.get("v.parenRecordTypeName") == 'Testing_Projects' || cmp.get("v.parenRecordTypeName") == 'Testing_Opportunities'){
                	
                    eventObj.dateVal = cmp.get("v.parentOralExamDate");
                    eventObj.startTime = cmp.get("v.parentOralExamTime");
                    if(eventObj.startTime){
                    	eventObj.startTimeMinutes = helper.getMinutes(cmp,eventObj.startTime, false);   
                    }
                }  
                
                eventObj.status = 'Scheduled';
                eventObj.instructor = [];
                eventObj.room = [];
                eventObj.projTask = [];
                
                cmp.set("v.eventObj",eventObj);
                helper.endTimeValue(cmp, event, helper);
                helper.initializeTable(cmp, event, helper);
                
            } else {                
                var toast = cmp.get("v.toastMessage");
                toast.message = response.getError()[0].pageErrors[0].message;
                toast.header = 'Error';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusMsgModal"))) {
                    cmp.find("statusMsgModal")[0].open();
                }else{
                    cmp.find("statusMsgModal").open();
                }
                cmp.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecord : function(cmp, event, helper) {
        console.log(':::TABLE::::');
        helper.eventRecords(cmp, event, helper);
    },
    
    closeStatusModal : function(cmp, event, helper) {
        if(Array.isArray(cmp.find("statusMsgModal"))) {
            cmp.find("statusMsgModal")[0].close();
        }else{
            cmp.find("statusMsgModal").close();
        }
    },
    
    updateSelectedEvent : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        helper.selectedEvents(cmp, event, helper, 'updateSelectedEvent');
    },
    
    tableActionHandler : function(cmp, event, helper){
        var actionId = event.getParam('actionId'),
            rowRecord = event.getParam("row");
        
        if(actionId == 'updateEventBtn'){
            cmp.set("v.showSpinner",true);
            helper.selectedEvents(cmp, event, helper, actionId);
        }else if(actionId == 'openzoommeeting'){
            var row = event.getParam('row');
            window.open(row.Meeting_URL__c, '_blank')
        }else if(actionId == 'lessonPlan'){
            rowRecord.dateStr = '';
            if(rowRecord.Date__c){
                var dateArr = rowRecord.Date__c.split('-');
                rowRecord.dateStr = dateArr[1]+'/'+dateArr[2]+'/'+dateArr[0];
            }
            helper.openLessonPlanModal(cmp, rowRecord);      
        } 
    },
    createEvent : function(cmp, event, helper){
        cmp.set("v.showCreateEventModal",true);
        if(Array.isArray(cmp.find("newEventModal"))) {
            cmp.find("newEventModal")[0].open();
        }else{
            cmp.find("newEventModal").open();
        }
    },    
    instructorLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getGenericLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('instructorLookup').search(serverSearchAction);
    },
    
    roomLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('roomLookup').search(serverSearchAction);
    },
    
    projectTaskLookupSearch: function(cmp, event, helper){
        var projectTaskCondition = 'AcctSeed__Project__c = \''+cmp.get('v.proIdString')+'\' AND Project_Task_Type__c != \'Material budget\'';
        cmp.set('v.projectTaskCondition', projectTaskCondition);
        const serverSearchAction = cmp.get('c.getGenericLookupRecords');
        cmp.find('projectTaskLookup').search(serverSearchAction);
    },
    
    submitOnNewEvent : function(cmp, event, helper){
        helper.validateInput(cmp);
    },
    closeOnNewEvent : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("newEventModal"))) {
            cmp.find("newEventModal")[0].close();
        }else{
            cmp.find("newEventModal").close();
        }
        cmp.set("v.showCreateEventModal",false);
    },
    assignCRValueToCA : function(cmp ,event ,helper) { 
        
        var costRateInfo = event.getParam("costRateInfo"); 
        var caRecord = cmp.get("v.caRecord");
        var parentObjName = cmp.get("v.sObjectName");
        var defaultCR = cmp.get("v.defaultCostRate");
        var isCACreatewithCR = false;
        
        console.log('::>',costRateInfo);

        if(costRateInfo.costRateId && costRateInfo.costRateLabel){
            isCACreatewithCR = true;
            if(costRateInfo.costRateLabel == 'RateCost'){
                caRecord.Rate_Card_Rate__c = costRateInfo.costRateId;   
                caRecord.Drafted_Labor_Cost_Rate__c = null;
            }else {
                caRecord.Drafted_Labor_Cost_Rate__c = costRateInfo.costRateId; 
                caRecord.Rate_Card_Rate__c = null;
            }
            
            if(parentObjName == 'AcctSeed__Project__c' && defaultCR == 'Non-SCA Testing' && costRateInfo.nohrsExcepted != null){
                caRecord.Total_Qty_Planned__c = costRateInfo.nohrsExcepted;
                caRecord.Quantity_Unit__c = 'Hours'; 
            }
            
            cmp.set("v.caRecord",caRecord);
        }
        
        if(costRateInfo.isErrorFROMCRModal){
            cmp.set("v.showCostRateModal",false);
        }else if(isCACreatewithCR){
            helper.createEventRecords(cmp);
            cmp.set("v.showCostRateModal",false);    
            cmp.set("v.showCreateEventModal",false); 
        }else{   
            var appEvent = $A.get("e.c:reloadEvent");
            appEvent.fire();
        }
    },
    setEventTimeAndDuration: function(cmp, event, helper){
        
        var eventObj = cmp.get('v.eventObj');
        var isEndTime = eventObj.endTime == '12:00 AM';
		
		if(eventObj.startTime) {			
            eventObj.startTimeMinutes = helper.getMinutes(cmp,eventObj.startTime, isEndTime);
		}
		
		if(eventObj.endTime){
			eventObj.endTimeMinutes = helper.getMinutes(cmp,eventObj.endTime, isEndTime);
		}
		   
		if(eventObj.startTimeMinutes && eventObj.endTimeMinutes){			           
			var totalHrsPerSession = (eventObj.endTimeMinutes - eventObj.startTimeMinutes) / 60;
			eventObj.duration = totalHrsPerSession;			
        }else{
            eventObj.duration = 0;
        }
        
        if(event.getSource().get("v.label") == 'Start Time'){
        	helper.endTimeValue(cmp, event, helper);
        }
        cmp.set("v.eventObj",eventObj);
    },
    closeLessonPlanModal : function(cmp, event, helper){
        cmp.find("lessonPlanModal").close();
        cmp.set("v.showLessonPlan", false);            
    },
    closeTestingProDatesModal : function(cmp, event, helper){
        cmp.set("v.testingProOralDateVal",false);
    },
    updateTestingProOralDates : function(cmp, event, helper){
        cmp.set("v.testingProOralDateVal",false);
        helper.checkInstructorAvailable(cmp);
    }
    
})