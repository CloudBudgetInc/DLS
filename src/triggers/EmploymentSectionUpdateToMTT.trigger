trigger EmploymentSectionUpdateToMTT on Deployed_Instructor__c (after insert, after update, after delete) { 

if (trigger.isInsert){
Map<Id,Id> instructorsToDepsMap = new Map<Id,Id>();
for(Deployed_Instructor__c A : trigger.new)
           instructorsToDepsMap.put(A.Contact__c,A.Id);
 
List<Contact> contactsToUpdate = new List<Contact>();

      
    for (Contact Instructor: [SELECT Id, Employment_Section__c, Current_Account__c FROM Contact WHERE Id IN:  instructorsToDepsMap.keySet()])
    {
        Id DepId = instructorsToDepsMap.get(Instructor.Id);
        Deployed_Instructor__c Dep = trigger.newMap.get(DepId);
        
        //boolean transition = trigger.IsInsert || (trigger.isUpdate && trigger.oldMap.get(Dep.Id).Status__c != Dep.Status__c); //insert or update with a status change
        boolean Closedtransition = trigger.isUpdate && trigger.oldMap.get(Dep.Id).Status__c=='Deployed'; //update and status changed to closed
        
//CASE 1: if inserting a deployed instructor with status Deployed or To Be Deployed, and Location a Hub location, set Employment_Section__c to AFPAK Hubs
if((Dep.Status__c=='Deployed'||Dep.Status__c=='To Be Deployed')&&(Dep.Location__c=='NAS Oceana (HUB Norfolk), VA'||Dep.Location__c=='Tampa, FL')){
Instructor.Employment_Section__c='AFPAK Hubs';
Instructor.Current_Account__c='DLI';
Instructor.Instructor_Status__c='Employed';
Instructor.Next_Availability__c=Dep.End_Date__c;
contactsToUpdate.add(instructor);

//CASE 2: if inserting a deployed instructor at another location as Deployed or To Be Deployed, set Employment_Section__c to MTT
}
else if((Dep.Status__c=='Deployed'||Dep.Status__c=='To Be Deployed')){
Instructor.Employment_Section__c='MTT';
Instructor.Current_Account__c='DLI';
Instructor.Instructor_Status__c='Employed';
Instructor.Next_Availability__c=Dep.End_Date__c;
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
      
    for (Contact Instructor: [SELECT Id,Employment_Section__c, Current_Account__c FROM Contact WHERE Id IN:  instructorsToDepsMap.keySet()])
    {
        Id DepId = instructorsToDepsMap.get(Instructor.Id);
        Deployed_Instructor__c Dep = trigger.newMap.get(DepId);
       
        boolean Deptransition = (trigger.oldMap.get(dep.Id).Status__c != dep.Status__c)&&(trigger.oldMap.get(dep.Id).Status__c!='To Be Deployed');
        boolean transitiontoactive = (trigger.oldMap.get(dep.Id).Status__c != dep.Status__c)&&(trigger.oldMap.get(dep.Id).Status__c != 'Deployed');
        boolean Closedtransition = (trigger.oldMap.get(dep.Id).Status__c != dep.Status__c)&&((trigger.oldMap.get(dep.Id).Status__c != 'No Longer Deployed')||(trigger.oldMap.get(dep.Id).Status__c != 'Replaced'));
        boolean DateChange = (trigger.oldMap.get(dep.Id).End_Date__c != dep.End_Date__c);
        
//CASE 4: update and Not Deployed to Deployed and Hub location       
if (Dep.Status__c=='Deployed'&&(Deptransition||DateChange)&&
(Dep.Location__c=='NAS Oceana (HUB Norfolk), VA'||Dep.Location__c=='Tampa, FL')){
Instructor.Employment_Section__c='AFPAK Hubs';
Instructor.Current_Account__C='DLI';
Instructor.Instructor_Status__c='Employed';
Instructor.Next_Availability__c=Dep.End_Date__c;
contactsToUpdate.add(instructor);
}
//CASE 5: update and Not Deployed to Deployed and MTT location
else if (Dep.Status__c=='Deployed'&&(Deptransition||DateChange)){
Instructor.Employment_Section__c='MTT';
Instructor.Current_Account__c='DLI';
Instructor.Instructor_Status__c='Employed';
Instructor.Next_Availability__c=Dep.End_Date__c;
contactsToUpdate.add(instructor);
}
//CASE 6: update and Not Deployed to To Be Deployed, Hub Location
else if (Dep.Status__c=='To Be Deployed'&&(transitiontoactive||DateChange)&&
(Dep.Location__c=='NAS Oceana (HUB Norfolk), VA'||Dep.Location__c=='Tampa, FL')){
Instructor.Employment_Section__c='MTT';
Instructor.Current_Account__c='DLI';
Instructor.Instructor_Status__c='Employed';
Instructor.Next_Availability__c=Dep.End_Date__c;
contactsToUpdate.add(instructor);
}
//CASE 7: update and Not Deployed to To Be Deployed, MTT Location
else if (Dep.Status__c=='To Be Deployed'&&(transitiontoactive||DateChange)){
Instructor.Employment_Section__c='MTT';
Instructor.Current_Account__c='DLI';
Instructor.Instructor_Status__c='Employed';
Instructor.Next_Availability__c=Dep.End_Date__c;
contactsToUpdate.add(instructor);
}
//CASE 8: update and Deployed to Not Deployed
else if (Dep.Status__c=='No Longer Deployed'&&Closedtransition){
Instructor.Employment_Section__c=null;
Instructor.Current_Account__c=null;
Instructor.Instructor_Status__c='Available';
Instructor.Next_Availability__c=null;
contactsToUpdate.add(instructor);
}
//CASE 9: update and Deployed to replaced
else if (Dep.Status__c=='Replaced'&&Closedtransition){
Instructor.Employment_Section__c=null;
Instructor.Current_Account__c=null;
Instructor.Instructor_Status__c='Available';
Instructor.Next_Availability__c=null;
contactsToUpdate.add(instructor);
}
}
if(contactsToUpdate != null && !contactsToUpdate.isEmpty())
Database.update(contactsToUpdate);
}
if(trigger.isDelete){
Map<Id,Id> instructorsToDepsMap2 = new Map<Id,Id>();
for(Deployed_Instructor__c A : trigger.old)
           instructorsToDepsMap2.put(A.Contact__c,A.Id);
 
List<Contact> contactsToUpdate2 = new List<Contact>();

      
   for (Contact Instructor2: [SELECT Id, Employment_Section__c, Current_Account__c FROM Contact WHERE Id IN:  instructorsToDepsMap2.keySet()])
   {
        Id DepId = instructorsToDepsMap2.get(Instructor2.Id);
        Deployed_Instructor__c Dep = system.trigger.oldMap.get(DepId);
        
if (Dep.Status__c=='Deployed'){
Instructor2.Employment_Section__c=null;
Instructor2.Current_Account__c=null;
Instructor2.Instructor_Status__c='Available';
Instructor2.Next_Availability__c=null;
contactsToUpdate2.add(instructor2);
}
else if (Dep.Status__c=='To be Deployed'){
Instructor2.Employment_Section__c=null;
Instructor2.Current_Account__c=null;
Instructor2.Instructor_Status__c='Available';
Instructor2.Next_Availability__c=null;
contactsToUpdate2.add(instructor2);
}
}
if(contactsToUpdate2 != null && !contactsToUpdate2.isEmpty())
Database.update(contactsToUpdate2);
}
}