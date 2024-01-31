/***********************************************************************************
        - Send Email to the Contract Users ( Contracts public group)
        - Work Item : W-002115
        - An e-mail notification to the contracts public group to reminding that the Contract is ending
        - This scheduler class runs daily basis 
        - Email Template : HTML
        - Created by HL on Jul 15 2019 
    *****************************************************************************************/
global class ContractEndingEmailNotification implements Schedulable{

    global void execute(SchedulableContext SC) {
            
        Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id, Name, ContractNumber FROM Contract WHERE EndDate = TODAY AND EndDate != NULL]);
        System.debug('contractMap==='+contractMap+'contractMap SIZE=='+contractMap.size());
        
        if(contractMap.size() > 0){
        
            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
            List<String> mailToAddresses = new List<String>();
            Set<Id> userIds = new Set<Id>();
            
            Group g = [SELECT (SELECT UserOrGroupId from GroupMembers) FROM group WHERE Name = 'Contracts'];
            System.debug('GROUP==='+g);
            
            for (GroupMember gm : g.groupMembers) {
                userIds.add(gm.userOrGroupId);
            }
        
            List<User> users = [SELECT Email FROM user WHERE Id IN :userIds];
            System.debug('USER==='+users+'USER SIZE=='+users.size());
            
            for(User u : users) {
                mailToAddresses.add(u.Email);
            }
            System.debug('mailToAddresses==='+mailToAddresses+'mailToAddresses SIZE=='+mailToAddresses.size());
        
            
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Contracts'];
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
                        
            if(mailToAddresses.size() > 0){
            
                try{
                
                    for(Id cId : contractMap.keySet()){
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        if(orgWideEmailId != NULL) {
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                        }
                        
                        String cName;
                        if(contractMap.get(cId).Name != NULL){
                            cName = contractMap.get(cId).Name;
                        }else{
                            cName = contractMap.get(cId).ContractNumber;
                        }
                        
                        mail.subject = 'Contract Ending Today - '+cName;
                        String htmlBody = '';
                        htmlBody  += 'Dear Contracts User, <br/><br/>';
                        htmlBody += 'The following Contract is scheduled to end today. <br/><br/>';
                        htmlBody += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+ contractMap.get(cId).Id +'" target="_blank">'+ cName +'</a><br/>';
                        htmlBody += '<br/>System Generated Email';
                        mail.setHtmlBody(htmlBody);
                        mail.setWhatId(cId);
                        mail.setToAddresses(mailToAddresses);
                        mail.setSaveAsActivity(TRUE);
                        mailsToSend.add(mail);
                    }
                    System.debug('mailsToSend==='+mailsToSend+'mailsToSend SIZE=='+mailsToSend.size());
                    
                    if(mailsToSend.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(mailsToSend);
                    }
                }catch(Exception e) {
                
                    List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
                    mail.setSubject('Error on Contract Ending Email Notification'); 
                    mail.setPlainTextBody(e.getMessage());
                    ErrorMailMsg.add(mail);
                    try{
                        if( ErrorMailMsg != NULL && ErrorMailMsg.size() > 0 ){
                            Messaging.sendEmail(ErrorMailMsg); 
                        }
                    } catch (Exception ex){
                        system.debug('Ex::::'+ex);
                    }    
                }
            }
        }
    }
}