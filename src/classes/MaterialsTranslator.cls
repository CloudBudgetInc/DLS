/**********************************************************************
    Created by Sukanya on Jan 11 2017: Translator class used for Material object inner class formation
***********************************************************************/

global class MaterialsTranslator {
     
     /**********************************************************************
        Created by Sukanya on Jan 11 2017: Translator class used for MaterialDetailPageController_Component inner class formation
    ***********************************************************************/
     
     global static MaterialsDomain.materialComponentInfo materialComponentMethod(List<RecordType> recordType,List<Materials__c> materialInfo,List<Favourite_Material__c> favourite,List<Material_Rating__c> newBtnrate,List<RecordType> materialReqRTList,Id conId,Boolean allowLTS) {
         
         MaterialsDomain.materialComponentInfo materialInformation = new MaterialsDomain.materialComponentInfo();
         materialInformation.recordTypeList = recordType;
         materialInformation.materialRecords = materialInfo;
         materialInformation.favouriteDetails = favourite;
         materialInformation.materialRatingFornewBtn = newBtnrate;
         materialInformation.materialRequestRTList = materialReqRTList;
         materialInformation.contactId = conId;
         materialInformation.allowLTS_EditDescription = allowLTS;
         
         return materialInformation;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 11 2017: Translator class used for MaterialDetailPageController_Component inner class formation
    ***********************************************************************/
     
     global static MaterialsDomain.materialComponentDetails materialdetailsFormation(List<Material_Rating__c> materialRate,List<Materials_Request__c> materialReq,List<AggregateResult> numberOfReq) {
         
         MaterialsDomain.materialComponentDetails materialInfo = new MaterialsDomain.materialComponentDetails();
         materialInfo.materialRatingList = materialRate;
         materialInfo.materialRequestList = materialReq;
         materialInfo.numberDownLoadCountList = numberOfReq;
         
         return materialInfo;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 11 2017: Translator class used for MaterialDetailPageController_Component inner class formation
    ***********************************************************************/
     
     global static MaterialsDomain.userProjectInfo materialUsrProjectMethod(List<User> usrRecords,List<AcctSeed__Project_Task__c> projectTasks) {
         
         MaterialsDomain.userProjectInfo materialUsrInfo = new MaterialsDomain.userProjectInfo();
         materialUsrInfo.usrList = usrRecords;
         materialUsrInfo.projectTaskList = projectTasks;
         
         return materialUsrInfo;
     }
     
    /**********************************************************************
    Created by Sukanya on July 16 2019: Used in LibrarySearchController for Material detail page wrapper formation
    ***********************************************************************/
    public static MaterialsDomain.MaterialDetailInfo materialDetailFormation(List<Materials__c> materialRecord,List<Favourite_Material__c> favourites,List<Material_Rating__c> currentReview,List<Material_Rating__c> overAllRating,Id contactId,Boolean allowLTS,List<Materials_Request__c> orderRequests,List<Materials_Request__c> loanRequests){
    
        MaterialsDomain.MaterialDetailInfo info = new MaterialsDomain.MaterialDetailInfo();
        info.materialDetail = materialRecord[0];
        info.favouriteList = favourites;
        info.currentUserRating = currentReview;
        info.overAllRatings = overAllRating;
        info.contactId = contactId;
        info.allowLTS_EditDescription = allowLTS;
        info.orderMaterialRequests = orderRequests;
        info.loanMaterialRequests = loanRequests;
        
        if(currentReview.size() > 0){
            info.displayNewReviewBtn = false;
        }else {
            info.displayNewReviewBtn = true;
        }
        
        return info;
    }
}