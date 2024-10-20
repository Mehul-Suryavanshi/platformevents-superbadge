trigger LogBatchExecutionException on BatchApexErrorEvent (after insert) {
    Set<Id> asyncApexJobIds = new Set<Id>();
    for(BatchApexErrorEvent evt:Trigger.new){
        asyncApexJobIds.add(evt.AsyncApexJobId);
    }
    
    Map<Id,AsyncApexJob> jobs = new Map<Id,AsyncApexJob>(
        [SELECT id, ApexClass.Name FROM AsyncApexJob WHERE Id IN :asyncApexJobIds]
    );
    
    List<Error_Log__c> errorLogs = new List<Error_Log__c>();
    for(BatchApexErrorEvent evt:Trigger.new){
        //only handle events for the job(s) we care about
        if(jobs.get(evt.AsyncApexJobId).ApexClass.Name == 'PilotRatingBatch'){
            
            Error_Log__c a = new Error_Log__c(
                Async_Apex_Job_Id__c = evt.AsyncApexJobId,
                Job_Scope__c = evt.JobScope,
                Type__c = evt.ExceptionType,
                Message__c = evt.Message,
                Stacktrace__c = evt.StackTrace,
                Location__c = evt.Phase
            );
            errorLogs.add(a);
            
        }
    }
    insert errorLogs;
}