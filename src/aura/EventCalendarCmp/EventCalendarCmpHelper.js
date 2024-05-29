({
    getCommunityName : function(cmp,event, helper){
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityPathPrefix');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                if(response){
                    cmp.set("v.communityName", response);
                }
                
                if(response == 'student'){
                    self.getRequestEventDetails(cmp, event);
                } else if(response == 'client'){
                    let selectedEventTypes = cmp.get('v.selectedEventTypes');
                    selectedEventTypes.preparation = false;
                    selectedEventTypes.testing = false;
                    cmp.set('v.selectedEventTypes', selectedEventTypes);
                }
                self.getEventRecords(cmp, event, helper);                             
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner", false);
                self.showToast(cmp, event, errors[0].message, 'error', 'Error');
            }),
            false, 
            false,
            false
        );
    },

    // Get All Event records in the initial load
    getEventRecords : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        var self = this;
        
        var status = JSON.parse(JSON.stringify(cmp.get("v.selectedStatus")));
        var param = {};
        param.year1 = cmp.get("v.year1");
        param.year2 = cmp.get("v.year2");
        
        if(!status.includes("Submitted for Reschedule")){
            status.push("Submitted for Reschedule");
        }
        param.statusValues = status;
        param.contactId = cmp.get("v.recordId");
        const server = cmp.find('server');
        const action = cmp.get('c.getEventRecordList');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                
                var eventRecords = response;
                
                for(var i = 0;i < eventRecords.length;i++){
                    var startTime = self.get24HourFormat(eventRecords[i].startTime); 
                    /*console.log(moment(self.dateFormatFunction(eventRecords[i].eventDate)+' '+startTime[0]+':'+startTime[1]).tz(eventRecords[i].timezone));
                    var eventDtTime = moment(self.dateFormatFunction(eventRecords[i].eventDate)+' '+startTime[0]+':'+startTime[1]);
                    var currentDtTime = moment();
                    console.log('eventDtTime::>'+eventDtTime);
                    console.log('currentDtTime::>'+currentDtTime);
                    if(cmp.get("v.communityName") == 'student') {
                        if(eventDtTime.isBefore(currentDtTime) && eventRecords[i].showRescheduleBtn){
                            eventRecords[i].showRescheduleBtn = false;
                        }
                    } else {
                        eventRecords[i].showRescheduleBtn = false;
                    }
                    */
                    if(eventRecords[i].eventType != 'Holiday' && eventRecords[i].eventType != 'StudentPlanned Days Off' && eventRecords[i].eventType != 'InstructorPlanned Days Off') {
                        var endTime = self.get24HourFormat(eventRecords[i].endTime);
                                                
                        var stDate = self.dateFormatFunction(eventRecords[i].eventDate)+' '+startTime[0]+':'+startTime[1];
                        var endDate = self.dateFormatFunction(eventRecords[i].eventDate)+' '+endTime[0]+':'+endTime[1];
                        
                        var st1 = new Date(stDate);
                        //st1.setTime(st1.getTime() + st1.getTimezoneOffset() * 1000 * 60);
                        
                        var st2 = new Date(endDate);
                        //st2.setTime(st2.getTime() + st2.getTimezoneOffset() * 1000 * 60);
                        
                        eventRecords[i].start = st1;
                        eventRecords[i].end = st2;
                        //eventRecords[i].allDay = false;
                    }else {
                        eventRecords[i].start = new Date(self.dateFormatFunction(eventRecords[i].eventDate));
                    }   
                    
                    //eventRecords[i].classNames = [];
                    if(eventRecords[i].status == 'Canceled' || eventRecords[i].status == 'Late Cancellation'){
                        eventRecords[i].className = ['eventNameClass'];
                    }
                }
                cmp.set("v.wholeEventRecords", eventRecords);
                console.log(eventRecords);
                self.filterEventBasedonEventType(cmp, event, helper);
                cmp.set("v.fireEventChange", false);
                cmp.set("v.showSpinner", false);
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
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[0]+'/'+dateVal.split('-')[1]+'/'+dateVal.split('-')[2];
    },

    filterEventBasedonEventType : function(cmp, event, helper){
        var wholeEvents = cmp.get("v.wholeEventRecords");
        var selectedEventType = cmp.get("v.selectedEventTypes");
        var communityName = cmp.get("v.communityName");
        var status = cmp.get("v.selectedStatus");
        var filteredEvents = [];
        var parentEvents = [];
        var isPendingEventsAvailable = false;
        var eventIds = [];
        helper.getPendingApprovalRecords(cmp, event, helper);
        
        for(var i = 0;i < wholeEvents.length;i++){
                       
            if(wholeEvents[i].status == 'Submitted for Reschedule'){
                parentEvents.push(wholeEvents[i]);
            }else if(eventIds.indexOf(wholeEvents[i].eventId) == -1){
                if(selectedEventType.training && wholeEvents[i].eventType == 'Language Training'){
                    filteredEvents.push(wholeEvents[i]);
                    eventIds.push(wholeEvents[i].eventId);
                }
                if(selectedEventType.preparation && wholeEvents[i].eventType == 'Preparation time' && communityName != 'student'){
                    filteredEvents.push(wholeEvents[i]);
                    eventIds.push(wholeEvents[i].eventId);
                }
                if(selectedEventType.testing && wholeEvents[i].eventType == 'Language Testing'){
                    filteredEvents.push(wholeEvents[i]);
                    eventIds.push(wholeEvents[i].eventId);
                }
                if(selectedEventType.holiday && wholeEvents[i].eventType == 'Holiday'){
                    filteredEvents.push(wholeEvents[i]);
                    //eventIds.push(wholeEvents[i].eventId);
                }
                if(selectedEventType.studentPDO && wholeEvents[i].eventType == 'StudentPDO'){
                    filteredEvents.push(wholeEvents[i]);
                    eventIds.push(wholeEvents[i].eventId);
                }
                if(selectedEventType.instructorPDO && wholeEvents[i].eventType == 'InstructorPDO'){
                    filteredEvents.push(wholeEvents[i]);
                    eventIds.push(wholeEvents[i].eventId);
                }
                if(wholeEvents[i].eventType == 'PendingApproval'){
                //  pendingApprovalEvents.push(wholeEvents[i]);
                    isPendingEventsAvailable = true;
                    if(selectedEventType.pendingEventApproval && (status.length == 0 || status.includes('Draft'))){
                        filteredEvents.push(wholeEvents[i]);
                        eventIds.push(wholeEvents[i].eventId);
                        console.log('::::::::::filteredEvents:::pending');
                    }
                }
            }
        }        
        cmp.set("v.parentEvents", parentEvents);
        cmp.set("v.filteredEvents",  filteredEvents);
        cmp.set('v.isPendingEventsAvailable', isPendingEventsAvailable);
        console.log('initttt:>'+cmp.get("v.initialLoad"));
        //cmp.set("v.pendingApprovalEvents", pendingApprovalEvents);
        if(cmp.get("v.initialLoad")){
            this.loadCalendar(cmp, helper, filteredEvents);
        }else {
            this.titleFormation(cmp, helper);
            $('#calendar').fullCalendar('removeEventSources');
            $('#calendar').fullCalendar('addEventSource', filteredEvents);
        }
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
    
    loadCalendar: function(component, helper, data) {
        
        var windowSize = innerHeight;
        var calHeight = 1000;
        var defaultView;
        var headerObj ={};
        var device = component.get("v.displayDevice");
        
        if (device == 'Mobile') {
            headerObj  = {
                left: 'prev,next today',
                center: 'title',
                right: 'agendaDay,agendaWeek'    // right: 'agendaDay,agendaWeek,listWeek' (Removed list view )
            }
        } else {
            headerObj  = {
                left: 'prev,next today',
                center: 'title',
                right: 'agendaDay,agendaWeek,month'     //right: 'agendaDay,agendaWeek,month,listWeek'
            }
        }
        
        component.set('v.showRequestEventBtn', component.get("v.communityName") == 'student' && component.get('v.projectRefWithNewReqEvent') && Object.keys(component.get('v.projectRefWithNewReqEvent')).length > 0);
        
        var m = moment();
        
        $('#calendar').fullCalendar({
            header: headerObj,
            displayEventTime : false,
            contentHeight:750,
            defaultView: (device == 'Mobile' ? 'agendaDay' : 'month'),
            background: '#A0A8A0',
            eventTextColor:'white;font-weight:bold',
            defaultDate : m.format(),
            events: data,
            scrollTime: '06:00:00',
            navLinks: true,
            editable: true,
            //selectable: true,
            //selectHelper: true,
            eventStartEditable: component.get("v.communityName") != 'student' ? false : true,
            eventLimit: true,
            views: {
                agenda: {
                  eventLimit: 3 // adjust to 3 only for agendaWeek/agendaDay
                }
            },
            nowIndicator:true,
            now: new Date(),
            buttonText: {
                agendaDay:'Day',
                today: 'Today',
                list: 'List',
                month: 'Month',
                agendaWeek : 'Week'
            },
            eventClick: function(data, event, view) {
                console.log('selected record:::::', data);
                console.log('selected event:::::', event);
                if(data.eventType != 'Holiday' && data.eventType != 'StudentPDO' && data.eventType != 'InstructorPDO'){
                    
                    data.eventTime = helper.formatEventTime(data);                    
                    component.set('v.selectedRecord',data);

                    var selectedRecordCopy = {};
                    selectedRecordCopy.eventId = data.eventId;
                    selectedRecordCopy.approvalStatus = data.approvalStatus;
                    
                    if(data.rejectComment){
                        selectedRecordCopy.rejectComment = data.rejectComment;
                    }else{
                        selectedRecordCopy.rejectComment = ''; 
                    }
                    component.set("v.selectedRecordCopy",selectedRecordCopy);
                    
                    var parentEvent = {};
                    var showParent = false;
                    var parentEvents = component.get("v.parentEvents");
                    for(var i = 0;i < parentEvents.length;i++){                        
                        if(parentEvents[i].eventId == data.parentEventId){
                            parentEvent = parentEvents[i];
                            showParent = true;
                            let parentEvtDate = new Date(parentEvent.eventDate);
                            let parentEvtMonthName = parentEvtDate.toLocaleString('default', { month: 'long' });                    
                            let parentEventTime = parentEvent.dayOfWeek+', '+parentEvtMonthName+' '+parentEvtDate.getDate()+', '+parentEvtDate.getFullYear();
                            parentEvent.eventTime = parentEventTime;
                        }
                    }
                    component.set("v.parentEventInfo",parentEvent);
                    component.set("v.showParentInfo",showParent);
                    helper.openInfoWindow(event, component);
                }else if(data.eventType == 'InstructorPDO' || data.eventType == 'StudentPDO'){
                    component.find("plannedModal").open();
                    component.set('v.selectedRecord',data);
                }
            },
            viewRender: function(view, element) {
                var year1 = view.start._d.getFullYear();
                var year2 = view.end._d.getFullYear();
                
                component.set("v.year1",year1);
                component.set("v.year2",year2);
                
                if(view.type != component.get("v.currentView")){
                    component.set("v.currentView",view.type);
                    helper.titleFormation(component,helper);
                }
                
                if(year1 != year2) {
                    component.set("v.initialLoad", false);
                    helper.getEventRecords(component, event, helper);
                }
            },
            eventDrop: function(event, delta, revertFunc) {

                if(component.get("v.communityName") == 'student') {
                    $("#infoWindow").hide();
                    
                    if (!event.showRescheduleBtn || (moment().add(1, 'days').isAfter(moment(new Date(event.start)), 'second'))) {
                        if(event.showRescheduleBtn){
                            var msg = "The event you are attempting to reschedule is currently scheduled to begin less than 24 hours in the future, and cannot be rescheduled through DLS Online.  Please contact your Language Training Supervisor for this class ";
                    		msg += event.LTSName ? "("+ event.LTSName +") for assistance." :  "for assistance.";
                            component.set("v.successErrorMsg",msg);
                            component.set("v.successErrorTitle",'Error');                            
                            component.find("successErrorModel").open();
                        }
                        revertFunc();
                    } else {
                                            
                        if(event.start) {
                            event.draggedStartTime = moment(event.start.format()).format("hh:mm A");
                        }
                        
                        if(event.end) {
                            event.draggedEndTime = moment(event.end.format()).format("hh:mm A");
                        }
                        event.draggedDate = event.start.format('YYYY-MM-DD');
                        event.isDragAndDrop = true;
                                                
                        component.set('v.selectedRecord', event);
                        component.set('v.showRescheduleModel', true);
                    }
                }
                
            },
            eventResize: function(event, delta, revertFunc) {
                revertFunc();
            }
        });
       // this.changeButtonStyle(component);
        // objeName[keyName] = value;
        var colourDiv = component.find('Colours');
        $A.util.removeClass(colourDiv, 'slds-hidden');
        $A.util.addClass(colourDiv, 'slds-visible');
        
    },
    openInfoWindow : function(jsEvent, component) {
        component.set("v.showInfoWindow", true);
        var device = $A.get("$Browser.formFactor");
        var communityName = component.get("v.communityName");
        console.log('popUpHeight:',$('#infoWindow').height());
        console.log('popupWidth',$('#infoWindow').width());
        console.log('windowInnerHeight:',window.innerHeight);
        console.log('windowInnerWidth',window.innerWidth);
        console.log('scrollY',window.scrollY);
        console.log('pageY',jsEvent.pageY);
        console.log('pagex',jsEvent.pageX);
        
        if(device != 'PHONE') {
            let popUpHeight = $('#infoWindow').height();
            let popupWidth = $('#infoWindow').width();
            let windowInnerHeight = window.innerHeight;
            let windowInnerWidth = window.innerWidth;
            let pageY = jsEvent.pageY;
            let pageX = jsEvent.pageX;
            let scrollY = window.scrollY;
            let left = pageX;
            let top = pageY;

            let topSpace = pageY - scrollY;
            let bottomSpace = windowInnerHeight - topSpace;
            let rightSpace = windowInnerWidth - pageX;
            
            console.log('topSpace',topSpace);
            console.log('bottomSpace',bottomSpace);
            console.log('rightSpace',rightSpace);

            if(rightSpace < popupWidth) {
                left = pageX - popupWidth;
            }

            if(bottomSpace > popUpHeight) {
                console.log(1);
                top = jsEvent.pageY;    
            } else if(topSpace > popUpHeight) {
                console.log(2);
                top = pageY - popUpHeight;
            } else {
                console.log(3);
                let scrollNum = scrollY + (popUpHeight - bottomSpace);
                window.scrollTo(0, scrollNum);
            }
            if(communityName == 'Internal'){
                left = ((windowInnerWidth /2) - 100);
                top = (windowInnerHeight /2);
            }
            console.log({ left: left+'px', top: top+'px'});      
            $('#infoWindow').css({ left: left+'px', top: top+'px'}).show();
        } else {
            console.log(4);
            component.set("v.showBackDrop", true);
            $('#infoWindow').css({ top: '50%', left: '50%',transform: 'translate(-50%, -50%)',position: 'fixed', zIndex: '9999' }).show();
        }
        
        
    },

    getItemsByStatus : function(component, event, helper, filter){
        var items = component.get("v.dummyScheduleList");
        var itemList = [];
        items.forEach(function(item){
            if(item.status == filter){
                itemList.push(item);
            }                                   
        });
                
        component.set("v.scheduleList",itemList);
    },
    titleFormation : function(cmp,helper){
        
        var viewType = cmp.get("v.currentView");
        
        var filteredEvents = cmp.get("v.filteredEvents");
        for(var i = 0;i < filteredEvents.length;i++){
            if(filteredEvents[i].eventType != 'Holiday' && filteredEvents[i].eventType != 'StudentPDO' && filteredEvents[i].eventType != 'InstructorPDO'){
                
                if(viewType == 'agendaDay'){
                    filteredEvents[i].title = filteredEvents[i].startTime+'-'+filteredEvents[i].endTime+' / '+filteredEvents[i].project+' / Room: '+(filteredEvents[i].room ? filteredEvents[i].room : '');
                }else if(viewType == 'agendaWeek'){
                    filteredEvents[i].title = filteredEvents[i].startTime+'-'+filteredEvents[i].endTime+' / '+filteredEvents[i].project+' / Room: '+(filteredEvents[i].room ? filteredEvents[i].room : '');
                }else if(viewType == 'month'){
                    filteredEvents[i].title = filteredEvents[i].startTime+'-'+filteredEvents[i].endTime+' / '+filteredEvents[i].project;
                }else if(viewType == 'listWeek'){
                    if(cmp.get("v.communityName") == 'student') {
                        filteredEvents[i].title = filteredEvents[i].eventName+' / '+filteredEvents[i].dateStr+' / '+filteredEvents[i].status+' / ';
                        filteredEvents[i].title += (filteredEvents[i].room ? filteredEvents[i].room : '')+' / '+filteredEvents[i].instructor+' / '+filteredEvents[i].startTime+' / '+filteredEvents[i].endTime+' / '+filteredEvents[i].timezone;
                    }else {
                        filteredEvents[i].title = filteredEvents[i].eventName+' / '+filteredEvents[i].dateStr+' / '+filteredEvents[i].status+' / ';
                        filteredEvents[i].title += (filteredEvents[i].room ? filteredEvents[i].room : '')+' / '+filteredEvents[i].studentNames+' / '+filteredEvents[i].startTime+' / '+filteredEvents[i].endTime+' / '+filteredEvents[i].timezone;
                    }
                }
            }
        }
        cmp.set("v.filteredEvents",filteredEvents);
        $('#calendar').fullCalendar('removeEventSources');
        $('#calendar').fullCalendar('addEventSource', filteredEvents);
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
    getPendingApprovalRecords : function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);
		var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getEventsForApproval');
        server.callServer(
            action,
            {'contactId' : cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {
                
                cmp.set("v.showSpinner", false);
                if(cmp.get('v.showApprovalModel') && response.length == 0) {  
                    cmp.set("v.initialLoad", false);                 
                    cmp.set("v.showApprovalModel", false);
                    helper.getEventRecords(cmp, event, helper);
                    helper.showToast(cmp,event,'Events updated successfully.','success','Success')
                } else {
                    var pendingApprovalEvent,
                        eventIdFromUrl,
                        urlString = window.location.href.split("="); 
                               
                    if(urlString.length > 1){
                        eventIdFromUrl = urlString[1];
                    }
                    
                    for(var i=0; i<response.length; i++) {
                        response[i].selectedEvent.eventTime = helper.formatEventTime(response[i].selectedEvent)
                        if(response[i].parentEvent){
                            response[i].parentEvent.eventTime = helper.formatEventTime(response[i].parentEvent)        
                        }
                        if(eventIdFromUrl && response[i].selectedEvent.eventId == eventIdFromUrl){
                            pendingApprovalEvent = response[i];
                        }
                    }
                    
                    if(cmp.get('v.showApprovalModel')) {    
                        helper.showToast(cmp,event,'Events updated sucessfully.','success','Success');
                        if(!cmp.get("v.showPendingEventList")){
                            cmp.set("v.initialLoad", false);
                            cmp.set('v.showApprovalModel', false);
                            helper.getEventRecords(cmp, event, helper);
                        }                        
                    }
                    if(cmp.get("v.initialLoad") && pendingApprovalEvent){
                        cmp.set("v.showApprovalModel", true);
                        cmp.set("v.pendingApprovalEvent", pendingApprovalEvent);
                    }
                    cmp.set("v.pendingApprovalEvents", response);
                    //cmp.set("v.showApprovalModel", true);
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
    
    formatEventTime : function(data) {
        var date = moment(data.eventDate);
		var dt = date._d;
        let monthName = dt.toLocaleString('default', { month: 'long' });                    
        let eventTime = data.dayOfWeek+', '+monthName+' '+dt.getDate()+', '+dt.getFullYear();
        return eventTime;
    },
    closePendingEvents: function(cmp, event, helper){
        if(cmp.get('v.showInfoWindow')) {
            cmp.set('v.showInfoWindow', false);
            $('#infoWindow').hide();
            cmp.set("v.initialLoad", false);
            helper.getEventRecords(cmp, event, helper);
        }

        if(cmp.get('v.showApprovalModel')) {            
            helper.getPendingApprovalRecords(cmp, event, helper);
        }
    },
    getRequestEventDetails : function(cmp, event) {
        cmp.set("v.showSpinner", true);
		var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getDetailsForRequestEvent');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('newReq::>'+response)
                cmp.set("v.showSpinner", false);
                cmp.set('v.projectRefWithNewReqEvent', response);                
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    }
})