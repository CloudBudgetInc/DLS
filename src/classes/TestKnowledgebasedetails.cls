@isTest(SeeAllData=True)
public with sharing class TestKnowledgebasedetails
{
    static testmethod void sampleTest()
    {
        
        list<KnowledgeArticleVersion> knArtVer=[SELECT Id,Title,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Language = 'en_US' AND PublishStatus = 'Online'];
        system.debug('::::::::'+knArtVer[0].id);
        Id urlid;
        ID paid;
        if( knArtVer != null && knArtVer.size() > 0 ) {
            urlid = knArtVer[0].id;
            paid = knArtVer[0].KnowledgeArticleId;
        }
        ApexPages.currentPage().getParameters().put('id',knArtVer[0].id);
        Integer index = 5;
        
        //PageReference reference = Page.knowledgebasedetails;
        ApexPages.currentPage().getParameters().put('newRating', String.valueOf(index));
        system.debug('::::::::::::::'+paid);
        Test.startTest();
        KnowledgebaseCtrl1 knowledgeBaseDetail = new KnowledgebaseCtrl1();
        if (knArtVer != null && knArtVer.size() > 1) {
            knowledgeBaseDetail.paid=knArtVer[1].KnowledgeArticleId;
            knowledgeBaseDetail.rateRec();
        }
        Test.stopTest();
    }
    
    static testMethod void sampleTest1(){
        
        List<KnowledgeArticleVersion> knArtVer = [SELECT Id,Title,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Language = 'en_US' AND PublishStatus = 'Online'];
         
        Id urlid;
        ID paid;
        if( knArtVer != null && knArtVer.size() > 0 ) {
            urlid = knArtVer[0].id;
            paid = knArtVer[0].KnowledgeArticleId;
        }
        ApexPages.currentPage().getParameters().put('id',knArtVer[0].id);
        Integer index = 5;
        
        //PageReference reference = Page.knowledgebasedetails;
        ApexPages.currentPage().getParameters().put('newRating', String.valueOf(index));
        
        KnowledgebaseCtrl1 kbc = new KnowledgebaseCtrl1();
        kbc.rateRec();
    }
}