public class ArticleDetailController {
    
    //W-001630
    
    @AuraEnabled
    public static String getVotesForArticle(String articleId){
        try{
            
            VoteInfo voteIformation = new VoteInfo();
            voteIformation.upvotesCount = 0;
            voteIformation.downVotes = 0;
            String knowledgeArticleid;
            List<Community__kav>  articleVersionList = new List<Community__kav>();
            
            List<KnowledgeArticleVersion> knowledgeVersionList = [SELECT Id,knowledgearticleid from KnowledgeArticleVersion WHERE Id =: articleId];
            
            if(knowledgeVersionList.size() > 0){
                knowledgeArticleid = knowledgeVersionList[0].knowledgearticleid;
            }
            
            if(knowledgeArticleid != null){
                articleVersionList   = [SELECT Id,title,summary,body__c,knowledgearticleid FROM Community__kav WHERE knowledgearticleid = :knowledgeArticleid];
            }
            
            if(articleVersionList.size() > 0 && articleVersionList[0].KnowledgeArticleId != null){
                
                voteIformation.title = articleVersionList[0].title;
                voteIformation.body = articleVersionList[0].body__c;
                
                for(Vote voteRec : [SELECT id,type,createdById FROM vote WHERE ParentId =: articleVersionList[0].KnowledgeArticleId AND createdBy.isportalenabled = True AND createdBy.isActive = True]){
                    
                    system.debug('voteRec' +voteRec);
                    
                    if(voteRec.type == '5'){
                        voteIformation.upvotesCount = voteIformation.upvotesCount + 1;
                    }else if (voteRec.type == '1'){
                        voteIformation.downVotes = voteIformation.downVotes + 1;
                    }
                    
                    if(voteRec.createdById == UserInfo.getUserId()){
                    
                        if(voteRec.Type == '5'){
                            voteIformation.currentStatus = 'Like';
                        }else if(voteRec.Type == '1'){
                            voteIformation.currentStatus = 'DisLike';
                        }
                    }
                }
            }
            
            system.debug('voteIformation' +voteIformation);
            return Json.serialize(voteIformation);
            
        }catch(Exception e){
            throw new auraHandledException(e.getMessage());   
        }
    }
    
    @AuraEnabled
    public static void  updateArticle(String response,String articleId){
        
        List<KnowledgeArticleVersion>  articleVersionList = [SELECT id,KnowledgeArticleId,title,summary from KnowledgeArticleVersion where Id = :articleId];
        
        if(articleVersionList.size() > 0 && articleVersionList[0].KnowledgeArticleId != null){
            
            vote voteRec = [SELECT Id,Type FROM vote WHERE ParentId = :articleVersionList[0].KnowledgeArticleId AND CreatedById = :userInfo.getUserId() LIMIT 1];
            
            system.debug('vote list:::::::'+voteRec);
            
            if(voteRec != null){
            
                if(response == 'Like'){
                    voteRec.Type = '5';
                }else if(response == 'DisLike'){
                    voteRec.Type = '1';
                } 
                Update voteRec;
            }
        }
    }
    
    public class VoteInfo {
        @AuraEnabled
        public Decimal upvotesCount;
        @AuraEnabled
        public Decimal downVotes; 
        @AuraEnabled
        public String currentStatus;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String body;
    }
}