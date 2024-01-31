global class TimeCardScheduleClass implements Schedulable {
   global void execute(SchedulableContext SC) {
      TimeCardController Timecard = new TimeCardController(); 
      Timecard.TimeCardCreateRec();
   }
}