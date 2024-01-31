public without sharing class WeeklyLessonPlanExportPDF_Ctrl {
    public Id lessonPlanId;
    public weeklyLessonPlansWrap weeklyLessonPlansWrap {get; set;}    
    
    public WeeklyLessonPlanExportPDF_Ctrl() {
    
        lessonPlanId = ApexPages.currentPage().getParameters().get('lessonPlanId'); 
        String communityname = ApexPages.currentPage().getParameters().get('communityname');
        
        if(communityname == null){
            communityname = 'internal';
        }        
        
        Lesson_Plan__c lessonPlan = LessonPlanService.getLessonPlanWithLessonPlanHours('Id = \''+lessonPlanId+'\'', ', Instructor__r.Name,RecordType.DeveloperName')[0];
        date weekStart = lessonPlan.Date__c.toStartofWeek();
        date weekEnd = weekStart.addDays(6);
        String headerStr = 'Weekly Lesson Plan '+ DateTime.newInstance(weekStart.year(),weekStart.month(),weekStart.day()).format('MM/dd/YYYY') +' - '+ DateTime.newInstance(weekEnd.year(),weekEnd.month(),weekEnd.day()).format('MM/dd/YYYY');
        
        weeklyLessonPlansWrap = new weeklyLessonPlansWrap();
        weeklyLessonPlansWrap.headerStr = headerStr;
        weeklyLessonPlansWrap.classNum = lessonPlan.Class__c;
        weeklyLessonPlansWrap.studentName = lessonPlan.Student_Name__c;
        weeklyLessonPlansWrap.insName = lessonPlan.Instructor__r.Name;
        
        String filterStr = 'Project__c = \''+lessonPlan.Project__c+'\' AND Status__c = \'Completed\'';
        if(communityname == 'student'){
            filterStr += ' AND Share_with_my_student_s__c = true';
        }
        List<Lesson_Plan__c> lessonPlans = LessonPlanService.getweeklyLessonPlansWithLessonPlanHours(weekStart,weekEnd,filterStr, ', Instructor__r.Name,RecordType.DeveloperName');
        
        weeklyLessonPlansWrap.dateStr = new List<String>{''};                
        Map<String, List<Lesson_Plan_Hour__c>> lessonPlanNameWithRecsMap = new Map<String, List<Lesson_Plan_Hour__c>>();
        for(Lesson_Plan__c lp : lessonPlans){
            for(Lesson_Plan_Hour__c lph : lp.Lesson_Plan_Hours__r){ 
                if(!lessonPlanNameWithRecsMap.containsKey(lph.Name)){
                    lessonPlanNameWithRecsMap.put(lph.Name, new List<Lesson_Plan_Hour__c>());
                }
            }
        }
        
        weeklyLessonPlansWrap.lessonPlans= new List<Lesson_Plan__c>();
        weeklyLessonPlansWrap.lessonPlanHrs = new List<lessonPlanHrs>();
        
        for(Lesson_Plan__c lp : lessonPlans){
            Datetime dt = DateTime.newInstance(lp.Date__c, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek=dt.format('EEEE');            
            weeklyLessonPlansWrap.dateStr.add(dayOfWeek+' '+dt.format('MM/dd'));            
            
            List<lessonPlanHrs> lessonPlanHrs = new List<lessonPlanHrs>();
            
            for(String lphName : lessonPlanNameWithRecsMap.keySet()){
                Boolean isAvailable = false;
                for(Lesson_Plan_Hour__c lph : lp.Lesson_Plan_Hours__r){
                    if(lphName == lph.Name){
                        lessonPlanNameWithRecsMap.get(lphName).add(lph);
                        isAvailable = true;
                    }
                }
                if(!isAvailable){
                    lessonPlanNameWithRecsMap.get(lphName).add(new Lesson_Plan_Hour__c());
                }
            }
            
            weeklyLessonPlansWrap.lessonPlans.add(lp);
        }
        
        weeklyLessonPlansWrap.lessonPlanHrs = new List<lessonPlanHrs>();
        for(String lphName : lessonPlanNameWithRecsMap.keySet()){
            lessonPlanHrs lessonPlanHrs = new lessonPlanHrs();
            lessonPlanHrs.name = lphName;
            lessonPlanHrs.lessonPlanHrs = new List<Lesson_Plan_Hour__c>();
            lessonPlanHrs.lessonPlanHrs.addAll(lessonPlanNameWithRecsMap.get(lphName));
            weeklyLessonPlansWrap.lessonPlanHrs.add(lessonPlanHrs);
        }
        String fileName = headerStr+'.pdf';          
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+fileName);
    }
    
    public class weeklyLessonPlansWrap{
        public String headerStr {get; set;}
        public String classNum {get; set;} 
        public String studentName {get; set;} 
        public String insName {get; set;}
        public List<String> dateStr {get; set;}
        public List<Lesson_Plan__c> lessonPlans {get; set;}
        public List<lessonPlanHrs> lessonPlanHrs {get; set;} 
    }
    
    public class lessonPlanHrs{
        public String name {get; set;}
        public List<Lesson_Plan_Hour__c> lessonPlanHrs {get; set;}
    }   
}