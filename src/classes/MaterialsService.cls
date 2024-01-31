/**********************************************************************
    Created by Sukanya on Jan 6 2017: Service class used for Materials__c object
***********************************************************************/
public class MaterialsService {
     
     /**********************************************************************
        Created by Sukanya on Jan 6 2017: This method return list of materials
        @materialIdset - set of Material records Ids
        return - list of material records
    ***********************************************************************/
    
     public static list<Materials__c> getMaterialsbyIds(Set<Id> materialIdset) {
         list<Materials__c> materialsData = new list<Materials__c>();
         String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Materials__c');
         
         if(materialIdset != null && materialIdset.size() > 0) {
            
            materialsData = Database.query('SELECT '+fieldName
                                           +', Language_LU__r.Name,Google_Books_Language__r.ISO_2_Charac_Code__c,Google_Books_Language__r.Name'
                                           +' FROM'
                                           +' Materials__c'
                                           +' WHERE'
                                                +' Id IN :materialIdset'
                                           +' AND'
                                                +' OwnerId != null');
        }
        return materialsData;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 6 2017: This method return list of materials with 2 conditions
         Number of request/ Average rating with some number count
         @materialIdset - set of material record ids
         @fieldName - field name to add at where condition (Number of Request / Average rating)
         @limitCcount - count for fieldName values
         return - list of material records
    ***********************************************************************/
    
     public static list<Materials__c> getMaterialsbyIds(Set<Id> materialIdset,String fieldName,Integer limitCount) {
         
         list<Materials__c> materialsData = new list<Materials__c>();
         String materialQry;
         String objfieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Materials__c');
         
         if(materialIdset != null && materialIdset.size() > 0) {
             materialQry = 'SELECT '+objfieldName
                            +', Language_LU__r.Name,Google_Books_Language__r.ISO_2_Charac_Code__c, Google_Books_Language__r.Name'
                            +' FROM Materials__c '
                            +' WHERE Id IN :materialIdset'+' AND '+fieldName+' > '+limitCount;
             system.debug(':::materialQry:::'+materialQry);
             materialsData = Database.query(materialQry);
        }
        return materialsData;
     }
     
   /**********************************************************************
        Created by Sukanya on Jan 9 2017: This method return list of materials with n conditions
         @filterQry - where condition is received 
         return - list of material records
    ***********************************************************************/
    
     
     public static list<Materials__c> getMaterialsbyFilters(String filterQry,String sortingField,String sortingType, String offsetQry) {
     
         list<Materials__c> materialsData = new list<Materials__c>();
         String objfieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Materials__c');
         
         String materialQry = 'SELECT '+objfieldName
                              +', Language_LU__r.Name'
                              +' FROM Materials__c WHERE OwnerId != null';         
                         
         if(filterQry != null && filterQry != '') {
             materialQry = materialQry + filterQry;
         }
         
         if(String.isNotBlank(sortingField) && String.isNotBlank(sortingType)){
             materialQry += ' ORDER BY '+sortingField+' '+sortingType;
         }
         
         if(String.isNotBlank(offsetQry)){
             materialQry += offsetQry;
         }else{
             materialQry += ' LIMIT 100';
         }
         
         materialsData = Database.query(materialQry);
         
        return materialsData;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 9 2017: This method return list of materials with n conditions
         @searchInput - keyword string for search
         @filterCondition - where condition add to query
         return - list of list of Sobject records
         
         SOSL QRY
    ***********************************************************************/
    
    public static List<List<SObject>> getMaterialsbySearchParamter(String searchInput,String filterCondition) {
        
        List<List<SObject>> resultData = new List<List<SObject>>();
        
        String searchQry = 'FIND {'+searchInput+'} IN NAME Fields Returning Materials__c (Cost__c,Description__c,Dialect__c,ILR_Level__c,ISBN__c,Language_LU__c,Language_LU__r.Name,Notes__c,DLS_Section__c,URLs__c,OwnerId,Name,Id,Author__c,Book_Format__c,Book_Cover__c,Book_Series__c,Quantity_Available__c,Sum_Of_Rating__c,Average_Rating__c,Total_Quantity_Available__c,Total_Quantity_Available_Stock__c,Total_Quantity_Loaned_Out__c,Number_of_Requests__c,CreatedDate,Material_Ratings__c ';
        
        if(filterCondition != null && filterCondition != '') {
            searchQry = searchQry + filterCondition;
        }
        
        if(searchInput != null) {
            resultData = search.query(searchQry);
        }
        
        return resultData;
    }
    
    /**********************************************************************
        Created by Sukanya on August 17 2018: This method return list of materials with n conditions
         @filterQry - where condition is received 
         @nameSet - name set
         return - list of material records
    ***********************************************************************/
    
     
     public static list<Materials__c> getMaterialsbyName(String filterQry,Set<String> nameValues) {
     
         list<Materials__c> materialsData = new list<Materials__c>();
         String objfieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Materials__c');
         
         String materialQry = 'SELECT '+objfieldName
                              +', Language_LU__r.Name'
                              +' FROM Materials__c WHERE OwnerId != null';         
                         
         if(filterQry != null && filterQry != '') {
             materialQry = materialQry + filterQry;
         }
         
         if(nameValues != null && nameValues.size() > 0) {
                 materialQry += ' AND Name IN :nameValues';
         }
         materialsData = Database.query(materialQry);
         
        return materialsData;
     }
    
     
}