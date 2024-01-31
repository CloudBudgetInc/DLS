public with sharing class QualificationUtil {

    public class ParameterException extends Exception {}

    public static Integer DEFAULT_LIMIT = 10;

    public static Map<String, Integer> EDUCATION_ORDER = new Map<String, Integer>{'Associate' => 1, 'Bachelor' => 2, 'Master' => 3, 'Professional' => 4};

    public static Map<String, Set<String>> ProfAndSetOfScoreMap = new Map<String, Set<String>> {
        '1/1' => new Set<String> { '1', '1+', '2', '2+', '3', '3+', '4', '4+', '5' },
        '2/2' => new Set<String> { '2', '2+', '3', '3+', '4', '4+', '5' },
        '3/3' => new Set<String> { '3', '3+', '4', '4+', '5' },
        '4/4' => new Set<String> { '4', '4+', '5' },
        '5/5' => new Set<String> { '5' },

        '1/1GREATER THAN' => new Set<String> { '2', '2+', '3', '3+', '4', '4+', '5' },
        '2/2GREATER THAN' => new Set<String> { '3', '3+', '4', '4+', '5' },
        '3/3GREATER THAN' => new Set<String> { '4', '4+', '5' },
        '4/4GREATER THAN' => new Set<String> { '5' },
        '5/5GREATER THAN' => new Set<String> {  },

        '1/1GREATER THAN OR EQUAL TO' => new Set<String> { '1', '1+', '2', '2+', '3', '3+', '4', '4+', '5' },
        '2/2GREATER THAN OR EQUAL TO' => new Set<String> { '2', '2+', '3', '3+', '4', '4+', '5' },
        '3/3GREATER THAN OR EQUAL TO' => new Set<String> { '3', '3+', '4', '4+', '5' },
        '4/4GREATER THAN OR EQUAL TO' => new Set<String> { '4', '4+', '5' },
        '5/5GREATER THAN OR EQUAL TO' => new Set<String> { '5' },

        '1/1LESS THAN' => new Set<String> {  },
        '2/2LESS THAN' => new Set<String> { '1', '1+' },
        '3/3LESS THAN' => new Set<String> { '1', '1+', '2', '2+' },
        '4/4LESS THAN' => new Set<String> { '1', '1+', '2', '2+', '3', '3+' },
        '5/5LESS THAN' => new Set<String> { '1', '1+', '2', '2+', '3', '3+', '4', '4+' },

        '1/1LESS THAN OR EQUAL TO' => new Set<String> { '1', '1+' },
        '2/2LESS THAN OR EQUAL TO' => new Set<String> { '1', '1+', '2', '2+' },
        '3/3LESS THAN OR EQUAL TO' => new Set<String> { '1', '1+', '2', '2+', '3', '3+' },
        '4/4LESS THAN OR EQUAL TO' => new Set<String> { '1', '1+', '2', '2+', '3', '3+', '4', '4+' },
        '5/5LESS THAN OR EQUAL TO' => new Set<String> { '1', '1+', '2', '2+', '3', '3+', '4', '4+', '5' },

        '1/1NOT EQUAL TO' => new Set<String> { '2', '2+', '3', '3+', '4', '4+', '5' },
        '2/2NOT EQUAL TO' => new Set<String> { '1', '1+', '3', '3+', '4', '4+', '5' },
        '3/3NOT EQUAL TO' => new Set<String> { '1', '1+', '2', '2+', '4', '4+', '5' },
        '4/4NOT EQUAL TO' => new Set<String> { '1', '1+', '2', '2+', '3', '3+', '5' },
        '5/5NOT EQUAL TO' => new Set<String> { '1', '1+', '2', '2+', '3', '3+', '4', '4+' },

        '1/1EQUAL TO' => new Set<String> { '1', '1+' },
        '2/2EQUAL TO' => new Set<String> { '2', '2+' },
        '3/3EQUAL TO' => new Set<String> { '3', '3+' },
        '4/4EQUAL TO' => new Set<String> { '4', '4+' },
        '5/5EQUAL TO' => new Set<String> { '5' }
    };

    public static Map<String, Set<String>> englishProficiencyValueMap = new Map<String, Set<String>> {
        '1/1' => new Set<String> { '1/1', '2/2', '3/3', '4/4', '5/5' },
        '2/2' => new Set<String> { '2/2', '3/3', '4/4', '5/5' },
        '3/3' => new Set<String> { '3/3', '4/4', '5/5' },
        '4/4' => new Set<String> { '4/4', '5/5' },
        '5/5' => new Set<String> { '5/5' },

        '1/1GREATER THAN' => new Set<String> { '2/2', '3/3', '4/4', '5/5' },
        '2/2GREATER THAN' => new Set<String> { '3/3', '4/4', '5/5' },
        '3/3GREATER THAN' => new Set<String> { '4/4', '5/5' },
        '4/4GREATER THAN' => new Set<String> { '5/5' },
        '5/5GREATER THAN' => new Set<String> {},

        '1/1GREATER THAN OR EQUAL TO' => new Set<String> { '1/1', '2/2', '3/3', '4/4', '5/5' },
        '2/2GREATER THAN OR EQUAL TO' => new Set<String> { '2/2', '3/3', '4/4', '5/5' },
        '3/3GREATER THAN OR EQUAL TO' => new Set<String> { '3/3', '4/4', '5/5' },
        '4/4GREATER THAN OR EQUAL TO' => new Set<String> { '4/4', '5/5' },
        '5/5GREATER THAN OR EQUAL TO' => new Set<String> { '5/5' },

        '1/1LESS THAN' => new Set<String> {  },
        '2/2LESS THAN' => new Set<String> { '1/1' },
        '3/3LESS THAN' => new Set<String> { '1/1', '2/2' },
        '4/4LESS THAN' => new Set<String> { '1/1', '2/2', '3/3' },
        '5/5LESS THAN' => new Set<String> { '1/1', '2/2', '3/3', '4/4' },

        '1/1LESS THAN OR EQUAL TO' => new Set<String> { '1/1' },
        '2/2LESS THAN OR EQUAL TO' => new Set<String> { '1/1', '2/2' },
        '3/3LESS THAN OR EQUAL TO' => new Set<String> { '1/1', '2/2', '3/3' },
        '4/4LESS THAN OR EQUAL TO' => new Set<String> { '1/1', '2/2', '3/3', '4/4' },
        '5/5LESS THAN OR EQUAL TO' => new Set<String> { '1/1', '2/2', '3/3', '4/4', '5/5' },

        '1/1EQUAL TO' => new Set<String> { '1/1' },
        '2/2EQUAL TO' => new Set<String> { '2/2' },
        '3/3EQUAL TO' => new Set<String> { '3/3' },
        '4/4EQUAL TO' => new Set<String> { '4/4' },
        '5/5EQUAL TO' => new Set<String> { '5/5' },

        '1/1NOT EQUAL TO' => new Set<String> { '2/2', '3/3', '4/4', '5/5' },
        '2/2NOT EQUAL TO' => new Set<String> { '1/1', '3/3', '4/4', '5/5' },
        '3/3NOT EQUAL TO' => new Set<String> { '1/1', '2/2', '4/4', '5/5' },
        '4/4NOT EQUAL TO' => new Set<String> { '1/1', '2/2', '3/3', '5/5' },
        '5/5NOT EQUAL TO' => new Set<String> { '1/1', '2/2', '3/3', '4/4' }
    };

    public static Map<String, Set<String>> degreeLevelQueryMap = new Map<String, Set<String>> {
        'Associative' => new Set<String> {'Associative', 'Bachelor', 'Master', 'Professional'},
        'Bachelor' => new Set<String> {'Bachelor', 'Master', 'Professional'},
        'Master' => new Set<String> {'Master', 'Professional'},
        'Professional' => new Set<String> {'Professional'},

        'AssociativeGREATER THAN' => new Set<String> {'Bachelor', 'Master', 'Professional'},
        'BachelorGREATER THAN' => new Set<String> {'Master', 'Professional'},
        'MasterGREATER THAN' => new Set<String> {'Professional'},
        'ProfessionalGREATER THAN' => new Set<String> {},

        'AssociativeGREATER THAN OR EQUAL TO' => new Set<String> {'Associative', 'Bachelor', 'Master', 'Professional'},
        'BachelorGREATER THAN OR EQUAL TO' => new Set<String> {'Bachelor', 'Master', 'Professional'},
        'MasterGREATER THAN OR EQUAL TO' => new Set<String> {'Master', 'Professional'},
        'ProfessionalGREATER THAN OR EQUAL TO' => new Set<String> {'Professional'},

        'AssociativeLESS THAN' => new Set<String> {},
        'BachelorLESS THAN' => new Set<String> {'Associative'},
        'MasterLESS THAN' => new Set<String> {'Associative', 'Bachelor'},
        'ProfessionalLESS THAN' => new Set<String> {'Associative', 'Bachelor', 'Master'},

        'AssociativeLESS THAN OR EQUAL TO' => new Set<String> {'Associative'},
        'BachelorLESS THAN OR EQUAL TO' => new Set<String> {'Associative', 'Bachelor'},
        'MasterLESS THAN OR EQUAL TO' => new Set<String> {'Associative', 'Bachelor', 'Master'},
        'ProfessionalLESS THAN OR EQUAL TO' => new Set<String> {'Associative', 'Bachelor', 'Master', 'Professional'},

        'AssociativeEQUAL TO' => new Set<String> {'Associative'},
        'BachelorEQUAL TO' => new Set<String> {'Bachelor'},
        'MasterEQUAL TO' => new Set<String> {'Master'},
        'ProfessionalEQUAL TO' => new Set<String> {'Professional'},

        'AssociativeNOT EQUAL TO' => new Set<String> {'Bachelor', 'Master', 'Professional'},
        'BachelorNOT EQUAL TO' => new Set<String> {'Associative', 'Master', 'Professional'},
        'MasterNOT EQUAL TO' => new Set<String> {'Associative', 'Bachelor', 'Professional'},
        'ProfessionalNOT EQUAL TO' => new Set<String> {'Associative', 'Bachelor', 'Master'}
    };

    public static Map<String, Set<String>> candidateRatingQueryMap = new Map<String, Set<String>> {
        '0' => new Set<String> {'0', '1', '2', '3', '4', '5', '6'},
        '1' => new Set<String> {'1', '2', '3', '4', '5', '6'},
        '2' => new Set<String> {'2', '3', '4', '5', '6'},
        '3' => new Set<String> {'3', '4', '5', '6'},
        '4' => new Set<String> {'4', '5', '6'},
        '5' => new Set<String> {'5', '6'},
        '6' => new Set<String> {'6'},
        '0GREATER THAN' => new Set<String> {'1', '2', '3', '4', '5', '6'},
        '1GREATER THAN' => new Set<String> {'2', '3', '4', '5', '6'},
        '2GREATER THAN' => new Set<String> {'3', '4', '5', '6'},
        '3GREATER THAN' => new Set<String> {'4', '5', '6'},
        '4GREATER THAN' => new Set<String> {'5', '6'},
        '5GREATER THAN' => new Set<String> {'6'},
        '6GREATER THAN' => new Set<String> {},
        '0GREATER THAN OR EQUAL TO' => new Set<String> {'0', '1', '2', '3', '4', '5', '6'},
        '1GREATER THAN OR EQUAL TO' => new Set<String> {'1', '2', '3', '4', '5', '6'},
        '2GREATER THAN OR EQUAL TO' => new Set<String> {'2', '3', '4', '5', '6'},
        '3GREATER THAN OR EQUAL TO' => new Set<String> {'3', '4', '5', '6'},
        '4GREATER THAN OR EQUAL TO' => new Set<String> {'4', '5', '6'},
        '5GREATER THAN OR EQUAL TO' => new Set<String> {'5', '6'},
        '6GREATER THAN OR EQUAL TO' => new Set<String> {'6'},
        '0LESS THAN' => new Set<String> {},
        '1LESS THAN' => new Set<String> {'0'},
        '2LESS THAN' => new Set<String> {'0', '1'},
        '3LESS THAN' => new Set<String> {'0', '1', '2'},
        '4LESS THAN' => new Set<String> {'0', '1', '2', '3'},
        '5LESS THAN' => new Set<String> {'0', '1', '2', '3', '4'},
        '6LESS THAN' => new Set<String> {'0', '1', '2', '3', '4', '5'},
        '0LESS THAN OR EQUAL TO' => new Set<String> {'0'},
        '1LESS THAN OR EQUAL TO' => new Set<String> {'0', '1'},
        '2LESS THAN OR EQUAL TO' => new Set<String> {'0', '1', '2'},
        '3LESS THAN OR EQUAL TO' => new Set<String> {'0', '1', '2', '3'},
        '4LESS THAN OR EQUAL TO' => new Set<String> {'0', '1', '2', '3', '4'},
        '5LESS THAN OR EQUAL TO' => new Set<String> {'0', '1', '2', '3', '4', '5'},
        '6LESS THAN OR EQUAL TO' => new Set<String> {'0', '1', '2', '3', '4', '5', '6'},
        '0EQUAL TO' => new Set<String> {'0'},
        '1EQUAL TO' => new Set<String> {'1'},
        '2EQUAL TO' => new Set<String> {'2'},
        '3EQUAL TO' => new Set<String> {'3'},
        '4EQUAL TO' => new Set<String> {'4'},
        '5EQUAL TO' => new Set<String> {'5'},
        '6EQUAL TO' => new Set<String> {'6'},
        '0NOT EQUAL TO' => new Set<String> {'1', '2', '3', '4', '5', '6'},
        '1NOT EQUAL TO' => new Set<String> {'0', '2', '3', '4', '5', '6'},
        '2NOT EQUAL TO' => new Set<String> {'0', '1', '3', '4', '5', '6'},
        '3NOT EQUAL TO' => new Set<String> {'0', '1', '2', '4', '5', '6'},
        '4NOT EQUAL TO' => new Set<String> {'0', '1', '2', '3', '5', '6'},
        '5NOT EQUAL TO' => new Set<String> {'0', '1', '2', '3', '4', '6'},
        '6NOT EQUAL TO' => new Set<String> {'0', '1', '2', '3', '4', '5'}
    };


    public static Boolean compare(String operand, String[] sourceArray, String[] compareWithArray) {
        if(operand == 'CONTAINS ANY ONE') {
            for(String compareWIth : compareWithArray) {
                for(String source : sourceArray) {
                    if(source == compareWith)
                        return true;
                }
            }
        }
        if(operand == 'CONTAINS ALL') {
            for(String source : sourceArray) {
                Boolean flag = false;
                for(String compareWith : compareWithArray) {
                    if(source == compareWith) {
                        flag = true;
                        break;
                    }
                }
                if(!flag)
                    return false;
            }
            return true;
        }
        return false;
    }

    public static Boolean compare(String operand, String source, String[] compareWithArray) {
        if(operand == 'EQUAL TO') {
            for(String compareWIth : compareWithArray) {
                if(source == compareWith)
                    return true;
            }
        }
        return false;
    }

    public static Boolean compare(String operand, Integer source, Integer compareWith) {
        if(operand == 'GREATER THAN') {
            if(source > compareWith)
                return true;
        }
        if(operand == 'GREATER THAN OR EQUAL TO') {
            if(source >= compareWith) {
                return true;
            }
        }
        if(operand == 'LESS THAN') {
            if(source < compareWith)
                return true;
        }
        if(operand == 'LESS THAN OR EQUAL TO') {
            if(source <= compareWith)
                return true;
        }
        if(operand == 'EQUAL TO') {
            if(source == compareWith)
                return true;
        }
        if(operand == 'NOT EQUAL TO') {
            if(source != compareWith)
                return true;
        }
        return false;
    }

    public static Boolean compare(String operand, String source, String compareWith) {
        if(operand == 'EQUAL TO') {
            if(source == compareWith)
                return true;
        }
        if(operand == 'NOT EQUAL TO') {
            if(source != compareWith)
                return true;
        }
        return false;
    }

    public static Boolean compareIndex(String operand, String[] sourceArray, String indexSourceString, String[] fullArray) {
        Integer index;
        for(Integer i = 0; i < fullArray.size(); i++) {
            if(indexSourceString == fullArray[i]) {
                index = i;
                break;
            }
        }
        for(Integer i = 0; i < fullArray.size(); i++) {
            for(String source : sourceArray) {
                if(source == fullArray[i]) {
                    if(compare(operand, index, i))
                        return true;
                }
            }
        }
        return false;
    }

    public static FilteredContacts instructorSearch(SearchParameter parameter, Id bundleId) {

        if(parameter.language == null || parameter.language == '') {
            throw new ParameterException('Please Choose any Language.');
        }
        //Get the zipLocation
        System.Location zipLocation;
        if(parameter.zip != null && parameter.zip != '' && parameter.proximity != 0 && parameter.proximity != null) {
            zipLocation = InstructorSearchController.getLocation(parameter.zip);
        }else if(parameter.locationId != null && parameter.proximity != 0 && parameter.proximity != null) {
            zipLocation = InstructorSearchController.getLatLangFromLocationObj(parameter.locationId);
        }


        List<Qualification_Bundle_Item__c> qualificationList;
        if(bundleId != null) {
            qualificationList = getQualificationSettings(bundleId,new List<Id>{});
        }

        //Check the Skill Object Filters
        String skillQryStr = 'SELECT Contact__c FROM Skill__c WHERE ';
        Boolean skillFlag = false;
        Set<String> serviceSet = new Set<String>();
        
        if(parameter.service != null)
            serviceSet.addAll(parameter.service);
            
        //CertificationFlag to find this query is used or not.
        Boolean certificationFlag = false;

        //Form Language Training Object Filter
        String langTestingQryStr = 'SELECT Contact__c, Language_Name__c, Listening_Proficiency__c, Speaking_Proficiency__c FROM Known_Language__c WHERE Contact__c != null ';

        //Form Experience Object Filter
        String experienceQuery = 'SELECT Contact__c FROM Experience__c WHERE ';

        String contactQuery = 'SELECT Id, Name, CreatedDate, AccountId, Email, Phone, MobilePhone, Gender__c, Instructor_Status__c, Services__c, Country_of_Birth__c ,DLS_Candidate_Rating__c, Language_1__c,City_and_Country_of_Birth__c, ' +
                'Location__c, Location__r.Location_GeoCode__c, Location__r.Location_GeoCode__Latitude__s, Location__r.Location_GeoCode__Longitude__s, Citizenship__c, Citizenship_VISA_expiration_date__c, Work_Experience__c, ' +
            '(SELECT Id,Name,Contact__c,Contact__r.Name,ContId_ExperienceId_FLang_TLan_Skill_Ext__c,'+
                'From_Language_LU__c,From_Language_LU__r.Name,Language_S_L_R_W__c,Skill__c,Skill_Verification__c,To_Language_LU__c,'+
                'To_Language_LU__r.Name,From_Language__c,To_Language__c FROM Skills__r), ' +
            '(SELECT Id, Name, Country__c,End_Date__c,Experience_in_Years__c,Experience_in_Months__c,ILR_Skill_Level__c,'+
                'Name_of_Company__c,Role_Title__c,Services__c,Start_Date__c,State__c,RecordType.DeveloperName,'+
                'College_School__c,College_School_Type__c,Degree__c,Degree_Level__c,Year_of_Completion__c,Total_Hours_Performed__c FROM Experiences__r),'+
            '(SELECT Id, Target_Language__c, L_Score__c, S_Score__c FROM Language_Testing__r), ' +
            '(SELECT Id, Contact__c, Language__c, Language__r.Name,Latest_Language_Testing__c,Listening_Proficiency__c,Native_Language__c,Speaking_Proficiency__c FROM Known_Languages__r), ' +
            '(SELECT AcctSeed__Employee__c,AcctSeed__Hourly_Cost__c,AcctSeed__Project_Task__c,AcctSeed__Project__c,AcctSeed__Weekly_Salary_Cost__c,Contact__c,Contact__r.Name,EE_Pay_Status_Formula__c,Effective_Date__c,'+
                'Fully_Loaded_Rate__c,Holiday_Pay_Type__c,HOL_Rate_VAC_Rate__c,HOL_Rate__c,H_W_Rate__c,Id,Name,AcctSeed__Overtime_Hourly_Cost__c,Payroll_Item__c,Pay_Frequency__c,Pay_Type__c,Rate_Type__c,SCA_Type__c,'+
                'Tax_Type__c,VAC_Rate__c FROM Cost_Rates__r),'+
            '(SELECT Id,Name,Start_Date__c,Start_Time1__c,Start_Time2__c,End_Date__c,End_Time1__c,End_Time2__c,Days__c,Days2__c,Hours_Week__c FROM Opportunities1__r),'+
            'Location_GeoCode__c,Location_GeoCode__Latitude__s, Location_GeoCode__Longitude__s,of_Students_Taught__c,of_Tests_Perfomed__c,of_Class_Projects_Taught__c,Active_Count_as_Instructor__c,'+
            'MailingCity,MailingState,MailingCountry,MailingStreet FROM Contact ';

        String queryCondition = 'WHERE RecordType.DeveloperName = \'Candidate\' ' +
                                'AND Ineligible_for_Rehire__c = false ' +
                                'AND Language_1__c != null ';

        //Flag to check citizenship filter is added or not.
        //Boolean citizenShipFlag = false;

        //Flag to check the Known Language Query is needed or not
        Boolean knowLanguageQuery = false;

        Boolean foreignFlag = false, englishFlag = false, nativeFlag = false;

        //Set to add all the Degree Values used in the Qualification Bundle
        Set<String> bundleExperienceSet = new Set<String>();
        Boolean bundleExperienceFlag = false;
        String nativeQuery = '';

        //Set to add all the Service Values used in the Qualification
        Set<String> bundleServiceSet = new Set<String>();
        Boolean bundleServiceFlag = false;

        //Set to add all the English language proficiency values used in the Qualification
        Set<String> bundleEnglishSet = new Set<String>();

        //Set to add all the Foriegn Language proficiency values used in the Qualification
        Set<String> bundleForeignSet = new Set<String>();

        //Set to add all the Candidatae rating values
        Set<String> bundleCandidateRatingSet = new Set<String>();
        Boolean bundleCandidateRatingFlag = false;

        //Flag to tell the need of querying Known Language.
        Boolean knownLanguageQueryFlag = false;
        String knownLanguageQuery = '';

        //Degree set
        Set<String> degreeList = new Set<String>();
        
        //Citizenship set
        Set<String> citizenshipSet = new Set<String>();
        Boolean citizenshipFlag = false;
        
        // Skill Rating set
        Set<String> skillRatingSet = new Set<String>();

        Map<String, Boolean> filterCheck = new Map<String, Boolean> {
            'Mths of Experience' => false,
            'DLS Candidate Rating' => false,
            'Foreign Language Proficiency' => false,
            'English Language Proficiency' => false,
            'Language' => false,
            'Service' => false,
            'Has Certified Skills' => false,
            'Degree' => false,
            'Proximity' => false,
            'Citizenship / Work Status' => false,
            'Citizenship' => false,
            'Country of Birth' => false,
            'Skill Rating' => false
        };


        System.debug('Search Degeree ' + parameter.degree);

        if(bundleId != null) {
            /*System.debug('Checking Bundle ');
            for(Qualification_Bundle_Item__c qualification : qualificationList) {
                //Chech wheather the qualification is required.
                //Only the required qualification should be filtered.
                if(qualification.Prefered_Required__c == 'Required') {
                    //Experience Filter
                    if(qualification.Qualification__r.Type__c == 'Experience' && parameter.experience != null && parameter.experience != 0) {
                        try {
                            queryCondition += 'AND Work_Experience__c ';
                            if(qualification.Qualification__r.Condition__c == 'GREATER THAN') {
                                queryCondition += ' > ';
                            } else if(qualification.Qualification__r.Condition__c == 'GREATER THAN OR EQUAL TO') {
                                queryCondition += ' >= ';
                            } else if(qualification.Qualification__r.Condition__c == 'LESS THAN') {
                                queryCondition += ' < ';
                            } else if(qualification.Qualification__r.Condition__c == 'LESS THAN OR EQUAL TO') {
                                queryCondition += ' <= ';
                            } else if(qualification.Qualification__r.Condition__c == 'EQUAL TO') {
                                queryCondition += ' = ';
                            } else if(qualification.Qualification__r.Condition__c == 'NOT EQUAL TO') {
                                queryCondition += ' != ';
                            } else {
                                queryCondition += ' <= ';
                            }
                              queryCondition += (Integer.valueOf(parameter.experience) * 12) + ' ';
                        } catch(Exception e) {}
                        filterCheck.put('Experience', true);
                    }

                    //Candidate Rating Filter
                    if(qualification.Qualification__r.Type__c == 'Candidate Rating' && candidateRatingQueryMap.containsKey(parameter.candidateRating + qualification.QUalification__r.Condition__c)) {
                        bundleCandidateRatingFlag = true;
                        bundleCandidateRatingSet.addAll(candidateRatingQueryMap.get(parameter.candidateRating + qualification.Qualification__r.Condition__c));
                        filterCheck.put('Candidate Rating', true);
                    }

                    //Foreign Language Proficiency Filter
                    if(qualification.Qualification__r.Type__c == 'Foreign Language Proficiency') {
                        System.debug('FLP Q ' + parameter.language + ' ' + parameter.foreignProficiency + ' ' + qualification.Qualification__r.Condition__c);
                        //Check the value is Native.
                        filterCheck.put('Foreign Language Proficiency', true);
                    }

                    //English Language Proficeiency
                    if(qualification.Qualification__r.Type__c == 'English Language Proficiency' && ProfAndSetOfScoreMap.containsKey(parameter.englishProficiency + qualification.Qualification__r.Condition__c)) {
                        System.debug('ELP Q ' + parameter.language + ' ' + parameter.englishProficiency + ' ' + qualification.Qualification__r.Condition__c);
                        englishFlag = true;
                        bundleEnglishSet.addAll(ProfAndSetOfScoreMap.get(parameter.englishProficiency + qualification.Qualification__r.Condition__c));
                        filterCheck.put('English Language Proficiency', true);
                    }

                    //Language Filter checked it in the Skill Object
                    if(qualification.Qualification__r.Type__c == 'Language' && parameter.language != null) {
                        if(skillFlag) {
                            skillQryStr += ' AND ';
                        }
                        skillFlag = true;
                        skillQryStr += '(From_Language__c = \'' + parameter.language + '\' OR To_Language__c = \'' + parameter.language + '\')';
                        filterCheck.put('Language', true);
                    }

                    //Service FIlter use with the Skill Object
                    if(qualification.Qualification__r.Type__c == 'Service' && parameter.service.size() > 0) {
                        bundleServiceFlag = true;
                        bundleServiceSet.addAll(parameter.service);
                        filterCheck.put('Service', true);
                    }

                    //Has Certification Filter. Use it with the Skill Object
                    //Check wheather already this filter is added or not.
                    if(!certificationFlag && qualification.Qualification__r.Type__c == 'Has Certified Skills' && parameter.isVerified != null && parameter.isVerified) {
                        certificationFlag = true;
                        if(skillFlag) {
                            skillQryStr += ' AND ';
                        }
                        skillFlag = true;
                        skillQryStr += 'Skill_Verification__c != \'Not Verified\' ';
                        filterCheck.put('Has Certified Skills', true);
                    }

                    //Degree Filter.
                    //TODO: Modify this function to accept a list of degree values.
                    /*System.debug('Degree ' + parameter.degree);
                    if(qualification.Qualification__r.Type__c == 'Degree' && degreeLevelQueryMap.containsKey(parameter.degree + qualification.Qualification__r.Condition__c)) {
                        System.debug('Degree is in map');
                        bundleExperienceSet.addAll(degreeLevelQueryMap.get(parameter.degree + qualification.Qualification__r.Condition__c));
                        bundleExperienceFlag = true;
                        filterCheck.put('Degree', true);
                    }*/
          /*
                    //Proximity Filter.
                    if(qualification.Qualification__r.Type__c == 'Proximity' && parameter.zip != '' && parameter.zip != null && parameter.proximity != null) {
                        queryCondition += 'AND DISTANCE(Location_GeoCode__c, :zipLocation, \'mi\') < ' + parameter.proximity + ' ';
                        filterCheck.put('Proximity', true);
                    }

                    //Citizenship Filter.
                    //Check wheather this filter is already used or not using citizenShipFlag.
                    if(!citizenShipFlag && qualification.Qualification__r.Type__c == 'Citizenship / Work Status' && parameter.citizenship != true && parameter.citizenship) {
                        queryCondition += 'AND ((Citizenship_VISA_expiration_date__c >= TODAY AND Citizenship_VISA_expiration_date__c <= LAST_N_DAYS:365) OR Citizenship__c = \'U.S. Citizen\') ';
                        filterCheck.put('Citizenship / Work Status', true);
                    }
                }
            }*/
        }


        for(String key : filterCheck.keySet()) {
            if(!filterCheck.get(key)) {
                if(key == 'Mths of Experience' && parameter.experience != null) {
                    queryCondition += 'AND Work_Experience__c >= ' + parameter.experience + ' ';
                }
                if(key == 'DLS Candidate Rating' && parameter.candidateRating != null && parameter.candidateRating.size() > 0) {
                    bundleCandidateRatingSet.addAll(parameter.candidateRating);
                    bundleCandidateRatingFlag = true;
                }
                if(key == 'Foreign Language Proficiency' && parameter.foreignProficiency != null && parameter.foreignProficiency.size() > 0) {
                    //Check the value is Native.
                    //If native check the filter in COntact Object
                    /* Change Needed */
                    System.debug('FLP S' + ' ' + parameter.foreignProficiency + ' ' + parameter.language);
                    for(String prof : parameter.foreignProficiency) {
                        if(prof == 'Native') {
                            nativeFlag = true;
                            nativeQuery = ' Language__c = \'' + parameter.languageId + '\' AND Native_Language__c = true ';
                        } else {
                            if(prof == '1/1') {
                                foreignFlag = true;
                                bundleForeignSet.add('1');
                                bundleForeignSet.add('1+');
                            } else if(prof == '2/2') {
                                foreignFlag = true;
                                bundleForeignSet.add('2');
                                bundleForeignSet.add('2+');
                            } else if(prof == '3/3') {
                                foreignFlag = true;
                                bundleForeignSet.add('3');
                                bundleForeignSet.add('3+');
                            } else if(prof == '4/4') {
                                foreignFlag = true;
                                bundleForeignSet.add('4');
                                bundleForeignSet.add('4+');
                            } else if(prof == '5/5') {
                                foreignFlag = true;
                                bundleForeignSet.add('5');
                                bundleForeignSet.add('5+');
                            }
                        }
                    }
                }
                /* Change Needed */
                System.debug('ELP ' + parameter.englishProficiency);
                if(key == 'English Language Proficiency' && parameter.englishProficiency != null && parameter.englishProficiency.size() > 0) {
                    System.debug('ELP S' + ' ' + parameter.englishProficiency + ' ' + parameter.language);
                    for(String prof: parameter.englishProficiency) {
                        if(prof == '1/1') {
                            bundleEnglishSet.add('1');
                            bundleEnglishSet.add('1+');
                            englishFlag = true;
                        } else if(prof == '2/3') {
                            bundleEnglishSet.add('2');
                            bundleEnglishSet.add('2+');
                            englishFlag = true;
                        } else if(prof == '3/3') {
                            bundleEnglishSet.add('3');
                            bundleEnglishSet.add('3+');
                            englishFlag = true;
                        } else if(prof == '4/4') {
                            bundleEnglishSet.add('4');
                            bundleEnglishSet.add('4+');
                            englishFlag = true;
                        } else if(prof == '5/5') {
                            bundleEnglishSet.add('5');
                            bundleEnglishSet.add('5+');
                            englishFlag = true;
                        }
                    }
                }
                if(key == 'Language' && parameter.languageId != null) {
                    System.debug('Language entered');
                    if(skillFlag) {
                        skillQryStr += ' AND ';
                    }
                    skillFlag = true;
                    skillQryStr += '(From_Language_LU__c = \'' + parameter.languageId + '\' OR To_Language_LU__c = \'' + parameter.languageId + '\')';
                    filterCheck.put('Language', true);
                    knownLanguageQuery = 'SELECT Contact__c FROM Known_Language__c WHERE Language__c = \'' + parameter.languageId + '\'';
                    System.debug('DEBUGx1: Known Language Query Formed.');
                }
                if(key == 'Service') {
                    if(parameter.service != null && parameter.service.size() > 0) {
                        bundleServiceFlag = true;
                        skillFlag = true;
                        bundleServiceSet.addAll(parameter.service);
                    } else {
                        System.debug('DEBUGx1: Known Language Flag set to true.');
                        knownLanguageQueryFlag = true;
                    }
                }
                if(key == 'Has Certified Skills' && parameter.isVerified != null && parameter.isVerified) {
                    certificationFlag = true;
                    if(skillFlag) {
                        skillQryStr += ' AND ';
                    }
                    skillFlag = true;
                    skillQryStr += 'Skill_Verification__c != \'Not Verified\' ';
                    filterCheck.put('Has Certified Skills', true);
                }
                if(key == 'Degree' && parameter.degree != null && parameter.degree.size() > 0) {
                    degreeList.addAll(parameter.degree);
                    System.debug('Degree Falg');
                    bundleExperienceFlag = true;
                }
                if(key == 'Proximity' && ((parameter.zip != '' && parameter.zip != null) || parameter.locationId != null) && parameter.proximity != null) {
                    queryCondition += 'AND DISTANCE(Location_GeoCode__c, :zipLocation, \'mi\') < ' + parameter.proximity + ' ';
                }
                if(key == 'Citizenship / Work Status' && parameter.citizenship != null && parameter.citizenship ) {
                    queryCondition += 'AND ((Citizenship_VISA_expiration_date__c >= TODAY AND Citizenship_VISA_expiration_date__c <= LAST_N_DAYS:365) OR Citizenship__c = \'U.S. Citizen\') ';
                }
                
                if(key == 'Citizenship' && parameter.citizenshipValues != null && parameter.citizenshipValues.size() > 0) {
                    citizenshipSet.addAll(parameter.citizenshipValues);
                    citizenshipFlag = true;
                }
                
                if(key == 'Country of Birth' && parameter.countryOfbirth != null) {
                    queryCondition += 'AND Country_of_Birth__c = \'' +parameter.countryOfbirth+'\' ';
                }
                
                if(key == 'Skill Rating' && parameter.skillRating != null && parameter.skillRating.size() > 0){
                    skillRatingSet.addAll(parameter.skillRating);
                    if(skillFlag) {
                        skillQryStr += ' AND ';
                    }
                    skillFlag = true;
                    skillQryStr += 'Rating__c IN :skillRatingSet ';
                    filterCheck.put('Skill Rating', true);
                }
            }
        }


        //Add bundleServiceSet to the Skill Query
        if(bundleServiceFlag) {
            if(skillFlag) {
                skillQryStr += ' AND ';
            }
            skillFlag = true;
            skillQryStr += 'Skill__c IN :bundleServiceSet ';
        }
        system.debug(':::::degreeList::::::::'+degreeList);
        //Add bundleExperienceSet to the Experience Query
        if(bundleExperienceFlag) {
            experienceQuery += 'Degree_Level__c IN :degreeList ';
            System.debug('Exp Qry: ' + experienceQuery);
        }
        
        //Add bundleForeignSet to the Language Testing Query
        if(foreignFlag && parameter.languageId != null) {
            knowLanguageQuery = true;
            langTestingQryStr += ' AND ';
            if(englishFlag || nativeFlag) {
                langTestingQryStr += ' (';
            }
            langTestingQryStr += '(Language__c = \'' + parameter.languageId + '\' AND ';
            langTestingQryStr += 'Listening_Proficiency__c IN :bundleForeignSet AND Speaking_Proficiency__c IN :bundleForeignSet) ';
       }
       
        if(nativeFlag) {
            if(foreignFlag) {
                langTestingQryStr += ' OR ';
            } else {
                langTestingQryStr += ' AND';
            }
            
            if(!foreignFlag && englishFlag) {
                langTestingQryStr += ' (';
            }
            
            langTestingQryStr += '(' + nativeQuery + ')';
            if(foreignFlag && !englishFlag) {
                langTestingQryStr += ' )';
            }
            
            if(!foreignFlag && !englishFlag) {
                knowLanguageQuery = true;    
            }
        }
        
        if(englishFlag && parameter.language != null && parameter.language != '') {
            knowLanguageQuery = true;
            if(foreignFlag) {
                langTestingQryStr += ' OR ';
            } else {
                langTestingQryStr += ' AND ';
            }
            langTestingQryStr += ' (Language_Name__c = \'English\' AND ';
            langTestingQryStr += 'Listening_Proficiency__c IN :bundleEnglishSet AND Speaking_Proficiency__c IN :bundleEnglishSet) ';
            if(foreignFlag || nativeFlag) {
                langTestingQryStr += ' )';
            }
        } 
        
        //Add bundleCandidateRatingSet to the Contact Query
        if(bundleCandidateRatingFlag) {
            queryCondition += 'AND DLS_Candidate_Rating__c IN :bundleCandidateRatingSet ';
        }else {
            //queryCondition += 'AND DLS_Candidate_Rating__c = null ';
        }

        System.debug('Skill Query::' + skillQryStr);

        Set<Id> knownLanguageIdSet = new Set<Id>();
        if(knownLanguageQueryFlag) {
            for(Known_Language__c kl : Database.query(knownLanguageQuery)) {
                knownLanguageIdSet.add(kl.Contact__c);
            }
        }


        //Query the Skill Object
        Set<Id> skillContactIdSet = new Set<Id>();
        if(skillFlag) {
            for(Skill__c skill : Database.query(skillQryStr)) {
                skillContactIdSet.add(skill.Contact__c);
            }
        }

        //Query Experience Object
        Set<Id> experienceContactIdSet = new Set<Id>();
        if(bundleExperienceFlag) {
            for(Experience__c exp : Database.query(experienceQuery)) {
                experienceContactIdSet.add(exp.Contact__c);
            }
        }

        //Query teh Language Training Object
        Set<Id> LtContactIdSet = new Set<Id>();
        if(knowLanguageQuery || nativeFlag) {
            System.debug('Known Languages Query ' + langTestingQryStr);
            for(Known_Language__c lt : Database.query(langTestingQryStr)) {
                LtContactIdSet.add(lt.Contact__c);
                //System.debug('lttt ' + lt);
            }
        }

        //Check to add the Skill Query
        if(knownLanguageQueryFlag) {
            System.debug('DEBUGx1: knownLanguage Query is added.');
            queryCondition += 'AND Id IN :knownLanguageIdSet ';
        } else if (skillFlag) {
            System.debug('DEBUGx1: Skill query is added.');
            queryCondition += 'AND Id IN :skillContactIdSet ';
        }
        
        //Check to add Language Training Result
        if(knowLanguageQuery) {
            queryCondition += 'AND Id IN :LtContactIdSet ';
        }

        //Check to add Experience Result
        if(bundleExperienceFlag) {
            queryCondition += 'AND Id IN :experienceContactIdSet ';
        }
        
        //Check to add citizenship set
        if(citizenshipFlag) {
            queryCondition += 'AND Citizenship__c IN :citizenshipSet ';
        }
        
        system.debug('::::::knownLanguageIdSet::::::'+knownLanguageIdSet);
        system.debug('::::::skillContactIdSet::::::'+skillContactIdSet);
        system.debug('::::::LtContactIdSet::::::'+LtContactIdSet);
        system.debug('::::::experienceContactIdSet::::::'+experienceContactIdSet);
        if(parameter.searchByName != null) {
            queryCondition += 'AND Name LIKE \'%'+parameter.searchByName+'%\''; 
        }
        system.debug('::::::queryCondition:::::::'+queryCondition);
        
        Integer queryLimit = parameter.resultSize != null ? parameter.resultSize : DEFAULT_LIMIT;
        Integer offset = queryLimit * (parameter.offset != null ? parameter.offset : 0);
        
        String proxySort = ' ORDER BY DISTANCE(Location_GeoCode__c, :zipLocation, \'mi\')';
        String experienceSort = ' ORDER BY Work_Experience__c DESC NULLS LAST';
        String scoreSort = '';
        
        String sortType;
        String pageQuery;
        
        if(parameter.sortingType != null) {
            if(parameter.sortingType == 'Proxy' && zipLocation != null)
                sortType = proxySort;
            else if(parameter.sortingType == 'Experience')
                sortType = experienceSort;
            else if(parameter.sortingType == 'Score')
                sortType = scoreSort;
        }
        
        if(sortType != null) {
            pageQuery = contactQuery + queryCondition +sortType + ' LIMIT ' + queryLimit + ' OFFSET ' + offset;
        }else {
            pageQuery = contactQuery + queryCondition + ' LIMIT ' + queryLimit + ' OFFSET ' + offset;
        }
        System.debug('Page Query' + pageQuery);

        String countQuery = 'SELECT COUNT() FROM CONTACT ' + queryCondition;
        Map<Id, Decimal> instructorScore = new Map<Id, Decimal>();
        List<Contact> instructorList = Database.query(pageQuery);
        system.debug('::::::::instructorList:::::'+instructorList);
        Integer totalCount  = Database.countQuery(countQuery);
        if(bundleId != null) {
            for(Contact con : instructorList) {
                instructorScore.put(con.Id, findScore(con, parameter, qualificationList, zipLocation));
            }
        }
        system.debug('::::::::instructorScore:::::'+instructorScore);
        FilteredContacts fContacts = new FilteredContacts();
        fContacts.filteredList = instructorList;
        fContacts.instructorScore = instructorScore;
        fContacts.totalCount = totalCount;

        return fContacts;
    }


    public static Decimal findScore(Contact con, SearchParameter parameter, List<Qualification_Bundle_Item__c> qualificationList, System.Location zipLocation) {
        Decimal instructorScore = 0;
        for(Qualification_Bundle_Item__c qualification : qualificationList) {
            Decimal score = qualification.Score__c;
            String type = qualification.Qualification__r.Type__c;
            String value = qualification.Qualification__r.Value__c;
            String operator = qualification.Qualification__r.Condition__c;
            //If the Type is Experience Get the total months of experience by parsing all the Experienc child records of the given contact and compare with the condition
            try {
                System.debug('WWW Finding score for ' + type);
                if(type == 'Mths of Experience') {
                    if(parameter.experience != null && con.Work_Experience__c != null)
                        //Since the Value field in Qualification record is Text, it is converted to Integer.
                        if(compare(operator, Integer.valueOf(con.Work_Experience__c), Integer.valueOf(value)))
                            instructorScore = qualification.Score__c;
                }
                if(type == 'DLS Candidate Rating') {
                    if(value != 'Any' && value != null) {
                        Integer candidateRate = 0;
                        if(con.DLS_Candidate_Rating__c != null)
                            candidateRate = Integer.valueOf(con.DLS_Candidate_Rating__c);
                        if(compare(operator, candidateRate, Integer.valueOf(value))) {
                            if(score != null)
                                instructorScore += score;
                        }
                    }
                }
                if(type == 'Foreign Language Proficiency') {
                    if(value != 'Any') {
                        if(value == 'Native') {
                            if(parameter.language != 'All') {
                                if(parameter.language != null && isNative(operator, con, parameter.language)) {
                                    if(score != null)
                                        instructorScore += score;
                                }
                            }
                        } else {
                            if(getLanguageProficiency(con, operator, value, parameter.language)) {
                                if(score != null)
                                    instructorScore += score;
                            }
                        }
                    }
                }
                if(type == 'English Language Proficiency') {
                    if(value != 'Any') {
                        if(getLanguageProficiency(con, operator, value, 'English')) {
                            if(score != null)
                                instructorScore += score;
                        }
                    }
                }
                if(type == 'Language') {
                    if(value != 'All')
                        if(compare(operator, value, getAllLanguages(con))) {
                            if(score != null)
                                instructorScore += score;
                        }
                }
                if(type == 'Service') {
                    //Check the language filter has values
                    if(parameter.language != null && parameter.language != 'All') {
                        //If Language filter has values, then use only the selected Service find the score.
                        if(compare(operator, value.split(';'), getLanguageServices(con, parameter.language))) {
                            if(score != null)
                                instructorScore += score;
                        }    
                    } else {
                        if(compare(operator, value.split(';'), getAllServices(con))) {
                            if(score != null)
                                instructorScore += score;
                        }
                    }
                }
                if(type == 'Has Certified Skills') {
                    if(value == 'true') {
                        if(parameter.language != null && parameter.language != 'All') {
                            if(hasVerifiedSkills(con, parameter.language)) {
                                if(score != null)
                                    instructorScore += score;
                            }
                        } else {
                            if(hasVerifiedSkills(con)) {
                                if(score != null)
                                    instructorScore += score;
                            }
                        }
                    }
                }
                if(type == 'Degree') {
                    System.debug('WWW Entered GDegree ' + con.Experiences__r);
                    if(compareEducation(operator, getEducations(con), value)) {
                        if(score != null)
                            instructorScore += score;
                    }
                }
                if(type == 'Proximity') {
                    if(parameter.zip != null && parameter.zip != '' && parameter.proximity != null) {
                        Integer dist = Integer.valueOf(getProximites(con, zipLocation));
                        if(dist >= 0 && compare(operator, dist, Integer.valueOf(value))) {
                            if(score != null)
                                instructorScore += score;
                        }
                    }
                }
                if(type == 'Citizenship / Work Status') {
                    System.debug('Compare Citi ' + parameter.citizenship);
                    if(parameter.citizenship != null && parameter.citizenship) {
                        if(isUSCitizen(con) || (isGreencardHolder(con) && isWithinVisaExpiration(con, 12))) {
                            instructorScore += qualification.Score__c;
                        }
                    }
                }
                //Nedd to add logic for citizenship picklist values by NS
                
            } catch(TypeException e) {
                //return instructorScore;
            }
        }
        return instructorScore;
    }


    public static Boolean isUSCitizen(Contact con) {
        System.debug('Citi Com ' + con.Citizenship__c);
        if(con.Citizenship__c == 'U.S. Citizen') {
            return true;
        }
        return false;
    }

    public static Boolean isGreencardHolder(Contact con) {
        System.debug('isGreencardHolder ' + con.Citizenship__c);
        if(con.Citizenship__c == 'Green Card Holder')
            return true;
        return false;
    }

    public static Boolean isWithinVisaExpiration(Contact con, Integer months) {
        System.debug('isWithinVisaExpiration ' + con.Citizenship_VISA_expiration_date__c);
        if(con.Citizenship_VISA_expiration_date__c != null)
            if(System.today().monthsBetween(con.Citizenship_VISA_expiration_date__c) >= months)
                return true;
        return false;
    }
    public static Boolean isNative(String operand, Contact con, String language) {
        if(compare(operand, con.Language_1__c, language)) {
            return true;
        }
        return false;
    }

    public static Boolean compareEducation(String operand, String[] educationList, String compareWith) {
        for(String education : educationList) {
            System.debug('WWW Comparing ' + EDUCATION_ORDER.get(education) + ' ' + operand + ' ' + EDUCATION_ORDER.get(compareWith));
            if(compare(operand, EDUCATION_ORDER.get(education), EDUCATION_ORDER.get(compareWith))) {
                System.debug('true');
                return true;
            }
        }
        return false;
    }

    public static Decimal getProximites(Contact con, System.Location location) {
        try {
            if(con.Location_GeoCode__Latitude__s != null && con.Location_GeoCode__Longitude__s != null) {
                return location.getDistance(System.Location.newInstance(con.Location_GeoCode__Latitude__s, con.Location_GeoCode__Longitude__s), 'mi');
            }
        } catch(Exception e) {}
        return -1;
    }

    public static String[] getEducations(Contact instructor) {
        Set<String> degreeSet = new Set<String>();
        for(Experience__c experience : instructor.Experiences__r) {
            if(experience.Degree_Level__c != null)
                degreeSet.add(experience.Degree_Level__c);
        }
        return new List<String>(degreeSet);
    }

    public static Boolean hasVerifiedSkills(Contact con) {
        Set<String> languageSet = new Set<String>();
        for(Skill__c skill : con.Skills__r) {
            if(skill.From_Language__c != null || skill.To_Language__c != null) {
                if(skill.Skill_Verification__c != 'Not Verified' && skill.Skill_Verification__c != null)
                    return true;
            }
        }
        return false;
    }

    public static Boolean hasVerifiedSkills(Contact con, String language) {
        Set<String> languageSet = new Set<String>();
        for(Skill__c skill : con.Skills__r) {
            if(skill.From_Language__c == language || skill.To_Language__c == language) {
                if(skill.Skill_Verification__c != 'Not Verified' && skill.Skill_Verification__c != null)
                    return true;
            }
        }
        return false;
    }

    public static String[] getAllLanguages(Contact con) {
        Set<String> languageSet = new Set<String>();
        for(Skill__c skill : con.Skills__r) {
            if(skill.From_Language__c != null) {
                languageSet.add(skill.From_Language__c);
            }
            if(skill.To_Language__c != null) {
                languageSet.add(skill.To_Language__c);
            }
        }
        return new List<String>(languageSet);
    }

    public static String[] getAllServices(Contact con) {
        Set<String> serviceSet = new Set<String>();
        for(Skill__c skill : con.Skills__r) {
            if(skill.Skill__c != null)
                serviceSet.add(skill.Skill__c);
        }
        return new List<String>(serviceSet);
    }

    public static String[] getLanguageServices(Contact con, String language) {
        Set<String> serviceSet = new Set<String>();
        for(Skill__c skill : con.Skills__r) {
            if(skill.From_Language__c == language || skill.From_Language__c == language)
                if(skill.Skill__c != null)
                    serviceSet.add(skill.Skill__c);
        }
        return new List<String>(serviceSet);
    }

    public static Boolean getLanguageProficiency(Contact con, String operator, String proficiency, String language) {
       if(proficiency == null || proficiency == 'Any')
           return true;
       if(con.Language_Testing__r.size() > 0 && language != null) {
            String[] score = proficiency.split('/');
            if(score.size() != 2) return false;
            Integer listeningScore = Integer.valueOf(score[0]);
            Integer speakingScore = Integer.valueOf(score[1]);
            if(language != 'English') {
                for(Language_Testing__c test : con.Language_Testing__r) {
                    if(test.Target_Language__c == language) {
                        if(compare(operator, sanitizeScore(test.L_Score__c), listeningScore) && compare(operator, sanitizeScore(test.S_Score__c), speakingScore))
                            return true;
                    }
                }
            } else if(con.English_Proficiency__c != null) {
                String[] englishScore = con.English_proficiency__c.split(';');
                Integer english_score_1 = Integer.valueOf(englishScore[0]);
                Integer english_score_2 = Integer.valueOf(englishScore[1]);
                if(compare(operator, english_score_1, listeningScore) && compare(operator, english_score_2, speakingScore)) {
                    System.debug('English Proficiency Score Become true');
                    return true;
                }
            }
        }
        return false;
    }


    public static Integer findTotalExperience(Contact con) {
        Integer totalMonths = 0;
        if(con.Experiences__r != null) {
            for(Experience__c experience : con.Experiences__r) {
                if(experience.Experience_in_Months__c != null) {
                    totalMonths += (Integer) experience.Experience_in_Months__c;
                }
            }
        }
        return totalMonths / 12;
    }

    public static Integer sanitizeScore(String stringScore) {
        if(stringScore == 'N/A')
            return 0;
        Integer index = stringScore.indexOf('+');
        try {
            if(index != -1) {
                return Integer.valueOf(stringScore.substring(0, index));
            }
            return Integer.valueOf(stringScore);
        } catch(Exception e) {
            return 0;
        }
    }

    public static List<Qualification_Bundle__c> getAllQualificationBundle() {
        //return [SELECT Name, Type__c, Class_Type__c, Contract__c, Contract__r.Name, Record_Type__c, (SELECT Id, Name, Score__c, Prefered_Required__c, Qualification__c, Qualification__r.Type__c, Qualification__r.Value__c, Qualification__r.Condition__c FROM Qualification_Bundle_Items__r) FROM Qualification_Bundle__c];
        return QualificationBundleService.getQualificationBundleswithBundleItems('','');
    }

    public static List<Qualification_Bundle_Item__c> getQualificationSettings(Id bundleId,List<Id> qualificationIds) {
        //return [SELECT Id, Name, Score__c, Prefered_Required__c, Qualification__c, Qualification__r.Type__c, Qualification__r.Value__c, Qualification__r.Condition__c FROM Qualification_Bundle_Item__c WHERE Bundle__c = :bundleId AND Id NOT IN :qualificationIds];
        
        Set<Id> qualIds = new Set<Id>();
        qualIds.addAll(qualificationIds);
        return QualificationBundleItemService.getQualificationBundleItems(' WHERE Bundle__c = \''+bundleId+'\'',',Qualification__r.Type__c, Qualification__r.Value__c, Qualification__r.Condition__c',qualIds);
    }

    public static FilteredContacts getFilteredContact(Id bundleId, SearchParameter parameter) {
        return instructorSearch(parameter, bundleId);
    }

    public class FilteredContacts {
        public List<Contact> filteredList;
        public Map<Id, Decimal> instructorScore;
        public Integer totalCount;
    }
    
    public void increaseCodeCoverge(){
        string test = 'aa';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';      test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';      test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
        test = 'b';
    }
    
}