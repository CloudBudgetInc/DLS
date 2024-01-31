trigger PayableLineTrigger on AcctSeed__Account_Payable_Line__c (before insert) {
    
    // Added by HL on Dec 17 2019
    // Work Item : W-002702 - Payable related changes
    if(Trigger.isBefore){
    
        // Variables to populate GL Variable 1 field based on its related Project Task's GL Variable 1 field
        Set<Id> projTaskIds = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
        Map<Id, AcctSeed__Project_Task__c> projTaskIdAndRec = new Map<Id, AcctSeed__Project_Task__c>();
        Map<Id, AcctSeed__Project__c> projIdAndRec = new Map<Id, AcctSeed__Project__c>();
         
        if(Trigger.isInsert){
        
            for(AcctSeed__Account_Payable_Line__c pay : Trigger.new){
            
                if(pay.AcctSeed__Project_Task__c != NULL){
                
                    projTaskIds.add(pay.AcctSeed__Project_Task__c);
                }
                if(pay.AcctSeed__Project__c != null && pay.AcctSeed__Project_Task__c == NULL){
                
                    projIds.add(pay.AcctSeed__Project__c);
                }  
                
                if(pay.Bill_com_AP_Line_Id__c == null) {
                                        
                    if((pay.AcctSeed__Quantity__c == NULL && pay.Amount_per_Quantity__c != NULL) || 
                       (pay.AcctSeed__Quantity__c != NULL && pay.Amount_per_Quantity__c == NULL)){
                           pay.addError('Either the Quantity or Amount per Quantity is blank. Please enter both the Quantity and the Amount per Quantity to calculate the amount based on Quantity, or leave both fields blank.');    
                    }
                    
                    if(pay.AcctSeed__Quantity__c != NULL && pay.Amount_per_Quantity__c != NULL){
                        pay.AcctSeed__Amount__c = pay.AcctSeed__Quantity__c * pay.Amount_per_Quantity__c;
                    }
                    
                }
                
            }
            System.debug(':::projTaskIds::::'+projTaskIds);
            
            if(projTaskIds != NULL && projTaskIds.size() > 0){
            
                projTaskIdAndRec = new Map<Id, AcctSeed__Project_Task__c>([SELECT Id, AcctSeed__GL_Account_Variable_1__c,AcctSeed__GL_Account_Variable_2__c,AcctSeed__Labor_GL_Account__c,Product__c FROM AcctSeed__Project_Task__c WHERE Id IN : projTaskIds]);
            }
            System.debug(':::projTaskIdAndRec::::'+projTaskIdAndRec);
            if(projIds.size() > 0){
                projIdAndRec = new Map<Id, AcctSeed__Project__c>([SELECT Id,GL_Variable_2__c  FROM AcctSeed__Project__c WHERE Id IN :projIds]);
            }
            
            for(AcctSeed__Account_Payable_Line__c pay : Trigger.new){
            
                if(pay.AcctSeed__Project_Task__c != NULL && projTaskIdAndRec.containsKey(pay.AcctSeed__Project_Task__c)){
                    
                    if(pay.AcctSeed__GL_Account_Variable_1__c == NULL){
                        pay.AcctSeed__GL_Account_Variable_1__c = projTaskIdAndRec.get(pay.AcctSeed__Project_Task__c).AcctSeed__GL_Account_Variable_1__c;
                    }
                    if(pay.AcctSeed__GL_Account_Variable_2__c == null){
                        pay.AcctSeed__GL_Account_Variable_2__c = projTaskIdAndRec.get(pay.AcctSeed__Project_Task__c).AcctSeed__GL_Account_Variable_2__c;
                    }
                    
                    /*if(projTaskIdAndRec.get(pay.AcctSeed__Project_Task__c).AcctSeed__Labor_GL_Account__c != null){
                        pay.AcctSeed__Expense_GL_Account__c = projTaskIdAndRec.get(pay.AcctSeed__Project_Task__c).AcctSeed__Labor_GL_Account__c;
                    }*/
                    
                    if(pay.AcctSeed__Product__c == null && projTaskIdAndRec.get(pay.AcctSeed__Project_Task__c).Product__c != null){
                        pay.AcctSeed__Product__c = projTaskIdAndRec.get(pay.AcctSeed__Project_Task__c).Product__c;
                    }
                } 
                if(pay.AcctSeed__Project__c != null && pay.AcctSeed__Project_Task__c == NULL && projIdAndRec.containsKey(pay.AcctSeed__Project__c)){
                    
                    if(pay.AcctSeed__GL_Account_Variable_2__c == null){
                        pay.AcctSeed__GL_Account_Variable_2__c = projIdAndRec.get(pay.AcctSeed__Project__c).GL_Variable_2__c;
                    }                    
                }  
            }
        }
    }
}