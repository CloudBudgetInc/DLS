({
    updateCA : function(component, event, helper) {
        var selectedRows = component.find('CAUtilTable').getSelectedCA(),
            caToUpdate = [],
            conAssignIdWithCongaUrlMap = component.get('v.conAssignIdWithCongaUrlMap');

        if(selectedRows.length > 0){
            var d = new Date(),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();
                
            if (month.length < 2) 
                month = '0' + month;
            if (day.length < 2) 
                day = '0' + day; 

            for(var row of selectedRows){
                var ca = {};
                ca.Id = row.Id;
                ca.DLS_P_and_P_Conga_URL__c = conAssignIdWithCongaUrlMap[row.Id];
                ca.DLS_P_and_P_Generated_Date__c = [year, month, day].join('-'); 
                caToUpdate.push(ca);
            }
            if(caToUpdate.length > 0){                
                helper.updateCA(component, event, helper, caToUpdate);               
            }
        }else{
            helper.showToast(component, event,'Please select atleast one student to send DLS Policy and Procedures for signature.', "error", "Error");
        }
    }
})