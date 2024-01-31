global with sharing class LanguageSearchController {

    public String lang1{get; set;}
    public transient List<Known_Language__c> conList{get; set;}
    public transient List<Known_Language__c> conList1{get; set;}    
    public String filter{get; set;}
    public static  String mainQuery{get; set;}
    public static  String subQuery{get; set;}
    public String ContactListJSONStr{get; set;}
    
    global LanguageSearchController(){
    
        lang1 = ApexPages.currentPage().getParameters().get('param1');
        filter = ApexPages.currentPage().getParameters().get('param2');
        
        
        searchContact();
        
    }
    
    
    public List<SelectOption> getLanguages(){
    
          List<SelectOption> options = new List<SelectOption>();
                
           Schema.DescribeFieldResult fieldResult = Contact.Language_1__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
           for( Schema.PicklistEntry f : ple)
           {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }   
           system.debug('options:::'+options);    
           return options;
    }
    
     public List<SelectOption> getfilterOptions(){
    
          List<SelectOption> filOptions = new List<SelectOption>();
           
              filOptions.add(new SelectOption('All languages', 'All languages' ));
              filOptions.add(new SelectOption('Language 1', 'Language 1' ));
              filOptions.add(new SelectOption('Language 2', 'Language 2' ));
              filOptions.add(new SelectOption('Language 3', 'Language 3' ));
              filOptions.add(new SelectOption('Source Language 1', 'Source Language 1' ));
              filOptions.add(new SelectOption('Source Language 2', 'Source Language 2' ));
              filOptions.add(new SelectOption('Target Language 1', 'Target Language 1' ));
              filOptions.add(new SelectOption('Target Language 2', 'Target Language 2' ));
           
           system.debug('filOptions:::'+filOptions);    
           return filOptions;
    }
    
    public PageReference searchContact(){
        conList1 = new List<Known_Language__c>();
        ContactListJSONStr = ''; 
        
        if(lang1 != null && lang1 !=''){
        
            system.debug('filter:::'+filter);
            
            mainQuery= 'SELECT Id, Native_Language__c, Language__c, Language_Name__c, Listening_Proficiency__c, Speaking_Proficiency__c, Latest_Language_Testing__c,Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingCountry, Contact__r.MailingPostalCode FROM Known_Language__c';  
            system.debug('mainQuery::'+mainQuery);  
            subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' ';
            system.debug('subQuery::'+subQuery);    
            /*if(filter != null && filter != ''){
            
                if(filter == 'All languages'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND (Contact__r.Language_1__c LIKE \''+lang1+'%\' OR Contact__r.Language_2__c LIKE \''+lang1+'%\' OR Contact__r.Language_3__c LIKE \''+lang1+'%\' OR Contact__r.Source_Language_1__c LIKE \''+lang1+'%\' OR Contact__r.Source_Language_2__c LIKE \''+lang1+'%\' OR Contact__r.Target_Language_1__c LIKE \''+lang1+'%\' OR Contact__r.Target_Language_2__c LIKE \''+lang1+'%\' )';
                    system.debug('subQuery::'+subQuery);
                
                }
               else if(filter == 'Language 1'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND Contact__r.Language_1__c LIKE \''+lang1+'%\' ';
                    system.debug('subQuery::'+subQuery);
                
                }
                else if(filter == 'Language 2'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND Contact__r.Language_2__c LIKE \''+lang1+'%\' ';
                    system.debug('subQuery::'+subQuery);
                
                }
                else if(filter == 'Language 3'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND Contact__r.Language_3__c LIKE \''+lang1+'%\' ';
                    system.debug('subQuery::'+subQuery);
                
                }
                else if(filter == 'Source Language 1'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND Contact__r.Source_Language_1__c LIKE \''+lang1+'%\' ';
                
                }
                else if(filter == 'Source Language 2'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND Contact__r.Source_Language_2__c LIKE \''+lang1+'%\' ';
                    system.debug('subQuery::'+subQuery);
                
                }
                else if(filter == 'Target Language 1'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND Contact__r.Target_Language_1__c LIKE \''+lang1+'%\'  ';
                    system.debug('subQuery::'+subQuery);
                
                }
                else if(filter == 'Target Language 2'){
                    
                    subQuery='WHERE Language_Name__c LIKE \''+lang1+'%\' AND Contact__r.Target_Language_2__c LIKE \''+lang1+'%\' ';
                    system.debug('subQuery::'+subQuery);
                
                }else{
                
                //do nothing
                }
                subQuery += ' LIMIT 9000';
            }*/
            
            conList1 = Database.Query(mainQuery + ' ' + subQuery);
            system.debug('conList1:::'+conList1);
            system.debug('conList1size:::'+conList1.size());
            system.debug('conList1source1:::'+conList1.size());
            String  tempContactListJSONStr = JSON.serialize(conlist1);
            ContactListJSONStr = String.escapeSingleQuotes(tempContactListJSONStr);
            
            Integer i;
            Integer c ;
            conList = new List<Known_Language__c>();
            
            if(conList1.size() > 5){
                c=5;
            }
            else{
                c=conList1.size();
            }
            
                for(i = 0;i < c; i++){
                
                conList.add(conList1[i]);
                
                }
            
            
        
            system.debug('conList:::'+conList);
          
        }
        return null;
    
    }
    
    //Added by Sukanya Sep 12 2016
    
    @RemoteAction
    global static List<Known_Language__c> getLanguageDetails(Id contactId) {
       
       List<Known_Language__c> knownLangList = [SELECT Id, Native_Language__c, Language__c, Language_Name__c, Listening_Proficiency__c, Speaking_Proficiency__c, Latest_Language_Testing__c,Contact__c, Contact__r.Name ,Contact__r.Email, Contact__r.MobilePhone, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingCountry, Contact__r.MailingPostalCode FROM Known_Language__c WHERE Contact__c = :contactId];
       
       system.debug(':::::::::::::knownLangList:::::::::::'+knownLangList);
       
       return knownLangList;
    }
    
    // Added by Sukanya Sep 15 2016
    
    @RemoteAction 
    global static List<Known_Language__c> searchLanguageRelatedDetails(String lang) {
        
        List<Known_Language__c> conList1 = new List<Known_Language__c>();
        
        if(lang != null && lang !=''){
            mainQuery= 'SELECT Id, Native_Language__c, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingCountry, Contact__r.MailingPostalCode FROM Known_Language__c';  
            system.debug('mainQuery::'+mainQuery);  
            subQuery='WHERE Language_Name__c LIKE \''+lang+'%\' ';
            system.debug('subQuery::'+subQuery);  
            
            conList1 = Database.Query(mainQuery + ' ' + subQuery);
            system.debug('conList1:::'+conList1);
        }
        
        system.debug('::::::conList1:::::'+conList1);
        
        return conList1;
    }
    
}