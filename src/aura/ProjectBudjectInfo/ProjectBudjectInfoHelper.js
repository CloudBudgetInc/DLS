({
	setColumnList : function(component, event, helper) {
		var columns = [
            {
                'label':'Product Name',
                'name':'productName',
                'type':'reference',
                'value':'Id',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank',
            },
            {
                'label':'Qty Planned',
                'name':'quantityPlanned',
                'type':'String',
                'sortable':false
            },
            {
                'label':'CLIN',
                'name':'clin',
                'type':'reference',
                'value':'clinId',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank',
            },
             {
                'label':'Price',
                'name':'productPrice',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Extended Price',
                'name':'extendedPrice',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Description',
                'name':'description',
                'type':'String',
                'sortable':false
            }
            
        ];
        var materialcolumns = [
            {
                'label':'Product Name',
                'name':'productName',
                'type':'String',
                'value':'Id',
                'type':'reference',
                'resizeable':true,
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Qty Planned',
                'name':'quantityPlanned',
                'type':'String',
                'sortable':false
            },
            {
                'label':'CLIN',
                'name':'clin',
                'type':'reference',
                'value':'clinId',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank',
            },
             {
                'label':'Price',
                'name':'productPrice',
                'type':'currency',
                 'sortable':false
            },
            {
                'label':'Extended Price',
                'name':'extendedPrice',
                'type':'currency',
                'sortable':false
            }];
        
        component.set("v.serviceColumns",columns);
        component.set("v.materialColumns",materialcolumns);
        
          var config = { 
            "massSelect":false,
            "searchBox":false,
            "searchByColumn":false,
            'paginate':false
          
        };
        
        if(component.get("v.sObjectName") === 'Opportunity' && component.get("v.projectList").length == 0){
            config.rowAction = [
                {
                    "type":"image",
                    "class":"imgAction1",
                    "id":"fund",
                    "src":"/resource/SLDS_2_1_3/assets/icons/action/update_60.png",
                      'visible':function(row){
                          return (row.Id ? true : false);
                      }
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"editicon",
                    "src":"/resource/1482987504000/Edit_Icon",
                      'visible':function(row){
                          return (row.Id ? true : false);
                      }
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"delete",
                    "src":"/resource/1482987503000/Delete_Icon",
                      'visible':function(row){
                          return (row.Id ? true : false);
                      }
                }
            ],
                config.rowActionPosition = 'right',
                config.rowActionWidth = 140;
            
        }
        component.set("v.serviceColumnConfig",config);
        if(component.get("v.sObjectName") == 'Opportunity' && component.get('v.serviceRecords').length > 0){ 
            component.find("ldtServiceTable").initialize({'order':[]});
        }
	},
    setServiceColumnList : function(component, event, helper ,isActivity) {
       
        if(isActivity){
            var columns = [
                {
                    'label':'Product Name',
                    'name':'productName',
                    'type':'String',
                    'value':'Id',
                    'type':'reference',
                    'resizeable':true,
                    'truncate' : {
                      "characterLength" : 10
                    },
                    'sortable':false,
                    'target':'_blank'
                },
                {
                    'label':'Qty Planned',
                    'name':'quantityPlanned',
                    'type':'String',
                    'sortable':false
                },
                {
                    'label':'Qty Paid    ',
                    'name':'quantityPaid',
                    'type':'String',
                    'sortable':false
                },
                {
                    'label':'Qty Scheduled',
                    'name':'quantityScheduled',
                    'type':'Currency',
                    'sortable':false
                },
                {
                    'label':'Qty Used   ',
                    'name':'quantityUsed',
                    'type':'Currency',
                    'sortable':false
                },
                {
                    'label':'Qty Planned Remaining',
                    'name':'quantityPlannedRemaining',
                    'type':'String',
                    'sortable':false
                },
                {
                    'label':'Qty Paid Remaining',
                    'name':'quantityPaidRemaining',
                    'type':'String',
                    'sortable':false
                },
                {
                    // 'label':'Scheduled Deficit',
                    'label':'Remaining Qty to Schedule',
                    'name':'quantityScheduledDeficit',
                    'class':'boldCls',
                    'type':'String',
                    'sortable':false
                }
                
            ];
        } else {
            var columns = [
                {
                    'label':'Product Name',
                    'name':'productName',
                    'type':'String',
                    'value':'Id',
                    'type':'reference',
                    'resizeable':true,
                    'truncate' : {
                      "characterLength" : 10
                    },
                    'sortable':false,
                    'target':'_blank'
                },
                {
                    'label':'Qty Planned',
                    'name':'quantityPlanned',
                    'type':'String',
                    'sortable':false
                },
                {
                    'label':'CLIN',
                    'name':'clin',
                    'type':'reference',
                    'value':'clinId',
                    'resizeable':true,
                    'truncate' : {
                      "characterLength" : 10
                    },
                    'sortable':false,
                    'target':'_blank',
                },
                {
                    'label':'Price',
                    'name':'productPrice',
                    'type':'currency',
                    'sortable':false
                },
                {
                    'label':'Extended Price',
                    'name':'extendedPrice',
                    'type':'currency',
                    'sortable':false
                },
                {
                    'label':'Description',
                    'name':'description',
                    'type':'String',
                    'sortable':false
                }
            ];
        }
        component.set("v.serviceColumns",columns);
        component.set("v.fringeColumns",columns);
        component.set("v.regularHoursColumns",columns);
        component.set("v.odcColumns",columns);
        
         var config = { 
            "massSelect":false,
            "searchBox":false,
            "searchByColumn":false,
            'paginate':false
          
        };
        
        if(component.get("v.sObjectName") != 'Opportunity') {
            if(component.get("v.tabName") === 'Travel ODC' && component.get("v.odcRecords").length > 0) {
                component.find("ldtOdcTable").initialize({'order':[]});
            } else if(component.get("v.tabName") === 'Regular Hours' && component.get("v.regularHoursRecords").length > 0) {
                component.find("ldtRegularHoursTable").initialize({'order':[]});
            }else if(component.get("v.tabName") === 'Fringe' && component.get("v.fringeRecords").length > 0) {
                component.find("ldtFringeTable").initialize({'order':[]});
            }
        }
        
        if(component.get("v.sObjectName") == 'Opportunity'){
            if(component.get("v.tabName") == 'Travel ODC' && component.get("v.odcRecords").length > 0){
                component.find("ldtOdcTable").initialize({'order':[]});
            }else if(component.get("v.tabName") != 'Travel ODC' && component.get("v.serviceRecords").length > 0) { 
                component.find("ldtServiceTable").initialize({'order':[]});
            }
        }
        
        if(!component.get("v.activityChecked") && component.get("v.tabName") == 'Materials' && component.get("v.materialRecords").length > 0) {
            component.find("ldtMaterialTable").initialize({'order':[]});
            component.set("v.tabName",'Materials');
        }  else if(component.get("v.tabName") == 'Materials' && component.get("v.requestRecords").length > 0){
            component.find("ldtRequestTable").initialize({'order':[]});
        }
    },
    launchOpportunityBudgetPage : function(component, event, helper) {
        
        let action = component.get("c.getWrapperOppBudgetInfo");
        
        action.setParams({'oppId':component.get("v.recordId") ,'objectName':component.get('v.sObjectName') });
        
        action.setCallback(this,(response) => {
            if(response.getState() === 'SUCCESS'){
                let opportunityWrapperContainer = response.getReturnValue();
                component.set("v.isRecordLoaded",true);
                component.set("v.parentRecordName",opportunityWrapperContainer.parentObjectName);
                component.set("v.projectList",opportunityWrapperContainer.projectlist);
                let showMatDelIcon = opportunityWrapperContainer.isShowMaterialDelIcon;
                component.set("v.showMatDeleteIcon",showMatDelIcon);
                //console.log(opportunityWrapperContainer);
            if(opportunityWrapperContainer.parentRecordTypeName === 'DLI_W_TO_Opportunities'){
            component.set("v.odcRecords",opportunityWrapperContainer.odcWrapperList);
            		component.set("v.showFourTabView",true);
                    component.set("v.tabName",'Services');  
                    component.set("v.serviceRecords",opportunityWrapperContainer.serviceWrapperList);
                    component.set("v.materialRecords",opportunityWrapperContainer.materialWrapperList);        
                    this.setColumnList(component, event, helper);
                    this.hideSpinner(component,event);     
                        
        		} else {
                	component.set("v.showFourTabView",false);   
                    component.set("v.tabName",'Services');         
                    component.set("v.serviceRecords",opportunityWrapperContainer.serviceWrapperList);
                    component.set("v.materialRecords",opportunityWrapperContainer.materialWrapperList);        
                    this.setColumnList(component, event, helper);
                    this.hideSpinner(component, event, helper);
                }
            	
        	}else {
        		console.log(':::::::::error:::::',response.getError()[0].message);
        		this.hideSpinner(component,event);
        	}
        });
        
        $A.enqueueAction(action);
    },
    launchProjectBudgetPage: function(component, event, helper) {
         let action = component.get("c.getWrapperProjectBudgetInfo");
        
        action.setParams({'objectName':component.get("v.sObjectName") ,'projectId':component.get('v.recordId') });
        
        action.setCallback(this,(response) => {
            //console.log('sdf',response.getState());
            if(response.getState() === 'SUCCESS'){
            	console.log('sdf',response.getReturnValue());
            	let opportunityWrapperContainer = response.getReturnValue();
            	let parentRecordTypeName  = opportunityWrapperContainer.parentRecordTypeName;
           		let showMatDelIcon = opportunityWrapperContainer.isShowMaterialDelIcon;
                component.set("v.showMatDeleteIcon",showMatDelIcon);
            	component.set("v.isRecordLoaded",true);
           		let projectTaskRecordTypes = opportunityWrapperContainer.projectTaskRecordTypes || [];
	            component.set("v.requestRecords",opportunityWrapperContainer.requestlist);
	            component.set("v.loanRecords",opportunityWrapperContainer.loanList);
	            component.set("v.parentRecordName",opportunityWrapperContainer.parentObjectName);
	            this.setRequestAndLoanColumns(component, event, helper);
	            let picklistValues = projectTaskRecordTypes.map((recType)=>{
	            	return {label:recType.Name,value:recType.Id}
	        	});
	        	component.set("v.pickListValues",picklistValues);
	            if( parentRecordTypeName === 'Project_RT' || parentRecordTypeName === 'Admin_Projects' ||
	        		parentRecordTypeName === 'MTT_Projects' || parentRecordTypeName === 'EFL_Projects'){
                    
	                component.set("v.odcRecords",opportunityWrapperContainer.odcWrapperList);
	                component.set("v.fringeRecords",opportunityWrapperContainer.fringeWrapperList);
	                component.set("v.regularHoursRecords",opportunityWrapperContainer.regularHoursWrapperList);
                    //console.log('regularHoursWrapperList:::',JSON.stringify(component.get("v.regularHoursRecords")));
	                component.set("v.materialRecords",opportunityWrapperContainer.materialWrapperList);
	                component.set("v.showFourTabView",true);
	                component.set("v.parentRecordTypeName",parentRecordTypeName);
	                this.setProjectFourTabViewColumnList(component, event, helper);
	                
	                
                    if(parentRecordTypeName === 'Admin_Projects'){
                        component.set("v.tabName",'Regular Hours'); 
                        if(component.get('v.regularHoursRecords').length > 0){
                            component.set("v.activityChecked",false);
                            component.find("ldtRegularHoursTable").initialize({'order':[]});
                        }
                    } else {
	                    component.set("v.tabName",'Services'); 
	                    component.set("v.serviceRecords",opportunityWrapperContainer.serviceWrapperList);
                        component.set("v.materialRecords",opportunityWrapperContainer.materialWrapperList);
                        
                        if(component.get("v.activityChecked")){
                            this.setServiceColumnList(component, event, helper,component.get("v.activityChecked")); 
                        }else{
                            this.setProjectColumnList(component, event, helper);
                        }
                        //component.find("ldtServiceTable").initialize({'order':[]});
	                }
	                
	            } else {
	                component.set("v.showFourTabView",false);   
	                component.set("v.tabName",'Services');         
	                component.set("v.serviceRecords",opportunityWrapperContainer.serviceWrapperList);
	                component.set("v.materialRecords",opportunityWrapperContainer.materialWrapperList);
                    
                    if(component.get("v.activityChecked")){
                        this.setServiceColumnList(component, event, helper,component.get("v.activityChecked")); 
                    }else{
                        this.setProjectColumnList(component, event, helper);
                    }
                }
                //console.log('Service records:::::',component.get('v.serviceRecords'));
	            this.hideSpinner(component, event, helper);	
        	}else {
        		console.log(':::::::::error:::::',response.getError()[0].message);
        		this.hideSpinner(component,event);
        	}
        });
        
        $A.enqueueAction(action);
    
    },
    setProjectColumnList: function(component, event, helper) {
		var columns = [
            {
                'label':'Product Name',
                'name':'productName',
                'type':'reference',
                'value':'Id',
                'resizeable':true,
                 'class':'boldCls',
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Qty Planned',
                'name':'quantityPlanned',
                'type':'String',
                'sortable':false
            },
            {
                'label':'CLIN',
                'name':'clin',
                'type':'reference',
                'value':'clinId',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank',
            },
             {
                'label':'Price',
                'name':'productPrice',
                'type':'currency',
                 'sortable':false
            },
            {
                'label':'Extended Price',
                'name':'extendedPrice',
                'type':'currency',
                'sortable':false
            },
            
           
            {
                'label':'Description',
                'name':'description',
                'type':'String',
                'sortable':false
            }
            
        ];
        
        var materialcolumns = [
            {
                'label':'Product Name',
                'name':'productName',
                'type':'String',
                'value':'Id',
                'class':'boldCls',
                'type':'reference',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Qty Planned',
                'name':'quantityPlanned',
                'type':'String',
                'sortable':false
            },
            {
                'label':'CLIN',
                'name':'clin',
                'type':'reference',
                'value':'clinId',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank',
            },
             {
                'label':'Price',
                'name':'productPrice',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Extended Price',
                'name':'extendedPrice',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Budget Requested',
                'name':'totalBudjeted',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Budget Paid',
                'name':'totalAmountPaid',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Budget Used',
                'name':'totalSpent',
               'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Paid Remaining',
                'name':'totalPaidRemaining',
                'type':'currency',
                'sortable':false
            }];
        component.set("v.serviceColumns",columns);
        component.set("v.materialColumns",materialcolumns);
          var config = { 
            "massSelect":false,
            "searchBox":false,
            "searchByColumn":false,
            'paginate':false,
              
              'rowClass':function(row){
                        if(row.quantityScheduledDeficit < 0){
                            return 'addRedColor';
                        } else if(row.quantityScheduledDeficit == 0){
                            return 'addgreenColor';
                        } else {
                            return 'addyellowColor';
                        }
						return 'addyellowColor';
                    },
              "rowAction":[
                {
                    "type":"image",
                    "class":"imgAction1",
                    "id":"fund",
                    "src":"/resource/SLDS_2_1_3/assets/icons/action/update_60.png",
                      'visible':function(row){
                  
                  return (row.Id ? true : false);
              }
                    
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"editicon",
                    "src":"/resource/1482987504000/Edit_Icon",
                      'visible':function(row){
                  return (row.Id ? true : false);
              }
                    
                   
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"delete",
                    "src":"/resource/1482987503000/Delete_Icon",
                      'visible':function(row){
                  
                  return (row.Id ? true : false);
              }
                    
                }
                  ],
              'rowActionPosition':'right',
              'rowActionWidth' : 140
        };
         component.set("v.serviceColumnConfig",config);
        
	},
    setProjectFourTabViewColumnList: function(component, event, helper) {
        var columns = [
            {
                'label':'Product Name',
                'name':'productName',
                'type':'reference',
                'value':'Id',
                'resizeable':true,
                 'class':'boldCls',
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Qty Planned',
                'name':'quantityPlanned',
                'type':'String',
                'sortable':false
            },
            {
                'label':'CLIN',
                'name':'clin',
                'type':'reference',
                'value':'clinId',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank',
            },
             {
                'label':'Price',
                'name':'productPrice',
                'type':'currency',
                 'sortable':false
            },
            {
                'label':'Extended Price',
                'name':'extendedPrice',
                'type':'currency',
                'sortable':false
            },
            
           
            {
                'label':'Description',
                'name':'description',
                'type':'String',
                'sortable':false
            }
            
        ];

        var materialcolumns = [
            {
                'label':'Product Name',
                'name':'productName',
                'type':'String',
                'value':'Id',
                'type':'reference',
                 'class':'boldCls',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Qty Planned',
                'name':'quantityPlanned',
                'type':'String',
                'sortable':false
            },
            {
                'label':'CLIN',
                'name':'clin',
                'type':'reference',
                'value':'clinId',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank',
            },
             {
                'label':'Price',
                'name':'productPrice',
                'type':'currency',
                 'sortable':false
            },
            {
                'label':'Extended Price',
                'name':'extendedPrice',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Budget Requested',
                'name':'totalBudjeted',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Budget Paid',
                'name':'totalAmountPaid',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Budget Used',
                'name':'totalSpent',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'Materials Paid Remaining',
                'name':'totalPaidRemaining',
                'type':'currency',
                'sortable':false
            }];
        component.set("v.materialColumns",materialcolumns);
        component.set("v.odcColumns",columns);
        component.set("v.regularHoursColumns",columns);
        component.set("v.fringeColumns",columns);
          var config = { 
            "massSelect":false,
            "searchBox":false,
            "searchByColumn":false,
            'paginate':false,
     
              'rowClass':function(row){
                        if(row.quantityScheduledDeficit < 0){
                            return 'addRedColor';
                        } else if(row.quantityScheduledDeficit == 0){
                            return 'addgreenColor';
                        } else {
                            return 'addyellowColor';
                        }
						return 'addyellowColor';
                    },
              "rowAction":[
                {
                    "type":"image",
                    "class":"imgAction1",
                    "id":"fund",
                    "src":"/resource/SLDS_2_1_3/assets/icons/action/update_60.png",
                     'visible':function(row){
                  
                  return (row.Id ? true : false);
              }
                     
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"editicon",
                    "src":"/resource/1482987504000/Edit_Icon",
                      'visible':function(row){
                  
                  return (row.Id ? true : false);
              }
                   
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"delete",
                    "src":"/resource/1482987503000/Delete_Icon",
                      'visible':function(row){
                  
                  return (row.Id ? true : false);
              }
                    
                }
                  ],
              'rowActionPosition':'right',
              'rowActionWidth':140
        };
         component.set("v.serviceColumnConfig",config);
        
	},
   createRecord: function(component, event, helper,apiName,recordTypeId){
       let createRecordEvent = $A.get("e.force:createRecord");
       createRecordEvent.setParams({
          "entityApiName": apiName,
          "recordTypeId":recordTypeId,
           "defaultFieldValues": {'AcctSeed__Project__c' : component.get("v.recordId")}
       });
       createRecordEvent.fire();
    },
    editRecord : function(component, event, helper,recordId) {
        let editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    },
    setRequestAndLoanColumns: function(component, event, helper){
             var columns = [
            {
                'label':'Request #',
                'name':'Name',
                'type':'reference',
                'value':'Id',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Request Status',
                'name':'requestStatus',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Date Delivered',
                'name':'dateDeliverd',
                'type':'date',
                'format':'MM/DD/YYYY',
                'sortable':false
            },
             {
                'label':'Vendor Name',
                'name':'vendorName',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Material Title',
                'name':'materialName',
                'type':'String',
                'sortable':false
            },
            
           
            {
                'label':'Sales Tax',
                'name':'salesTax',
                'type':'currency',
                'sortable':false
            },
            
            {
                'label':'Qty',
                'name':'qty',
                'type':'Currency',
                'sortable':false
            },
            
           
            {
                'label':'Vendor Total',
                'name':'vendorTotal',
                'type':'currency',
                'sortable':false
            },
            {
                'label':'DLS Total',
                'name':'dlsTotal',
                'type':'currency',
                'sortable':false
            }  
            
        ];

        var loancolumns = [
            {
                'label':'Request #',
                'name':'Name',
                'type':'String',
                'value':'Id',
                'type':'reference',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Material Title',
                'name':'Materials_Name__r.Name',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Contact',
                'name':'Contact__r.Name',
                'type':'String',
                'sortable':false
            },
             {
                'label':'Loan Status',
                'name':'Request_Status__c',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Date Loaned Out',
                'name':'Date_Loaned_Out__c',
                'type':'date',
                'format':'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Date Returned',
                'name':'Date_Returned__c',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Qty',
                'name':'Qty__c',
                'type':'String',
                'sortable':false
            }            
        ];
        component.set("v.requestColumns",columns);
        component.set("v.loanColumns",loancolumns);
        var showMatDeleteIcon = component.get("v.showMatDeleteIcon");
          var config = { 
            "massSelect":false,
            "searchBox":false,
            "searchByColumn":false,
            'paginate':false,
              
              "rowAction":[
   
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"editicon",
                    "src":"/resource/1482987504000/Edit_Icon",
                    'visible':function(row){
                        
                        return (row.Id ? true : false);
                    }
                    
                    
                   
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"delete",
                    "src":"/resource/1482987503000/Delete_Icon",
                    'visible':function(row){
                            return ((row.Id && showMatDeleteIcon == true) ? true : false);
                    }
                }
                  ],
              'rowActionPosition':'right',
              'rowActionWidth':140
        };
         component.set("v.requestColumnConfig",config);
    },
	isEmptyObject :function(obj){
        const isEmpty = (obj) => {
            if (obj === null ||
            obj === undefined ||
            Array.isArray(obj) ||
            typeof obj !== 'object'
            ) {
            return true;
        }
        return Object.getOwnPropertyNames(obj).length === 0;
    };
   },
   getFundingItemRecords : function(component,event,protaskId){
       this.showSpinner(component,event);
          let action ;
       if(component.get("v.sObjectName") !== 'Opportunity'){
			action = component.get("c.proTaskRelatedFundItem");
       		action.setParams({'protaskId': protaskId,'proId':component.get("v.recordId") });
       } else {
            action = component.get("c.oppRelatedFundItem");
       		action.setParams({'opliId': protaskId,'oppId':component.get("v.recordId") });
       }
        
        action.setCallback(this,(response) => {
            if(response.getState() === 'SUCCESS'){
                let result = response.getReturnValue();      
                component.set("v.fundingItemRecords",result);
                component.find('ModalComponent').openModal(true);
                
                this.setFundingColumns(component,event);
                component.find("fundingTable").initialize({'order':[]});
               //console.log(result);
               this.hideSpinner(component,event);
            }else {
            	this.hideSpinner(component,event);
            }
            	
        });
        
        $A.enqueueAction(action);  
   },
   setFundingColumns: function(component,event){
       var columns = [
            {
                'label':'Name',
                'name':'Name',
                'type':'reference',
                'value':'Id',
                'resizeable':true,
                'truncate' : {
	              "characterLength" : 10
                },
                'sortable':false,
                'target':'_blank'
            },
            {
                'label':'Quantity',
                'name':'Quantity__c',
                'type':'String',
                'sortable':false
            },
            {
                'label':'Rate Per Quantity',
                'name':'Rate_per_Quantity__c',
                'type':'String',
                'sortable':false
            },
             {
                'label':'Amount',
                'name':'Amount__c',
                'type':'currency',
                 'sortable':false
            },
            {
                'label':'Payment',
                'name':'Payment__r.Name',
                'type':'String',
                'sortable':false
            },
            
           
            {
                'label':'Project Task',
                'name':'Project_Task__r.Name',
                'type':'String',
                'sortable':false
            }           

        ];
       component.set("v.fundingItemColumns",columns);
       var config = { 
            "massSelect":false,
            "searchBox":false,
            "searchByColumn":false,
            'paginate':false,
            
        };
         component.set("v.fundingColumnConfig",config);
       //console.log( component.get("v.fundingItemColumns"), component.get("v.fundingColumnConfig"));

   },
   getCustomFieldId : function(component,event){
          let action = component.get("c.getCustomFieldId");
            var customfieldId = '';
        
        action.setCallback(this,(response) => {
            if(response.getState() === 'SUCCESS'){
            let result = response.getReturnValue();
            console.log(result,component.get("v.parentRecordName"));	
            result.map((rec) => {
            if (component.get("v.sObjectName") != 'Opportunity' && rec.Object_API_Name__c == 'Transaction__c') {
            	if(rec.Field_API_Name__c == 'Project__c') {
                    customfieldId = rec.Value__c;
       		 	}
        	}
            if (component.get("v.sObjectName") == 'Opportunity' && rec.Object_API_Name__c == 'Transaction__c') {
            	if(rec.Field_API_Name__c == 'Opportunity__c') {
                    customfieldId = rec.Value__c;
       		 	}
        	}
       
        	})
            if(customfieldId.length > 15){
				customfieldId = customfieldId.subString(0,15);            
        	}
			
			window.open('/apex/PaymentAndPaymentItemCreation?CF'+customfieldId+'='+component.get("v.parentRecordName")+'&CF'+customfieldId+'_lkid='+component.get("v.recordId")+'&scontrolCaching=1&retURL=/'+component.get("v.recordId")+'&sfdc.override=1','_self');
      		//console.log(result);
            }
            	
        });
        
        $A.enqueueAction(action);  
   },
    deleteRecord : function(component,event,helper){
        let action = component.get("c.deleteRecordById");
        action.setParams({'id':component.get("v.deleteId")});
        action.setCallback(this,(response) => {
            component.set("v.deleteId",null);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            "type":'success',
            "title": "Success!",
            "message": "The record has deleted successfully."
        });
        toastEvent.fire();
        //console.log('sdf',component.get("v.sObjectName"));
        component.set("v.subtabName", '');
        this.showSpinner(component,event);
        if(component.get("v.sObjectName") === 'Opportunity'){
            helper.launchOpportunityBudgetPage(component, event, helper);
        } else {
            //console.log('sdf');
            helper.launchProjectBudgetPage(component, event, helper); 
        }  
        
        
    });

    $A.enqueueAction(action);  
    },
    navigateToRecord : function (component, event, helper,recordId) {
       var navEvt = $A.get("e.force:navigateToSObject");
       navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "related"
       });
       navEvt.fire();
    },
    hideSpinner : function(component, event, helper){
        /*if(!$A.util.hasClass(component.find('spinnerHolder'),'slds-hide')){
            $A.util.addClass(component.find('spinnerHolder'),'slds-hide');
        }*/
        component.set("v.showSpinner",false);
    },
    showSpinner : function(component, event, helper){
            /* if($A.util.hasClass(component.find('spinnerHolder'),'slds-hide')){
            $A.util.removeClass(component.find('spinnerHolder'),'slds-hide');
        } */
        component.set("v.showSpinner",true);
    }, 
     //#W-001548  
    // As an LTS user, I would like to be able to export the Material Request Details from the Project page.
   exportAsFileType : function(cmp,columns,rows,fileName,type,useValuePropForReference) {
       var self = this;
       // This builds the spreadsheet - the headerColumns are the first row
      // and the spreadsheet data is an array of arrays for the rest of the data
       this.setData = function(headerColumns, spreadsheetData) {
           // Gets the labels from the data columns 
           
           var columnNames = [];
           
           headerColumns.forEach(function(thisHeaderRow) {
               // Add the name if there's no label for some reason 
               
               var columnId = thisHeaderRow["label"] || thisHeaderRow["name"];
               
               if(!('exportable' in thisHeaderRow) || thisHeaderRow["exportable"] != false){
                   columnNames.push(columnId);
               }
               
           });
           
           // This holds the rows for our data sheet, initially put in the header row
           var columns = [];
           columnNames.forEach(function(col) {
               columns.push(col.replace(/[#]/g,''));
           });
           var rows = [columns];                 
           // Iterate through every line item
           spreadsheetData.forEach(function(thisRecord) {
               var thisRecordProperties = [];
               // For each header column, get the property on the record that matches the name of the column
               headerColumns.forEach(function(thisRow) {
                   if( thisRow.type && (thisRow.type).toLowerCase() === 'reference'){
                       let referenceField = useValuePropForReference ? thisRow['value'] : thisRow["name"];
                       thisRecordProperties.push(('"'+thisRecord[referenceField]).replace(/[#]/g,'')+'"');  
                   } else if(thisRow.type && (thisRow.type).toLowerCase() === 'date'){
                       if(thisRecord[thisRow["name"]]){
                           var dt = new Date (thisRecord[thisRow["name"]]);
                           var mm = dt.getMonth() + 1;
                           mm = (mm < 10) ? '0' + mm : mm;
                           var dd = dt.getDate();
                           var yyyy = dt.getFullYear();
                           var date = mm + '/' + dd + '/' + yyyy;
                           thisRecordProperties.push(date);
                       }else{
                           thisRecordProperties.push(thisRecord[thisRow["name"]]);  
                       }
                   }else {
                       if(thisRecord[thisRow["name"]]){
                           thisRecordProperties.push(('"'+thisRecord[thisRow["name"]]).replace('/[#]/g','')+'"');  
                       }else{
                           thisRecordProperties.push(thisRecord[thisRow["name"]]);  
                       }
                   }
                   
               });
               
               // Push all the properties extracted from this line item to the data rows array
               rows.push(thisRecordProperties);
           });
           rows.splice(spreadsheetData.length,1);
           this.rows = rows;
       };
       
       this.setData(columns, rows); // Call setData on object construction
       // This function actually downloads the spreadsheet
       this.downloadData = function() {
           var isInIE = this.getIsIE();
           
           var fileContent = (!isInIE) ? "data:text/plain;charset=utf-8," : "";
           
           // Right now rows is an array of arrays, break each inner array into a tab-separated string
           this.rows.forEach(function(rowArray) {
               //console.log(rowArray);
               var row = rowArray.join(",");
               console.log('join',row);
               fileContent += row + "\r\n"; // Add carriage return
           }); 
           
           // Create an anchor element with the fileContent, this will allow us to automatically download file
           var encodedUri = encodeURI(fileContent);
           
           var link = document.createElement("a");
           let blob = new Blob([fileContent]);
           
           if(isInIE && !window.navigator.msSaveOrOpenBlob) {
               link.href = window.URL.createObjectURL(blob, {type: "text/plain"});
               link.download = this.getFileName();
           } else {
               link.setAttribute("href", encodedUri);
               link.setAttribute("download", this.getFileName());
           }
           
           
           if(!isInIE) {
               link.click();
           } else {
               
               if (window.navigator.msSaveOrOpenBlob) {
                   window.navigator.msSaveBlob(blob, this.getFileName());
               }
               else {
                   link.click(); 
               }
           }
       };
       
       // Getter and Setter for the file name
       this.setFileName = function(fileName,type) {
           // Add a file extension if one wasn't passed in
           
           if(fileName && type){
               fileName += '.' + type;
           }
           
           this.fileName = fileName;
       };
       this.setFileName(fileName,type);
       
       this.getFileName = function() {
           if(this.fileName) {
               return this.fileName;
           } else {
               if(type) return "Unnamed_Document." + type;
               return "Unnamed_Document.csv";
           }
       };	
       var ua = window.navigator.userAgent;
       var msie = ua.indexOf("MSIE");
       
       // Returns true if the browswer is IE or Edge; otherwise false
       this.getIsIE = function() {
           // Checks for instance of documentMode (IE-only property) or the userAgent with name of "Edge"
           if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./) || /Edge/.test(navigator.userAgent)) {
               return true;
           } else {
               return false;
           }
       }
       this.downloadData();
   },
       
})