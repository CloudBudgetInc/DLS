// Work Item : W-001299
// Scheduler to call ContactRollupHelperBatch class for field rollup
// Created by HL on Mar 26 2019
// Scheduled on Daily basis - @ 01:00 AM on Everyday 
global class ContactRollupHelperBatch_Schedule implements Schedulable {
    //ContactRollupHelperBatch m = new ContactRollupHelperBatch();
    //String sch = '0 0 1 * * ? *';
    //String jobID = system.schedule('Daily Job to update Contact', sch, m);
    global void execute(SchedulableContext sc) {
    
        System.debug('ContactRollupHelperBatch======');
        ContactRollupHelperBatch rollupBatch = new ContactRollupHelperBatch();
        database.executeBatch(rollupBatch,1);
    }
}