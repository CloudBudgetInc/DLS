/*********************************
Created by Karthiga on Feb 28, 2018
***********************************/ 
public with Sharing Class CongaTranslator{
    public Static List<APXTConga4__Conga_Merge_Query__c> congaQry = new List<APXTConga4__Conga_Merge_Query__c>();
    public Static List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c>();
    /*******
    @name - Name of the Conga Query
    return - Returns the Id of the Conga Query
    ********/
    public static Id getCongaQuery(String name) {
        Id retId;
        if(congaQry.size() == 0) {
            congaQry = CongaQueryService.CongaQryList();
        }
        
        for (APXTConga4__Conga_Merge_Query__c cq : congaQry) {
            if( cq.APXTConga4__Name__c == name ) {
                retId = cq.Id;
            }
        }
        return retId;
    }
    
    /*******
    @name - Name of the Conga Template
    return - Returns the Id of the Conga Template
    ********/
    public static Id getCongaTemplate(String name) {
        Id retId;
        if(congaTemp.size() == 0) {
            congaTemp = CongaQueryService.CongaTempList();
        }
        
        for (APXTConga4__Conga_Template__c cq : congaTemp) {
            if( cq.APXTConga4__Name__c == name ) {
                retId = cq.Id;
            }
        }
        return retId;
    }
}