trigger feedItemTrigger on FeedItem (after insert) { 
    
    if(Trigger.isInsert && Trigger.isAfter) {
    
        Set<Id> caseIds = new Set<Id>();
        List<FeedItem> feedItems = new List<FeedItem>();
        
        Set<Id> userIds  = new Set<Id>{UserInfo.getUserId()};
        System.debug('UserIds====='+userIds);
        
        for(FeedItem fi : trigger.new) {
         
            if (fi.ParentId.getSObjectType() == Case.SObjectType) {
        
                caseIds.add(fi.ParentId); 
                feedItems.add(fi);
            }
        }    
        System.debug('caseIds========'+caseIds+'caseIds SIZE========'+caseIds.size());
        System.debug('userIds========'+userIds+'userIds SIZE========'+userIds.size());
        System.debug('feedItems========'+feedItems+'feedItems SIZE========'+feedItems.size());
    
        if(feedItems.size() > 0){
                  
            Map<Id, Case> caseIdAndRec = new Map<Id, Case>();
            Set<Id> conIds = new Set<Id>();
            
            Map<Id, User> userRec = new Map<Id, User>([SELECT Id, FirstName, LastName, Name, IsPortalEnabled FROM User WHERE Id IN :userIds AND IsActive = TRUE]);
            System.debug('userRec========'+userRec+'userRec SIZE========'+userRec.size());
            
            for(Case c : [SELECT Id, Subject, CaseNumber, OwnerId, Owner.Name, Owner.Email, ContactId, Contact.Name, Contact.Email, Owner.Type FROM Case WHERE Id IN :caseIds AND ContactId != NULL ]){
                                            
                caseIdAndRec.put(c.Id, c);
                conIds.add(c.ContactId);
            }
            System.debug('caseIdAndRec========'+caseIdAndRec+'caseIdAndRec SIZE========'+caseIdAndRec.size());        
            System.debug('conIds========'+conIds+'conIds SIZE========'+conIds.size());
            
            if(caseIdAndRec.size() > 0){
                
                // Find the Case contact related to user Ids
                Map<Id, Id> conIdUserId = PlannedDaysOffHandler.getContactRelatedUsers(conIds); 
                System.debug('conIdUserId========'+conIdUserId+'conIdUserId SIZE========'+conIdUserId.size());
                
                List<Messaging.SingleEmailMessage> emailTosend = new List<Messaging.SingleEmailMessage>();
                
                for(FeedItem f : feedItems){
                    
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    
                    // Email Notification to Case Owner and FeedItem should be created by community user
                    if(userRec.containsKey(f.InsertedById) && userRec.get(f.InsertedById).IsPortalEnabled == TRUE){
                    
                        //Check for Case Owner Type because an email send to case owner and don't send an email to Queue                        
                        if(caseIdAndRec.containsKey(f.ParentId) && caseIdAndRec.get(f.ParentId).Owner.Type != 'Queue' && 
                            caseIdAndRec.get(f.ParentId).Owner.Email != NULL && userRec.get(f.InsertedById).Id != caseIdAndRec.get(f.ParentId).OwnerId
                        ){
                            
                            // Email send If FeedItem body dosn't have Case Owner Name
                            if(!f.body.toLowerCase().contains('@'+caseIdAndRec.get(f.ParentId).Owner.Name.toLowerCase())){
                                
                                msg.toAddresses = new List<String>{caseIdAndRec.get(f.ParentId).Owner.Email};
                                
                                msg.subject = 'A new comment has been posted on your case: '+ caseIdAndRec.get(f.ParentId).Subject;
                                
                                msg.HTMLBody = '';
                                msg.HTMLBody += '<b> Case Message</b>: '+f.body;
                                msg.HTMLBody += '<b> Created by</b>: ' +userRec.get(f.InsertedById).Name;
                                msg.HTMLBody += '<br/><b> Case Subject</b>: ' +caseIdAndRec.get(f.ParentId).Subject;
                                msg.HTMLBody += '<br/><b> Case Number</b>: '+'<a href="'+System.Label.Org_Prefix_Start_URL+'/'+caseIdAndRec.get(f.ParentId).Id+'" target="_blank">'+caseIdAndRec.get(f.ParentId).CaseNumber+'</a>';
                                msg.HTMLBody += '<br/><b> Contact Name</b>: '+'<a href="'+System.Label.Org_Prefix_Start_URL+'/'+caseIdAndRec.get(f.ParentId).ContactId+'" target="_blank">'+caseIdAndRec.get(f.ParentId).Contact.Name+'</a>';
                                emailTosend.add(msg);
                            }
                        }
                    }
                    
                    // Email Notification to Case Contact and FeedItem should be created by Internal user
                    if(userRec.containsKey(f.InsertedById) && userRec.get(f.InsertedById).IsPortalEnabled == FALSE){
                        
                        //Check for Case Contact Email because an email send to case contact 
                        if(caseIdAndRec.containsKey(f.ParentId) && caseIdAndRec.get(f.ParentId).Contact.Email != NULL && 
                            (!conIdUserId.containsKey(caseIdAndRec.get(f.ParentId).ContactId) || 
                            (conIdUserId.containsKey(caseIdAndRec.get(f.ParentId).ContactId) && conIdUserId.get(caseIdAndRec.get(f.ParentId).ContactId) != userRec.get(f.InsertedById).Id))
                        ){
                            
                            // Email send If FeedItem body dosn't have Case Contact Name
                            if(!f.body.toLowerCase().contains('@'+caseIdAndRec.get(f.ParentId).Contact.Name.toLowerCase())){
                            
                                msg.toAddresses = new List<String>{caseIdAndRec.get(f.ParentId).Contact.Email};
                                
                                msg.subject = 'A new comment has been posted on your case: '+ caseIdAndRec.get(f.ParentId).Subject;
                                
                                msg.HTMLBody = '';
                                msg.HTMLBody += '<b> Case Message</b>: '+f.body;
                                msg.HTMLBody += '<b> Created by</b>: ' +userRec.get(f.InsertedById).Name;
                                msg.HTMLBody += '<br/><b> Case Subject</b>: ' +caseIdAndRec.get(f.ParentId).Subject;
                                msg.HTMLBody += '<br/><b> Case Number</b>: '+'<a href="'+System.Label.Org_Prefix_Start_URL+'/'+caseIdAndRec.get(f.ParentId).Id+'" target="_blank">'+caseIdAndRec.get(f.ParentId).CaseNumber+'</a>';
                                msg.HTMLBody += '<br/><b> Contact Name</b>: '+'<a href="'+System.Label.Org_Prefix_Start_URL+'/'+caseIdAndRec.get(f.ParentId).ContactId+'" target="_blank">'+caseIdAndRec.get(f.ParentId).Contact.Name+'</a>';
                                emailTosend.add(msg);
                            }
                        }
                    }
                }
                System.debug('emailTosend=============='+emailTosend+'emailTosend SIZE====='+emailTosend.size());
                
                if(emailTosend.size() > 0) {
                
                    try{
                    
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailTosend);
                    }catch(Exception e) {
            
                        List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                        mail.setToAddresses(new String[] {'karthiga@softsquare.biz'});
                        mail.setSubject('Error on Case Owner notification when Feed Item Creation'); 
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
}