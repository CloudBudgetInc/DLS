({
    getLanguages : function(component,event,helper){
        
        var header = [
            {
                'label':'Language Name',
                'name':'Language_Name__c',
                'type':'reference',  
                'target':'_blank',
                'value':'Language__c',
                'sortable':false
            },
            {
                'label':'Native Language',
                'name':'Native_Language__c', 
                'type':'checkbox',
                'visible':'true',
                'sortable':false
                
            },
            {
                'label':'Speaking Proficiency',
                'name':'Speaking_Proficiency__c',
                'type':'text',
                'sortable':false
                
            },
            {
                'label':'Listening Proficiency',
                'name':'Listening_Proficiency__c',
                'type':'text',
                'sortable':false
                
            }    
        ];

        component.set("v.candidateRows",component.get("v.allCandidateRows").lstLanguage);
        component.set("v.candidateHeader",header); 
    },
    
    getSkills : function(component,event,helper){
        
        var header=[
            {
                'label':'Skill',
                'name':'Skill__c',
                'type':'picklist',
                //'width' : '150px',
                'truncate' : {
                    "characterLength" :30
                },
                'sortable':false
            },             
            {
                'label':'Language',
                'name':'language', 
                'type':'richtext',
                'sortable':false
                
            },
            {
                'label':'Rating',
                'name':'Rating__c',
                'type':'picklist',
                //'width' : '70px',
                'sortable':false
                
            },
            {
                'label':'Skill Verification',
                'name':'Skill_Verification__c',
                //'width' : '150px',
                'truncate' : {
                    "characterLength" :30
                },
                'sortable':false
            },
            {
                'label':'DLI Qualified',
                'name':'DLI_Qualified__c', 
                'type':'checkbox',
                'visible':'true',
                'sortable':false
                    
            }];
        
        component.set("v.candidateRows",component.get("v.allCandidateRows").lstSkills);
        component.set("v.candidateHeader",header);
    },
    getExperience : function(component,event,helper){
        var header=[
            {
                'label':'Name',
                'name':'Name',
                'type':'reference',
                'target':'_blank',
                'value':'Id',
                'sortable':false
                
            },
            {
                'label':'Name of Company',
                'name':'Name_of_Company__c', 
                'type':'text' ,
                'truncate' : {
                    "characterLength" :60
                }   ,
                'sortable':false
            },  
            {
                'label':'Role/Title',
                'name':'Role_Title__c',
                'type':'text',
                'sortable':false,
                'truncate' : {
                    "characterLength" :80
                }   
            },
            {
                'label':'Services',
                'name':'Services__c',
                'type':'multipicklist',
                'sortable':false,
                'truncate' : {
                    "characterLength" : 10
                }
                
            },
            {
                'label':'FT_PT',
                'name':'FT_PT__c',
                'type':'picklist',
                'visible':false,
                'sortable':false
            },
            {
                'label':'Exp.in Months',
                'name':'Experience_in_Months__c',
                'type':'text',
                'sortable':false
            },
            {
                'label':'Exp.in Years',
                'name':'Experience_in_Years__c', 
                'type':'text' ,
                'sortable':false    
            },  
            {
                'label':'Total # of Hours',
                'name':'Total_Hours_Performed__c',
                'type':'text',
                'sortable':false,
                'truncate' : {
                    "characterLength" : 10	
                }
            },
            {
                'label':'Start Date',
                'name':'Start_Date__c',
                'type':'date',
                'format':'MM/DD/YYYY',
                'visible':true,
                'sortable':false
                
            },
            {
                'label':'End Date',
                'name':'End_Date__c',
                'type':'string',
                'visible':true,
                'sortable':false
                
            },
            {
                'label':'City',
                'name':'City__c',
                'type':'text',
                'visible':false,
                'sortable':false
                
            },
            {
                'label':'State',
                'name':'State__c',
                'type':'text',
                'visible':false,
                'sortable':false
                
            },
            {
                'label':'Country',
                'name':'Country__c',
                'type':'text',
                'sortable':false
                
            },
            {
                'label':'Average Hrs Per Week',
                'name':'Average_Hrs_Per_Week__c',
                'type':'Number',
                'visible':false,
                'sortable':false
                
            },
            {
                'label':'Description',
                'name':'Description__c	',
                'type':'textarea',
                'visible':false,
                'sortable':false
                
            }];
        
        component.set("v.candidateRows",component.get("v.allCandidateRows").lstWork);
        if(component.get("v.candidateRows").length > 0){
            component.set("v.recordType",component.get("v.candidateRows")[0].RecordType.Name);
        }
        component.set("v.candidateHeader",header);
        
        
    },
    getEducation : function(component,event,helper){
        
        var header=[
            {
                'label':'Name',
                'name':'Name',
                'type':'reference',
                'target':'_blank',
                'value':'Id',
                'sortable':false
            },
            {
                'label':'College / School',
                'name':'College_School__c', 
                'type':'text',
                'truncate' : {
                    "characterLength" : 60
                },
                'sortable':false
                
            },  
            {
                'label':'School Type',
                'name':'College_School_Type__c',
                'type':'picklist',
                'sortable':false
            },
            {
                'label':'Degree',
                'name':'Degree__c',
                'type':'text',
                'truncate' : {
                    "characterLength" : 20	
                }
                ,
                'sortable':false
                
            },
            {
                'label':'Degree Level',
                'name':'Degree_Level__c',
                'type':'picklist',
                'sortable':false
            },
            {
                'label':'Field of Concentration',
                'name':'Field_of_Concentration__c',
                'type':'text',
                'visible':false
            },
            {
                'label':'Year of Completion',
                'name':'Year_of_Completion__c', 
                'type':'text',
                'truncate' : {
                    "characterLength" : 10	
                }
            },
            {
                'label':'City',
                'name':'City__c', 
                'type':'text',
                'visible':false
            },
            {
                'label':'State',
                'name':'State__c', 
                'type':'text',
                'visible':false     
            },
            
            {
                'label':'Country',
                'name':'Country__c',
                'type':'text',
                'sortable':false,
                'truncate' : {
                    "characterLength" :30
                }  
                
            }];
        
        component.set("v.candidateRows",component.get("v.allCandidateRows").lstEducation);
        if(component.get("v.candidateRows").length > 0){
            component.set("v.recordType",component.get("v.candidateRows")[0].RecordType.Name);
        }
        component.set("v.candidateHeader",header);
    },
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[1]+'/'+dateVal.split('-')[2]+'/'+dateVal.split('-')[0];
    },
    getProfPublicationAwardHelper : function(component,event,helper){
          
        var header = [
            {
                'label':'Name',
                'name':'Name',
                'type':'reference',  
                'target':'_blank',
                'value':'Name',
                'sortable':false
            },
            {
                'label':'Name of the Publication Award',
                'name':'Name_of_the_Publication_Award__c', 
                'type':'text',
                'visible':'true',
                'sortable':false
                
            },
             {
                'label':'Company Institution',
                'name':'Company_Institution_Name__c',
                'type':'text', 
                 'visible':'true',
                'sortable':false                
            },              
            {
                'label':'Year',
                'name':'Year__c',
                'type':'text',
                'sortable':false
                
            }    
        ];
		console.log(component.get("v.allCandidateRows").lstProfPublicationAward);
        component.set("v.candidateRows",component.get("v.allCandidateRows").lstProfPublicationAward);
        component.set("v.candidateHeader",header); 
    }
})