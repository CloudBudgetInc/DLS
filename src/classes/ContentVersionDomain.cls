/**********************************************************************
    Created by Sukanya on Jan 10 2017: Domain class used for ContentVersion
***********************************************************************/

global class ContentVersionDomain {
     
     /**********************************************************************
        Modified by Sukanya on Jan 11 2017: Domain class used for LibraryDetailController_Component
    ***********************************************************************/
     global Class LanguageFileTypeInfo {
        
        public List<Language__c> languageRecords;
        public List<ContentVersion> contentVersionrecords;
     }
     
   /**********************************************************************
        Created by Sukanya on Jan 11 2017: Domain class used for LibraryContentDetailController_Component contentVersion record related data
    ***********************************************************************/
    
    global class libraryDetailComponentInfo {
        
        public List<ContentVersion> contentRec;
        public List<ContentWorkspace> contentWorkspace;
        public List<Material_Rating__c> newBtnMaterialRating;
        public List<Material_Rating__c> materialRatingList;
        public List<Favourite_Material__c> favouriteList;
        public List<AggregateResult> numberOfDownloadCount;
        public List<Request__c> bookRequestDetails;
        public List<RecordType> recordtypeInfo;
        public List<AcctSeed__Project__c> projectForInternal;
        public List<Contact_Assignments__c> projectRelatedcontactAssignment;
        public Id contactId;
        public Boolean allowLTS_EditDescription;
    } 
    
    /**********************************************************************
    Created by Sukanya on Junly 9 2019: Domain class used for Content Version detail cmp
    ***********************************************************************/
    
    public class ContentVersionInfo {
        
        public ContentVersion contentRec;
        public Boolean displayNewReviewBtn;
        public List<Material_Rating__c> currentUserRating;
        public List<Material_Rating__c> overAllRatingDetails;
        public List<Favourite_Material__c> favouriteList;
        public Integer downloadCount;
        public String requestRTId;
        public Id currentContactId;
        public Boolean allowLTS_EditDescription;
        public List<Request__c> bookRequestDetails;
        public ContentWorkspace workSpaceDetail;
    }
}