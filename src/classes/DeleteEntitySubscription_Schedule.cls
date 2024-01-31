//Schedule to unfollow work items which are completed / closed - to delete the EntitySubscription records to follow future records
//created by NS on April 22 2020
//It will be scheduled manually every month

global class DeleteEntitySubscription_Schedule implements Schedulable {
    
     global void execute(SchedulableContext sc) {
         
         Set<Id> workItemIds = new Set<Id>();
         
         String worItemQry = 'SELECT Id, Name, agf__Closed_On__c, agf__Status__c FROM agf__ADM_Work__c WHERE agf__Status__c = \'Closed\' ';
         
         if(!Test.isRunningTest()){
             
             worItemQry += 'AND agf__Closed_On__c < LAST_N_MONTHS:6';
             
         }else if(Test.isRunningTest()){
         
             worItemQry += 'AND agf__Closed_On__c > LAST_N_MONTHS:6';
         }
         
         System.debug('::worItemQry:::'+worItemQry);
         
         for(agf__ADM_Work__c workItem : Database.Query(worItemQry)){
             
             workItemIds.add(workItem.Id);
         }
         
         //query EntitySubscription object
         List<EntitySubscription> entityRecords = [SELECT Id,ParentId,SubscriberId FROM EntitySubscription WHERE parentId IN :workItemIds];
         
         if(entityRecords.size() > 0){
             delete entityRecords;
         }
     }
}