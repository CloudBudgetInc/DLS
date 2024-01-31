@isTest(SeeAllData=True)
public class ArticleDetailController_Test {

    //W-001630
    
    public  static testMethod void myTest(){
        
        
        List<KnowledgeArticleVersion> knArtVer = [SELECT Id,Title,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Language = 'en_US' AND PublishStatus = 'Online' AND Title LIKE '%How do I join a Zoom meeting?%' LIMIT 2];
        
        List<KnowledgeArticle> articleList = [SELECT Id FROM KnowledgeArticle WHERE Id = :knArtVer[0].KnowledgeArticleId LIMIT 1];
        
        List<User> userList = [SELECT Id FROM User WHERE isPortalEnabled = true AND IsActive = true AND Profile.Name IN ('Instructor Community','Student Community') LIMIT 2];
        
        
        if(knArtVer.size() > 0 && knArtVer[0].KnowledgeArticleId != null){
        
            Vote voteRec = new Vote(type = '1',parentId = articleList[0].Id);
            
            System.runAs(userList[1]){
                Insert voteRec;
                ArticleDetailController.getVotesForArticle(knArtVer[0].Id);
            }
            
            System.runAs(userList[0]){
                
                Vote voteRec1 = new Vote(type = '5',parentId = articleList[0].Id);
                Insert voteRec1;
                
                ArticleDetailController.getVotesForArticle(knArtVer[0].Id);
                ArticleDetailController.updateArticle('DisLike',knArtVer[0].Id);
                
                List<Vote> votesList = [SELECT Id,Type FROM Vote WHERE ParentId = :knArtVer[0].KnowledgeArticleId];
                if(votesList.size() > 0){
                    //system.assertEquals(votesList[0].type, '1');
                }
                
                ArticleDetailController.updateArticle('Like',knArtVer[0].Id);
                
                List<Vote> votesList1 = [SELECT Id,Type FROM Vote WHERE ParentId = :knArtVer[0].KnowledgeArticleId AND CreatedById = :userList[0].Id];
                if(votesList1.size() > 0){
                    system.assertEquals(votesList1[0].type, '5');
                }
            }
        }
        
    }
    
    private static testMethod void getInitialArticleRecords_Test(){
         
         ArticleListView_Controller.getInitialArticleRecords();
     }
}