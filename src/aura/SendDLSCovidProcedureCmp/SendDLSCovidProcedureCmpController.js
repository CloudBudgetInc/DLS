({
    doInit: function (component, event, helper) {
        
        helper.getCAs(component, event, helper);         
    },    
    sendMail: function(component, event, helper){
        let allRows= component.get("v.contactAssignments"),
            emailParams = component.get("v.emailParams"),
        	congaBaseUrlStr = component.get('v.congaBaseUrl').split('&id='),
            selectedRows = component.find('CAUtilTable').getSelectedCA(),
            caToUpdate = []
        
        if(allRows.length > 0){
            let i = 0;
            for(const row of selectedRows){
                var url = '&id='+row.Id+congaBaseUrlStr[1]+ row.Candidate_Name__c;
                url += '&OFN=Acknowledgment of DLS Office Procedures - '+row.Candidate_Name__r.Name+' - ';
                
                var d = new Date(),
                    month = '' + (d.getMonth() + 1),
                    day = '' + d.getDate(),
                    year = d.getFullYear();
            
                if (month.length < 2) 
                    month = '0' + month;
                if (day.length < 2) 
                    day = '0' + day;    			
                
                url += [month, day, year].join('-');
                url += ' -- '+row.Name;
                url += emailParams+row.Candidate_Name__c;
                
                var ca = {};
                ca.Id = row.Id;
                ca.DLS_Covid_Form_Conga_URL__c = url;
                ca.DLS_Covid_Form_Generated_Date__c = [year, month, day].join('-'); 
                caToUpdate.push(ca);
                
                i += 1;
            }
			
            if(caToUpdate.length > 0){                
                helper.updateCA(component, event, helper, caToUpdate);               
            }else{
                helper.showToast(component, event,'Please select atleast one student/Instructor to send DLS Office Procedures.', "error", "Error");
            }
        }else{
            helper.showToast(component, event,'Contact Assignment not available to send DLS Office Procedures.', "error", "Error");
        }
    },
    closeModal: function(component, event, helper){         
        $A.get("e.force:closeQuickAction").fire();                
    }
})