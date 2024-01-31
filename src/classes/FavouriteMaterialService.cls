/**********************************************************************
    Created by Vinitha on Jan 17 2017: Service class used for Favourite_Material__c object
***********************************************************************/
public class FavouriteMaterialService {
    
     /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of favouriteMaterial 
        @filterQry - Pass Where conditions
        return - list of favouriteMaterial records
    ***********************************************************************/    
    public static list<Favourite_Material__c> getFavouritematerial(String filterQry) {
        
        List<Favourite_Material__c> favmaterialList = new List<Favourite_Material__c>();
                    
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Favourite_Material__c');
        String defaultQry = 'SELECT ' +fieldName+ ' FROM  Favourite_Material__c';
        
        if(filterQry != null && filterQry != ''){
            defaultQry +=  filterQry;   
        } 
        system.debug('::defaultQry::'+defaultQry);
        system.debug(':filterQry::'+filterQry);
        favmaterialList = Database.query(defaultQry);
        return favmaterialList; 
    }
           
    /**********************************************************************
        Created by Vinitha on Jan 17 2017: This method return newly created list of favouriteMaterial 
        @favmaterialList - List of favourite Material records
        return - list of favouriteMaterial records
    ***********************************************************************/ 
    public static list<Favourite_Material__c> insertFavouritematerial(list<Favourite_Material__c> favmaterialList) {
    
        if(favmaterialList != null && favmaterialList.size() > 0){
            insert favmaterialList;            
        }
        return favmaterialList;    
    } 
    /**********************************************************************
        Created by Vinitha on Jan 17 2017: This method return list of favouriteMaterial 
        @favmaterialList - List of favourite Material records
        return - list of favouriteMaterial records
    ***********************************************************************/ 
    public static list<Favourite_Material__c> updateFavouritematerial(list<Favourite_Material__c> favmaterialList) {
    
        if(favmaterialList != null && favmaterialList.size() > 0){
            update favmaterialList;            
        }
        return favmaterialList;    
    }
    /**********************************************************************
        Created by Vinitha on Jan 17 2017: This method return list of favouriteMaterial 
        @favmaterialList - List of favourite Material records
        return - list of favouriteMaterial records
    ***********************************************************************/ 
    public static list<Favourite_Material__c> deleteFavouritematerial(list<Favourite_Material__c> favmaterialList) {
    
        if(favmaterialList != null && favmaterialList.size() > 0){
            delete favmaterialList;            
        }
        return favmaterialList;    
    } 
    
}