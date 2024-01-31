({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set("v.parentType",cmp.get("v.sObjectName"));
        helper.getParentInfo(cmp, event, helper);
    },
    openRecord : function(cmp, event, helper) {
        
        cmp.set("v.showSpinner",true);
        var recId = event.currentTarget.dataset.value;
        //console.log(':::',recId);
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": recId,
            "slideDevName": 'related'
        })
        sObjectEvent.fire();
        cmp.set("v.showSpinner",false);
        
    },
    statusChanged : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        helper.getScheduleInformation(cmp);
    },
    
    handleTableActions : function(component, event, helper){
    	component.set("v.showSpinner",true);
    	var type = event.getParam("canceltype");

        if(type == 'cancel' || type == 'delete' || type == 'complete'){
    		helper.deleteRecord(component, event, helper,event.getParam("deleteIndex"),event.getParam("canceltype"));
        }else if(type == 'Notify FEO'){
            helper.sendEmailtoNotifyFEOTeam(component,event,helper);
        }else if(type != 'Reload' && type != 'complete'){
			helper.editOrPlusIconclick(component,event.getParam("deleteIndex"),type);
        }else if(type == 'Reload'){
            helper.getScheduleInformation(component);
        }
    },
    
    lookupSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.getLookupRecords');
        component.find('lookup').search(serverSearchAction);
    },
    
    openDeleteModal : function(component, event, helper){
        component.set("v.deleteIndex",event.getSource().get("v.name"));
    	component.find("deleteModal").open();    
    },
    
    closedeleteModal : function(component, event, helper){
        component.find("deleteModal").close();
    },
    addScheduleBtnClick : function(component, event, helper){
    	component.set("v.showSpinner",true);
        var action = component.get("c.checkProductOrPTExist");
        action.setParams({
            "parentId" : component.get("v.recordId"),
            "parentType" : component.get("v.sObjectName")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var productOrPTExist = response.getReturnValue();
                //console.log("::::::hrs:day::product:pt:::exist::",productOrPTExist);
                if(!productOrPTExist){
                    component.set("v.productOrPTExist",productOrPTExist);
                    helper.addScheduleRelatedValdiation(component,'Product Msg');
                }else if(!component.get("v.haveDLSClassNo")){
                	// check wheather Opp / Project have dls class number value or not
            		// If not through validation
                	helper.addScheduleRelatedValdiation(component,'DLS Class Msg');
                }else {
                	//console.log(':::::::::sobjectName:::::',component.get("v.sObjectName"));
                	//console.log(':::::::::recordId:::::',component.get("v.recordId"));
                	//component.set("v.showAddModel",false);
                	component.set("v.scheduleType",'Regular');
                    component.set("v.showAddModel",true);
                    component.set("v.showSpinner",false);
                }
            }else {
                console.log(":::::error::::::",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    closeValidationModal : function(component, event, helper){
    	component.find("validationModal").close();
    },
    navigateToProject : function (component, event, helper) {
       var navEvt = $A.get("e.force:navigateToSObject");
       navEvt.setParams({
            "recordId": component.get("v.projectId"),
            "slideDevName": "detail"
       });
       navEvt.fire();
    },
    refreshTable : function(component, event, helper){
    	//console.log(':::::::::enter:::refresh table::');
    	component.set("v.showAddModel",false);
    	helper.getScheduleInformation(component);
    	event.stopPropagation();
    },
    activeTaChange:  function(cmp, event, helper){
    	
        if(cmp.get("v.activeTab") == 'EventsTab'){
        	var proIds = [];
	        proIds.push(cmp.get("v.recordId"));
	        cmp.set("v.proRecordIds",proIds);
        	cmp.set("v.dipslayEventTab",true);
        	cmp.set("v.displayPDOTab",false);
        }else if(cmp.get("v.activeTab") == 'pdoTab'){
        	cmp.set("v.dipslayEventTab",false);
        	if(cmp.get("v.parentType") == 'Opportunity'){
        		cmp.set("v.parentTypeForPDO",'OPPORTUNITY');
        	}else {
        		cmp.set("v.parentTypeForPDO",'PROJECT');
        	}
        	//console.log('::::v.parentTypeForPDO:::',cmp.get("v.parentTypeForPDO"));
        	cmp.set("v.displayPDOTab",true);
        }else {
        	cmp.set("v.dipslayEventTab",false);
        	cmp.set("v.displayPDOTab",false);
        }
    }
       
})