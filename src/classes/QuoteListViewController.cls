/***********************************************************************************************
 - Created by NS on May 23 2019
 - For Student Community Quote information display
 - Work Item No: W-001731
***********************************************************************************************/

public without sharing class QuoteListViewController {
    
    public class QuoteDetails {
        
        public String quoteId;
        public String quoteNumber;
        public String quoteDate;
        public String registrar;
        public Decimal totalPrice;
        
    }
    
    public Class QuoteLineItemDetails {
    
        public String productName;
        public Decimal salesPrice;
        public Decimal quantity;
        public Decimal subTotal;
    }
    
    public Class QuoteAndQuoteLineDetails {
    
        public QuoteDetails quoteInfo;
        public List<QuoteLineItemDetails> quoteLineInfo;
    }
    
    //Method to get the Quote List information on student community project detail view
    @AuraEnabled
    public static String getQuoteInformation(String projectId){
        
        system.debug('::::::projectId::::::'+projectId);
        
        List<QuoteDetails> quoteDetails = new List<QuoteDetails>();
        
        List<AcctSeed__Project__c> projectRec = [SELECT Id,Name,AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id = :projectId];
        
        if(projectRec.size() > 0){
            
            for(Quote quo : [SELECT Id,QuoteNumber,Date__c,Registrar__c,TotalPrice FROM Quote WHERE OpportunityId = :projectRec[0].AcctSeed__Opportunity__c]){
                
                QuoteDetails qtDetail = new QuoteDetails();
                qtDetail.quoteId = quo.Id;
                qtDetail.quoteNumber = quo.QuoteNumber;
                qtDetail.quoteDate = quo.Date__c != null ? String.valueOf(quo.Date__c).split('-')[1]+'/'+String.valueOf(quo.Date__c).split('-')[2]+'/'+String.valueOf(quo.Date__c).split('-')[0] : '';
                qtDetail.registrar = quo.Registrar__c;
                qtDetail.totalPrice = quo.TotalPrice;
                
                quoteDetails.add(qtDetail);
                
            }
        }
        
        return JSON.serialize(quoteDetails);
    }
    
    // Method to get the Quote & Quote Line Item details based on selected quote
    @AuraEnabled
    public Static String getQuoteLineInformation(String quoteId){
    
        QuoteDetails quoteInfo = new QuoteDetails();
        List<QuoteLineItemDetails> quoteLineInfo = new List<QuoteLineItemDetails>();
        
        List<Quote> quoteRec = [SELECT Id,QuoteNumber,Date__c,Registrar__c,TotalPrice FROM Quote WHERE Id = :quoteId];
        
        quoteInfo.quoteId = quoteRec[0].Id;
        quoteInfo.quoteNumber = quoteRec[0].QuoteNumber;
        quoteInfo.quoteDate = quoteRec[0].Date__c != null ? String.valueOf(quoteRec[0].Date__c).split('-')[1]+'/'+String.valueOf(quoteRec[0].Date__c).split('-')[2]+'/'+String.valueOf(quoteRec[0].Date__c).split('-')[0] : '';
        quoteInfo.registrar = quoteRec[0].Registrar__c;
        quoteInfo.totalPrice = quoteRec[0].TotalPrice;
        
        for(QuoteLineItem quoteLine : [SELECT Id,ServiceDate,LineNumber,Quantity,Product2.Name,UnitPrice,Subtotal FROM QuoteLineItem WHERE QuoteId = :quoteId]){
        
            QuoteLineItemDetails line = new QuoteLineItemDetails();
            line.productName = quoteLine.Product2.Name;
            line.salesPrice = quoteLine.UnitPrice;
            line.quantity = quoteLine.Quantity;
            line.subTotal = quoteLine.Subtotal;
            
            quoteLineInfo.add(line);
        }
        
        QuoteAndQuoteLineDetails detail = new QuoteAndQuoteLineDetails();
        detail.quoteInfo = quoteInfo;
        detail.quoteLineInfo = quoteLineInfo;
        
        return JSON.serialize(detail);
    }
    
}