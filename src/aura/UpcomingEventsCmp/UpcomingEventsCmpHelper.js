({
    getCommunityNames : function(cmp,event,helper){
        
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityName');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::',response);
                cmp.set("v.communityName",response);
                if(response == 'student'){
                    self.getRequestEventDetails(cmp, event);
                }
                self.getEventRecords(cmp,event)
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    getEventRecords : function(cmp,event){
        var eventList = [];
        var self = this;
        var communityName = cmp.get("v.communityName");
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityNameWithEventsInfo');
        server.callServer(
            action,
            {
                'communityName' : communityName,
                'newYorkDateNow' : self.getNewYorkDate(cmp)
            },
            false,
            $A.getCallback(function(response) {
                eventList = JSON.parse(response);
                
                var filteredEvents = [];
                var pendingApprovalEvtList = [];
                
                if(eventList.length > 0){
                    for(var i = 0;i < eventList.length;i++){
                                                
                        /*var startTime = self.get24HourFormat(eventList[i].startTime);                    
                        var eventDtTime = moment(self.dateFormatFunction(eventList[i].eventDate)+' '+startTime[0]+':'+startTime[1]).tz(eventList[i].timezone).format();
                        var currentDtTime = moment().add('days', 1).tz(eventList[i].timezone).format();
                       
                        if(communityName == 'student') {
                            if(!(eventDtTime >= currentDtTime) && eventList[i].showRescheduleBtn){
                                eventList[i].showRescheduleBtn = false;
                            }
                        } else {
                            eventList[i].showRescheduleBtn = false;
                        }
                        /*if((!(eventDtTime >= currentDtTime) &&  eventList[i].showRescheduleBtn) || eventList[i].status == 'Draft'){
                            eventList[i].showRescheduleBtn = false;
                        }*/
                        filteredEvents.push(eventList[i]);
                    }
                    //filteredEvents.sort((a, b) => (a['startDateTime'] > b['startDateTime']) ? 1 : -1);
                    // pendingApprovalEvtList.sort((a, b) => (a['eventDate'] > b['eventDate']) ? 1 : -1);
                }
                console.log('filteredEvents::>'+JSON.stringify(filteredEvents));
                cmp.set("v.evtList",filteredEvents);
                self.getPendingApprovalRecords(cmp, event);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },

    getPendingApprovalRecords : function(cmp, event) {
		var self = this;
        const server = cmp.find('server');
        cmp.set("v.showSpinner", true);
        
        const action = cmp.get('c.getEventsForApproval');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response::approval:',response);
                cmp.set("v.pendingApprovalEvtList", response);
                if(!response || response.length < 1){
                    cmp.set("v.showApprovalModel", false);
                }
                cmp.set("v.showSpinner", false);
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
               
                cmp.set("v.showSpinner", false);                
                cmp.set("v.showRequestEvent", Object.keys(response).length > 0);
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
                var eventList = cmp.get("v.evtList"); 
                var response = JSON.parse(responseStr);
                eventList[index] = response.event;
                cmp.set('v.evtList', eventList);
                if(response.message){
                    var modal = {header:'User Creation', message:response.message};
                    cmp.set('v.modal', modal);
                    cmp.find("msgModal").open();
                }
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                var modal = {header:'Error', message:errors[0].message};
                cmp.set('v.modal', modal);
                cmp.find("msgModal").open();
                //self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    getNewYorkDate: function(component){
                
    	return moment().tz("America/New_York").format('YYYY-MM-DD');   
    }
})