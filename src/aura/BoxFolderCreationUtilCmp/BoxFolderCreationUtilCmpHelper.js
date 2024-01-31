({
    subscribePlatformEvent : function(cmp, event, helper, recordId) {
        console.log('sub');
        // Get the empApi cmp
        const empApi = cmp.find('empApi');
        // Get the channel from the input box
        const channel = cmp.get('v.channel');
        
        // Replay option to get new events
        const replayId = -1;

        cmp.set("v.showSpinner",true);

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            var userId = $A.get("$SObjectType.CurrentUser.Id");            
            var receivedData = eventReceived.data.payload;
            
            if(receivedData.Record_Id__c == recordId &&  userId == receivedData.User_Id__c){
                cmp.set("v.showSpinner",false);                
                this.unSubscribePlatformEvent(cmp, event, helper);
                this.createBoxRecordHelper(cmp, event, helper, receivedData);
            }else{
              this.unSubscribePlatformEvent(cmp, event, helper);
              this.subscribePlatformEvent(cmp, event, helper);                                                
            }
                                                               
        }))
        .then(subscription => {
                // Confirm that we have subscribed to the event channel.
                // We haven't received an event yet.
                // Save subscription to unsubscribe later
                cmp.set('v.subscription', subscription);
                
                window.setTimeout($A.getCallback(function() {
                    cmp.set("v.showSpinner",false);
                    $A.get("e.force:closeQuickAction").fire();
            }), 100000);
            
        });
    },
    unSubscribePlatformEvent : function(cmp, event, helper) {
        
        // Get the empApi cmp
        const empApi = cmp.find('empApi');
        // Get the subscription that we saved when subscribing
        const subscription = cmp.get('v.subscription');
        
        // Unsubscribe from event
        empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
            // Confirm that we have unsubscribed from the event channel
            console.log('Unsubscribed from channel '+ unsubscribed.subscription);
            cmp.set('v.subscription', {});
        }));
    },
    createBoxRecordHelper : function(cmp, event, helper ,boxRecs){
           
        var frup = {};
        
        if(boxRecs.Folder_Id__c){
            frup.box__Folder_ID__c = boxRecs.Folder_Id__c; // newly created folder id
        }
        
        if(boxRecs.Object_Name__c){
            frup.box__Object_Name__c = boxRecs.Object_Name__c; // Api name of the Object
        }
        
        if(boxRecs.Record_Id__c){
            frup.box__Record_ID__c = boxRecs.Record_Id__c; // record id of the assessment report
        }
        
        frup.box__Permission__c = 'Read/Write';
        
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.createBoxFRUPRecs");
        server.callServer(
            action, {frupJSON : JSON.stringify(frup)},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                $A.get("e.c:boxFolderCreationEvt").fire();
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                helper.showToast(component, event,errors[0].message, "error", "Error");
            }),
            false,
            false,
            false
        );
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
    }
})