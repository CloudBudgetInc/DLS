/*****************************************
    - Class used in GetAverageHourlyCostCmp visualforce component 
    - Used for return Average_Hourly_Cost_LT_Cost_Rate__c field value in Language__c object    // Average_Hourly_Cost_Non_SCA_LT__c modified into Average_Hourly_Cost_LT_Cost_Rate__c
    *****************/
public class GetAverageHourlyCostCmpController {
    
    public String languageNameValue { get; set; }
    public String laborCostRateId{ get; set; }
    
    public Decimal hourlyCost {
    
        get{
            Decimal d = 0.0;
            if(String.isNotBlank(languageNameValue)){
            
                List<Language__c> languages = [SELECT Id, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c WHERE Name = :languageNameValue];                
                
                if(languages.size() > 0 && languages[0].Average_Hourly_Cost_LT_Cost_Rate__c != null){
                    d = languages[0].Average_Hourly_Cost_LT_Cost_Rate__c.setscale(2);
                }
            }
            return d;
        }
        set;
    }
    
    public Decimal hourlyCost_WithoutPrep {
    
        get{
            Decimal d = 0.0;
            if(String.isNotBlank(languageNameValue)){
            
                List<Language__c> languages = [SELECT Id, Average_Hourly_Cost_LT_without_Prep__c FROM Language__c WHERE Name = :languageNameValue];                
                
                if(languages.size() > 0 && languages[0].Average_Hourly_Cost_LT_without_Prep__c != null){
                    d = languages[0].Average_Hourly_Cost_LT_without_Prep__c.setscale(2);
                }
            }
            return d;
        }
        set;
    }
    
    public Labor_Cost_Rate_Master__c lCRMRec_WithPrep{
    
        get{
        
            Labor_Cost_Rate_Master__c lcrm = new Labor_Cost_Rate_Master__c();
            
            //ContactAssignmentLightningCtrl.isFromCA == True &&
            if(laborCostRateId != NULL){
            
                List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Id = :laborCostRateId];
                
                if(costRate.size() > 0){
                
                    String rateType = costRate[0].Rate_Type__c;
                    // Non-SCA LT modified into LT
                    if(String.isNotBlank(rateType) && (rateType == 'LT with Prep' || rateType == 'LT without Prep')){ // Added LT condition by GRK on 16/10/19, since we have the logic only for LT not for CD
                    
                        List<Labor_Cost_Rate_Master__c> lCRmasterRecs = [
                            SELECT Id, YTD_Merit_Increases__c, Annual_Merit_Budget__c 
                            FROM Labor_Cost_Rate_Master__c 
                            WHERE Rate_Type__c = 'LT with Prep' 
                        ];
                        
                        if(lCRmasterRecs.size() > 0){
                            lcrm = lCRmasterRecs[0];
                        }
                    }
                }
            }
            return lcrm;
        }
        set;
    }
    
    public Labor_Cost_Rate_Master__c lCRMRec_WithoutPrep{
    
        get{
        
            Labor_Cost_Rate_Master__c lcrm = new Labor_Cost_Rate_Master__c();
            
            //ContactAssignmentLightningCtrl.isFromCA == True &&
            if(laborCostRateId != NULL){
            
                List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Id = :laborCostRateId];
                
                if(costRate.size() > 0){
                
                    String rateType = costRate[0].Rate_Type__c;
                    // Non-SCA LT modified into LT
                    if(String.isNotBlank(rateType) && (rateType == 'LT with Prep' || rateType == 'LT without Prep')){ // Added LT condition by GRK on 16/10/19, since we have the logic only for LT not for CD
                    
                        List<Labor_Cost_Rate_Master__c> lCRmasterRecs = [
                            SELECT Id, YTD_Merit_Increases__c, Annual_Merit_Budget__c 
                            FROM Labor_Cost_Rate_Master__c 
                            WHERE Rate_Type__c = 'LT without Prep' 
                        ];
                        
                        if(lCRmasterRecs.size() > 0){
                            lcrm = lCRmasterRecs[0];
                        }
                    }
                }
            }
            return lcrm;
        }
        set;
    }
    
    public List<Contact_Assignments__c> conAssign{
    
        get{
            
            List<Contact_Assignments__c> caRecs = new List<Contact_Assignments__c>();
            
            if(ContactAssignmentLightningCtrl.isFromCA == True && laborCostRateId != NULL){
            
                List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Prior_Version__c FROM AcctSeed__Cost_Rates__c WHERE Id = :laborCostRateId AND Prior_Version__c != NULL];
                
                if(costRate.size() > 0){
                
                    List<Contact_Assignments__c> conAss = [
                        SELECT Id, Project__r.Name, Project__r.AcctSeed__Status__c 
                        FROM Contact_Assignments__c 
                        WHERE (Rate_Card_Rate__c = :costRate[0].Prior_Version__c OR Drafted_Labor_Cost_Rate__c = :costRate[0].Prior_Version__c) AND
                            Project__r.AcctSeed__Status__c IN ('Order', 'Active')
                    ];
                    if(conAss.size() > 0){
                        caRecs = conAss;
                    }
                }
            }
            return caRecs;
        }
        set;
    }
}