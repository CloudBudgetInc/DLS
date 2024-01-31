public without sharing class FormResponseCtrl {
    @AuraEnabled
    public static formTemplateWrap getFormTemplate(String formTemplateId){
        
        Form_Template__c formTemplate = FormTemplateService.getFormTempWithFormTempElements('Id =\''+formTemplateId+'\'');
        Set<Id> questionIds = new Set<Id>();
        Map<Id, Map<String, Decimal>> formTempEleIdwithOptionLimit = new Map<Id, Map<String, Decimal>>();
        Map<Id, List<String>> formTempEleIdWithResponseForUniqueResponse = new Map<Id, List<String>>();

        for(Form_Template_Element__c formTempEle : formTemplate.Form_Template_Elements__r){
            if(String.isNotBlank(String.valueOf(formTempEle.Limit_Response__c))){
                questionIds.add(formTempEle.Id);

                if(String.isNotBlank(formTempEle.Answer_Options__c)){
                    Map<String, Decimal> optionsWithLimitMap = new Map<String, Decimal>();
                    for(String option : formTempEle.Answer_Options__c.split(';')){
                        optionsWithLimitMap.put(option, formTempEle.Limit_Response__c);
                    }
                    formTempEleIdwithOptionLimit.put(formTempEle.Id, optionsWithLimitMap);
                }else{
                    formTempEleIdWithResponseForUniqueResponse.put(formTempEle.Id, new List<String>());                    
                }
            }
        }
        if(questionIds.size() > 0){
            for(Form_Response_Element__c formResEle : FormResponseElementsService.getFormResElementsByQuestion('',questionIds)){
                if(formTempEleIdwithOptionLimit.get(formResEle.Question__c) != null){
                    Map<String, Decimal> optionsWithLimitMap = formTempEleIdwithOptionLimit.get(formResEle.Question__c);
                    if(optionsWithLimitMap.get(formResEle.Response__c) != null){
                        optionsWithLimitMap.put(formResEle.Response__c, optionsWithLimitMap.get(formResEle.Response__c) - 1);
                    }
                    formTempEleIdwithOptionLimit.put(formResEle.Question__c, optionsWithLimitMap);
                }else if(formTempEleIdWithResponseForUniqueResponse.get(formResEle.Question__c) != null){
                    formTempEleIdWithResponseForUniqueResponse.get(formResEle.Question__c).add(formResEle.Response__c.toUpperCase());
                }
            }
        }

        return new formTemplateWrap(formTemplate, formTempEleIdwithOptionLimit, formTempEleIdWithResponseForUniqueResponse);
    } 
    
    @AuraEnabled
    public static String saveFormResAndFormResElements(Form_Response__c formResponse, List<Form_Response_Element__c> formResponseElements){
        String result = 'success';
        try{
            
            formTemplateWrap wrap = getFormTemplate(formResponse.Form_Template__c);
            Boolean isValid = true;
            for(Form_Response_Element__c formResEle : formResponseElements){
                if(wrap.formTempEleIdwithOptionLimit.get(formResEle.Question__c) != null){
                    Map<String, Decimal> optionWithLimitMap = wrap.formTempEleIdwithOptionLimit.get(formResEle.Question__c);
                    if(optionWithLimitMap.get(formResEle.Response__c) != null && optionWithLimitMap.get(formResEle.Response__c) < 1){
                        result = 'Invalid value for '+formResEle.Question__c;
                        isValid = false;
                    }
                }
                if(wrap.formTempEleIdWithResponseForUniqueResponse.get(formResEle.Question__c) != null && wrap.formTempEleIdWithResponseForUniqueResponse.get(formResEle.Question__c).contains(formResEle.Response__c.toUpperCase())){
                    result = 'Invalid value for '+formResEle.Question__c;
                    isValid = false;
                }
            }
            if(isValid){
                insert formResponse;
                for(Form_Response_Element__c formResEle : formResponseElements){
                    formResEle.Form_Response__c = formResponse.Id;
                }
                insert formResponseElements;
            }
        }
        catch(Exception exe){
            result = exe.getMessage();
        }

        return result;
    }

    public class formTemplateWrap{
        @auraEnabled public Form_Template__c formTemplate;
        @auraEnabled public Map<Id, Map<String, Decimal>> formTempEleIdwithOptionLimit;
        @auraEnabled public Map<Id, List<String>> formTempEleIdWithResponseForUniqueResponse;

        formTemplateWrap(Form_Template__c formTemplate, Map<Id, Map<String, Decimal>> formTempEleIdwithOptionLimit, Map<Id, List<String>> formTempEleIdWithResponseForUniqueResponse){
            this.formTemplate = formTemplate;
            this.formTempEleIdwithOptionLimit = formTempEleIdwithOptionLimit;
            this.formTempEleIdWithResponseForUniqueResponse = formTempEleIdWithResponseForUniqueResponse;
        }
    }
}