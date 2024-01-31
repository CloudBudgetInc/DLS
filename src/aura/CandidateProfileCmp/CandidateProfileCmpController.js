({
    
    doInit:function(component,event,helper){
        
        console.log(':::***::header:',component.get("v.candidateHeader"))
        var action=component.get("c.getTabsetRecords");
        action.setParams({'recordId':component.get("v.recordId")});
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                var result = data.getReturnValue();
                //Form the skill Language column data
                var skills = result.lstSkills;
                for(var i = 0;i < skills.length;i++){
                    if(skills[i].From_Language_LU__c && skills[i].To_Language_LU__c){
                        skills[i].language = 'From: '+skills[i].From_Language_LU__r.Name;
                        skills[i].language += '<br/>To: '+skills[i].To_Language_LU__r.Name;
                        
                    }else if(skills[i].From_Language_LU__c){
                        skills[i].language = skills[i].From_Language_LU__r.Name;
                    }else if(skills[i].To_Language_LU__c){
                        skills[i].language = skills[i].To_Language_LU__r.Name;
                    }
                }
                
                //Need to populate Present string in end date for experience if that is blank
                var experience = result.lstWork;
                for(var i = 0;i < experience.length;i++){
                    if(experience[i].End_Date__c){
                        experience[i].End_Date__c = helper.dateFormatFunction(experience[i].End_Date__c);
                    }else {
                        experience[i].End_Date__c = 'Present';
                    }
                }
                
                component.set("v.allCandidateRows",result);
                helper.getLanguages(component, event, helper);
                component.set("v.showSpinner",false);
            }
            else if(state === "ERROR"){
              var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message : data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
    getCandidateRecord : function(component, event, helper) {
        
        var selectedTab=component.get("v.selTabName");        
        component.set("v.candidateRows", []);
        if(selectedTab === 'Known Language'){
            helper.getLanguages(component, event, helper);
            component.set("v.sObjectType",'Known_Language__c');
            
        }else if(selectedTab === 'Skill') {
            component.set("v.sObjectType",'Skill__c');
            helper.getSkills(component, event, helper);
            
        }else if(selectedTab === 'Experience') {
            component.set("v.sObjectType",'Experience__c');
            helper.getExperience(component, event, helper); 
            
        }else if(selectedTab === 'Education') {
            component.set("v.sObjectType",'Experience__c');
            helper.getEducation(component, event, helper);
        }else if(selectedTab === 'Professional Publication and Award') {
            component.set("v.sObjectType",'Professional_Publication_and_Award__c');
            helper.getProfPublicationAwardHelper(component, event, helper);
        }
    },
    addRecord:function(component,event,helper){
        
        var selectedTab=component.get("v.selTabName");
        var sObjectType=component.get("v.sObjectType");
        var recordTypeId = ''
        var candidateRows = component.get("v.allCandidateRows");
        
        var createRecordEvent = $A.get("e.force:createRecord");
        if(selectedTab == 'Experience' || selectedTab == 'Education'){
            
            if(selectedTab == 'Experience'){
                recordTypeId = candidateRows.expTabRecTypeId;
            }else if(selectedTab == 'Education'){
                recordTypeId = candidateRows.eduTabRecTypeId;
            }
            
            createRecordEvent.setParams({
                "entityApiName":sObjectType,
                'recordTypeId' : recordTypeId,
                "defaultFieldValues": {                    
                    'Contact__c' :component.get("v.recordId")
                }
            });
            createRecordEvent.fire();
        }else {
            createRecordEvent.setParams({
                "entityApiName":sObjectType,
                "defaultFieldValues": {
                    'Contact__c' :component.get("v.recordId")
                }
            });
            createRecordEvent.fire();
        }
    },
    
})