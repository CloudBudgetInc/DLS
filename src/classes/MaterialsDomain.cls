/**********************************************************************
    Created by Sukanya on Jan 10 2017: Domain class used for Material object inner class formation
***********************************************************************/

global class MaterialsDomain {
    
    /**********************************************************************
        Modified by Sukanya on Jan 11 2017: Domain class used for MaterialDetailPageController_Component inner class formation
    ***********************************************************************/
    
    global class materialComponentInfo {
        public List<RecordType> recordTypeList;
        public List<Materials__c> materialRecords;
        public List<Favourite_Material__c> favouriteDetails;
        public List<Material_Rating__c> materialRatingFornewBtn;
        public List<RecordType> materialRequestRTList;
        public Id contactId;
        public Boolean allowLTS_EditDescription;
    }
    
    /**********************************************************************
        Modified by Sukanya on May 23 2017: Domain class used for MaterialDetailPageController_Component inner class formation
    ***********************************************************************/
    
    global class materialComponentDetails {
        public List<Material_Rating__c> materialRatingList;
        public List<Materials_Request__c> materialRequestList;
        public List<AggregateResult> numberDownLoadCountList;
    }
    
     /**********************************************************************
        Modified by Sukanya on Jan 11 2017: Domain class used for MaterialDetailPageController_Component inner class formation
    ***********************************************************************/
    
    global class userProjectInfo {
        public List<User> usrList;
        public List<AcctSeed__Project_Task__c> projectTaskList;
    } 
    
    /**********************************************************************
       Added by Sukanya on July 16 2019: Material Detail Cmp wrapper
    ***********************************************************************/
    public Class MaterialDetailInfo {
    
        public Materials__c materialDetail;
        public List<Favourite_Material__c> favouriteList;
        public List<Material_Rating__c> currentUserRating;
        public List<Material_Rating__c> overAllRatings;
        public Id contactId;
        public Boolean allowLTS_EditDescription;
        public List<Materials_Request__c> orderMaterialRequests;
        public List<Materials_Request__c> loanMaterialRequests;
        public Boolean displayNewReviewBtn;
    }
    
   
}