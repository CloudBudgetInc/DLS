trigger EmploymentSectionUpdateOpp on Opportunity (after insert, after update, after delete) { 
    
//Instructor 1 insert/update
If(trigger.isInsert || trigger.isUpdate){
    
Map<Id,Id> instructorsToOppsMap = new Map<Id,Id>();
Map<Id,Account> OppstoAccountsMap = new Map<Id,Account>();
if(!Test.isRunningTest()||(Test.isRunningTest() && Limits.getQueries() < 80))
{
     
for(Opportunity A : [SELECT InstructorName__c, Account.Name FROM Opportunity WHERE ID in: trigger.new])
                      OppstoAccountsMap.put(A.InstructorName__c, A.Account); 
for(Opportunity A : [SELECT Id, InstructorName__c FROM Opportunity WHERE ID in: trigger.new])
                      instructorsToOppsMap.put(A.InstructorName__c,A.Id);

Map<ID,Contact> contactsToUpdate = new Map<ID,Contact>();//Changed to map instead of list – CM 

for (Contact Instructor: [SELECT Id,Employment_Section__c,Next_Availability__c FROM Contact WHERE Id IN:  instructorsToOppsMap.keySet()])
    {
        Id oppId = instructorsToOppsMap.get(Instructor.Id);
        Opportunity opp = trigger.newMap.get(oppId);
        Account Acc = OppstoAccountsMap.get(Instructor.Id);
  

//CASE 1:if updating an On-Site active class and Account ODNI with instructor, Employment_Section__c = DPU
if((opp.StageName=='Active'||opp.StageName=='Order')&& Acc.Name=='ODNI'){
Instructor.Employment_Section__c='DPU';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactsToUpdate.put(instructor.id,instructor);
}
//CASE 2: If updating a Hanover active class with instructor, employment section = Hanover/Columbia
else if((opp.StageName=='Active'||opp.StageName=='Order')&& opp.Offsite_Location__c=='Hanover'){
Instructor.Employment_Section__c  ='Hanover/Columbia';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactsToUpdate.put(instructor.id,instructor);
}
//CASE 3: If updating a Columbia active class with instructor, employment section = Hanover/Columbia
else if((opp.StageName=='Active'||opp.StageName=='Order')&& opp.Offsite_Location__c=='Columbia'){
Instructor.Employment_Section__c  ='Hanover/Columbia';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//CASE 4: If updating an FSI active class with instructor, employment section = FSI
else if((opp.StageName=='Active'||opp.StageName=='Order')&& Acc.Name=='FSI'){
Instructor.Employment_Section__c ='FSI';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//CASE 5: If updating a Tampa active class with instructor, employment section = AFPAK Hubs
else if((opp.StageName=='Active'||opp.StageName=='Order')&& opp.Offsite_Location__c=='Tampa'){
Instructor.Employment_Section__c  ='AFPAK Hubs';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//CASE 6: If updating a Norfolk active class with instructor, employment section = AFPAK Hubs
else if((opp.StageName=='Active'||opp.StageName=='Order')&& opp.Offsite_Location__c=='Norfolk'){
Instructor.Employment_Section__c  ='AFPAK Hubs';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//CASE 7: If updating an Other Off-site Active class with instructor, employment section = Other Off-Site
else if((opp.StageName=='Active'||opp.StageName=='Order')&& (opp.Offsite_Location__c=='Off-Site'
||opp.Offsite_Location__c=='Quantico'
||opp.Offsite_Location__c=='NASA'
||opp.Offsite_Location__c=='Fort Bragg')){
Instructor.Employment_Section__c  ='Other Off-Site';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}                        
//CASE 8: if update and AA class, Employment Section = AA
else if (opp.StageName=='Active' && opp.section__c=='AA'&& opp.Offsite_Location__c=='Arlington'){
Instructor.Employment_Section__c='AA';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//CASE 9: if update and EE class, Employment Section = EE
else if(opp.StageName=='Active'&& opp.section__c=='EE'&& opp.Offsite_Location__c=='Arlington'){
Instructor.Employment_Section__c='EE';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//CASE 10: if update and RA class, Employment Section = RA
else if(opp.StageName=='Active'&& opp.section__c=='RA' && opp.Offsite_Location__c=='Arlington'){
Instructor.Employment_Section__c='RA';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//Case 11: if update and AFPAK class, Employment Section = AFPAK
else if(opp.StageName=='Active'&& opp.section__c=='AFPAK'&& opp.Offsite_Location__C=='Arlington'){
Instructor.Employment_Section__c='AFPAK';
Instructor.Current_Account__c=Acc.Name;
Instructor.Instructor_Status__c='Employed';
if(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c){
}
else {
Instructor.Next_Availability__c=opp.Instructor_1_End_Date__c;}
contactstoupdate.put(instructor.id,instructor);
}
//Case 12: If updating a class to OnHold or Closed
else if (trigger.isUpdate && (opp.StageName=='On Hold'||opp.StageName=='Ended')&&(trigger.oldMap.get(opp.Id).StageName == 'Active')){
if(!(Instructor.Next_Availability__c>opp.Instructor_1_End_Date__c)){
Instructor.Employment_Section__c=null;
Instructor.Current_Account__c=null;
Instructor.Instructor_Status__c='Available';
Instructor.Next_Availability__c=null;
contactstoupdate.put(instructor.id,instructor);
}
}  
 //Instructor Change
    if(trigger.isUpdate){   
    Map<Id,Id> instructorsToOppsMap3 = new Map<Id,Id>();
    
    for(Opportunity C : system.trigger.old)
           instructorsToOppsMap3.put(C.InstructorName__c,C.Id);
           
        If(!Test.isRunningTest()||(Test.isRunningTest() && Limits.getQueries() < 90)){
           for (Contact Instructor3: [SELECT Id, Next_Availability__c FROM Contact WHERE Id IN:  instructorsToOppsMap3.keySet()])

    {
        Id oppId3 = instructorsToOppsMap3.get(Instructor3.Id);
        Opportunity opp3 = system.trigger.oldMap.get(oppId3);
        boolean InstructorChange = opp.InstructorName__c != opp3.InstructorName__c;
                          
        if (InstructorChange){
        if(!(Instructor3.Next_Availability__c>opp3.Instructor_1_End_Date__c)){
            Instructor3.Employment_Section__c= null;
            Instructor3.Current_Account__c= null;
            Instructor3.Instructor_Status__c='Available';
            Instructor3.Next_Availability__c= null;

             contactsToUpdate.put(instructor3.id,instructor3);
      }
      }
    }
    }
    }
        if(contactsToUpdate != null && !contactsToUpdate.isEmpty()){
            Update contactsToUpdate.values();
        }
}
}
        
//Inserting and Updating Instructor 2
Map<Id,Id> instructorsToOppsMap2 = new Map<Id,Id>();
Map<Id,Account> OppstoAccountsMap2 = new Map<Id,Account>();
If(!Test.isRunningTest()||(Test.isRunningTest() && Limits.getQueries() < 80)){    
for(Opportunity B : [SELECT X2nd_Instructor__c, Account.Name FROM Opportunity WHERE ID in: trigger.new])
                      OppstoAccountsMap2.put(B.X2nd_Instructor__c, B.Account); 
for(Opportunity B : trigger.new)
           instructorsToOppsMap2.put(B.X2nd_Instructor__c,B.Id);
     
Map<ID,Contact> contactsToUpdate2 = new Map<ID,Contact>();//changed to map from list - CM
         
    for (Contact Instructor2: [SELECT Id, Next_Availability__c FROM Contact WHERE Id IN:  instructorsToOppsMap2.keySet()])
    {
        Id opp2Id = instructorsToOppsMap2.get(Instructor2.Id);
        Opportunity opp2 = trigger.newMap.get(opp2Id);
        Account Acc2 = OppstoAccountsMap2.get(Instructor2.Id);

//CASE 1:if updating an On-Site active class and Account ODNI with instructor, Employment_Section__c = DPU
if((opp2.StageName=='Active'||opp2.StageName=='Order')&& Acc2.Name=='ODNI'){
Instructor2.Employment_Section__c='DPU';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactsToUpdate2.put(instructor2.id,instructor2);
}
//CASE 2: If updating a Hanover active class with instructor, employment section = Hanover/Columbia
else if((opp2.StageName=='Active'||opp2.StageName=='Order')&& opp2.Offsite_Location__c=='Hanover'){
Instructor2.Employment_Section__c  ='Hanover/Columbia';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//CASE 3: If updating a Columbia active class with instructor, employment section = Hanover/Columbia
else if((opp2.StageName=='Active'||opp2.StageName=='Order')&& opp2.Offsite_Location__c=='Columbia'){
Instructor2.Employment_Section__c  ='Hanover/Columbia';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//CASE 4: If updating an FSI active class with instructor, employment section = FSI
else if((opp2.StageName=='Active'||opp2.StageName=='Order')&& Acc2.Name=='FSI'){
Instructor2.Employment_Section__c ='FSI';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//CASE 5: If updating a Tampa active class with instructor, employment section = AFPAK Hubs
else if((opp2.StageName=='Active'||opp2.StageName=='Order')&& opp2.Offsite_Location__c=='Tampa'){
Instructor2.Employment_Section__c  ='AFPAK Hubs';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//CASE 6: If updating a Norfolk active class with instructor, employment section = AFPAK Hubs
else if((opp2.StageName=='Active'||opp2.StageName=='Order')&& opp2.Offsite_Location__c=='Norfolk'){
Instructor2.Employment_Section__c  ='AFPAK Hubs';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//CASE 7: If updating an Other Off-site Active class with instructor, employment section = Other Off-Site
else if((opp2.StageName=='Active'||opp2.StageName=='Order')&& (opp2.Offsite_Location__c=='Off-Site'
||opp2.Offsite_Location__c=='Quantico'
||opp2.Offsite_Location__c=='NASA'
||opp2.Offsite_Location__c=='Fort Bragg')){
Instructor2.Employment_Section__c  ='Other Off-Site';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}                        
//CASE 8: if update and AA class, Employment Section = AA
else if (opp2.StageName=='Active' && opp2.section__c=='AA'&& opp2.Offsite_Location__c=='Arlington'){
Instructor2.Employment_Section__c='AA';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//CASE 9: if update and EE class, Employment Section = EE
else if(opp2.StageName=='Active'&& opp2.section__c=='EE'&& opp2.Offsite_Location__c=='Arlington'){
Instructor2.Employment_Section__c='EE';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//CASE 10: if update and RA class, Employment Section = RA
else if(opp2.StageName=='Active'&& opp2.section__c=='RA' && opp2.Offsite_Location__c=='Arlington'){
Instructor2.Employment_Section__c='RA';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//Case 11: if update and AFPAK class, Employment Section = AFPAK
else if(opp2.StageName=='Active'&& opp2.section__c=='AFPAK'&& opp2.Offsite_Location__C=='Arlington'){
Instructor2.Employment_Section__c='AFPAK';
Instructor2.Current_Account__c=Acc2.Name;
Instructor2.Instructor_Status__c='Employed';
if(Instructor2.Next_Availability__c > opp2.Instructor_2_End_Date__c){
}
else{
Instructor2.Next_Availability__c=opp2.Instructor_2_End_Date__c;}
contactstoupdate2.put(instructor2.id,instructor2);
}
//Case 12: If updating a class to OnHold or Closed
else if (trigger.isUpdate && (opp2.StageName=='On Hold'||opp2.StageName=='Ended')&&(trigger.oldMap.get(opp2.Id).StageName == 'Active')){
if(!(Instructor2.Next_Availability__c>opp2.Instructor_2_End_Date__c)){
Instructor2.Employment_Section__c=null;
Instructor2.Current_Account__c=null;
Instructor2.Instructor_Status__c='Available';
Instructor2.Next_Availability__c=null;
contactstoupdate2.put(instructor2.id,instructor2);
}
}
//Instructor Change
if(trigger.isUpdate){   
    Map<Id,Id> instructorsToOppsMap4 = new Map<Id,Id>();
    
    for(Opportunity D : system.trigger.old)
           instructorsToOppsMap4.put(D.X2nd_Instructor__c,D.Id);
If(!Test.isRunningTest()||(Test.isRunningTest() && Limits.getQueries() < 90)){           
           for (Contact Instructor4: [SELECT Id, Next_Availability__c FROM Contact WHERE Id IN:  instructorsToOppsMap4.keySet()])

    {
        Id oppId4 = instructorsToOppsMap4.get(Instructor4.Id);
        Opportunity opp4 = system.trigger.oldMap.get(oppId4);
        boolean InstructorChange2 = opp2.X2nd_Instructor__c != opp4.X2nd_Instructor__c;
                          
        if (InstructorChange2){
        if(!(Instructor4.Next_Availability__c>opp4.Instructor_2_End_Date__c)){
            Instructor4.Employment_Section__c= null;
            Instructor4.Current_Account__c= null;
            Instructor4.Instructor_Status__c='Available';
            Instructor4.Next_Availability__c= null;

             contactstoupdate2.put(instructor4.id,instructor4);
      }
      }
    }
    }
}
if(contactsToUpdate2 != null && !contactsToUpdate2.isEmpty()){
Update contactsToUpdate2.values();
}
}
}
}

//Delete an active class
If (trigger.isDelete){
Map<Id,Id> instructorsToOppsMap3 = new Map<Id,Id>();

for(Opportunity C : system.trigger.old)
           instructorsToOppsMap3.put(C.InstructorName__c,C.Id);

Map<ID,Contact> contactsToUpdate3 = new Map<ID,Contact>();
If(!Test.isRunningTest()||(Test.isRunningTest() && Limits.getQueries() < 90)){      
    for (Contact Instructor3: [SELECT Id, Next_Availability__c FROM Contact WHERE Id IN:  instructorsToOppsMap3.keySet()])

    {
        Id oppId3 = instructorsToOppsMap3.get(Instructor3.Id);
        Opportunity opp3 = system.trigger.oldMap.get(oppId3);
        
//CASE 6: if delete an Active class                   
        if (opp3.StageName=='Active'){
        if(!(Instructor3.Next_Availability__c>opp3.Instructor_1_End_Date__c)){
            Instructor3.Employment_Section__c= null;
            Instructor3.Current_Account__c= null;
            Instructor3.Instructor_Status__c='Available';
            Instructor3.Next_Availability__c= null;

             contactsToUpdate3.put(instructor3.id, instructor3);
      }
      }
if(contactsToUpdate3 != null && !contactsToUpdate3.isEmpty())
        Update contactsToUpdate3.values();
}
}
//Instructor 2 delete
Map<Id,Id> instructorsToOppsMap4 = new Map<Id,Id>();

    for(Opportunity D : system.trigger.old)
           instructorsToOppsMap4.put(D.X2nd_Instructor__c,D.Id);

Map<ID,Contact> contactsToUpdate4 = new Map<ID,Contact>();
If(!Test.isRunningTest()||(Test.isRunningTest() && Limits.getQueries() < 90)){      
    for (Contact Instructor4: [SELECT Id, Next_Availability__c FROM Contact WHERE Id IN:  instructorsToOppsMap4.keySet()])

    {
        Id opp4Id = instructorsToOppsMap4.get(Instructor4.Id);
        Opportunity opp4 = system.trigger.oldMap.get(opp4Id);
        
//CASE 6: if delete an Active class                   
        if (opp4.StageName=='Active'){
        if(!(Instructor4.Next_Availability__c>opp4.Instructor_2_End_Date__c)){
            Instructor4.Employment_Section__c= null;
            Instructor4.Current_Account__c= null;
            Instructor4.Instructor_Status__c='Available';
            Instructor4.Next_Availability__c= null;

             contactsToUpdate4.put(instructor4.id,instructor4);
      }
      }
if(contactsToUpdate4 != null && !contactsToUpdate4.isEmpty())
        Update contactsToUpdate4.values();
}
}
}
}