@isTest
public class LogBatchExecutionExceptionTest implements Database.RaisesPlatformEvents  {

    @testSetup
    static void setup() {
          List<Contact> pilots = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact pilot = new Contact(
                FirstName = 'Test',
                LastName = 'Pilot' + i,
                Pilot_Rating__c = 3.0
            );
            pilots.add(pilot);
        }
        insert pilots;

        List<Mission__c> missions = new List<Mission__c>();
		List<Mission__c> missions1 = new List<Mission__c>();

        for (Contact pilot : pilots) {
            Mission__c mission = new Mission__c(
                Pilot__c = pilot.Id,
                Completion_Rating__c = 4.0,
                Overall_Rating__c = 5.0,
                Safety_Incidents__c = 1.0,
                Status__c = 'Complete',
                Subject__c = 'test'
            );
            missions.add(mission);
        }
        insert missions;
        
        
         Mission__c mission = new Mission__c(
                Pilot__c = pilots[0].Id,
                Completion_Rating__c = 4.0,
                Overall_Rating__c = 5.0,
                Safety_Incidents__c = 1.0,
                Status__c = 'Complete',
                Subject__c = 'test'
            );
        
        insert mission;
    }

    @isTest
    static void testBatchApexErrorEventTrigger() {
        try{
        Test.startTest();

       Database.executeBatch(new PilotRatingBatch());
        Test.stopTest();
        }catch(Exception ex){
            
        }
		Test.getEventBus().deliver();

        // Verify that the error logs were created
        List<Error_Log__c> errorLogs = [SELECT Id, Name, Async_Apex_Job_Id__c, Message__c FROM Error_Log__c];
        Assert.isTrue(errorLogs.size() > 0, 'Error logs should be created.');
        }
}