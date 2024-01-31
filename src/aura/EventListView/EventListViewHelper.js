({
    getCurrentCommunityName : function(cmp,event){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityName');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::',response);
                cmp.set("v.community",response);
                
                 if(response == 'client'){
                    let filterObj = cmp.get('v.filterObj');
                    filterObj.preparation = false;
                    filterObj.testing = false;
                    cmp.set('v.filterObj', filterObj);
                }
                self.getEventRecords(cmp, event);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                alert('error');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
	getEventRecords : function(cmp,event) {

        var self = this;
        var param = {};
        
        var statusValues = cmp.get("v.selectedStatus");
        console.log('statusValues',statusValues);
        var isPendingEventsAvailable = false;
        var projectId = cmp.get("v.selectedProject");
        console.log('projct is is',projectId);
        
        var filterObj = cmp.get("v.filterObj");
        
        if(projectId){
            param.projectId = projectId;
        }else{
            param.projectId = null;
        }
        
        if(filterObj.fromDate){
            param.stDate = filterObj.fromDate;
        }
        if(filterObj.toDate){
            param.edDate = filterObj.toDate;
        }
        param.statusValues = [];
        if(statusValues){
            param.statusValues = statusValues;
        }
        param.taskType = [];
        param.otherTaskTypes = [];
        if(filterObj.training){
            param.taskType.push('Language Training');
        }
        
        if(filterObj.testing){
            param.taskType.push('Language Testing');
        }
        if(filterObj.studentPDO || filterObj.instructorPDO){
            param.otherTaskTypes.push('PlannedDayOff');
        }
        
        if(filterObj.holiday){
            param.otherTaskTypes.push('Holiday');
        }
        
        if(filterObj.preparation && cmp.get("v.community") != 'student'){
            param.taskType.push('Preparation time');
        }
        console.log('param',param);
        const server = cmp.find('server');
        const action = cmp.get('c.getEventRecords');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var recordsWrap = JSON.parse(response);
                var eventRecords = recordsWrap.eventRecords;
                var filteredEventRecords = [];
                var pendingApprovalEvents = [];
                
                if(eventRecords.length > 0){
                    for(var i = 0;i < eventRecords.length; i++){
                        
                        /*var startTime = self.get24HourFormat(eventRecords[i].startTime);                    
                        var eventDtTime = moment(self.dateFormatFunction(eventRecords[i].eventDate)+' '+startTime[0]+':'+startTime[1]).tz(eventRecords[i].timezone).format();
                        var currentDtTime = moment().add('days', 1).tz(eventRecords[i].timezone).format();
                        
                        if(!(eventDtTime >= currentDtTime) && eventRecords[i].showRescheduleBtn){
                            eventRecords[i].showRescheduleBtn = false;
                        }*/
                    
                        if(eventRecords[i].eventType == 'StudentPDO' || eventRecords[i].eventType == 'InstructorPDO'){
                            if(filterObj.studentPDO && eventRecords[i].eventType == 'StudentPDO'){
                                filteredEventRecords.push((eventRecords[i]));   
                            }
                            if(filterObj.instructorPDO && eventRecords[i].eventType == 'InstructorPDO'){
                                filteredEventRecords.push((eventRecords[i]));  
                            }
                        }else if(eventRecords[i].eventType == 'PendingApproval'){
                            pendingApprovalEvents.push(eventRecords[i]);
                            isPendingEventsAvailable = false;
                            if(filterObj.pendingEventApproval && (statusValues.length == 0 || statusValues.includes('Draft'))){
                                if((projectId && eventRecords[i].projectId == projectId) || (!projectId || projectId == 'All')){
                                    console.log( eventRecords[i].parentEventStatus);
                                    if(eventRecords[i].status == 'Draft'  && eventRecords[i].parentEventStatus && eventRecords[i].parentEventStatus == 'Submitted for Reschedule'){
                                        eventRecords[i].status = eventRecords[i].approvalStatus;
                                    }
                                    filteredEventRecords.push((eventRecords[i]));  
                                }
                            }
                        }else {
                            filteredEventRecords.push((eventRecords[i])); 
                        }
                    }
                    
                }
                cmp.set('v.isPendingEventsAvailable', isPendingEventsAvailable);
                
                console.log('eventRecords',filteredEventRecords);
                cmp.set("v.eventRecords",filteredEventRecords);
                cmp.set("v.pendingApprovalEvents",pendingApprovalEvents);
                cmp.set("v.projectValues",recordsWrap.projectValues);
                console.log('initial load',cmp.get("v.initialLoad"))
                if(cmp.get("v.initialLoad")){
                    cmp.set("v.filterObj.fromDate",recordsWrap.stDate);
                    cmp.set("v.filterObj.toDate",recordsWrap.endDate);
                    cmp.set("v.initialLoad" ,false);
                }else {
                    self.tableInitialize(cmp);
                }
                self.getPendingApprovalRecords(cmp, event);
                cmp.set("v.fireEventChange",false);//After changed status false this for multiple changes
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
	},
    showToast :  function(cmp,event,message,type,title){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    tableInitialize : function(cmp){
        var header = [
            
            {
            	'label':'',
            	'name':'eventId',
            	'type':'String',
                'width':50,  
                'sorting':false
            },
            {
                'label':'Name',
                'name':'eventName',
                'type':'String',
                'value':'eventId',
                'resizeable':true
            },
            {
                'label':'Date',
                'name':'eventDate',
                'type':'date',
                'format':'MM/DD/YYYY'
            },
            {
                'label':'Status',
                'name':'status',
                'type':'text',
                'class':'boldCls'
            },
            {
                'label':'Instructor',
                'name':'instructor',
                'type':'String'
            },
            {
                'label':'Room',
                'name':'room',
                'type':'String'
            },
            {
                'label':'Start Time',
                'name':'startTime',
                'type':'text'
            },
            {
                'label':'End Time',
                'name':'endTime',
                'type':'text'
            },
            {
                'label':'Time Zone',
                'name':'timezone',
                'type':'text',
                'truncate':{length:6}
            },
            
        ];
        console.log('config is',header);
        cmp.set("v.header",header);
        var tableConfig = {
            "massSelect":false,
            "globalAction":[],
            "rowAction":[
                {
                    "type": "image",
                    "class": "imgAction1",
                    "id": "reScheduleTask",
                    "src": "/instructor/resource/Community_Reschedule_Icon",
                    "visible": function(task){
                        return (task.showRescheduleBtn == true);
                    }
                },
                 {
                     "type": "image",
                     "class": "imgAction2",
                      "id": "pendingEventApproval",
                      "src": "/instructor/resource/Community_Event_Pending_Approval_Icon",
                      "visible": function(task){
                         return (task.showPendingApprovalIcon == true && task.status == 'LTS Approved'); 
                      }
                },
                {
                    "type": "image",
                    "class": "imgZoomLogo",
                     "id": "joinMeetingUrl",
                     "src": $A.get('$Resource.zoom_logo'),
                     "visible": function(task){
                        return (task.meetingUrl != null); 
                     }
               },
                {
                    "type": "image",
                    "class": "imgAction2",
                     "id": "lessonPlan",
                     "src": $A.get('$Resource.lessonPlan'),
                    "visible": function(event){
                        return (event.eventType == "Language Training" && event.showLessonPlan); 
                     }
               },
               {	
                   "label": "Create Zoom Meeting",
                    "type": "url",
                    "class": "zoomActionFont",
                     "id": "createMeeting",
                     //"src": $A.get('$Resource.schedulebutton'),
                     "visible": function(task){
                         
                        return ((task.meetingUrl == null && (task.room == 'Zoom - Online' || task.isHybridRoom)) && task.eventType != 'Preparation time' && task.status == 'Scheduled' && task.showMeetingIcons && cmp.get('v.community') == 'instructor'); 
                     }
               },         
               {	
                    "label": "Move Online",
                    "type": "url",
                    "class": "zoomActionFont",
                     "id": "moveOnline",
                     //"src": $A.get('$Resource.zoom_logo'),
                     "visible": function(task){
                         
                        return ((task.meetingUrl == null && (task.room != 'Zoom - Online' || task.isHybridRoom)) && task.eventType != 'Preparation time' && task.status == 'Scheduled' && task.showMeetingIcons && cmp.get('v.community') == 'instructor'); 
                     }
               }  
               
            ],
            "rowActionPosition":'right',
            //"rowActionWidth": 150,
            "paginate":true,
                'rowClass':function(row){
                    if(row.classColour == 'trainingClass'){
                        return 'trainingClass';
                    } else if(row.classColour == 'preparationClass'){
                        return 'preparationClass';
                    } else if(row.classColour == 'testingClass'){
                        return 'testingClass';
                    } else if(row.classColour == 'holidayClass'){
                        return 'holidayClass';
                    } else if(row.classColour == 'instructorPDOClass'){
                        return 'instructorPDOClass';
                    } else if(row.classColour == 'studentPDOClass'){
                        return 'studentPDOClass';
                    }else if(row.classColour == 'pendingApproval'){
                        return 'pendingApproval';
                    }
                },};
    
        cmp.set("v.showSpinner",false);
        cmp.set("v.eventTableConfig",tableConfig);
        cmp.find("eventTable").initialize({
            "order":[2,'asc'],
            "itemMenu" : [15,20,25],
            
        });
    },
    getPendingApprovalRecords : function(cmp, event) {
		var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getEventsForApproval');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response::approval:',response);
                cmp.set("v.showSpinner",false);
                if(cmp.get('v.showApprovalModel') && response.length == 0) {                    
                    cmp.set("v.showApprovalModel", false);
                    cmp.set("v.initialLoad" ,false);
                    self.getEventRecords(cmp, event, helper);                   
                } else {
                    cmp.set("v.pendingApprovalEvtList", response);
                    cmp.set('v.selectedPendingApprovalEvent', cmp.get('v.pendingApprovalEvtList'));
                }              
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
    get24HourFormat : function(time) {
        if(time == undefined) {
            return [0, 0];
        }
        var h = time.split(' ');
        var m = h[0].split(':');
        var t = [];
        if(m[1] != undefined)
            t[1] = m[1];
        else
            t[1] = 0;
        if(h[1] == 'AM') {
            t[0] = m[0];
        } else if(h[1] == 'PM'){
            if(m[0] == '12')
                t[0] = parseInt(m[0]);
            else
                t[0] = parseInt(m[0]) + 12;
        }
        return t;
    },
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[0]+'/'+dateVal.split('-')[1]+'/'+dateVal.split('-')[2];
    },
    moveEventOnline : function(cmp, eventToMoveOnline, index) {
        cmp.set("v.showSpinner", true);
		var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.moveEventToOnline');
        server.callServer(
            action,
            {'eventStr' : JSON.stringify(eventToMoveOnline)},
            false,
            $A.getCallback(function(responseStr) {
                cmp.set("v.showSpinner", false);
                console.log(response);
                var eventList = cmp.get("v.eventRecords");                
                var response = JSON.parse(responseStr);
                eventList[index] = response.event;
                
                if(response.message){
                    var modal = {header:'User Creation', message:response.message};
                    cmp.set('v.modal', modal);
                    cmp.find("msgModal").open();
                }
                cmp.set('v.eventRecords', eventList);
                cmp.find("eventTable").rerenderRows();
                self.showToast(cmp,event,'Meeting Created Successfully!','success','Success');
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                var modal = {header:'Error', message:errors[0].message};
                cmp.set('v.modal', modal);
                cmp.find("msgModal").open();
            }),
            false, 
            false,
            false
        );
    },
    openLessonPlanModal: function(cmp, event){
       cmp.set("v.selectedRecord", event);
       
        var communityName = cmp.get('v.community'),
            selectedRecord = cmp.get('v.selectedRecord');
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s/"))+'/s/lesson-plan?';
        
        var url = baseURL+'communityName='+communityName+'&eventId='+selectedRecord.eventId+'&modalHeader=Lesson Plan ' +selectedRecord.dateStr;   
        window.open(url, '_blank');
    }
})