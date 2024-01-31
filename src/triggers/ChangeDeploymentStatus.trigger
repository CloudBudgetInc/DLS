trigger ChangeDeploymentStatus on MTT__c (after update, before delete) {
if (trigger.isUpdate){  

 List < Id > MTTIds = new List < Id >();
    List < Id > DepIds = new List < Id >();
   
    for(MTT__c Mtt1: Trigger.New) {
        
        if(Mtt1.Stage__c == 'Ended'){
           
           List<Deployed_Instructor__c> depObj = [select d.Id,d.Status__c,d.MTT_Name__c from Deployed_Instructor__c d where d.MTT_Name__c =:Mtt1.Id];
           if(depObj.size() > 0){
               for(Deployed_Instructor__c dep : depObj ){
                   dep.Status__c = 'No Longer Deployed';
                   update dep;
               }
           }
        }
     }
  }

}