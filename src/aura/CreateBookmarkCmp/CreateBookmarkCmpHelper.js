({
	getBookMark : function(cmp,event,helper) {
		
        var action = cmp.get('c.getBookMark');
        action.setParams({
            'ContactId' : cmp.get('v.recordId'),
            'userId' : cmp.get('v.seletcedUser').length > 0 ? cmp.get('v.seletcedUser')[0].Id : null
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log(response.getReturnValue())
                var result = response.getReturnValue();
                cmp.set('v.bookMark',result);
                if(result.Id != null){
                    cmp.set("v.isUpdate",true);
                    
                    var selectedSkill = [];
                    if(result.Skill__c){
                        if(result.Skill__c.indexOf(';') != -1){
                            selectedSkill = result.Skill__c.split(';');  
                        }else {
                            selectedSkill.push(result.Skill__c);
                        }  
                    }
                    cmp.set('v.selectedSkills', selectedSkill);
                }
            } else if(state == 'ERROR'){
                console.log('error:::',response.getError()[0].message);
            }
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, helper,type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    toggleSpinner : function(cmp){
        
        if($A.util.hasClass(cmp.find('spinner'),'slds-hide')){
            $A.util.removeClass(cmp.find('spinner'),'slds-hide');
        } else{ 
            $A.util.addClass(cmp.find('spinner'),'slds-hide');
        }
    },
    getSkillPicklist : function(cmp,event){
        var action = cmp.get('c.getPicklistValues');
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                cmp.set('v.skillValues',result);
                
            } else if(state == 'ERROR'){
                console.log('error:::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }
})