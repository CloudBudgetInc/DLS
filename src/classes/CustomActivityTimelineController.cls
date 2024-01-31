public with sharing class CustomActivityTimelineController {
    @AuraEnabled
    public static String getActivities(String recordId){

        try{
            System.debug('recordId: '+recordId);
            ActivityTimelineWrapper timelineWrapperInstance = new ActivityTimelineWrapper();
            Id parentId = Id.valueOf(recordId);
            String objectName = String.valueOf(parentId.getSObjectType());
            String query = 'SELECT Id , Name, (Select Id,Subject,ActivityType,ActivitySubtype,Description,ActivityDate,ActivityDateTime,StartDateTime,EndDateTime,CompletedDateTime , IsAllDayEvent FROM ActivityHistories ORDER BY ActivityDate DESC, LastModifiedDate DESC NULLS FIRST LIMIT 500) FROM ' + objectName + ' WHERE Id = :parentId';

            List<SObject> sobjectActivities = Database.query(query);
            List<ActivityHistory> activityHistoriesList = (List<ActivityHistory>) sobjectActivities[0].getSObjects('ActivityHistories');
            if(activityHistoriesList == null){
                timelineWrapperInstance.activityWrapperWithStringMap.put('No Activities',new List<ActivitiesWrapper>{});
            }
            else{
                timelineWrapperInstance.Name = (String) sobjectActivities[0].get('Name');
                
                Map<Id,EmailMessage> emailMessageWithActivityId = new Map<Id,EmailMessage>();
                Set<Id> emailMessageIds = new Set<Id>();
            
                for(ActivityHistory activityHistory : activityHistoriesList){
                    emailMessageIds.add(activityHistory.Id);
                }
            
                for(EmailMessage emailMessageInstance : [SELECT Id , ActivityId , FromAddress , ToAddress , LastOpenedDate , HasAttachment FROM EmailMessage WHERE ActivityId IN :emailMessageIds]){
                    emailMessageWithActivityId.put(emailMessageInstance.ActivityId , emailMessageInstance);
                }
            
                List<ActivitiesWrapper> activitiesWrapperInstance = new List<ActivitiesWrapper>();
            
                Map<String,List<ActivitiesWrapper>> activityWrapperWithStringMap = new Map<String,List<ActivitiesWrapper>>();

                for(ActivityHistory activityHistory : activityHistoriesList){
                    ActivitiesWrapper wrapperInstance = new ActivitiesWrapper();
                    wrapperInstance.activityId = activityHistory.Id;
                    wrapperInstance.subject = activityHistory.Subject != null ? activityHistory.Subject : '[No Subject]';
                    wrapperInstance.description = activityHistory.Description;
                    wrapperInstance.activitySubType = activityHistory.ActivitySubtype;            
                
                    if(activityHistory.ActivitySubtype == 'Task'){
                        wrapperInstance.cssClass = 'slds-timeline__item_expandable slds-timeline__item_task';
                        wrapperInstance.iconName = 'standard:task';
                        wrapperInstance.activityString = 'You had a task';
                        wrapperInstance.dateFieldsWrapperInstance = populateDateFields(activityHistory.ActivitySubtype , activityHistory.CompletedDateTime , false);
                    }
                    else if(activityHistory.ActivitySubtype == 'Email'){
                        wrapperInstance.activityId = emailMessageWithActivityId.get(activityHistory.Id).Id;
                        wrapperInstance.subject = activityHistory.Subject.substring(6,activityHistory.Subject.length());
                        wrapperInstance.cssClass = 'slds-timeline__item_expandable slds-timeline__item_email';
                        wrapperInstance.iconName = 'standard:email';
                    
                        if(emailMessageWithActivityId.get(activityHistory.Id).FromAddress == UserInfo.getUserEmail()){
                            wrapperInstance.fromAddress = 'You';
                        }
                    
                        else{
                            wrapperInstance.fromAddress = emailMessageWithActivityId.get(activityHistory.Id).FromAddress;
                        }
                    
                        if(emailMessageWithActivityId.get(activityHistory.Id).LastOpenedDate == null){
                            wrapperInstance.isUnOpened = true;
                            wrapperInstance.lastOpenedDate = 'Unopened';
                        }
                        else{
                            wrapperInstance.isUnOpened = false;
                            Integer daysBetween = emailMessageWithActivityId.get(activityHistory.Id).LastOpenedDate.date().daysBetween(System.today());
                            if( daysBetween == 0 ){
                                wrapperInstance.lastOpenedDate = 'Last Opened Today';
                            }
                            else if( daysBetween == 1 ){
                                wrapperInstance.lastOpenedDate = 'Last Opened Yesterday';
                            }
                            else if( daysBetween <=7 ) {
                                wrapperInstance.lastOpenedDate = 'Last Opened ' + String.valueOf(daysBetween) + ' days ago';
                            }
                            else {
                                wrapperInstance.lastOpenedDate = 'Last Opened ' +  emailMessageWithActivityId.get(activityHistory.Id).LastOpenedDate.format('MMM') + ' ' + String.valueOf(emailMessageWithActivityId.get(activityHistory.Id).LastOpenedDate.date()).split('-')[2];
                            }
                        }
                        wrapperInstance.activityString = ' sent an email to ';
                        String description = wrapperInstance.description;
                        String toAddress = emailMessageWithActivityId.get(activityHistory.Id).ToAddress;
                        List<String> toAddresses = toAddress.split(';');
                        wrapperInstance.toAddress = toAddresses[0];
                        if(emailMessageWithActivityId.get(activityHistory.Id).FromAddress != UserInfo.getUserEmail()){
                            if(toAddresses.size() > 1){
                                wrapperInstance.activityString = ' and ' + Integer.valueOf(toAddresses.size() - 1) + ' other';
                            }
                            else  if(toAddresses.size() == 1){
                                wrapperInstance.activityString = '';
                            }
                        }
                        wrapperInstance.mailSubject = description.substringAfter('Body:');
                        wrapperInstance.hasAttachment = emailMessageWithActivityId.get(activityHistory.Id).HasAttachment;
                        wrapperInstance.dateFieldsWrapperInstance = populateDateFields(activityHistory.ActivitySubtype , activityHistory.CompletedDateTime , false);
                    }
                    else if(activityHistory.ActivitySubtype == 'Call'){
                        wrapperInstance.cssClass = 'slds-timeline__item_expandable slds-timeline__item_call';
                        wrapperInstance.iconName = 'standard:log_a_call';
                        wrapperInstance.activityString = 'You logged a call';
                        wrapperInstance.dateFieldsWrapperInstance = populateDateFields(activityHistory.ActivitySubtype , activityHistory.CompletedDateTime , false);
                    }
                    else if(activityHistory.ActivitySubtype == 'Event'){
                        wrapperInstance.cssClass = 'slds-timeline__item_expandable slds-timeline__item_event';
                        wrapperInstance.iconName = 'standard:event';
                        wrapperInstance.eventStartDateInMilliSeconds = activityHistory.StartDateTime.getTime();
                        wrapperInstance.eventEndDateInMilliSeconds = activityHistory.EndDateTime.getTime();
                        wrapperInstance.activityString = 'You had an event';
                        wrapperInstance.dateFieldsWrapperInstance = populateDateFields(activityHistory.ActivitySubtype , activityHistory.StartDateTime , activityHistory.IsAllDayEvent);
                    }
                
                    if(timelineWrapperInstance.activityWrapperWithStringMap.get(wrapperInstance.dateFieldsWrapperInstance.monthAndYearAsString) == null){
                        timelineWrapperInstance.activityWrapperWithStringMap.put(wrapperInstance.dateFieldsWrapperInstance.monthAndYearAsString,new List<ActivitiesWrapper>{wrapperInstance});
                    }
                
                    else{
                        timelineWrapperInstance.activityWrapperWithStringMap.get(wrapperInstance.dateFieldsWrapperInstance.monthAndYearAsString).add(wrapperInstance);
                    }
                }
            }
            
            System.debug('timelineWrapperInstance: '+JSON.serialize(timelineWrapperInstance));

            String label = 'Upcoming & Overdue';

            String taskQuery = 'SELECT Id, Subject, ActivityDate, Status, Type, IsClosed, TaskSubtype, CompletedDateTime FROM Task WHERE IsClosed = false AND ( WhoId = :parentId OR WhatId = :parentId) ORDER BY ActivityDate ASC NULLS FIRST';

            for(Task taskInstance : Database.query(taskQuery)){
                ActivitiesWrapper wrapperInstance = new ActivitiesWrapper();
                wrapperInstance.activityId = taskInstance.Id;
                wrapperInstance.subject = taskInstance.Subject != null ? taskInstance.Subject : '[No Subject]';
                wrapperInstance.cssClass = 'slds-timeline__item_expandable slds-timeline__item_task';
                wrapperInstance.iconName = 'standard:task';
                wrapperInstance.activitySubType = 'Task';
                wrapperInstance.activityString = 'You have an upcoming task';
                wrapperInstance.dateFieldsWrapperInstance = new DateFieldsWrapper();
                wrapperInstance.dateFieldsWrapperInstance.activityDateAsStringClass = 'slds-timeline__date';
                if(taskInstance.ActivityDate != null){
                    wrapperInstance.dateFieldsWrapperInstance = populateDateFields('Task' , taskInstance.ActivityDate , false);
                    if(taskInstance.ActivityDate < System.today()){
                        wrapperInstance.dateFieldsWrapperInstance.activityDateAsStringClass += ' overdueRed';
                    }
                }
                else if (taskInstance.ActivityDate == null){
                    wrapperInstance.dateFieldsWrapperInstance.activityDateAsString = 'No due date';
                    
                }
                if(timelineWrapperInstance.activityWrapperWithStringMap.get(label) == null){
                    timelineWrapperInstance.activityWrapperWithStringMap.put(label,new List<ActivitiesWrapper>{wrapperInstance});
                }
                else{
                    timelineWrapperInstance.activityWrapperWithStringMap.get(label).add(wrapperInstance);
                }
            }

            Datetime dt = System.now();
            String eventQuery = 'SELECT Id , Subject, ActivityDateTime, StartDateTime, EndDateTime , IsAllDayEvent FROM Event WHERE ( WhoId = :parentId OR WhatId = :parentId) AND ActivityDateTime > :dt ORDER BY ActivityDateTime ASC NULLS FIRST';

            for(Event eventInstance : Database.query(eventQuery)){
                ActivitiesWrapper wrapperInstance = new ActivitiesWrapper();
                wrapperInstance.activityId = eventInstance.Id;
                wrapperInstance.subject = eventInstance.Subject != null ? eventInstance.Subject : '[No Subject]';
                wrapperInstance.cssClass = 'slds-timeline__item_expandable slds-timeline__item_event';
                wrapperInstance.iconName = 'standard:event';
                wrapperInstance.activitySubType = 'Event';
                wrapperInstance.eventStartDateInMilliSeconds = eventInstance.StartDateTime.getTime();
                wrapperInstance.eventEndDateInMilliSeconds = eventInstance.EndDateTime.getTime();
                wrapperInstance.activityString = 'You have an upcoming event';
                wrapperInstance.dateFieldsWrapperInstance = populateDateFields('Event' , eventInstance.ActivityDateTime , eventInstance.IsAllDayEvent);
                if(timelineWrapperInstance.activityWrapperWithStringMap.get(label) == null){
                    timelineWrapperInstance.activityWrapperWithStringMap.put(label,new List<ActivitiesWrapper>{wrapperInstance});    
                }
                else{
                    timelineWrapperInstance.activityWrapperWithStringMap.get(label).add(wrapperInstance);
                }
            }
            if(timelineWrapperInstance.activityWrapperWithStringMap.get(label) ==  null){
                timelineWrapperInstance.activityWrapperWithStringMap.put(label,new List<ActivitiesWrapper>{});
            }
            return JSON.serialize(timelineWrapperInstance);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static DateFieldsWrapper populateDateFields(String activitySubType , Datetime activityDateTime , Boolean isAllDayEvent){

        DateFieldsWrapper dateFieldsWrapperInstance = new DateFieldsWrapper();

        Date activityDate = activityDateTime.date();
        Time activityTime = activityDateTime.time();

        if(activityDate == System.today()){
            dateFieldsWrapperInstance.activityDateAsString = 'Today';
        }
        if(activityDate == System.today().addDays(-1)){
            dateFieldsWrapperInstance.activityDateAsString = 'Yesterday';
        }

        String day = String.valueOf(activityDate).split('-')[2];
        Integer month = activityDate.month();
        Integer year = activityDate.year();
        Integer hour = activityTime.hour();
        Integer minute = activityTime.minute();

        String meridian;

        if(hour == 0 ){
            hour = 12;
            meridian = 'AM';
        }
        else if(hour == 12){
            meridian = 'PM';
        }
        else if(hour < 12){
            meridian = 'AM';
        }
        else if(hour > 12 ){
            hour = hour - 12;
            meridian = 'PM';
        }


        String monthInWords;
        String minuteAsWholeNumber;

        String dateAsString;

        if(String.valueOf(minute).length() == 1){
            minuteAsWholeNumber = '0' + String.valueOf(minute);
        }
        else{
            minuteAsWholeNumber = String.valueOf(minute);
        }

        monthInWords = activityDateTime.format('MMM');
        dateFieldsWrapperInstance.monthAndYearAsString = activityDateTime.format('MMMM') + '  •  ' + String.valueOf(year);

        Integer monthsAgo = activityDate.monthsBetween(System.now().date());

        if(monthsAgo == 0){
            dateFieldsWrapperInstance.monthsAgo = 'This Month';
        }
        else if(monthsAgo == 1){
            dateFieldsWrapperInstance.monthsAgo = 'Last Month';
        }
        else if(monthsAgo >= 12){
            if(monthsAgo == 12 || monthsAgo > 12 || monthsAgo < =23 ){
                dateFieldsWrapperInstance.monthsAgo = 'Last Year';
            }
            else if(monthsAgo >= 24){
                dateFieldsWrapperInstance.monthsAgo = String.valueOf((Integer)monthsAgo/12) + ' Years Ago';
            }
        }
        else if(monthsAgo > 2 && monthsAgo <= 11 ){
            dateFieldsWrapperInstance.monthsAgo = String.valueOf(monthsAgo) + ' Months Ago';
        }

        if(activitySubType == 'Email'){
            if( activityDate == System.today() ){
                dateFieldsWrapperInstance.activityDateAsString = String.valueOf(hour) + ':' + minuteAsWholeNumber + ' ' + meridian + ' | ' + 'Today';
            }
            else if ( activityDate == System.today().addDays(-1) ){
                dateFieldsWrapperInstance.activityDateAsString = String.valueOf(hour) + ':' + minuteAsWholeNumber + ' ' + meridian + ' | ' + 'Yesterday';
            }
            else{
                dateFieldsWrapperInstance.activityDateAsString = String.valueOf(hour) + ':' + minuteAsWholeNumber + ' ' + meridian + ' | ' + monthInWords + ' ' + String.valueOf(day);
            }
        }

        if((activitySubType == 'Event' || activitySubType == 'Email') && dateFieldsWrapperInstance.activityDateAsString == null){
            if(activitySubType == 'Event' && isAllDayEvent == true ){
                dateFieldsWrapperInstance.activityDateAsString = 'All-Day Event' + ' | ' + monthInWords + ' ' + String.valueOf(day);
            }
            else{
                dateFieldsWrapperInstance.activityDateAsString = String.valueOf(hour) + ':' + minuteAsWholeNumber + ' ' + meridian + ' | ' + monthInWords + ' ' + String.valueOf(day);
            }
        }
        else if(dateFieldsWrapperInstance.activityDateAsString == null){
            dateFieldsWrapperInstance.activityDateAsString = monthInWords +  ' ' + String.valueOf(day);
        }
        return dateFieldsWrapperInstance;
    }
    @AuraEnabled
    public static String insertEvent(String eventRecord){
        try{
            List<Event> eventList = (List<Event>)JSON.deserialize(eventRecord, List<Event>.class);
            insert eventList;
            return 'Success';
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void insertTask(String taskRecord){
       try{
           List<Task> taskList = (List<Task>)JSON.deserialize(taskRecord, List<Task>.class);
           insert taskList;
       }
       catch(Exception e){
        throw new AuraHandledException(e.getMessage());

       }
    }
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getEmailTemplates(String searchKeyWord){
        try {
            String query = 'SELECT Id , FolderName  , Name , HtmlValue , Body , Description , Markup , TemplateType FROM EmailTemplate';
            if(searchKeyWord != null && searchKeyWord != ''){
                query = query + ' WHERE Name Like \'%' + searchKeyWord + '%\'';
            }
            return Database.query(query);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String mergeFields(String unMergedBody , String whoOrWhatId){
        
        try {
            Id parentId = Id.valueOf(whoOrWhatId);
            String objectName = String.valueOf(parentId.getSObjectType());
            List<Messaging.RenderEmailTemplateBodyResult> renderList = new List<Messaging.RenderEmailTemplateBodyResult>();
        
            if(objectName == 'Contact' || objectName == 'Lead'){
                renderList = Messaging.renderEmailTemplate(whoOrWhatId , null , new List<String>{unMergedBody});
            }
            else{
                renderList = Messaging.renderEmailTemplate(null , whoOrWhatId , new List<String>{unMergedBody});
            }
            return renderList[0].getMergedBody();   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean sendMail(String fromAddress , Map<String,String> toAddressListMap , List<Map<String,String>> ccAddressListMap , List<Map<String,String>> bccAddressListMap , String subject , String body , List<Map<String, Object>> filesJSON , String whatId){
        try {

            Boolean isOrgWide = false;

            String fromEmail = fromAddress.substringBetween('<','>');
            List<OrgWideEmailAddress> orgWideEmail;

            if( fromEmail != UserInfo.getUserEmail() ){
                orgWideEmail = [SELECT Id,DisplayName , Address FROM OrgWideEmailAddress WHERE Address = :fromEmail];
                if(orgWideEmail.size() > 0){
                    isOrgWide = true;
                }
            }

            List<String> ccAddressList = new List<String>();
            List<String> bccAddressList = new List<String>();

            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

            for(Map<String,String> ccAddress : ccAddressListMap){
                ccAddressList.add(ccAddress.get('Email'));
            }
            for(Map<String,String> bccAddress : bccAddressListMap){
                bccAddressList.add(bccAddress.get('Email'));
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(toAddressListMap.get('Id'));
            if(bccAddressList.size() > 0){
                mail.setBccAddresses(bccAddressList);
            }
            if(ccAddressList.size() > 0){
                mail.setCcAddresses(ccAddressList);
            }
            mail.setSubject(subject);
            mail.sethtmlBody(body);
            if(isOrgWide == true){
                mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
            }
            List < Messaging.EmailFileAttachment > attachments = new List < Messaging.EmailFileAttachment > {};
            List<Id> contentVersionIds = new List<Id>();
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            
            for (Map<String, Object> file : filesJSON) {
                
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                String base64Data = String.valueOf(file.values()[1]);
                attachment.setBody(EncodingUtil.base64Decode(base64Data));
                attachment.setFileName(String.valueOf(file.values()[0]));
                String fileName = String.valueOf(file.values()[0]);
                String extension = fileName.substring(fileName.lastIndexOf('.'),fileName.length());
                attachments.add(attachment);
                ContentVersion cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode(base64Data);
                cv.Title = String.valueOf(file.values()[0]);
                cv.PathOnClient = String.valueOf(file.values()[0]) + '.' + extension;
                cv.isMajorVersion = true;
                contentVersionList.add(cv);
            }
            insert contentVersionList;
            for(ContentVersion contentVersionInstance : contentVersionList){
                contentVersionIds.add(contentVersionInstance.Id);
            }
            mail.setEntityAttachments(contentVersionIds);
            mail.setWhatId(whatId);
            System.debug('mail: '+mail);
            mailList.add(mail);

            Messaging.SendEmailResult[] results;

            if(mailList.size() > 0 && !Test.isRunningTest()){
                results = Messaging.sendEmail(mailList);
            }
            return results[0].isSuccess();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<ComboBoxWrapper> getOrgWideEmailAddresses(){
        try {
            List<ComboBoxWrapper> wrapperList = new List<ComboBoxWrapper>();
            String emailName1 = UserInfo.getName() + ' <' + UserInfo.getUserEmail() + '>';
            ComboBoxWrapper wrapperInstance1 = new ComboBoxWrapper();
            wrapperInstance1.label = emailName1;
            wrapperInstance1.value = emailName1;
            wrapperList.add(wrapperInstance1);

            for(OrgWideEmailAddress emailAddress : [SELECT Id , DisplayName , Address FROM OrgWideEmailAddress ORDER BY DisplayName  ASC]){
                ComboBoxWrapper wrapperInstance = new ComboBoxWrapper();
                String emailName = emailAddress.DisplayName + ' <' + emailAddress.Address + '>';
                wrapperInstance.label = emailName;
                wrapperInstance.value = emailName;
                wrapperList.add(wrapperInstance);
            }
            return wrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Map<Id , Integer> getPendingActivities(Set<Id> whatIds){
        try {
            
            Map<Id,Integer> pendingActivities = new Map<Id,Integer>();
            Date todayDate = System.today();
            
            AggregateResult[] groupedResults = [SELECT WhatId,Count(Id) FROM Task WHERE IsClosed = false AND ActivityDate < :todayDate AND WhatId IN :whatIds GROUP BY WhatId];
            
            for (AggregateResult ar : groupedResults)  {
                pendingActivities.put(Id.valueOf(String.valueOf(ar.get('WhatId'))) ,Integer.valueOf(ar.get('expr0')) );
            }
            return pendingActivities;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class ComboBoxWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value; 
    }
    public class ActivityTimelineWrapper{
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public Map<String,List<ActivitiesWrapper>> activityWrapperWithStringMap = new Map<String,List<ActivitiesWrapper>>();
    }
    public class ActivitiesWrapper{
        @AuraEnabled
        public Id activityId;
        @AuraEnabled
        public string subject;
        @AuraEnabled
        public string description;
        @AuraEnabled
        public string activitySubType;
        @AuraEnabled
        public string cssClass;
        @AuraEnabled
        public string iconName;
        @AuraEnabled
        public Long eventStartDateInMilliSeconds;
        @AuraEnabled
        public Long eventEndDateInMilliSeconds;
        @AuraEnabled
        public String activityString;
        @AuraEnabled
        public String toAddress;
        @AuraEnabled
        public String fromAddress;
        @AuraEnabled
        public String lastOpenedDate;
        @AuraEnabled
        public Boolean isUnOpened;
        @AuraEnabled
        public String mailSubject;
        @AuraEnabled
        public Boolean hasAttachment;
        @AuraEnabled
        public DateFieldsWrapper dateFieldsWrapperInstance;
    }
    public class DateFieldsWrapper{
        @AuraEnabled
        public String activityDateAsString;
        @AuraEnabled
        public String monthAndYearAsString;
        @AuraEnabled
        public String monthsAgo;
        @AuraEnabled
        public String activityDateAsStringClass;
    }
}