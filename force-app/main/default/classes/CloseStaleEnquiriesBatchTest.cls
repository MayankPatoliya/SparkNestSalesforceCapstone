@IsTest
private class CloseStaleEnquiriesBatchTest {

    @IsTest
    static void testClosesStaleEnquiries() {
        Enquiry__c enquiry = new Enquiry__c(
            Subject__c = 'Stale Enquiry Test',
            Status__c = 'In Progress',
            Customer_Budget__c = 1500
        );
        insert enquiry;

        Test.startTest();

        Database.executeBatch(
            new CloseStaleEnquiriesBatch(
                System.now().addMinutes(1),
                Date.today().addDays(-30)
            ),
            200
        );

        Test.stopTest();

        Enquiry__c result = [
            SELECT Status__c, Closed_Date__c
            FROM Enquiry__c
            WHERE Id = :enquiry.Id
        ];

        System.assertEquals(
            'Closed',
            result.Status__c,
            'A stale Enquiry should be closed by the batch.'
        );

        System.assertEquals(
            Date.today(),
            result.Closed_Date__c,
            'Closing the Enquiry should stamp Closed Date.'
        );
    }

    @IsTest
    static void testSchedulerCanBeScheduled() {
        Test.startTest();

        String jobId = System.schedule(
            'Test Close Stale Enquiries',
            '0 0 2 * * ?',
            new CloseStaleEnquiriesScheduler()
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            jobId,
            'The scheduler should return a job ID.'
        );
    }
}