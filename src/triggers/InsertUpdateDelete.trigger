trigger InsertUpdateDelete on Opportunity (after insert, after update, after delete) { 

if (trigger.isInsert){
Map<Id,Id> instructorsToOppsMap = new Map<Id,Id>();
for(Opportunity A : trigger.new)
           instructorsToOppsMap.put(A.InstructorName__c,A.Id);
 
List<Contact> contactsToUpdate = new List<Contact>();

      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToOppsMap.keySet()])
    {
        Id oppId = instructorsToOppsMap.get(Instructor.Id);
        Opportunity opp = trigger.newMap.get(oppId);
        
//CASE 1: if inserting an active class, update instructor +1
            if (opp.StageName=='Active'){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
contactsToUpdate.add(instructor);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())

Database.update(contactsToUpdate);
}
if(trigger.isUpdate){
Map<Id,Id> instructorsToOppsMap = new Map<Id,Id>();
for(Opportunity A : trigger.new)
           instructorsToOppsMap.put(A.InstructorName__c,A.Id);

           
List<Contact> contactsToUpdate = new List<Contact>();
         
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToOppsMap.keySet()])
    {

        Id oppId = instructorsToOppsMap.get(Instructor.Id);
        Opportunity opp = trigger.newMap.get(oppId);
            boolean transition = (trigger.oldMap.get(opp.Id).StageName != opp.StageName);
            boolean Closedtransition = (trigger.oldMap.get(opp.Id).StageName != opp.StageName)&& trigger.oldMap.get(opp.Id).StageName=='Active';

            boolean instructorchange = (trigger.oldMap.get(opp.Id).InstructorName__c != opp.InstructorName__c);
            
//CASE 2: if update, transition from anything to Active, instructor +1
if (opp.StageName=='Active' && transition){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;

contactsToUpdate.add(instructor);

//CASE 3: if update, Active, and instructor change, new instructor +1
}else if(opp.StageName=='Active'&& instructorchange){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
contactsToUpdate.add(instructor);

//CASE 4: if update, and change from Active to a not active stage
}else if (opp.StageName!='Active' && Closedtransition){

Instructor.Active_Count__c=Instructor.Active_Count__c - 1;
contactsToUpdate.add(instructor);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}

//CASE 5: if update, Active, and instructor change, old instructor -1
if(trigger.isUpdate){
Map<Id,Id> instructorsToOppsMap2 = new Map<Id,Id>();
for(Opportunity B: trigger.old)
           instructorsToOppsMap2.put(B.InstructorName__c,B.Id);
List<Contact> oldcontactsToUpdate = new List<Contact>();

for (Contact OldInstructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToOppsMap2.keySet()])
    {
        Id oppId = instructorsToOppsMap2.get(OldInstructor.Id);
        Opportunity opp = trigger.oldMap.get(oppId);

        boolean instructorchange = (trigger.newMap.get(opp.Id).InstructorName__c != opp.InstructorName__c);
if(opp.StageName=='Active'&& instructorchange){
OldInstructor.Active_Count__c=OldInstructor.Active_Count__c - 1;

oldcontactsToUpdate.add(OldInstructor);
}
}
if(oldcontactsToUpdate != null && !oldcontactsToUpdate.isEmpty())
Database.update(oldcontactsToUpdate);
}
if(trigger.isDelete){
{
Map<Id,Id> instructorsToOppsMap3 = new Map<Id,Id>();

for(Opportunity A : system.trigger.old)
           instructorsToOppsMap3.put(A.InstructorName__c,A.Id);
 
List<Contact> contactsToUpdate3 = new List<Contact>();
      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToOppsMap3.keySet()])

    {
        Id oppId = instructorsToOppsMap3.get(Instructor.Id);
        Opportunity opp = system.trigger.oldMap.get(oppId);
        
//CASE 6: if delete an Active class, instructor -1                   
                    if (opp.StageName=='Active'){
            Instructor.Active_Count__c=Instructor.Active_Count__c - 1;

             contactsToUpdate3.add(instructor);
      }
      }
if(contactsToUpdate3 != null && !contactsToUpdate3.isEmpty())
        Database.update(contactsToUpdate3);
}
}
}