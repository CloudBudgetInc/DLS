/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 03/14/2022
 * @last modified by  : Dhinesh Kumar
**/
public class BookmarkHandler {
    
    @AuraEnabled
    public static String getUserName() {
        return JSON.serialize([SELECT Id,Name FROM User WHERE Id = :userinfo.getuserid()]);
    }
    @AuraEnabled
    public static Bookmark__c getBookMark(String ContactId,String userId){
        if(userId == null){
            userId = userinfo.getuserid();
        }
        Bookmark__c bookMark = new Bookmark__c();
        try{
            bookMark = [SELECT Id,Name,Referral_Source__c,To_Hire__c,Notes__c,
                        To_Interview__c,Top_Candidate__c,Skill__c,To_Preview__c,To_Screen__c FROM Bookmark__c 
                        WHERE Contact__c = :ContactId AND User__c = :userId]; 
           return bookMark; 
        } catch(Exception e){
           return bookMark; 
        }   
        
    }
    @AuraEnabled
    public static String upsertBookMark(List<Bookmark__c> bookMarks,String contactId,String chatterPostContent,Boolean isNew, List<String> selectedUserIds){
        
        try {
            upsert bookMarks;
            
            Map<Id, User> usrIdWithRecMap = new Map<Id, User>([SELECT Id,IsPortalEnabled,Staff_Access__c FROM User WHERE Id = :selectedUserIds]);
            
            for(Bookmark__c bookMarkObj : bookMarks){
                if(bookMarkObj.User__c != userinfo.getuserid() && usrIdWithRecMap.get(bookMarkObj.User__c) != null && !usrIdWithRecMap.get(bookMarkObj.User__c).IsPortalEnabled && isNew){
                    Bookmark__c bookmark = [SELECT Id,Name FROM Bookmark__c WHERE Id = :bookMarkObj.Id];
                    createChatterPost(userinfo.getuserid(),bookMarkObj.User__c,bookmark,chatterPostContent);
                }
            }
            return 'Success';
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //For User Search
    @AuraEnabled
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(searchString,objectName,fieldName,condition,selectedIds);
    }  
    
    // makes a simple chatter text post to the specified user from the running user 
    public static void createChatterPost(Id userId, Id userToMentionId, Bookmark__c bookmarkRec,String content) { 
    
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        mentionSegmentInput.id = userToMentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        if(content == 'Please view the contact record that I have bookmarked for you') {
            textSegmentInput.text = ' Please view the contact record that I have bookmarked for you: '+bookmarkRec.Name;
        }else {
            textSegmentInput.text = ' '+content; 
        }
        
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = bookmarkRec.Id;
        
        system.debug(':::::::::::::feedItemInput:::::::::'+feedItemInput);
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    } 
    
    //Added by NS on Feb 22 2022 - W-007368
    @AuraEnabled
    public static List<String> getPicklistValues(){
        
        List<String> skills = new List<String>();
        List<Schema.PicklistEntry> skillsPicklist = Bookmark__c.Skill__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : skillsPicklist) {
            skills.add(entry.getValue());
        }
        
        return skills;
    
    }
}