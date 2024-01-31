/***********************************************************************
- Created to execute the Bill.com push batch on every hours for Project, Project Task, Accounting Variable & GL Account records
- Created by NS on July 7 2020
***********************************************************************/
global class BillDotComSyncScheduler implements Schedulable{
     global void execute(SchedulableContext sc) {
        
        JobCreation job = new JobCreation();
        database.executebatch(job,1);
     }
  }