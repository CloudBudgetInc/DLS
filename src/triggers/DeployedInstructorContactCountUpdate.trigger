trigger DeployedInstructorContactCountUpdate on Deployed_Instructor__c (after insert, after update, after delete) { 

if (trigger.isInsert){
Map<Id,Id> instructorsToDepsMap = new Map<Id,Id>();
for(Deployed_Instructor__c A : trigger.new)
           instructorsToDepsMap.put(A.Contact__c,A.Id);
 
List<Contact> contactsToUpdate = new List<Contact>();

      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToDepsMap.keySet()])
    {
        Id DepId = instructorsToDepsMap.get(Instructor.Id);
        Deployed_Instructor__c Dep = trigger.newMap.get(DepId);
        
        //boolean transition = trigger.IsInsert || (trigger.isUpdate && trigger.oldMap.get(Dep.Id).Status__c != Dep.Status__c);
        boolean Closedtransition = trigger.isUpdate && trigger.oldMap.get(Dep.Id).Status__c=='Deployed';
        
//CASE 1: if inserting a deployed instructor with status Deployed, update instructor +1        
if (Dep.Status__c=='Deployed'){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
contactsToUpdate.add(instructor);

//CASE 2: if insert and status To Be Deployed, instructor +1 (still reserve as busy)
}if (Dep.Status__c=='To Be Deployed'){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
contactsToUpdate.add(instructor);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}
if(trigger.isUpdate){
Map<Id,Id> instructorsToDepsMap = new Map<Id,Id>();
for(Deployed_Instructor__c A : trigger.new)
           instructorsToDepsMap.put(A.Contact__c,A.Id);
 
List<Contact> contactsToUpdate = new List<Contact>();
      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToDepsMap.keySet()])
    {
        Id DepId = instructorsToDepsMap.get(Instructor.Id);
        Deployed_Instructor__c Dep = trigger.newMap.get(DepId);
       
        boolean transitionfromactive = (trigger.oldMap.get(dep.Id).Status__c != dep.Status__c)&&(trigger.oldMap.get(dep.Id).Status__c!='No Longer Deployed')&&(trigger.oldMap.get(dep.Id).Status__c!='Replaced');
        boolean Deptransition = (trigger.oldMap.get(dep.Id).Status__c != dep.Status__c)&&(trigger.oldMap.get(dep.Id).Status__c!='To Be Deployed');
        boolean transitiontoactive = (trigger.oldMap.get(dep.Id).Status__c != dep.Status__c)&&(trigger.oldMap.get(dep.Id).Status__c != 'Deployed');
        
//CASE 3: update and Not Deployed to Deployed        
if (Dep.Status__c=='Deployed'&&Deptransition){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
contactsToUpdate.add(instructor);
}

//CASE 4: update and Not Deployed to To Be Deployed
if (Dep.Status__c=='To Be Deployed'&&transitiontoactive){
Instructor.Active_Count__c=Instructor.Active_Count__c + 1;
contactsToUpdate.add(instructor);
}

//CASE 5: update and Deployed to Not Deployed
if (Dep.Status__c!='Deployed' && (dep.Status__c!='To Be Deployed')&& transitionfromactive){
Instructor.Active_Count__c=Instructor.Active_Count__c - 1;
contactsToUpdate.add(instructor);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}
if(trigger.isDelete){
{
Map<Id,Id> instructorsToDepsMap3 = new Map<Id,Id>();

for(Deployed_Instructor__c A : system.trigger.old)
           instructorsToDepsMap3.put(A.Contact__c,A.Id);
 
List<Contact> contactsToUpdate3 = new List<Contact>();
      
    for (Contact Instructor: [SELECT Id,Active_Count__c FROM Contact WHERE Id IN:  instructorsToDepsMap3.keySet()])

    {
        Id DepId = instructorsToDepsMap3.get(Instructor.Id);
       Deployed_Instructor__c Dep = system.trigger.oldMap.get(DepId);
        
//CASE 6: if delete a deployed instructor with status "Deployed", instructor -1                   
                    if ((Dep.Status__c=='Deployed')||(Dep.Status__c=='To Be Deployed')){
                    Instructor.Active_Count__c=Instructor.Active_Count__c - 1;

             contactsToUpdate3.add(instructor);
       }
       }
if(contactsToUpdate3 != null && !contactsToUpdate3.isEmpty())
        Database.update(contactsToUpdate3);
}
}
}