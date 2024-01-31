({
	init : function(cmp, event, helper) {
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getUserName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var currentUsr = JSON.parse(response.getReturnValue());
                console.log('::::::currentUsr:::::',currentUsr);
                cmp.set("v.userName", currentUsr[0].Name);
                cmp.set("v.userId", currentUsr[0].Id);
                if(cmp.get("v.seletcedUser").length == 0){
                    cmp.set("v.seletcedUser",currentUsr);
                }
                
                helper.getSkillPicklist(cmp,event);
                helper.getBookMark(cmp,event,helper);
                
            } else if(state == 'ERROR'){
                console.log('error:::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);	
    },
    closeBookMark : function(component, event, helper) { 
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    },
    saveBookMark : function(cmp,event,helper){
        helper.toggleSpinner(cmp);
    	console.log(cmp.get('v.bookMark'));
        var bookMarkObj = cmp.get('v.bookMark'),
            bookMarks = [],
            selectedUserIds = [],
            seletcedUsers = cmp.get("v.seletcedUser"),
            contactId = cmp.get('v.recordId'),
            userId = cmp.get('v.userId');
        
        bookMarkObj.Contact__c = contactId;
        bookMarkObj.User__c = userId;

        if(seletcedUsers.length > 0){
            for(var seletcedUser of seletcedUsers){
                var bookMark = Object.assign({},bookMarkObj); 
                if(seletcedUser.Id != userId){
                    delete bookMark.Id; 
                }                          
                bookMark.User__c = seletcedUser.Id;
                selectedUserIds.push(seletcedUser.Id);
                bookMarks.push(bookMark);
            }
        }else{
            bookMarks.push(bookMarkObj);
            selectedUserIds.push(userId);
        }
        console.log(bookMarks);
        var action = cmp.get('c.upsertBookMark');
        action.setParams({
            'bookMarks' : bookMarks,
            'contactId' : contactId,
            'chatterPostContent' : cmp.get('v.chatterPost'),
            'isNew' : cmp.get('v.headerContent') == 'Create Bookmark' ? true : false,
            'selectedUserIds': selectedUserIds
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log(response.getReturnValue());
                var reloadEvent = $A.get("e.c:reloadEvent");
                reloadEvent.fire();
                helper.toggleSpinner(cmp);
                if(cmp.get('v.closeQuickActionOnSave')){
                    $A.get("e.force:closeQuickAction").fire();                
                }
                //$A.get('e.force:refreshView').fire();
            } else if(state == 'ERROR'){
                 console.log('error:::',response.getError()[0].message);
                //helper.showToast(cmp,event,helper,'error',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    cancelBookMark: function(cmp, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    lookupSearch : function(cmp, event, helper){
        // Get the getLookupRecords server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('lookup').search(serverSearchAction);
    },
    populateSkillChange :  function(cmp, event, helper){
        var selectedSkill = cmp.get('v.selectedSkills'),
            bookMark = cmp.get('v.bookMark');
        
        bookMark.Skill__c = selectedSkill.join(";");
        cmp.set('v.bookMark', bookMark);
    }
    
})