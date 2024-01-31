({
    getPDORecords : function(cmp,event) {
        cmp.set("v.showSpinner",true);
        console.log('get recs');
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getPlannedRecords');
        
        server.callServer(
            action,
            {strDate : null,endrDate : null,projectId : null, recordLimit : true},
            false,
            $A.getCallback(function(response) {
                //console.log('response: in upcomming::',response);
                var result = JSON.parse(response);
                if(result) {
                    //console.log('Planned days length',result.leaveInfoList.length)
                    cmp.set("v.plannedOffRows",result.leaveInfoList);
                    cmp.set("v.projectValues",result.projectValues);
                    cmp.set("v.contactRec",result.contactInfo);
                    cmp.set("v.plannedDaysMap",result.plannedDaysOffMap );
                    cmp.set("v.requestOffRT",result.requestOffRTId);
                }
                cmp.set("v.showSpinner",false);
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
    
    updateEditRecords : function(cmp,event) {
        var self = this;
        
        var plannedDaysCmp = cmp.find("plannedDaysEdit");
        //console.log('plannedDaysCmp:::', plannedDaysCmp);
        //console.log('is array function::',Array.isArray(plannedDaysCmp));
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
        
        const server = cmp.find('server');
        const action = cmp.get('c.createNewPlannedOffRecords');
        server.callServer(
            action,
            {newPlannedOffJson : JSON.stringify(cmp.get("v.plannedOffDays")), status : status,allowParentPlanToUpdate : cmp.get("v.allowParentPlanToUpdate"),parentPlannedDayId : cmp.get("v.currentPlannedDay")},
            false,
            $A.getCallback(function(response) {
                //console.log('response:::new::off::::created:',response);
                //console.log('status:::',status);
                
                cmp.set("v.successTitle",'The Planned Days have been successfully '+status);
                
                cmp.find("editOffModel").close();
                cmp.set("v.showAddEditModel",false);
                
                cmp.set("v.showSuccessModel",true);
                cmp.find("successModel").open();
                
                /*window.setTimeout(
                    $A.getCallback(function() {
                        self.getPDORecords(cmp, event);
                    }), 1000);*/
                
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
                cmp.set("v.showDeleteModel",false);  
                self.getPDORecords(cmp, event);
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