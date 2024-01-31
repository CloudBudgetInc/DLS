public class journalEntryLineTriggerHandler{
    public static void populateGLAV2Field(List<AcctSeed__Journal_Entry_Line__c> newJournalEntryLines){
        Set<Id> projTaskIds = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
        Map<Id, AcctSeed__Project_Task__c> projTaskIdAndRec = new Map<Id, AcctSeed__Project_Task__c>();
        Map<Id, AcctSeed__Project__c> projIdAndRec = new Map<Id, AcctSeed__Project__c>();
        
        for(AcctSeed__Journal_Entry_Line__c jel : newJournalEntryLines){
            if(jel.AcctSeed__Project_Task__c != null){
                projTaskIds.add(jel.AcctSeed__Project_Task__c);
            }else if(jel.AcctSeed__Project__c != null){
                projIds.add(jel.AcctSeed__Project__c);
            }
        }
        
         if(projTaskIds != NULL && projTaskIds.size() > 0){
            
                projTaskIdAndRec = new Map<Id, AcctSeed__Project_Task__c>([SELECT Id, AcctSeed__GL_Account_Variable_1__c,AcctSeed__GL_Account_Variable_2__c,AcctSeed__Labor_GL_Account__c,Product__c FROM AcctSeed__Project_Task__c WHERE Id IN : projTaskIds]);
         }
         if(projIds.size() > 0){
            projIdAndRec = new Map<Id, AcctSeed__Project__c>([SELECT Id,GL_Variable_2__c  FROM AcctSeed__Project__c WHERE Id IN :projIds]);
         }
        
        for(AcctSeed__Journal_Entry_Line__c jel : newJournalEntryLines){
        
            if(jel.AcctSeed__Project_Task__c != NULL && projTaskIdAndRec.containsKey(jel.AcctSeed__Project_Task__c)){
                
                if(jel.AcctSeed__GL_Account_Variable_1__c == NULL){
                    jel.AcctSeed__GL_Account_Variable_1__c = projTaskIdAndRec.get(jel.AcctSeed__Project_Task__c).AcctSeed__GL_Account_Variable_1__c;
                }
                if(jel.AcctSeed__GL_Account_Variable_2__c == null){
                    jel.AcctSeed__GL_Account_Variable_2__c = projTaskIdAndRec.get(jel.AcctSeed__Project_Task__c).AcctSeed__GL_Account_Variable_2__c;
                }
            }else if(jel.AcctSeed__Project__c != null && jel.AcctSeed__Project_Task__c == NULL && projIdAndRec.containsKey(jel.AcctSeed__Project__c)){
                
                if(jel.AcctSeed__GL_Account_Variable_2__c == null){
                    jel.AcctSeed__GL_Account_Variable_2__c = projIdAndRec.get(jel.AcctSeed__Project__c).GL_Variable_2__c;
                }                    
            }  
        }
    }
}