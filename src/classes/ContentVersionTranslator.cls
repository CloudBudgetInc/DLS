/**********************************************************************
    Created by Sukanya on Jan 10 2017: Translator class used for ContentVersion object inner class formation
***********************************************************************/

global class ContentVersionTranslator {
     
     /**********************************************************************
        Created by Sukanya on Jan 10 2017: Translator class used for LibraryDetailController_Component- LanguageFileTypeInfo inner class formation
    ***********************************************************************/
     
     global static ContentVersionDomain.LanguageFileTypeInfo languageFileInfo(List<Language__c> langList,List<ContentVersion> contentList) {
         
         ContentVersionDomain.LanguageFileTypeInfo conLanguage = new ContentVersionDomain.LanguageFileTypeInfo();
         conLanguage.languageRecords = langList;
         conLanguage.contentVersionrecords = contentList;
         
         return conLanguage;
     }
     
    /**********************************************************************
    Added by Sukanya on Jan 11 2017: method used for LibraryContentDetailController_Component - libraryDetailComponentInfo inner class formation
    ***********************************************************************/
     
     global static ContentVersionDomain.libraryDetailComponentInfo libComponentInfoMethod(List<ContentVersion> contentRecs,List<ContentWorkspace> contentWorkspace,List<Material_Rating__c> newBtnRating,List<Material_Rating__c> materialRatingList,List<Favourite_Material__c> favourite,List<AggregateResult> numberDownload,List<Request__c> bookRequest,List<RecordType> recordType,List<AcctSeed__Project__c> projectData,List<Contact_Assignments__c> projectContactAssign,Id contactId,Boolean allowLTS) {
         
         ContentVersionDomain.libraryDetailComponentInfo libComInfo = new ContentVersionDomain.libraryDetailComponentInfo();
         libComInfo.contentRec = contentRecs;
         libComInfo.contentWorkspace = contentWorkspace;
         libComInfo.newBtnMaterialRating = newBtnRating;
         libComInfo.materialRatingList = materialRatingList;
         libComInfo.favouriteList = favourite;
         libComInfo.numberOfDownloadCount = numberDownload;
         libComInfo.bookRequestDetails = bookRequest;
         libComInfo.recordtypeInfo = recordType;
         libComInfo.projectForInternal = projectData;
         libComInfo.projectRelatedcontactAssignment = projectContactAssign;
         libComInfo.contactId = contactId;
         libComInfo.allowLTS_EditDescription = allowLTS;
         
         return libComInfo;
     }
     
    /**********************************************************************
    Added by Sukanya on July 9 2019: to form Content Version Cmp related wrapper class
    ***********************************************************************/
    public static ContentVersionDomain.ContentVersionInfo formContentVersionDetails(List<ContentVersion> contentDetail,Boolean displayNewRatingBtn,List<Material_Rating__c> currentUsrRating,List<Material_Rating__c> ratings,List<RecordType> requestRT,List<Favourite_Material__c> favourites,String contactId,Boolean allowLTS,List<Request__c> requests,Integer downlodedCount,List<ContentWorkspace> workspaceContent){
        
        system.debug(':::::::::::raitng::::'+ratings);
        
        ContentVersionDomain.ContentVersionInfo detail = new ContentVersionDomain.ContentVersionInfo();
        detail.contentRec = contentDetail[0];
        detail.displayNewReviewBtn = displayNewRatingBtn;
        detail.currentUserRating = currentUsrRating;
        detail.overAllRatingDetails = ratings;
        detail.favouriteList = favourites;
        detail.requestRTId = requestRT[0].Id;
        detail.currentContactId = contactId;
        detail.allowLTS_EditDescription = allowLTS;
        detail.bookRequestDetails = requests;
        detail.downloadCount = downlodedCount;
        detail.workSpaceDetail = workspaceContent[0];
        
        return detail;
    }
    
}