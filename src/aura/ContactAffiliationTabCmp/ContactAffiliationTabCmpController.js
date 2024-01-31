({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        helper.getInitialTabInformation(cmp);
    },
    tabChange : function(cmp, event, helper) {
        var recordtypeName = '';
        var selectedTab = cmp.get("v.activeTab");
        
        if(selectedTab == 'Student' ){
            recordtypeName = 'Student';
        }else if(selectedTab =='DLS Staff'){
            recordtypeName = 'Staff';
        }else if(selectedTab == 'Instructor'){
            recordtypeName = 'Instructor';
        }else if(selectedTab == 'Client/Partner'){
            recordtypeName = 'Client_Partner';
        }
        
        cmp.set("v.recordTypeName",recordtypeName);
        cmp.set("v.selectedStatus",'All');
        cmp.set("v.showSpinner",true);
        helper.getContactAffilationInfo(cmp);
    }
})