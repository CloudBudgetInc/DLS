global class scheduledLatLongForContAndLoc implements Schedulable{
     global void execute(SchedulableContext sc) {
        
        ContactLatLongBatchClass con = new ContactLatLongBatchClass(); 
        
        database.executebatch(con,1);
     }
  }