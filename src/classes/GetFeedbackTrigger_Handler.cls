public class GetFeedbackTrigger_Handler{

    /******
        - W-007606: Adjust GetFeedback Response Emails
        - This method is invoked from UpdateContactTrigger
        - Logic moved from workflow to here (Get_Feedback__c's trigger)
        - Get_Feedback__c Recordtypes used in this process: weekly_feedback / Monthly_Feedback_Survey / Ending_Feedback / End_of_Training_Evaluation_Instructor / VR_Survey
        ************/
    public static void sendResponseEmailToUser(List<Get_Feedback__c> gfListToSendResponseEmail, Set<Id> projIdsToSendResponseEmail, Map<Id, String> rtIdAndRTDevName){
       
        Set<String> groupNames = new Set<String>();
        Set<Id> userIds = new Set <Id>();
        
        Map<Id, AcctSeed__Project__c> projectRec = new Map<Id, AcctSeed__Project__c>();
        Map<Id, Set<Id>> groupIdAndUserIds = new Map<Id, Set<Id>>();
        Map<Id, String> userIdAndEmail = new Map<Id, String>();
        Map<Id, String> groupIdAndName = new Map<Id, String>();
        Map<String, Set<String>> groupNameAndEmails = new Map<String, Set<String>>();
        List<Get_Feedback__c> updateGetFeedbacks = new List<Get_Feedback__c>();
        
        Map<String, String> sectionNameAndGroupName = new Map<String, String>{
            'AA' => 'Group: AA',
            'MD' => 'Group: MD',
            'RA' => 'Group: RA',
            'EA' => 'Group: EA',
            'HRN' => 'Group: HRN'
        };
        
        for(AcctSeed__Project__c proj : [SELECT Id, Section__c, AcctSeed__Account__r.Name FROM AcctSeed__Project__c WHERE Id IN : projIdsToSendResponseEmail]){
            
            if(proj.Section__c != null && sectionNameAndGroupName.containsKey(proj.Section__c)){
                
                groupNames.add(sectionNameAndGroupName.get(proj.Section__c));
            }
            projectRec.put(proj.Id, proj);
        }
        
        for (GroupMember gm : [SELECT Id, GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Name IN : groupNames]){
            
            String userOrGroupId_Str = gm.UserOrGroupId;
            
            if (userOrGroupId_Str.startsWith('005')){
            
                userIds.add(gm.UserOrGroupId);  
                groupIdAndName.put(gm.GroupId, gm.Group.Name);
                
                if(!groupIdAndUserIds.containsKey(gm.GroupId)){
                    groupIdAndUserIds.put(gm.GroupId, new Set<Id>());
                }
                groupIdAndUserIds.get(gm.GroupId).add(gm.UserOrGroupId);
                
            }
        }
        
        if(userIds.size() > 0){
            
            for(User u : [SELECT Id, Email FROM User WHERE Id IN :userIds AND IsActive = True]){
            
                userIdAndEmail.put(u.Id, u.Email);
            }
        }
                
        for(Id gId : groupIdAndUserIds.keySet()){
            
            for(Id uId : groupIdAndUserIds.get(gId)){
                
                if(userIdAndEmail.containsKey(uId)){
                    
                    if(!groupNameAndEmails.containsKey(groupIdAndName.get(gId))){
                    
                        groupNameAndEmails.put(groupIdAndName.get(gId), new Set<String>());
                    }
                    groupNameAndEmails.get(groupIdAndName.get(gId)).add(userIdAndEmail.get(uId));
                }
            }
        }
        
        try{
                    
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
            Map<String, Id> emailTemplateNameAndId = new Map<String, Id>();
            List<String> defaultEmailAddress = new List<String>();
            List<String> doda_EmailAddress = new List<String>();
            List<String> dli_EmailAddress = new List<String>();
            
            System_Values__c toEmail_Default = System_Values__c.getValues('Get Feedback Response Email - Default'); 
            if (toEmail_Default != null && toEmail_Default.Value__c != null) {
                for (String st : toEmail_Default.Value__c.split(',')) {
                    defaultEmailAddress.add(st.trim());
                }
            }
            System_Values__c toEmail_DODA = System_Values__c.getValues('Get Feedback Response Email - DODA'); 
            if (toEmail_DODA != null && toEmail_DODA.Value__c != null) {
                for (String st : toEmail_DODA.Value__c.split(',')) {
                    doda_EmailAddress.add(st.trim());
                }
            }
            System_Values__c toEmail_DLI = System_Values__c.getValues('Get Feedback Response Email - DLI'); 
            if (toEmail_DLI != null && toEmail_DLI.Value__c != null) {
                for (String st : toEmail_DLI.Value__c.split(',')) {
                    dli_EmailAddress.add(st.trim());
                }
            }
                        
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                    
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
                
            for(EmailTemplate et : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN ('Getfeedback_response_to_user', 'Getfeedback_response_to_user_Monthly', 'Getfeedback_response_to_user_EOT', 'Instructor_Getfeedback_response_to_user_EOT', 'Getfeedback_Response_to_User_VR_Survey', 'Getfeedback_Response_to_User_DODA_EOT')]){
                
                emailTemplateNameAndId.put(et.DeveloperName, et.Id);      
            }
                                    
            for(Get_Feedback__c gf : gfListToSendResponseEmail){
                
                Id emailTemplateId;
                if(rtIdAndRTDevName.get(gf.RecordTypeId) == 'weekly_feedback'){
                    emailTemplateId = emailTemplateNameAndId.get('Getfeedback_response_to_user');
                }else if(rtIdAndRTDevName.get(gf.RecordTypeId) == 'Monthly_Feedback_Survey'){
                    emailTemplateId = emailTemplateNameAndId.get('Getfeedback_response_to_user_Monthly');
                }else if(rtIdAndRTDevName.get(gf.RecordTypeId) == 'Ending_Feedback'){
                    emailTemplateId = emailTemplateNameAndId.get('Getfeedback_response_to_user_EOT');  
                }else if(rtIdAndRTDevName.get(gf.RecordTypeId) == 'End_of_Training_Evaluation_Instructor'){
                    emailTemplateId = emailTemplateNameAndId.get('Instructor_Getfeedback_response_to_user_EOT');
                }else if(rtIdAndRTDevName.get(gf.RecordTypeId) == 'VR_Survey'){
                    emailTemplateId = emailTemplateNameAndId.get('Getfeedback_Response_to_User_VR_Survey');
                }else if(rtIdAndRTDevName.get(gf.RecordTypeId) == 'DODA_End_of_Training_Survey'){
                     emailTemplateId = emailTemplateNameAndId.get('Getfeedback_Response_to_User_DODA_EOT');
                }
                
                List<String> allEmailAddresses = new List<String>();
                allEmailAddresses.addAll(defaultEmailAddress);
                
                if(projectRec.containsKey(gf.Project__c)){
                    
                    if(projectRec.get(gf.Project__c).Section__c != null && 
                        sectionNameAndGroupName.containsKey(projectRec.get(gf.Project__c).Section__c) && 
                        groupNameAndEmails.containsKey(sectionNameAndGroupName.get(projectRec.get(gf.Project__c).Section__c))){
                        
                        Set<String> deptEmailAddress = groupNameAndEmails.get(sectionNameAndGroupName.get(projectRec.get(gf.Project__c).Section__c));
                        allEmailAddresses.addAll(deptEmailAddress);
                    }
                    
                    if(projectRec.get(gf.Project__c).AcctSeed__Account__r.Name != null){
                        if(projectRec.get(gf.Project__c).AcctSeed__Account__r.Name.contains('DODA')){
                        
                            allEmailAddresses.addAll(doda_EmailAddress);
                        }
                        if(projectRec.get(gf.Project__c).AcctSeed__Account__r.Name.contains('DLI')){
                        
                            allEmailAddresses.addAll(dli_EmailAddress);
                        }
                    }
                }
                //System.debug(':::allEmailAddresses:::'+allEmailAddresses);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(orgWideEmailId != null) {
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                }
                mail.setTemplateId(emailTemplateId);
                mail.setToAddresses(allEmailAddresses);
                // To fix the issue related to "System.EmailException: REQUIRED_FIELD_MISSING, Missing targetObjectId with template:"
                mail.setTargetObjectId(gf.Contact__c);
                // This method would make sure email will not be sent to user
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(gf.Id);
                sendEmailList.add(mail);
                
                //Workflow Field Update : Set Getfeedback send response flag true
                Get_Feedback__c getFeedback = new Get_Feedback__c();
                getFeedback.Id = gf.Id;
                getFeedback.Sent_Responce__c = True;
                updateGetFeedbacks.add(getFeedback);
            }
            System.debug(':sendEmailList:::'+sendEmailList);
            if(sendEmailList.size() > 0) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
            }
            // DML statement added here to prevent the updation of record if the response email doesn't send
            if(updateGetFeedbacks.size() > 0){
                update updateGetFeedbacks;
            }
        
        }catch(Exception e) {
                            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Get Feedback Response Email');
        }         
    }
}