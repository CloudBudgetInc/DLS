// This scheduler to execute the createAmortizationEntriesBatch once in month
// scheduled on ('0 0 6 17 * ?')

global class CreateAmortizationEntriesSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        CreateAmortizationEntriesBatch amoEntBatch = new CreateAmortizationEntriesBatch();
        database.executebatch(amoEntBatch, 10);
    }
}