public  without sharing class ArticleListView_Controller {
    
  /*********************************************
   Created by Siva Prasanth on April 30 2019, to get Article Records to display in community page
  **********************************************/
    @AuraEnabled
    public static String getInitialArticleRecords() {
        List<Community__kav> articleList = [SELECT Id,ArticleNumber,/*Category__c,*/Language,Sub_Category__c,Title FROM Community__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'];
        return JSON.serialize(articleList);
    }
}