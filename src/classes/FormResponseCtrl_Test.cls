@isTest
public without sharing class FormResponseCtrl_Test {
    
    @testsetup 
    static void setup() {
    
        Test.startTest();
            TestClassUtil.createFormTemplateAndFormTemplateElements();            
        Test.stopTest();
    }

    static testmethod void testFormResCtrl(){
        
        Form_Template__c formTemp = [SELECT Id FROM Form_Template__c LIMIT 1];
        
        Test.startTest();

        FormResponseCtrl.formTemplateWrap wrap = FormResponseCtrl.getFormTemplate(formTemp.Id);

        Form_Response__c formRes = new Form_Response__c(Form_Template__c=wrap.formTemplate.Id);
        List<Form_Response_Element__c> formResElements = new List<Form_Response_Element__c>();
        Form_Response_Element__c formResEle;
        List<String> options;
        for(Form_Template_Element__c formTempEle: wrap.formTemplate.Form_Template_Elements__r){
            formResEle = new Form_Response_Element__c(Question__c=formTempEle.Id);
            options = new List<String>();
            if(String.isNotBlank(String.valueOf(formTempEle.Limit_Response__c))){
                
                if(String.isNotBlank(formTempEle.Answer_Options__c)){
                    Map<String, Decimal> optionsWithLimitMap = wrap.formTempEleIdwithOptionLimit.get(formTempEle.Id);
                    for(String option : formTempEle.Answer_Options__c.split(';')){
                        System.assertEquals( formTempEle.Limit_Response__c, optionsWithLimitMap.get(option));
                        options.add(option);
                    }                    
                }
            }
            
            formResEle.Response__c = options.size() > 0 ? options[0] : (formTempEle.Question_Type__c == 'Email' ? 'test@test.com' : (formTempEle.Question_Type__c == 'Number' ? '20' : 'test'));
            if(formTempEle.Set_As_Response_Name__c){
                formRes.Name = formResEle.Response__c;
            }
            formResElements.add(formResEle);
        }
        List<Form_Response__c> beforeSave = [SELECT Id FROM Form_Response__c];
        System.assertEquals(0, beforeSave.size());
       
        String result = FormResponseCtrl.saveFormResAndFormResElements(formRes, formResElements);
        System.assertEquals('success', result);

        FormResponseCtrl.formTemplateWrap wrap2 = FormResponseCtrl.getFormTemplate(formTemp.Id);
        System.assertEquals(1, wrap2.formTempEleIdWithResponseForUniqueResponse.size());
        for(Form_Template_Element__c formTempEle: wrap2.formTemplate.Form_Template_Elements__r){
            
            if(String.isNotBlank(String.valueOf(formTempEle.Limit_Response__c))){
                
                if(String.isNotBlank(formTempEle.Answer_Options__c)){
                    Map<String, Decimal> optionsWithLimitMap = wrap2.formTempEleIdwithOptionLimit.get(formTempEle.Id);
                    Integer i = 0;
                    for(String option : formTempEle.Answer_Options__c.split(';')){
                        Decimal expected = i == 0 ? formTempEle.Limit_Response__c - 1 : formTempEle.Limit_Response__c;
                        System.assertEquals( expected, optionsWithLimitMap.get(option)); 
                        i++;                       
                    }                    
                }
            }
            
        }
        Test.stopTest();        
    }
}