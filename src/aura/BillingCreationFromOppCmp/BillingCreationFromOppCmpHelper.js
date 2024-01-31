({  // get Opp and OppLine Items Information
    getBillingTableInformation : function(cmp, event, helper) {
        
        var oppId = cmp.get("v.recordId");
        
        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.getBillingInfoFromOPP");
        server.callServer(
            action, {'oppId' : oppId},
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                cmp.set("v.billingRowInfo",result);
                
                if(result.studentContactsMap){
                    let studentContacts = [],
                         contactRecords = Object.values(result.studentContactsMap);
                    
                    for(let contact of contactRecords){
                        studentContacts.push({'label': contact.Name  , 'value': contact.Id});
                    }
                    cmp.set("v.studentContacts", studentContacts);
                    
                    if(contactRecords.length > 1){
                        cmp.set('v.showStudentSelection', true);
                    }
                }
                
                if(result.isPrePaymentOpp == false){
                    helper.showToast(cmp,event,helper,'error','','Billing creation only for Prepayment Billing Type.','pester','info_alt');
                    $A.get("e.force:closeQuickAction").fire();  
                }else{
                    if(result.projectExist){
                        // if Opportunity has Project, show msg "This Opportunity is already converted to Project, Please use Create Billing page to create Billing."
                        helper.showToast(cmp,event,helper,'error','','This Opportunity is already converted to Project, Please use Create Billing page to create Billing.','pester','info_alt');
                        $A.get("e.force:closeQuickAction").fire();  
                    }
                }
                
                console.log(result);
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
            }),
            false,
            false,
            false
        );
    },// Biling and Billing Line record creation
    createBillingRec : function(cmp, event, helper) {
        
        var billingRowInfo = cmp.get("v.billingRowInfo");
        var studentContacts = billingRowInfo['studentContactsMap'];
        console.log('studentContacts:::::::',studentContacts);
        console.log('v.selectedConId::::::::',cmp.get("v.selectedConId"));
        var selectedStudentContact;
        if(Object.keys(studentContacts).length > 1){
            selectedStudentContact = studentContacts[cmp.get("v.selectedConId")];
        }else if(Object.keys(studentContacts).length == 1){
            var selectedConId = cmp.get('v.studentContacts')[0].value;
            selectedStudentContact = studentContacts[selectedConId];           
        }
        var oppId = cmp.get("v.recordId");
        var self = this;    
        console.log('selectedStudentContact::::::',selectedStudentContact );
        //console.log('selectedStudentCA::::::::::>'+JSON.stringify(selectedStudentCA));
        if(!selectedStudentContact){
            selectedStudentContact = null;
        }
        if(billingRowInfo && billingRowInfo.opliItemsList && billingRowInfo.opliItemsList.length > 0){
            cmp.set("v.showSpinner",true);
            
            var billingLineList = billingRowInfo.opliItemsList;
            var billingLineCreationInfo = [];	
            var billingExistMap = {};
            var oppANDOPLIProductList = [];
            var billingIdExist = '';
            
            if(billingRowInfo.billingRecExistMapJSON){
                billingExistMap = JSON.parse(billingRowInfo.billingRecExistMapJSON);
                oppANDOPLIProductList = Object.keys(billingExistMap);
                
                if(oppANDOPLIProductList.length > 0 && billingExistMap[oppANDOPLIProductList[0]]){ 
                    billingIdExist = billingExistMap[oppANDOPLIProductList[0]].AcctSeed__Billing__c;
                }
            }
            console.log(oppANDOPLIProductList);
            for(var i = 0;i < billingLineList.length;i++){
                
                if(!oppANDOPLIProductList.includes(billingLineList[i].oppId+'~'+billingLineList[i].opliId)){
                    
                    var billingLineCreationRec = {}
                    billingLineCreationRec.AcctSeed__Rate__c = billingLineList[i].unitPrice;
                    billingLineCreationRec.AcctSeed__Hours_Units__c = billingLineList[i].quantity;
                    billingLineCreationRec.AcctSeed__Opportunity_Product_Id__c = billingLineList[i].opliId;
                    billingLineCreationRec.AcctSeed__Comment__c = billingLineList[i].comment;
                    
                    if(billingLineList[i].glAccountVar1){
                        billingLineCreationRec.AcctSeed__GL_Account_Variable_1__c = billingLineList[i].glAccountVar1;                                     
                    }
                    
                    if(billingLineList[i].revenueGLAccount){
                        billingLineCreationRec.AcctSeed__Revenue_GL_Account__c = billingLineList[i].revenueGLAccount;                   
                    }
                    
                    if(billingLineList[i].clinId){
                        billingLineCreationRec.CLIN__c = billingLineList[i].clinId;
                    }
                    
                    if(billingLineList[i].productId){
                        billingLineCreationRec.AcctSeed__Product__c = billingLineList[i].productId;                   
                    }
                    
                    billingLineCreationInfo.push(billingLineCreationRec);
                }
                
            }
            
            if(billingLineCreationInfo.length > 0){
                var billingRec = {};
                
                if(billingRowInfo.oppId){                
                    billingRec.AcctSeed__Opportunity__c = billingRowInfo.oppId;
                }
                
                
                if(billingRowInfo.accountId){
                    billingRec.AcctSeed__Customer__c = billingRowInfo.accountId; 
                }
                
                if(billingRowInfo.accBillingDueDays){
                    billingRec.AcctSeed__Due_Date2__c = billingRowInfo.accBillingDueDays;
                }
                
                if(billingRowInfo.proprietaryNo){
                    billingRec.AcctSeed__Proprietary_Billing_Number__c = billingRowInfo.proprietaryNo;                       
                }
                
                
                if(billingRowInfo.acpId){
                    billingRec.AcctSeed__Accounting_Period__c = billingRowInfo.acpId;
                    billingRec.AcctSeed__Billing_Cycle_Start_Date__c = billingRowInfo.acpStDt;
                    billingRec.AcctSeed__Billing_Cycle_End_Date__c = billingRowInfo.acpEdDt;
                }
                
                if(billingRowInfo.billingContact){
                    billingRec.AcctSeed__Billing_Contact__c = billingRowInfo.billingContact; 
                }
                
                var billRecJSON = "{}";
                if(billingIdExist){
                    billingRec.Id = billingIdExist;              
                }
                billRecJSON = JSON.stringify(billingRec); 
 
                var billLineRecJSON = JSON.stringify(billingLineCreationInfo);
                
                const server = cmp.find('server');
                var action = cmp.get("c.createBillingRecs");
                server.callServer(
                    action, 
                    {
                        'billingJSON' : billRecJSON,                     
                        'billingLineJSON' : billLineRecJSON,
                        'billingId'       : billingIdExist,
                        'opportId'        : oppId,
                        'contactStr': JSON.stringify(selectedStudentContact)
                    },
                    false,
                    $A.getCallback(function(response) {
                       self.congaURLFormation(cmp,event,helper,response);
                    }),
                    $A.getCallback(function(errors) {
                        cmp.set("v.showSpinner",false);
                        console.log(errors[0].message);
                        self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
                    }),
                    false,
                    false,
                    false
                );     
            }else{
                cmp.set("v.showSpinner",false);
                if(billingIdExist){
                    helper.goToCongaPage(cmp,event,helper,billingIdExist);
                }                
            }	                
        }
        
    },// show Toast Message
    showToast : function(cmp, event, helper, type, title, message, mode,key) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            key: key,
            title: title,
            type: type,
            mode: mode
        });
        toastEvent.fire();
    },
    // to launch the conga page
    goToCongaPage : function(cmp,event,helper,billingId){
        if(billingId){
            var self = this;
            var oppId = cmp.get("v.recordId");
            const server = cmp.find('server');
            var action = cmp.get("c.prepaymentCongaUrlInfo");
            cmp.set("v.showSpinner",true); 
            
            server.callServer(
                action, {'billId'  : billingId,
                        'opportId' : oppId},
                false,
                $A.getCallback(function(response) {
                    self.congaURLFormation(cmp,event,helper,JSON.stringify(response));
                }),
                $A.getCallback(function(errors) {
                    cmp.set("v.showSpinner",false);
                    self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
                }),
                false,
                false,
                false
            );
        }        
    },
    // Conga URL formation
    congaURLFormation : function(cmp, event, helper,congaUrlJSON){
        
        var returnValue = JSON.parse(congaUrlJSON);
        var templateId = null;
        var oppId = cmp.get("v.recordId");
        var properityNo = null;
        var billingId = null;
        var serverUrlSessionId = JSON.parse(returnValue.sessionIdServerURL);
        console.log(returnValue);
        
        if(returnValue.billingRec){
            
            if(returnValue.billingRec.Project_s_QB_Contract_Type__c == 'nonGSA'){
                templateId = returnValue.tempNameIdMap["Non-GSA Prepayment Invoice Template"];                    
            }else{                    
                templateId = returnValue.tempNameIdMap["GSA Prepayment Invoice Template"];                   
            } 
            
            if(returnValue.billingRec.AcctSeed__Proprietary_Billing_Number__c){                                
                properityNo = returnValue.billingRec.AcctSeed__Proprietary_Billing_Number__c;
            }
            
            if(returnValue.billingRec.Id){
                billingId = returnValue.billingRec.Id;
            }
        }
        
        var congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+"&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+oppId+"&OFN="+properityNo+
            "&templateId="+templateId+"&DefaultPDF=1&TemplateGroup=PrepaymentInvoice"+"&queryId=[Billing]"+returnValue.queryNameIdMap["Billing Query - Billing PDF"]+"?pv0="+
            billingId+",[BillingLine]"+returnValue.queryNameIdMap["Billing Line Query - Billing PDF"]+"?pv0="+billingId;
        
        if(returnValue.conAssignId){
            congaUrl += ",[Stud]"+returnValue.queryNameIdMap["Contact Assignment Query - Product Billing PDF"]+"?pv0="+returnValue.conAssignId; 
        }
        
        cmp.set("v.showSpinner",false);
        window.open(congaUrl,'_blank');
        $A.get("e.force:closeQuickAction").fire();   
    }
})