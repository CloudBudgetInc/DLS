({
    init : function(component, event, helper) {
        console.log('Initialized called');
        var urlString = window.location.href;
        console.log('urlString', urlString.split("=")[1]);
        var action = component.get("c.getCARecord");
        action.setParams({'projectId': component.get('v.projectId')});
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state:::',state);
            if(state == "SUCCESS") {
                let res = JSON.parse(response.getReturnValue());
                console.log('res:::', res);
                let recordType = [];
                console.log('res.CATabList.length', res.CATabList.length);
                res.CATabList.forEach(function(element) {
                    let obj = {};
                    if(element == 'Student'){
                        obj.recordTypeName = element;
                        obj.recordTypeValue = 'Student';
                    } 
                    if(element == 'Instructor' || element == 'Direct Labor' ) {
                        obj.recordTypeName = element;
                        obj.recordTypeValue = 'Instructor';
                    }
                    if(element == 'Staff' || element == 'Supervisor/LTS') {
                        obj.recordTypeName = element;
                        obj.recordTypeValue = 'Staff';
                    }
                    console.log(element, obj);
                    recordType.push(obj);
                });
                console.log('recordTyperecordTyperecordType',recordType);
                if(recordType.length > 0) {
                    component.set("v.cATabName",recordType[0].recordTypeValue);
                }
                component.set('v.CAListItems', res.CAListWrapper);
                helper.cATabRecords(component);
                component.set('v.tabNames', recordType);
                component.set('v.statusList', res.statusList);
                if(res.statusList.length > 0) {
                    component.set('v.selectedStatus', res.statusList[0]);
                }                
            }
        });
        $A.enqueueAction(action);
    },
    
    handleStatusChange : function(component, event, helper) {
        component.set("v.showSpinner",true);
        console.log('handle status change called', component.get('v.selectedStatus'));
        var urlString = window.location.href;
        console.log('urlString', urlString);
        let status = component.get('v.selectedStatus');
        if(status == 'All') {
            status = null;
        }
        console.log('status', status);
        var action = component.get("c.getCARecordByStatus");
        action.setParams({
            'projectId': component.get('v.projectId'),
            'status':status 
        });
        action.setCallback(this, function(response){
        	var state = response.getState();
            if(state == 'SUCCESS') {
                console.log('status response', response.getReturnValue());
                component.set('v.CAListItems', JSON.parse(response.getReturnValue()));
                helper.cATabRecords(component);
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    cATabClick: function(component, event, helper) {
        var tabName = event.currentTarget.name;
        component.set("v.cATabName",tabName);
        helper.cATabRecords(component);
        
    }
    
})