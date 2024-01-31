trigger EmploymentSectionUpdateToLinguist on Linguist_Assignment__c (after insert, after update, after delete) { 

if (trigger.isInsert){
Map<Id,Id> linguistsToDepsMap = new Map<Id,Id>();
for(Linguist_Assignment__c A : trigger.new)
           linguistsToDepsMap.put(A.Linguist_Name__c,A.Id);
 
List<Contact> contactsToUpdate = new List<Contact>();

      
    for (Contact Linguist: [SELECT Id, Employment_Section__c, Current_Account__c FROM Contact WHERE Id IN:  linguistsToDepsMap.keySet()])
    {
        Id DepId = linguistsToDepsMap.get(Linguist.Id);
        Linguist_Assignment__c Dep = trigger.newMap.get(DepId);
        
        //boolean transition = trigger.IsInsert || (trigger.isUpdate && trigger.oldMap.get(Dep.Id).Status__c != Dep.Status__c); //insert or update with a status change
        boolean Closedtransition = trigger.isUpdate && trigger.oldMap.get(Dep.Id).Status__c=='Active'; //update and status changed to closed
        
//CASE 1: if inserting an active linguist
if(Dep.Status__c=='Active'){
Linguist.Employment_Section__c='T&I';
Linguist.Current_Account__c='T&I';
Linguist.Instructor_Status__c='Employed';
Linguist.Next_Availability__c=Dep.End_Date__c;
contactsToUpdate.add(linguist);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}
if(trigger.isUpdate){
Map<Id,Id> linguistsToDepsMap = new Map<Id,Id>();
for(Linguist_Assignment__c A : trigger.new)
           linguistsToDepsMap.put(A.Linguist_Name__c,A.Id);
 
List<Contact> contactsToUpdate = new List<Contact>();
      
    for (Contact Linguist: [SELECT Id,Employment_Section__c, Current_Account__c FROM Contact WHERE Id IN:  linguistsToDepsMap.keySet()])
    {
        Id DepId = linguistsToDepsMap.get(Linguist.Id);
       Linguist_Assignment__c Dep = trigger.newMap.get(DepId);
       
        boolean transition = (trigger.oldMap.get(dep.Id).Status__c != dep.Status__c);
        boolean DateChange = (trigger.oldMap.get(dep.Id).End_Date__c != dep.End_Date__c);
        
//CASE 2: update and Not Active to Active (just in case)      
if (Dep.Status__c=='Active'&&(transition||DateChange)){
Linguist.Employment_Section__c='T&I';
Linguist.Current_Account__C='T&I';
Linguist.Instructor_Status__c='Employed';
Linguist.Next_Availability__c=Dep.End_Date__c;
contactsToUpdate.add(linguist);
}
//CASE 4: update and active to ended
else if (Dep.Status__c=='Ended'&&transition){
Linguist.Employment_Section__c=null;
Linguist.Current_Account__c=null;
Linguist.Instructor_Status__c='Available';
Linguist.Next_Availability__c=null;
contactsToUpdate.add(linguist);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}
if(trigger.isDelete){
Map<Id,Id> linguistsToDepsMap2 = new Map<Id,Id>();
for(Linguist_Assignment__c A : trigger.old)
           linguistsToDepsMap2.put(A.Linguist_Name__c,A.Id);
 
List<Contact> contactsToUpdate2 = new List<Contact>();

      
   for (Contact Linguist2: [SELECT Id, Employment_Section__c, Current_Account__c FROM Contact WHERE Id IN:  linguistsToDepsMap2.keySet()])
   {
        Id DepId = linguistsToDepsMap2.get(Linguist2.Id);
        Linguist_Assignment__c Dep = system.trigger.oldMap.get(DepId);
        
if (Dep.Status__c=='Active'){
Linguist2.Employment_Section__c=null;
Linguist2.Current_Account__c=null;
Linguist2.Instructor_Status__c='Available';
Linguist2.Next_Availability__c=null;
contactsToUpdate2.add(linguist2);
}
}
if(contactsToUpdate2 != null && !contactsToUpdate2.isEmpty())
Database.update(contactsToUpdate2);
}
}