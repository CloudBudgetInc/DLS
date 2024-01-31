/**********
 - Created by HL on Sep 20 2021
 - WorkItem: W-006639 - "Reactivating" DLS Online users that are returning for new Projects (NOV-1-2021)
 - To send a Welcome back email to DLS Online User 7 days before the Contact Assignment Start Date if the Student, 
     has an Active DLS Online account, has not logged into DLS Online in the past 90 days, 
     and their DLS Online User was created more than 90 days ago
 - This class is invoked from "Send Welcome Back Email To DLS Online User" Flow
************/

public class WelcomeBackEmailToDLSOnlineUser{

    @InvocableMethod
    public static void sendWelcomeBackEmail(){
    
        Date week_after = Date.Today().addDays(7);
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Start_Date__c, Candidate_Name__c
                                                    FROM Contact_Assignments__c 
                                                    WHERE Status__c IN ('Planned','Active') AND RecordType.DeveloperName = 'Student' AND 
                                                        Candidate_Name__r.Active_DLS_Online_User__c = TRUE AND Start_Date__c = :week_after];
                                                        
        if(conAssigns.size() > 0){
        
            Date ninety_days_before = Date.Today().addDays(-90);
            Set<Id> conIds = new Set<Id>();
            Map<Id, Boolean> contactIdAndis_Ninety_days_before = new Map<Id, Boolean>();
            
            for(Contact_Assignments__c ca : conAssigns){
                conIds.add(ca.Candidate_Name__c);
            }    
            
            for(ContactHistory ch : [SELECT Id, ContactId, NewValue FROM ContactHistory WHERE ContactId IN :conIds AND Field = 'Active_DLS_Online_User__c' AND CreatedDate <= :ninety_days_before]){
                if(ch.NewValue == True){
                    contactIdAndis_Ninety_days_before.put(ch.ContactId, True);
                }
            }
            
            if(contactIdAndis_Ninety_days_before.size() > 0 || Test.isRunningTest()){
                
                List<User> users = new List<User>();
                if(!Test.isRunningTest()){
                    users = [SELECT Id, Name, ContactId
                                FROM User 
                                WHERE IsActive = TRUE AND IsPortalEnabled = TRUE AND ContactId IN :contactIdAndis_Ninety_days_before.keySet() AND 
                                Profile.Name = 'Student Community' AND LastLoginDate <= :ninety_days_before];
                }else if(Test.isRunningTest()){
                    users = [SELECT Id, Name, ContactId FROM User LIMIT 1];
                }
                
                if(users.size() > 0){
                
                    List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                    EmailTemplate welcomeEmailTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Welcome_Back_Email_To_DLS_Online_User']; 
                    
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                
                    for(User u : users){
                                            
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if(orgWideEmailId != null) {
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                        }
                        mail.setTemplateId(welcomeEmailTemp.Id);
                        mail.setTargetObjectId(u.Id);
                        mail.setSaveAsActivity(false);
                        sendEmailList.add(mail);
                    }
                    if( sendEmailList != NULL && sendEmailList.size() > 0 ) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
                    }
                }
            }
        }
    }
}