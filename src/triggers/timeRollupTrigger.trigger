/*
Name: timeRollupTrigger
Developed on : June-30-2015
Developed By: Softsquare
Description: Roll-up the hours from Time__c to TASKRAY__Project_Task__c.Total_Hours__c
*/

trigger timeRollupTrigger on Time__c (after insert, after update,after delete) {
    
    /*set<Id> taskIdSet = new Set<Id>();

    for(Time__c timeRec : Trigger.isDelete ? Trigger.old : Trigger.new){
    
        if(Trigger.isDelete && timeRec.TaskRay_Task__c != NULL && timeRec.Hours__c > 0){
            taskIdSet.add(timeRec.TaskRay_Task__c);
        }
        
        if(Trigger.isInsert && timeRec.TaskRay_Task__c != NULL && timeRec.Hours__c > 0){
            taskIdSet.add(timeRec.TaskRay_Task__c);
        }
        
        if(Trigger.isUpdate && (Trigger.oldMap.get(timeRec.Id).TaskRay_Task__c != timeRec.TaskRay_Task__c ||
                                Trigger.oldMap.get(timeRec.Id).Hours__c != timeRec.Hours__c)){
                                
            if(timeRec.TaskRay_Task__c != NULL) taskIdSet.add(timeRec.TaskRay_Task__c);
            
            if(Trigger.oldMap.get(timeRec.Id).TaskRay_Task__c != timeRec.TaskRay_Task__c){
                if(Trigger.oldMap.get(timeRec.Id).TaskRay_Task__c != NULL) taskIdSet.add(String.valueOf(Trigger.oldMap.get(timeRec.Id).TaskRay_Task__c));
            }
        }
    }
    
    System.debug('::::taskIdSet::::::::'+taskIdSet);
    
    if(taskIdSet != NULL && taskIdSet.size() > 0){
    
        Set<Id> processedSet = new Set<Id>();
        aggregateResult[] agList = [SELECT SUM(Hours__c),TaskRay_Task__c 
                                    FROM Time__c 
                                    WHERE TaskRay_Task__c IN :taskIdSet 
                                    GROUP BY TaskRay_Task__c  ];
        
        List<TASKRAY__Project_Task__c> pTaskListToUpdate = new List<TASKRAY__Project_Task__c>();
        
        for(aggregateResult ag : agList){
        
            Id ptaskId = (Id)ag.get('TaskRay_Task__c');
            
            TASKRAY__Project_Task__c ptask = new TASKRAY__Project_Task__c(Id= ptaskId);
            ptask.Total_Hours__c = (Double)ag.get('expr0');
            pTaskListToUpdate.add(pTask);
            
            processedSet.add(ptaskId);
        }
        
        System.debug('::::processedSet::::::::'+processedSet.size());
        System.debug('::::taskIdSet::::::::'+taskIdSet.size());
        
        if(processedSet.size() < taskIdSet.size() ){
        
            for(Id ptaskId : taskIdSet){
                if(!processedSet.contains(ptaskId)){
                
                    TASKRAY__Project_Task__c ptask = new TASKRAY__Project_Task__c(Id= ptaskId);
                    ptask.Total_Hours__c = 0;
                    pTaskListToUpdate.add(pTask);
                }
            }
        }
        
        System.debug('::::pTaskListToUpdate ::::::::'+pTaskListToUpdate);
        System.debug('::::pTaskListToUpdate.size::::::::'+pTaskListToUpdate.size());
        
        IF(pTaskListToUpdate != NULL && pTaskListToUpdate.size() > 0){
            update pTaskListToUpdate;
        }
        
    }*/

}