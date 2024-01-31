trigger LanguageTesting_Trigger on Language_Testing__c (before Insert, after Insert, before update, after update) {
    
    Map<Id,Set<String>> contIdAndLangTestSet = new Map<Id,Set<String>>();
    Map<String,Id> contIdLangAndLangTestId = new  Map<String,Id>();
    List<Skill__c> skillUpdateList = new List<Skill__c>();
    
    // Variables to populate Name field
    Set<Id> projIds = new Set<Id>();
    Set<Id> testeeIds = new Set<Id>();
    Map<Id,AcctSeed__Project__c> projMap = new Map<Id,AcctSeed__Project__c>();
    Map<Id,Contact> contactMap = new Map<Id,Contact>();
    Map<String,Integer> gradeAndMarkMap = new  Map<String,Integer> {'0'=>1,'0+'=>2,'1'=>3,'1+'=>4,'2'=>5,'2+'=>6,'3'=>7,'3+'=>8,'4'=>9,'4+'=>10,'5'=>11};
    Set<Id> finalProjIds = new Set<Id>();
    Set<Id> finalStudIds = new Set<Id>();
    Map<String,Language_Testing__c> initialLTMap = new Map<String,Language_Testing__c>();
        
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
    
        for(Language_Testing__c lang : Trigger.new) {
            if(Trigger.isInsert) {
                if(lang.Project__c != null) {
                    projIds.add(lang.Project__c);
                }
                if(lang.Testee__c != null) {
                    testeeIds.add(lang.Testee__c);
                } 
            }
            
            Language_Testing__c oldL = trigger.isUpdate ? Trigger.oldMap.get(lang.Id) : null ;
            if(trigger.isInsert || (trigger.isUpdate && (lang.L_Goal__c != oldL.L_Goal__c || lang.S_Goal__c != oldL.S_Goal__c || lang.R_Goal__c != oldL.R_Goal__c || lang.W_Goal__c != oldL.W_Goal__c 
                || lang.L_Score__c != oldL.L_Score__c || lang.S_Score__c != oldL.S_Score__c || lang.R_Score__c != oldL.R_Score__c || lang.W_Score__c != oldL.W_Score__c) )) {
                
                if(lang.L_Goal__c != null && lang.L_Goal__c != 'N/A' && lang.L_Score__c != null && lang.L_Score__c != 'N/A') {
                    if(gradeAndMarkMap.get(lang.L_Score__c) > gradeAndMarkMap.get(lang.L_Goal__c)) {
                        lang.L_Score_vs_Goal__c = 'Exceeded goal';
                    } else if(gradeAndMarkMap.get(lang.L_Score__c) == gradeAndMarkMap.get(lang.L_Goal__c)) {
                        lang.L_Score_vs_Goal__c = 'Met goal';
                    } else if(gradeAndMarkMap.get(lang.L_Score__c) < gradeAndMarkMap.get(lang.L_Goal__c)) {
                        lang.L_Score_vs_Goal__c = 'Did not meet goal';
                    }
                }
                if(lang.R_Goal__c != null && lang.R_Goal__c != 'N/A' && lang.R_Score__c != null && lang.R_Score__c != 'N/A') {
                    if(gradeAndMarkMap.get(lang.R_Score__c) > gradeAndMarkMap.get(lang.R_Goal__c)) {
                        lang.R_Score_vs_Goal__c = 'Exceeded goal';
                    } else if(gradeAndMarkMap.get(lang.R_Score__c) == gradeAndMarkMap.get(lang.R_Goal__c)) {
                        lang.R_Score_vs_Goal__c = 'Met goal';
                    } else if(gradeAndMarkMap.get(lang.R_Score__c) < gradeAndMarkMap.get(lang.R_Goal__c)) {
                        lang.R_Score_vs_Goal__c = 'Did not meet goal';
                    }
                }
                if(lang.S_Goal__c != null && lang.S_Goal__c != 'N/A' && lang.S_Score__c != null && lang.S_Score__c != 'N/A') {
                    if(gradeAndMarkMap.get(lang.S_Score__c) > gradeAndMarkMap.get(lang.S_Goal__c)) {
                        lang.S_Score_vs_Goal__c = 'Exceeded goal';
                    } else if(gradeAndMarkMap.get(lang.S_Score__c) == gradeAndMarkMap.get(lang.S_Goal__c)) {
                        lang.S_Score_vs_Goal__c = 'Met goal';
                    } else if(gradeAndMarkMap.get(lang.S_Score__c) < gradeAndMarkMap.get(lang.S_Goal__c)) {
                        lang.S_Score_vs_Goal__c = 'Did not meet goal';
                    }                    
                }
                if(lang.W_Goal__c != null && lang.W_Goal__c != 'N/A' && lang.W_Score__c != null && lang.W_Score__c != 'N/A') {
                    if(gradeAndMarkMap.get(lang.W_Score__c) > gradeAndMarkMap.get(lang.W_Goal__c)) {
                        lang.W_Score_vs_Goal__c = 'Exceeded goal';
                    } else if(gradeAndMarkMap.get(lang.W_Score__c) == gradeAndMarkMap.get(lang.W_Goal__c)) {
                        lang.W_Score_vs_Goal__c = 'Met goal';
                    } else if(gradeAndMarkMap.get(lang.W_Score__c) < gradeAndMarkMap.get(lang.W_Goal__c)) {
                        lang.W_Score_vs_Goal__c = 'Did not meet goal';
                    }                    
                }
                
                // IF any one of the Score Vs Goal Did not meet goal then the overall Score vs Goal is Did not meet goal
                if(lang.L_Score_vs_Goal__c == 'Did not meet goal' || lang.S_Score_vs_Goal__c == 'Did not meet goal' || lang.R_Score_vs_Goal__c == 'Did not meet goal' || lang.W_Score_vs_Goal__c == 'Did not meet goal') {
                    lang.Overall_Score_vs_Goal__c = 'Did not meet goals';
                // IF any one of the Score Vs Goal Exceeded goal then the overall Score vs Goal is Exceeded goal
                } else if(lang.L_Score_vs_Goal__c == 'Exceeded goal' || lang.S_Score_vs_Goal__c == 'Exceeded goal' || lang.R_Score_vs_Goal__c == 'Exceeded goal' || lang.W_Score_vs_Goal__c == 'Exceeded goal') {
                    lang.Overall_Score_vs_Goal__c = 'Exceeded Goals';
                } else if( (lang.L_Score_vs_Goal__c != null || lang.S_Score_vs_Goal__c != null || lang.R_Score_vs_Goal__c != null || lang.W_Score_vs_Goal__c != null ) &&  (lang.L_Score_vs_Goal__c == null || lang.L_Score_vs_Goal__c == 'Met goal') 
                        && (lang.S_Score_vs_Goal__c == null || lang.S_Score_vs_Goal__c == 'Met goal') 
                        && (lang.R_Score_vs_Goal__c == null || lang.R_Score_vs_Goal__c == 'Met goal') 
                        && (lang.W_Score_vs_Goal__c == null || lang.W_Score_vs_Goal__c == 'Met goal')) {
                    lang.Overall_Score_vs_Goal__c = 'Met all goals';
                }
                
                if(trigger.isInsert || (trigger.isUpdate && (lang.L_Score__c != oldL.L_Score__c || lang.S_Score__c != oldL.S_Score__c || lang.R_Score__c != oldL.R_Score__c || lang.W_Score__c != oldL.W_Score__c))) {
            
                    // To update the L/R/S Initial Vs final Score value when a new Final Test Type Language Testing Records is created or updated
                    if(lang.Test_Type__c == 'Final' && lang.Project__c != null && lang.Testee__c != null) {
                        finalProjIds.add(lang.Project__c);
                        finalStudIds.add(lang.Testee__c);
                    } 
                }               
            }
        } 
        
        if( projIds != null && projIds.size() > 0 ) {
            projMap = new Map<Id,AcctSeed__Project__c>([SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c WHERE Id IN: projIds]);
        }     
        
        if( testeeIds != null && testeeIds.size() > 0 ) {
            contactMap = new Map<Id,Contact>([SELECT Id,Name FROM Contact WHERE Id IN: testeeIds]);
        }
        
        // To update the L/R/S Initial Vs final Score value when a new Final Test Type Language Testing Records is created or updated
        if(finalProjIds.size() > 0 && finalStudIds.size() > 0 ) {
            for( Language_Testing__c lt : [SELECT Id,Name,L_Score__c,R_Score__c,S_Score__c,Testee__c,Project__c,Test_Type__c,W_Score__c,Date_Time_Scheduled__c FROM Language_Testing__c WHERE Testee__c IN: finalStudIds AND Project__c IN: finalProjIds AND Test_Type__c = 'Initial' Order by Date_Time_Scheduled__c DESC]){
                if(!initialLTMap.containskey(lt.Testee__c + '~' + lt.Project__c)) {
                    initialLTMap.put(lt.Testee__c + '~' + lt.Project__c, lt);
                }
            }
        }
                
        for(Language_Testing__c lang : Trigger.new) {
            if(trigger.isInsert) {
                // Start - To populate the name 
                String nameVar = ''; 
                if(lang.Testee__c != null && contactMap.containskey(lang.Testee__c)) {
                    nameVar += contactMap.get(lang.Testee__c).Name + ' - ';
                }
                
                if(lang.Project__c != null && projMap.containskey(lang.Project__c)) {
                    nameVar += projMap.get(lang.Project__c).DLS_Class__c + ' - ';
                }
                
                if(lang.Date_Time_Scheduled__c != null) {
                    nameVar += lang.Date_Time_Scheduled__c.month() + '-' + lang.Date_Time_Scheduled__c.day() +'-'+ lang.Date_Time_Scheduled__c.year();
                }
                // To populate in the format “{Student/Testee Name} – {DLS Class #} – {Date from Date & Time Scheduled field}"
                lang.Name = nameVar;
                // End - To populate the name
                
                // Start Defaulty populate other field values
                if(lang.S_Goal__c == null || (lang.S_Goal__c).trim() == '') {
                    lang.S_Goal__c = 'N/A';
                }
                if(lang.L_Goal__c == null || (lang.L_Goal__c).trim() == '') {
                    lang.L_Goal__c = 'N/A';
                }
                if(lang.R_Goal__c == null || (lang.R_Goal__c).trim() == '') {
                    lang.R_Goal__c = 'N/A';
                }
                if(lang.W_Goal__c == null || (lang.W_Goal__c).trim() == '') {
                    lang.W_Goal__c = 'N/A';
                }
                // End Defaulty populate other field values
            } 
            
            // To update the L/R/S Initial Vs final Score value when a new Final Test Type Language Testing Records is created or updated
            Language_Testing__c oldL = trigger.isUpdate ? Trigger.oldMap.get(lang.Id) : null ;
            if(trigger.isInsert || (trigger.isUpdate && (lang.L_Score__c != oldL.L_Score__c || lang.S_Score__c != oldL.S_Score__c || lang.R_Score__c != oldL.R_Score__c || lang.W_Score__c != oldL.W_Score__c))) {

                if(initialLTMap != null && lang.Test_Type__c == 'Final' && lang.Testee__c != null && lang.Project__c != null && initialLTMap.containskey(lang.Testee__c + '~' + lang.Project__c) && initialLTMap.get(lang.Testee__c + '~' + lang.Project__c) != null) {
                    Language_Testing__c initL = initialLTMap.get(lang.Testee__c + '~' + lang.Project__c);
                    System.debug('initL::::'+initL);
                    if(initL.L_Score__c != null && initL.L_Score__c != 'N/A' && lang.L_Score__c != null && lang.L_Score__c != 'N/A') {
                        if(gradeAndMarkMap.get(lang.L_Score__c) > gradeAndMarkMap.get(initL.L_Score__c)) {
                            Double tmp = gradeAndMarkMap.get(lang.L_Score__c) - gradeAndMarkMap.get(initL.L_Score__c);
                            lang.L_Initial_vs_Final_Increase__c = tmp/2;
                        } else if(gradeAndMarkMap.get(lang.L_Score__c) == gradeAndMarkMap.get(initL.L_Score__c)) {
                            lang.L_Initial_vs_Final_Increase__c = 0;
                        } else if(gradeAndMarkMap.get(lang.L_Score__c) < gradeAndMarkMap.get(initL.L_Score__c)) {
                            Double tmp = gradeAndMarkMap.get(lang.L_Score__c) - gradeAndMarkMap.get(initL.L_Score__c);
                            lang.L_Initial_vs_Final_Increase__c = tmp/2;
                        }
                    }
                    if(initL.R_Score__c != null && initL.R_Score__c != 'N/A' && lang.R_Score__c != null && lang.R_Score__c != 'N/A') {
                        if(gradeAndMarkMap.get(lang.R_Score__c) > gradeAndMarkMap.get(initL.R_Score__c)) {
                            Double tmp = gradeAndMarkMap.get(lang.R_Score__c) - gradeAndMarkMap.get(initL.R_Score__c);
                            lang.R_Initial_vs_Final_Increase__c = tmp/2;
                        } else if(gradeAndMarkMap.get(lang.R_Score__c) == gradeAndMarkMap.get(initL.R_Score__c)) {
                            lang.R_Initial_vs_Final_Increase__c = 0;
                        } else if(gradeAndMarkMap.get(lang.R_Score__c) < gradeAndMarkMap.get(initL.R_Score__c)) {
                            Double tmp = gradeAndMarkMap.get(lang.R_Score__c) - gradeAndMarkMap.get(initL.R_Score__c);
                            lang.R_Initial_vs_Final_Increase__c = tmp/2;
                        }
                    }
                    if(initL.S_Score__c != null && initL.S_Score__c != 'N/A' && lang.S_Score__c != null && lang.S_Score__c != 'N/A') {
                        if(gradeAndMarkMap.get(lang.S_Score__c) > gradeAndMarkMap.get(initL.S_Score__c)) {
                            Double tmp = gradeAndMarkMap.get(lang.S_Score__c) - gradeAndMarkMap.get(initL.S_Score__c);
                            lang.S_Initial_vs_Final_Increase__c = tmp/2;
                        } else if(gradeAndMarkMap.get(lang.S_Score__c) == gradeAndMarkMap.get(initL.S_Score__c)) {
                            lang.S_Initial_vs_Final_Increase__c = 0;
                        } else if(gradeAndMarkMap.get(lang.S_Score__c) < gradeAndMarkMap.get(initL.S_Score__c)) {
                            Double tmp = gradeAndMarkMap.get(lang.S_Score__c) - gradeAndMarkMap.get(initL.S_Score__c);
                            lang.S_Initial_vs_Final_Increase__c = tmp/2;
                        }                    
                    }
                    if(initL.W_Score__c != null && initL.W_Score__c != 'N/A' && lang.W_Score__c != null && lang.W_Score__c != 'N/A') {
                        if(gradeAndMarkMap.get(lang.W_Score__c) > gradeAndMarkMap.get(initL.W_Score__c)) { 
                            Double tmp = gradeAndMarkMap.get(lang.W_Score__c) - gradeAndMarkMap.get(initL.W_Score__c);
                            lang.W_Initial_vs_Final_Increase__c = tmp/2;
                        } else if(gradeAndMarkMap.get(lang.W_Score__c) == gradeAndMarkMap.get(initL.W_Score__c)) {
                            lang.W_Initial_vs_Final_Increase__c = 0;
                        } else if(gradeAndMarkMap.get(lang.W_Score__c) < gradeAndMarkMap.get(initL.W_Score__c)) { 
                            Double tmp = gradeAndMarkMap.get(lang.W_Score__c) - gradeAndMarkMap.get(initL.W_Score__c);
                            lang.W_Initial_vs_Final_Increase__c = tmp/2;
                        }                    
                    }
                } 
            } 
        }  
    }
    
    if(trigger.isAfter && trigger.isInsert) {
        
        Set<Id> initialProjIds = new Set<Id>();
        Set<Id> initialStudIds = new Set<Id>();        
        
        Set<Id> finalProjIds = new Set<Id>();
        Set<Id> finalStudIds = new Set<Id>();
        
        for(Language_Testing__c l : Trigger.New) {
            
            if(!contIdAndLangTestSet.containsKey(l.Testee__c))
                contIdAndLangTestSet.put(l.Testee__c,new Set<String>());
                
            if(l.Target_Language__c != null) {
                contIdAndLangTestSet.get(l.Testee__c).add(l.Target_Language__c);
                contIdLangAndLangTestId.put(l.Testee__c+l.Target_Language__c,l.Id); // has Contact Id and Language as Key and Language Testing Rec Id as value
            }
            
            if(l.Test_Type__c == 'Final' && l.Project__c != null && l.Testee__c != null) {
                finalProjIds.add(l.Project__c);
                finalStudIds.add(l.Testee__c);
            }
            if(l.Test_Type__c == 'Initial' && l.Project__c != null && l.Testee__c != null) {
                initialProjIds.add(l.Project__c);
                initialStudIds.add(l.Testee__c);
            }
        }
        System.debug('contIdAndLangTestSet:::::'+contIdAndLangTestSet);
        System.debug('contIdLangAndLangTestId:::::'+contIdLangAndLangTestId);
        
        if( contIdAndLangTestSet != null && contIdAndLangTestSet.size() > 0 && contIdLangAndLangTestId != null && contIdLangAndLangTestId.size() > 0 ){
            
            for(Skill__c s : [SELECT Id,From_Language__c,To_Language__c,Contact__c,From_Language_Language_Testing__c,To_Language_Language_Testing__c FROM Skill__c WHERE Contact__c IN: contIdAndLangTestSet.keySet()]){
                
                for( String str : contIdAndLangTestSet.get(s.Contact__c)) {
                    
                    if( s.From_Language__c == str ) {
                        
                        s.From_Language_Language_Testing__c = (contIdLangAndLangTestId.containsKey(s.Contact__c+s.From_Language__c)?contIdLangAndLangTestId.get(s.Contact__c+s.From_Language__c):'');
                    }
                    if( s.To_Language__c == str ) {
                    
                        s.To_Language_Language_Testing__c = (contIdLangAndLangTestId.containsKey(s.Contact__c+s.To_Language__c)?contIdLangAndLangTestId.get(s.Contact__c+s.To_Language__c):'');
                    }
                    
                }
                skillUpdateList.add(s);            
            }
            System.debug('skillUpdateList:::::'+skillUpdateList);
            
            if( skillUpdateList != null && skillUpdateList.size() > 0 ) {
                
                Update skillUpdateList;
            }
        }
                
        //Added By Dhinesh - 18/11/2021 - W-007176 - To Check the Has Initial Score and Final Score Record checkbox in CA for report            
        if(initialStudIds.size() > 0 || finalStudIds.size() > 0){
            Set<Id> allProjIds = new Set<Id>();
            Set<Id> allStudIds = new Set<Id>();
            
            allProjIds.addAll(initialProjIds);
            allProjIds.addAll(finalProjIds);
            
            allStudIds.addAll(initialStudIds);
            allStudIds.addAll(finalStudIds);
            
            List<Contact_Assignments__c> caListToUpdate = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c, Initial_Score_Record__c, Final_Score_Record__c 
                                            FROM Contact_Assignments__c 
                                            WHERE  Candidate_Name__c IN :allStudIds AND Project__c IN :allProjIds]){
                if(initialStudIds.contains(ca.Candidate_Name__c)){
                    ca.Initial_Score_Record__c = true;
                }else if(finalStudIds.contains(ca.Candidate_Name__c)){
                    ca.Final_Score_Record__c = true;
                }                            
                caListToUpdate.add(ca);
            }
            
            if(caListToUpdate.size() > 0){
                update caListToUpdate;
            }
        }
    }    
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        
        Set<Id> initialProjIds = new Set<Id>();
        Set<Id> initialStudIds = new Set<Id>();
        List<Language_Testing__c> initialLTRecs = new List<Language_Testing__c>();
        
        Map<String,Language_Testing__c> finalLTMap = new Map<String,Language_Testing__c>();
        Map<Id, Language_Testing__c> updateFinalLTRecs = new Map<Id, Language_Testing__c>();
        
        for(Language_Testing__c l : trigger.new) {
            
            // Modified By HL on Apr 08 2021
            // To update the L/R/S Initial Vs final Score value when a new Initial Test Type Language Testing Records is created or updated
            // Added By HL on Feb 10 2022 - Work Item: W-007355 - DODA Language Testing Missing Increase Field Calculation
            if(l.Test_Type__c == 'Initial' && l.Project__c != null && l.Testee__c != null && (Trigger.isInsert || 
                (Trigger.isUpdate && (l.L_Score__c != Trigger.oldMap.get(l.Id).L_Score__c || l.R_Score__c != Trigger.oldMap.get(l.Id).R_Score__c || 
                l.S_Score__c != Trigger.oldMap.get(l.Id).S_Score__c || l.W_Score__c != Trigger.oldMap.get(l.Id).W_Score__c)))) {
                initialProjIds.add(l.Project__c);
                initialStudIds.add(l.Testee__c);
                initialLTRecs.add(l);
            }
        }
        // To update the L/R/S Initial Vs final Score value when a new Initial Test Type Language Testing Records is created or updated
        if(initialProjIds.size() > 0 && initialStudIds.size() > 0 ) {
        
            for( Language_Testing__c lt : [SELECT Id,Name,L_Score__c,R_Score__c,S_Score__c,
                                                Testee__c,Project__c,Test_Type__c,W_Score__c,Date_Time_Scheduled__c, 
                                                L_Initial_vs_Final_Increase__c,R_Initial_vs_Final_Increase__c,S_Initial_vs_Final_Increase__c, 
                                                W_Initial_vs_Final_Increase__c
                                            FROM Language_Testing__c 
                                            WHERE Testee__c IN: initialStudIds AND Project__c IN: initialProjIds AND Test_Type__c = 'Final' Order by Date_Time_Scheduled__c DESC]){
                if(!finalLTMap.containskey(lt.Testee__c + '~' + lt.Project__c)) {
                    finalLTMap.put(lt.Testee__c + '~' + lt.Project__c, lt);
                }
            }
            
            if(finalLTMap != NULL && finalLTMap.size() > 0){
            
                for(Language_Testing__c lang : initialLTRecs){
                
                    // To update the L/R/S Initial Vs final Score value when a new Initial Test Type Language Testing Records is created or updated
                    if(finalLTMap != null && finalLTMap.containskey(lang.Testee__c + '~' + lang.Project__c) && finalLTMap.get(lang.Testee__c + '~' + lang.Project__c) != null) {
                    
                        Language_Testing__c finalLT = finalLTMap.get(lang.Testee__c + '~' + lang.Project__c);
                        
                        if(finalLT.L_Score__c != null && finalLT.L_Score__c != 'N/A' && lang.L_Score__c != null && lang.L_Score__c != 'N/A') {
                            if(gradeAndMarkMap.get(finalLT.L_Score__c) > gradeAndMarkMap.get(lang.L_Score__c)) {
                                Double tmp = gradeAndMarkMap.get(finalLT.L_Score__c) - gradeAndMarkMap.get(lang.L_Score__c);
                                finalLT.L_Initial_vs_Final_Increase__c = tmp/2;
                            } else if(gradeAndMarkMap.get(finalLT.L_Score__c) == gradeAndMarkMap.get(lang.L_Score__c)) {
                                finalLT.L_Initial_vs_Final_Increase__c = 0;
                            } else if(gradeAndMarkMap.get(finalLT.L_Score__c) < gradeAndMarkMap.get(lang.L_Score__c)) {
                                Double tmp = gradeAndMarkMap.get(lang.L_Score__c) - gradeAndMarkMap.get(finalLT.L_Score__c);
                                finalLT.L_Initial_vs_Final_Increase__c = tmp/2;
                            }
                        }
                        if(finalLT.R_Score__c != null && finalLT.R_Score__c != 'N/A' && lang.R_Score__c != null && lang.R_Score__c != 'N/A') {
                            if(gradeAndMarkMap.get(finalLT.R_Score__c) > gradeAndMarkMap.get(lang.R_Score__c)) {
                                Double tmp = gradeAndMarkMap.get(finalLT.R_Score__c) - gradeAndMarkMap.get(lang.R_Score__c);
                                finalLT.R_Initial_vs_Final_Increase__c = tmp/2;
                            } else if(gradeAndMarkMap.get(finalLT.R_Score__c) == gradeAndMarkMap.get(lang.R_Score__c)) {
                                finalLT.R_Initial_vs_Final_Increase__c = 0;
                            } else if(gradeAndMarkMap.get(finalLT.R_Score__c) < gradeAndMarkMap.get(lang.R_Score__c)) {
                                Double tmp = gradeAndMarkMap.get(lang.R_Score__c) - gradeAndMarkMap.get(finalLT.R_Score__c);
                                finalLT.R_Initial_vs_Final_Increase__c = tmp/2;
                            }
                        }
                        if(finalLT.S_Score__c != null && finalLT.S_Score__c != 'N/A' && lang.S_Score__c != null && lang.S_Score__c != 'N/A') {
                            if(gradeAndMarkMap.get(finalLT.S_Score__c) > gradeAndMarkMap.get(lang.S_Score__c)) {
                                Double tmp = gradeAndMarkMap.get(finalLT.S_Score__c) - gradeAndMarkMap.get(lang.S_Score__c);
                                finalLT.S_Initial_vs_Final_Increase__c = tmp/2;
                            } else if(gradeAndMarkMap.get(finalLT.S_Score__c) == gradeAndMarkMap.get(lang.S_Score__c)) {
                                finalLT.S_Initial_vs_Final_Increase__c = 0;
                            } else if(gradeAndMarkMap.get(finalLT.S_Score__c) < gradeAndMarkMap.get(lang.S_Score__c)) {
                                Double tmp = gradeAndMarkMap.get(lang.S_Score__c) - gradeAndMarkMap.get(finalLT.S_Score__c);
                                finalLT.S_Initial_vs_Final_Increase__c = tmp/2;
                            }                    
                        }
                        if(finalLT.W_Score__c != null && finalLT.W_Score__c != 'N/A' && lang.W_Score__c != null && lang.W_Score__c != 'N/A') {
                            if(gradeAndMarkMap.get(finalLT.W_Score__c) > gradeAndMarkMap.get(lang.W_Score__c)) { 
                                Double tmp = gradeAndMarkMap.get(finalLT.W_Score__c) - gradeAndMarkMap.get(lang.W_Score__c);
                                finalLT.W_Initial_vs_Final_Increase__c = tmp/2;
                            } else if(gradeAndMarkMap.get(finalLT.W_Score__c) == gradeAndMarkMap.get(lang.W_Score__c)) {
                                finalLT.W_Initial_vs_Final_Increase__c = 0;
                            } else if(gradeAndMarkMap.get(finalLT.W_Score__c) < gradeAndMarkMap.get(lang.W_Score__c)) { 
                                Double tmp = gradeAndMarkMap.get(lang.W_Score__c) - gradeAndMarkMap.get(finalLT.W_Score__c);
                                finalLT.W_Initial_vs_Final_Increase__c = tmp/2;
                            }                    
                        }
                        updateFinalLTRecs.put(finalLT.Id, finalLT);
                    }
                }
                System.debug('::::updateFinalLTRecs::::'+updateFinalLTRecs);
                System.debug('::::updateFinalLTRecs::: SIZE:'+updateFinalLTRecs.size());
                if(updateFinalLTRecs != NULL && updateFinalLTRecs.size() > 0){
                    update updateFinalLTRecs.values();
                } 
            }                       
        }
    }
}