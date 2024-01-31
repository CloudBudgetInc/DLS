trigger CDassignmentContactCountUpdate on CD_Assignment__c (after insert, after update, after delete) { 

if (trigger.isInsert){
Map<Id,Id> instructorsToCDMap = new Map<Id,Id>();
Map<Id,Id> AccountstoCDMap = new Map<Id,Id>();
for(CD_Assignment__c A : [SELECT ID,Developer_Name__c FROM CD_Assignment__c WHERE ID in: trigger.new])
           instructorsToCDMap.put(A.Developer_Name__c,A.Id);
for(CD_Assignment__c A : [SELECT Curriculum_Development_Project__r.Client__c,Developer_Name__c FROM CD_Assignment__c WHERE ID in: trigger.new])
           AccountstoCDMap.put(A.Curriculum_Development_Project__r.Client__c, A.Developer_Name__c); 
        
List<Contact> contactsToUpdate = new List<Contact>();

      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToCDMap.keySet()])
    {
        Id CDId = instructorsToCDMap.get(Instructor.Id);
        CD_Assignment__c CDass = trigger.newMap.get(CDId);
        Account Acc = [SELECT Id, Name FROM Account WHERE Id IN: AccountstoCDMap.keySet()];
        
        //boolean transition = trigger.IsInsert || (trigger.isUpdate && trigger.oldMap.get(CDass.Id).developer_status__c != CDass.developer_status__c);
        //boolean Closedtransition = trigger.isUpdate && trigger.oldMap.get(CDass.Id).developer_status__c=='Active';
        
//CASE 1: if inserting a CD Assignment with status Active, update instructor +1        
if (CDass.status__c=='Active'){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
Instructor.Employment_Section__c='CD';
Instructor.Current_Account__c=Acc.Name;
contactsToUpdate.add(instructor);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}
if(trigger.isUpdate){
Map<Id,Id> instructorsToCDMap = new Map<Id,Id>();
Map<Id,Id> AccountstoCDMap = new Map<Id,Id>();
for(CD_Assignment__c A : trigger.new)
           instructorsToCDMap.put(A.developer_name__c,A.Id);
for(CD_Assignment__c A : [SELECT Curriculum_Development_Project__r.Client__c,Developer_Name__c FROM CD_Assignment__c WHERE ID in: trigger.new])
           AccountstoCDMap.put(A.Curriculum_Development_Project__r.Client__c, A.Developer_Name__c);  
List<Contact> contactsToUpdate = new List<Contact>();
      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToCDMap.keySet()])
    {
        Id CDId = instructorsToCDMap.get(Instructor.Id);
        CD_Assignment__c CDass = trigger.newMap.get(CDId);
        Account Acc = [SELECT Id, Name FROM Account WHERE Id IN: AccountstoCDMap.keySet()] ;
        boolean transition = (trigger.oldMap.get(CDass.Id).status__c != CDass.status__c);
     
        
//CASE 2: update and Ended to Active (just in case)        
if (CDass.status__c=='Active'&&transition){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
Instructor.Employment_Section__c='CD';
Instructor.Current_Account__c=Acc.Name;
contactsToUpdate.add(instructor);
}

//CASE 3: update and Active to Ended
if (CDass.status__c=='Ended' && transition){
Instructor.Active_Count__c=Instructor.Active_Count__c - 1;
contactsToUpdate.add(instructor);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}
if(trigger.isDelete){
{
Map<Id,Id> instructorsToCDMap3 = new Map<Id,Id>();

for(CD_Assignment__c A : system.trigger.old)
           instructorsToCDMap3.put(A.developer_name__c,A.Id);
 
List<Contact> contactsToUpdate3 = new List<Contact>();
      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToCDMap3.keySet()])

    {
        Id CDId = instructorsToCDMap3.get(Instructor.Id);
        CD_Assignment__c CDass = system.trigger.oldMap.get(CDId);
        
//CASE 4: if delete a developer assignment with status "Active", instructor -1                   
                    if (CDass.status__c=='Active'){
                    Instructor.Active_Count__c=Instructor.Active_Count__c - 1;

             contactsToUpdate3.add(instructor);
       }
       }
if(contactsToUpdate3 != null && !contactsToUpdate3.isEmpty())
        Database.update(contactsToUpdate3);
}
}
}