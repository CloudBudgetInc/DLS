({
    doInit: function (cmp, event, helper) {
        let valid = true,
            assessmentReport = cmp.get('v.assessmentReport'),
            fields = cmp.get('v.fields'),
            fieldsAPILabelMap = { 'Name': 'Training Report Name', 'Project__c': 'Project', 'Date_Completed__c': 'Date Completed', 
                                  'Project_Manager__c': 'Project Manager', 'Instructor__c': 'Instructor', 'Student_Name_s__c': 'Student Name(s)',
                                  'Status__c': 'Status', 'Class_Observed_Level__c': 'Class Observed – Level', 'Class_Observed_Skill_Grammar_Focus__c': 'Class Observed – Skill Grammar Focus',
                                  'Class_Observed_Topic__c': 'Class Observed – Topic', 'Comments__c': 'Comments', 'Annual_Review_Strengths__c' :'Annual Review Strengths',
                                  'Annual_Review_Areas_for_Further_Develop__c': 'Annual Review Areas for Further Develop', 'AR_Strengths_Other_Comments__c' : 'AR Strengths Other Comments',
                                  'AR_Further_Developments_Other_Comments__c' : 'AR Further Developments Other Comments'                                  
                                },
            error = { errorMsg: 'Please complete the following fields:<ul>' };
            
            let index = fields.indexOf('AR_Strengths_Other_Comments__c');
            fields.splice(index, 1); 
            index = fields.indexOf('AR_Further_Developments_Other_Comments__c');
            fields.splice(index, 1);             
            index = fields.indexOf('RecordType.DeveloperName');
            fields.splice(index, 1);
        	index = fields.indexOf('Not_Enough_Data_for_AR__c');
            fields.splice(index, 1);

        if (assessmentReport.RecordType.DeveloperName == 'Observation_Report' || assessmentReport.RecordType.DeveloperName == 'DLI_Observation_Report') {
            if (assessmentReport.Status__c != 'Completed') {
                valid = false;
                error.errorMsg = 'Only Completed Observation Report can be send to Instructor.';
            }

            if (valid) {
                if(assessmentReport.RecordType.DeveloperName == 'DLI_Observation_Report'){
                    index = fields.indexOf('Annual_Review_Areas_for_Further_Develop__c');
                    fields.splice(index, 1);
                    index = fields.indexOf('Annual_Review_Strengths__c');
                    fields.splice(index, 1);
                }
                for (let field of fields) {
                    if(field == 'Annual_Review_Areas_for_Further_Develop__c' || field == 'Annual_Review_Strengths__c'){
                        if(!assessmentReport.Not_Enough_Data_for_AR__c) {
                            if(!assessmentReport[field]){
                                valid = false;                        
                                error.errorMsg += '<li>' + fieldsAPILabelMap[field] + '</li>';
                            }else{
                                let fieldValue = assessmentReport[field].split(";"),
                                    hasOtherValue = fieldValue.indexOf('Other') != -1;
                                
                                if(hasOtherValue && field == 'Annual_Review_Areas_for_Further_Develop__c' && !assessmentReport['AR_Further_Developments_Other_Comments__c']){
                                    valid = false;                        
                                    error.errorMsg += '<li>' + fieldsAPILabelMap['AR_Further_Developments_Other_Comments__c'] + '</li>';
                                }else if(hasOtherValue && field == 'Annual_Review_Strengths__c' && !assessmentReport['AR_Strengths_Other_Comments__c']){
                                    valid = false;                        
                                    error.errorMsg += '<li>' + fieldsAPILabelMap['AR_Strengths_Other_Comments__c'] + '</li>';
                                }
                            }
                        }
                    } else if (!assessmentReport[field]) {
                        valid = false;                        
                        error.errorMsg += '<li>' + fieldsAPILabelMap[field] + '</li>';
                    }
                }
                error.errorMsg += '</ul>';
            }
        } else if (assessmentReport.RecordType.DeveloperName == 'Annual_Instructor_Performance_Review') {
            if (assessmentReport.Status__c != 'Ready to Send') {
                valid = false;
                error.errorMsg = "Status should be 'Ready to Send' to send Annual Performance Review Report to Instructor.";
            }

            if (valid && !assessmentReport.Instructor__c) {
                valid = false;
                error.errorMsg = "Instructor is not populated";
            }
        }

        error.isShow = !valid;
        cmp.set('v.error', error);

        if (valid) {
            helper.validateBoxFolderExist(cmp, event, helper);
        }
    },
    launchUrl: function(cmp, event, helper){
        helper.launchCongaUrl(cmp, cmp.get('v.congaUrl'));
    },
    closeAction: function(cmp){
        $A.get("e.force:closeQuickAction").fire();
    }
})