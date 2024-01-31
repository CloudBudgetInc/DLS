/**********************************************************************
    Created by Karthiga on Feb 17, 2017: Service class used for Conga Query and Conga Template 
***********************************************************************/
public with Sharing Class CongaQueryService {
    /*******************************************
    Created by Karthiga on Feb 17, 2017
    *******************************************/
    public static List<APXTConga4__Conga_Merge_Query__c> CongaQryList() {
        List<APXTConga4__Conga_Merge_Query__c> congaQry = [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c];
        return congaQry;
    }
    
    /*******************************************
    Created by Karthiga on Feb 28, 2018 to query the Conga Template
    *******************************************/
    public static List<APXTConga4__Conga_Template__c> CongaTempList() {
        return [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c];
    }
}