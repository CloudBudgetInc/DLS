@isTest
global class RChilliJSONDummyData {
    
    //@isTest
     public String jsonStr () {
        
       String resumeJson = '{'+
          '"ResumeParserData" : {'+
            '"ResumeFileName" : "TesDoc.doc",'+
            '"ResumeLanguage" : {'+
              '"Language" : "English",'+
              '"LanguageCode" : "en"'+
            '},'+
            '"ParsingDate" : "test date",'+
            '"ResumeCountry" : {'+
              '"Country" : "xxx",'+
              '"Evidence" : "PresentAddress",'+
              '"CountryCode" : {'+
                '"IsoAlpha2" : "xx",'+
                '"IsoAlpha3" : "xxx",'+
                '"UNCode" : "224"'+
              '}'+
            '},'+
            '"Name" : {'+
              '"FullName" : "Test Name",'+
              '"TitleName" : "",'+
              '"FirstName" : "Test",'+
              '"MiddleName" : "R.",'+
              '"LastName" : "Name",'+
              '"FormattedName" : "Test R. Name",'+
              '"ConfidenceScore" : 10'+
            '},'+
            '"DateOfBirth" : "",'+
            '"Gender" : "",'+
            '"FatherName" : "",'+
            '"MotherName" : "",'+
            '"MaritalStatus" : "",'+
            '"Nationality" : "",'+
            '"LanguageKnown" : [ {'+
              '"Language" : "Test Language",'+
              '"LanguageCode" : "xx"'+
            '} ],'+
            '"UniqueID" : "",'+
            '"LicenseNo" : "",'+
            '"PassportDetail" : {'+
              '"PassportNumber" : "",'+
              '"DateOfExpiry" : "",'+
              '"DateOfIssue" : "",'+
              '"PlaceOfIssue" : ""'+
            '},'+
            '"PanNo" : "",'+
            '"VisaStatus" : "",'+
            '"Email" : [ {'+
              '"EmailAddress" : "mytest.email@yahoo.com",'+
              '"ConfidenceScore" : 10'+
            '} ],'+
            '"PhoneNumber" : [ {'+
              '"Number_x" : "303.527.1220",'+
              '"ISDCode" : "+2",'+
              '"OriginalNumber" : "204-247-0520",'+
              '"FormattedNumber" : "+2 204-557-0660",'+
              '"Type" : "Phone",'+
              '"ConfidenceScore" : 10'+
            '} ],'+
            '"WebSite" : [ {'+
              '"Type" : "",'+
              '"Url" : ""'+
            '} ],'+
            '"Address" : [ {'+
              '"Street" : "1228 11th Street DE Apmt. 169",'+
              '"City" : "Test DC",'+
              '"State" : "",'+
              '"StateIsoCode" : "",'+
              '"Country" : "",'+
              '"CountryCode" : {'+
                '"IsoAlpha2" : "",'+
                '"IsoAlpha3" : "",'+
                '"UNCode" : ""'+
              '},'+
              '"ZipCode" : "80020",'+
              '"FormattedAddress" : "1228 11th Street DE Apt. 169, Test DC, 70020",'+
              '"Type" : "Present",'+
              '"ConfidenceScore" : 8'+
            '} ],'+
            '"Category" : "test Services",'+
            '"SubCategory" : "test",'+
            '"CurrentSalary" : {'+
              '"Amount" : "",'+
              '"Symbol" : "",'+
              '"Currency_x" : "",'+
              '"Unit" : "",'+
              '"Text" : ""'+
            '},'+
            '"ExpectedSalary" : {'+
              '"Amount" : "",'+
              '"Symbol" : "",'+
              '"Currency_x" : "",'+
              '"Unit" : "",'+
              '"Text" : ""'+
            '},'+
            '"Qualification" : "test BE",'+
            '"SegregatedQualification" : [ {'+
              '"Institution" : {'+
                '"Name" : "Test University",'+
                '"Type" : "University",'+
                '"ConfidenceScore" : 10,'+
                '"Location" : {'+
                  '"City" : "MyCity",'+
                  '"State" : "Test State",'+
                  '"StateIsoCode" : "",'+
                  '"Country" : "",'+
                  '"CountryCode" : {'+
                    '"IsoAlpha2" : "",'+
                    '"IsoAlpha3" : "",'+
                    '"UNCode" : ""'+
                  '}'+
                '}'+
              '},'+
              '"Degree" : {'+
                '"DegreeName" : "B.Sc",'+
                '"NormalizeDegree" : "Bachelor of Arts",'+
                '"Specialization" : [ "Spanish" ],'+
                '"ConfidenceScore" : 10'+
              '},'+
              '"FormattedDegreePeriod" : "2023",'+
              '"StartDate" : "",'+
              '"EndDate" : "Test Date",'+
              '"Aggregate" : {'+
                '"Value" : "",'+
                '"MeasureType" : ""'+
              '}'+
            '}],'+
            '"Certification" : "",'+
            '"SegregatedCertification" : [ {'+
              '"CertificationTitle" : "",'+
              '"Authority" : "",'+
              '"CertificationCode" : "",'+
              '"IsExpiry" : "",'+
              '"StartDate" : "",'+
              '"EndDate" : "",'+
              '"CertificationUrl" : ""'+
            '} ],'+
            '"SkillBlock" : "test vale",'+
            '"SkillKeywords" : "Learning",'+
            '"SegregatedSkill" : [ {'+
              '"Type" : "BehaviourSkill",'+
              '"Skill" : "Learning",'+
              '"Ontology" : "",'+
              '"Alias" : "",'+
              '"FormattedName" : "",'+
              '"Evidence" : "ExperienceSection,SkillSection",'+
              '"LastUsed" : "MyDateVal",'+
              '"ExperienceInMonths" : 23'+
            '}, {'+
              '"Type" : "SoftSkill",'+
              '"Skill" : "Communication Relationship Building",'+
              '"Ontology" : "",'+
              '"Alias" : "",'+
              '"FormattedName" : "",'+
              '"Evidence" : "ExperienceSection",'+
              '"LastUsed" : "MyDateVal",'+
              '"ExperienceInMonths" : 36'+
            '}, {'+
              '"Type" : "OperationalSkill",'+
              '"Skill" : "Zambia",'+
              '"Ontology" : "",'+
              '"Alias" : "",'+
              '"FormattedName" : "",'+
              '"Evidence" : "SkillSection",'+
              '"LastUsed" : "",'+
              '"ExperienceInMonths" : 0'+
            '} ],'+
            '"Experience" : "Teacher",'+
            '"SegregatedExperience" : [ {'+
              '"Employer" : {'+
                '"EmployerName" : "Maret School",'+
                '"FormattedName" : "",'+
                '"ConfidenceScore" : 10'+
              '},'+
              '"JobProfile" : {'+
                '"Title" : "Teacher",'+
                '"FormattedName" : "Teacher",'+
                '"Alias" : "Educational teacher, Educator, Senior Teacher",'+
                '"RelatedSkills" : [ {'+
                  '"Skill" : "Communication",'+
                  '"ProficiencyLevel" : "Proficient"'+
                '}, {'+
                  '"Skill" : "Self Improvement",'+
                  '"ProficiencyLevel" : "Moderate"'+
                '} ],'+
                '"ConfidenceScore" : 9'+
              '},'+
              '"Location" : {'+
                '"City" : "MyCity",'+
                '"State" : "DC",'+
                '"StateIsoCode" : "xx-DC",'+
                '"Country" : "xxx",'+
                '"CountryCode" : {'+
                  '"IsoAlpha2" : "xx",'+
                  '"IsoAlpha3" : "xxx",'+
                  '"UNCode" : "123"'+
                '}'+
              '},'+
              '"JobPeriod" : "MyDatePeriod",'+
              '"FormattedJobPeriod" : "MyDateVal",'+
              '"StartDate" : "MyDateVal",'+
              '"EndDate" : "MyDateVal",'+
              '"IsCurrentEmployer" : "true",'+
              '"JobDescription" : "",'+
              '"Projects" : [ {'+
                '"UsedSkills" : "",'+
                '"ProjectName" : "",'+
                '"TeamSize" : ""'+
              '} ]'+
            '}],'+
            '"CurrentEmployer" : "Test School",'+
            '"JobProfile" : "Teacher",'+
            '"WorkedPeriod" : {'+
              '"TotalExperienceInMonths" : "182",'+
              '"TotalExperienceInYear" : "15.2",'+
              '"TotalExperienceRange" : "GREATER THAN 10 YEAR"'+
            '},'+
            '"GapPeriod" : "test period",'+
            '"AverageStay" : "26",'+
            '"LongestStay" : "42",'+
            '"Summary" : "",'+
            '"ExecutiveSummary" : "test",'+
            '"ManagementSummary" : "test",'+
            '"Coverletter" : "",'+
            '"Publication" : "",'+
            '"SegregatedPublication" : [ {'+
              '"PublicationTitle" : "",'+
              '"Publisher" : "",'+
              '"PublicationNumber" : "",'+
              '"PublicationUrl" : "",'+
              '"Authors" : "",'+
              '"Description" : ""'+
            '} ],'+
            '"CurrentLocation" : [ ],'+
            '"PreferredLocation" : [ ],'+
            '"Availability" : "",'+
            '"Hobbies" : "communication",'+
            '"Objectives" : "",'+
            '"Achievements" : "",'+
            '"SegregatedAchievement" : [ {'+
              '"AwardTitle" : "",'+
              '"Issuer" : "",'+
              '"AssociatedWith" : "",'+
              '"IssuingDate" : "",'+
              '"Description" : ""'+
            '} ],'+
            '"References" : "Walter",'+
            '"CustomFields" : "",'+
            '"EmailInfo" : {'+
              '"EmailTo" : " ",'+
              '"EmailBody" : " ",'+
              '"EmailReplyTo" : " ",'+
              '"EmailSignature" : " ",'+
              '"EmailFrom" : " ",'+
              '"EmailSubject" : " ",'+
              '"EmailCC" : " "'+
            '},'+
            '"Recommendations" : [ {'+
              '"PersonName" : "",'+
              '"CompanyName" : "",'+
              '"Relation" : "",'+
              '"PositionTitle" : "",'+
              '"Description" : ""'+
            '} ],'+
            '"DetailResume" : "test",'+
            '"HtmlResume" : "test",'+
            '"CandidateImage" : {'+
              '"CandidateImageData" : "",'+
              '"CandidateImageFormat" : ""'+
            '},'+
            '"TemplateOutput" : {'+
              '"TemplateOutputFileName" : "TestDoc.pdf",'+
              '"TemplateOutputData" : "test"'+
            '},'+
            '"ApiInfo" : {'+
              '"Metered" : "Yes",'+
              '"CreditLeft" : "-1",'+
              '"AccountExpiryDate" : "",'+
              '"BuildVersion" : ""'+
            '}'+
          '}'+
        '}';

       return resumeJson;
    }   
}