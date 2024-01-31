({
    doInit: function (component, event, helper) {
        
        helper.getStudents(component, event, helper);    
    },
    actionHandler: function(component, event, helper){
        let allRows= component.get("v.students");
        for(const row of allRows){
            
            if(event.currentTarget.name == row.Id){
                let baseUrl = helper.getBaseUrl(component,row, true);
                var url = baseUrl+'&DS7Preview=1&DS7=3'; 
                url += '&OFN='+row.Candidate_Name__r.Name;
                if(row.Project__r.Language__r) url += ' - '+row.Project__r.Language__r.Name;
                url += ' - Certificate of Completion -- '+row.Name;
                console.log(url);
                window.open(url, '_blank');
            }
        }
    },
    toggleSelectAllRows: function(component, event, helper){        
        let checkBoxInputs = component.find('selectRow');
        if(!Array.isArray(checkBoxInputs)) checkBoxInputs = [checkBoxInputs];
        for(let i = 0; i < checkBoxInputs.length; i++){
            checkBoxInputs[i].set('v.checked', event.getSource().get('v.checked'));
        }
    },
    generateCertificate: function(component, event, helper){
        let allRows= component.get("v.students"),
        	rows = [];
        
        let checkBoxInputs = component.find('selectRow');
        if(!Array.isArray(checkBoxInputs)) checkBoxInputs = [checkBoxInputs];
        
        if(allRows.length > 0){
            let i = 0;
            
            for(const row of allRows){
                if(checkBoxInputs[i].get('v.checked')){
                    var url = helper.getBaseUrl(component,row, false) + helper.getEmailToId(component, row);//'&EmailToId='+row.Candidate_Name__c;
                    url += '&EmailRelatedToId='+row.Id;
                    url += '&OFN='+row.Candidate_Name__r.Name;
                    if(row.Project__r.Language__r) url += ' - '+row.Project__r.Language__r.Name;
                    url += ' - Certificate of Completion -- '+row.Name;
                    url += component.get('v.emailParams');
                    
                    var d = new Date(),
                        month = '' + (d.getMonth() + 1),
                        day = '' + d.getDate(),
                        year = d.getFullYear();
                
                    if (month.length < 2) 
                        month = '0' + month;
                    if (day.length < 2) 
                        day = '0' + day;    			
                    
                    row.Certificate_Generation_URL__c = url;
                    row.Certificate_Generated_Date__c = [year, month, day].join('-');
                    rows.push(row);
                }
                i += 1;
            }
            
            if(rows.length > 0){                
                if(component.get('v.isFromVFPage')){
                    var closeModal = $A.get("e.c:closeGenerateCertificateModal");
                    closeModal.setParams({
                        caList : rows
                    });
                    closeModal.fire(); 
                    component.destroy();
                }else{
            		helper.updateCA(component, event, helper, rows);
                }
            }else{
                helper.showToast(component, event,'Please select atleast one student to Generate Certificate.', "error", "Error");
            }
        }else{
            helper.showToast(component, event,'Student not available to Generate Certificate.', "error", "Error");
        }
    },
    closeModal: function(component, event, helper){         
        if(!component.get('v.isFromVFPage')){            
        	$A.get("e.force:closeQuickAction").fire();
        }
        var closeModal = $A.get("e.c:closeGenerateCertificateModal");
        closeModal.fire(); 
        component.destroy();
    }
})