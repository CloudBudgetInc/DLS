trigger ChangeDeveloperStatus on Curriculum_Development_Project__c (after update, before delete) {
if (trigger.isUpdate){  

 List < Id > CDIds = new List < Id >();
    List < Id > DevIds = new List < Id >();
   
    for(Curriculum_Development_Project__c Proj1: Trigger.New) {
        
        if(Proj1.Status__c == 'Ended'){
           
           List<CD_Assignment__c> devObj = [select d.Id,d.Status__c,d.Curriculum_Development_Project__c, d.developer_name__c 
           from CD_Assignment__c d 
           where d.Curriculum_Development_Project__c =:Proj1.Id];
           if(devObj.size() > 0){
               for(CD_Assignment__c dev : devObj ){
                   dev.Status__c = 'Ended';
                   update dev;
               }
             }
           }
       }
   }
}