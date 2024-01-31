Public Class BillingLineTriggerHandler{

    //Added By Dhinesh - W-006606 - To populate Total_Amount_Paid_Billing_Line__c, Most_Recent_Payment_Received_Date_Bill__c  - Fields in related Project Tasks for prepayments on Convert to Projects
    public static void populateProjTaskContractRollupFields(List<AcctSeed__Billing_Line__c> updatedBillingLines, Map<Id, AcctSeed__Billing_Line__c> oldBillingLineMap){
        Set<Id> billingIdsToCheckHasBillingCashReceipt = new Set<Id>();
        Map<Id, Set<Id>> billingIdWithProjectTasksIds = new Map<Id, Set<Id>>();
        Set<Id> projectTaskIds = new Set<Id>();
        
        for(AcctSeed__Billing_Line__c billingLine : updatedBillingLines){
            if(billingLine.AcctSeed__Project_Task__c != null && oldBillingLineMap.get(billingLine.Id).AcctSeed__Project_Task__c == null){
                billingIdsToCheckHasBillingCashReceipt.add(billingLine.AcctSeed__Billing__c);
                
                if(!billingIdWithProjectTasksIds.containsKey(billingLine.AcctSeed__Billing__c)){
                    billingIdWithProjectTasksIds.put(billingLine.AcctSeed__Billing__c, new Set<Id>());
                } 
                billingIdWithProjectTasksIds.get(billingLine.AcctSeed__Billing__c).add(billingLine.AcctSeed__Project_Task__c);
            }
        }
        
        if(billingIdsToCheckHasBillingCashReceipt.size() > 0){
            
            for(AcctSeed__Billing_Cash_Receipt__c billingCashReceipt : [SELECT Id, AcctSeed__Billing__c, AcctSeed__Cash_Receipt__c 
                                                                        FROM AcctSeed__Billing_Cash_Receipt__c 
                                                                        WHERE AcctSeed__Billing__c IN :billingIdsToCheckHasBillingCashReceipt
                                                                              AND AcctSeed__Cash_Receipt__r.Contract__c = null]){
                
                if(billingIdWithProjectTasksIds.containsKey(billingCashReceipt.AcctSeed__Billing__c)){
                    projectTaskIds.addAll(billingIdWithProjectTasksIds.get(billingCashReceipt.AcctSeed__Billing__c));
                }
            }
            
            if(projectTaskIds.size() > 0){
                BillingCashReceiptTriggerHandler.populateProjTaskRollupfieldsInFuture(projectTaskIds);
            }
        }
    }
    
    // Work Item: W-007090 - CLINs in the Billing line should pull corresponding Projects
    // To populate Billing Line CLIN field value based on its related project task CLIN field value
    public static void populateCLINField(List<AcctSeed__Billing_Line__c> newBillingLines, Map<Id, AcctSeed__Billing_Line__c> oldBillingLines){
    
        List<AcctSeed__Billing_Line__c> updateBillingLines = new List<AcctSeed__Billing_Line__c>();
        Set<Id> projTaskIds = new Set<Id>();
        
        for(AcctSeed__Billing_Line__c bl : newBillingLines){
            if(bl.CLIN__c == null && bl.AcctSeed__Project_Task__c != null && (Trigger.isInsert || 
                (Trigger.isUpdate && bl.AcctSeed__Project_Task__c != oldBillingLines.get(bl.Id).AcctSeed__Project_Task__c))){
                updateBillingLines.add(bl);
                projTaskIds.add(bl.AcctSeed__Project_Task__c);
            }
        }
        if(projTaskIds.size() > 0){
            Map<Id, AcctSeed__Project_Task__c> projtaskRec = new Map<Id, AcctSeed__Project_Task__c>([SELECT Id, CLIN__c FROM AcctSeed__Project_Task__c WHERE Id IN : projTaskIds AND CLIN__c != null]); 
            
            for(AcctSeed__Billing_Line__c bl : updateBillingLines){
                if(projtaskRec.containsKey(bl.AcctSeed__Project_Task__c)){
                    bl.CLIN__c = projtaskRec.get(bl.AcctSeed__Project_Task__c).CLIN__c;
                }    
            }   
        }
    }
    
    public static void populateGLAV2Field(List<AcctSeed__Billing_Line__c> newBillingLines){
        Set<Id> projTaskIds = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
        Map<Id, AcctSeed__Project_Task__c> projTaskIdAndRec = new Map<Id, AcctSeed__Project_Task__c>();
        Map<Id, AcctSeed__Project__c> projIdAndRec = new Map<Id, AcctSeed__Project__c>();
        
        for(AcctSeed__Billing_Line__c bl : newBillingLines){
            if(bl.AcctSeed__Project_Task__c != null){
                projTaskIds.add(bl.AcctSeed__Project_Task__c);
            }else if(bl.AcctSeed__Project__c != null){
                projIds.add(bl.AcctSeed__Project__c);
            }
        }
        
         if(projTaskIds != NULL && projTaskIds.size() > 0){
            
                projTaskIdAndRec = new Map<Id, AcctSeed__Project_Task__c>([SELECT Id, AcctSeed__GL_Account_Variable_1__c,AcctSeed__GL_Account_Variable_2__c,AcctSeed__Labor_GL_Account__c,Product__c FROM AcctSeed__Project_Task__c WHERE Id IN : projTaskIds]);
         }
         if(projIds.size() > 0){
            projIdAndRec = new Map<Id, AcctSeed__Project__c>([SELECT Id,GL_Variable_2__c  FROM AcctSeed__Project__c WHERE Id IN :projIds]);
         }
        
        for(AcctSeed__Billing_Line__c bl : newBillingLines){
        
            if(bl.AcctSeed__Project_Task__c != NULL && projTaskIdAndRec.containsKey(bl.AcctSeed__Project_Task__c)){
                
                if(bl.AcctSeed__GL_Account_Variable_1__c == NULL){
                    bl.AcctSeed__GL_Account_Variable_1__c = projTaskIdAndRec.get(bl.AcctSeed__Project_Task__c).AcctSeed__GL_Account_Variable_1__c;
                }
                if(bl.AcctSeed__GL_Account_Variable_2__c == null){
                    bl.AcctSeed__GL_Account_Variable_2__c = projTaskIdAndRec.get(bl.AcctSeed__Project_Task__c).AcctSeed__GL_Account_Variable_2__c;
                }
            }else if(bl.AcctSeed__Project__c != null && bl.AcctSeed__Project_Task__c == NULL && projIdAndRec.containsKey(bl.AcctSeed__Project__c)){
                
                if(bl.AcctSeed__GL_Account_Variable_2__c == null){
                    bl.AcctSeed__GL_Account_Variable_2__c = projIdAndRec.get(bl.AcctSeed__Project__c).GL_Variable_2__c;
                }                    
            }  
        }    
    }
    
    public static void populateIsBillPosted(List<AcctSeed__Billing_Line__c> newBillingLines){
        Set<Id> billingIds = new Set<Id>();
        for(AcctSeed__Billing_Line__c bl : newBillingLines){
            billingIds.add(bl.Acctseed__Billing__c);
        }
        
        Map<Id, Acctseed__Billing__c> billingMap = new Map<Id, Acctseed__Billing__c>([SELECT Id FROM Acctseed__Billing__c WHERE Id IN :billingIds AND Acctseed__Status__c = 'Posted']);
        
        for(AcctSeed__Billing_Line__c bl : newBillingLines){
            bl.Is_Bill_Posted__c = billingMap.containsKey(bl.Acctseed__Billing__c);
        }
    }
}