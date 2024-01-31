// Work Item : W-001471
// Schdeuler to call LCRStatusUpdationBatch
// Created by HL on June 10 2019
// Scheduled on Daily basis - To update LCR and CA

global class LCRStatusUpdationBatch_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        if(todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            LCRStatusUpdationBatch dailyRemainder= new LCRStatusUpdationBatch();
            database.executeBatch(dailyRemainder,1);
        }
    }
}