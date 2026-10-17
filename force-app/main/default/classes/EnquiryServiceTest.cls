@IsTest
private class EnquiryServiceTest {

    @IsTest
    static void testDefaultStatusAndFollowUpTask() {
        Enquiry__c enquiry = new Enquiry__c(
            Subject__c = 'Test Follow Up',
            Customer_Budget__c = 1500
        );

        Test.startTest();
        insert enquiry;
        Test.stopTest();

        Enquiry__c saved = [
            SELECT Status__c
            FROM Enquiry__c
            WHERE Id = :enquiry.Id
        ];
        System.assertEquals('New', saved.Status__c);

        Task followUp = [
            SELECT Subject, OwnerId, WhatId, ActivityDate
            FROM Task
            WHERE WhatId = :enquiry.Id
            LIMIT 1
        ];

        System.assertEquals('Follow up: Test Follow Up', followUp.Subject);
        System.assertEquals(enquiry.Id, followUp.WhatId);
        System.assertEquals(Date.today().addDays(3), followUp.ActivityDate);
        System.assertEquals(UserInfo.getUserId(), followUp.OwnerId);
    }

    @IsTest
    static void testClosedDateStamp() {
        Enquiry__c enquiry = TestDataFactory.createEnquiry(
            'Close Test', 'New', 1500
        );
        insert enquiry;

        enquiry.Status__c = 'Closed';

        Test.startTest();
        update enquiry;
        Test.stopTest();

        Enquiry__c saved = [
            SELECT Closed_Date__c
            FROM Enquiry__c
            WHERE Id = :enquiry.Id
        ];
        System.assertEquals(Date.today(), saved.Closed_Date__c);
    }

    @IsTest
    static void testBulkInsert200Enquiries() {
        List<Enquiry__c> enquiries = TestDataFactory.createEnquiries(200);

        Test.startTest();
        insert enquiries;
        Test.stopTest();

        System.assertEquals(
            200,
            [SELECT COUNT() FROM Enquiry__c WHERE Subject__c LIKE 'Test Enquiry %']
        );

        System.assertEquals(
            200,
            [SELECT COUNT() FROM Task WHERE Subject LIKE 'Follow up: Test Enquiry %']
        );
    }
    @IsTest
static void testBudgetBelowMinimumRejected() {
    Enquiry__c enquiry = TestDataFactory.createEnquiry(
        'Low Budget Test',
        'New',
        500
    );

    Database.SaveResult result = Database.insert(enquiry, false);

    System.assertEquals(
        false,
        result.isSuccess(),
        'An Enquiry below ₹1,000 must be rejected.'
    );

    System.assert(
        result.getErrors().size() > 0,
        'The rejected Enquiry should contain an error.'
    );

    String errorMessages = '';
    for (Database.Error err : result.getErrors()) {
        errorMessages += err.getMessage() + ' ';
    }

    System.assert(
        errorMessages.contains('Customer budget must be at least ₹1,000'),
        'Expected budget validation error. Actual errors: ' + errorMessages
    );
}
@IsTest
static void testDeleteAndUndeleteEnquiry() {
    Enquiry__c enquiry = TestDataFactory.createEnquiry(
        'Delete Undelete Test',
        'New',
        1500
    );
    insert enquiry;

    Test.startTest();
    delete enquiry;
    undelete enquiry;
    Test.stopTest();

    List<Enquiry__c> restored = [
        SELECT Id
        FROM Enquiry__c
        WHERE Id = :enquiry.Id
    ];

    System.assertEquals(
        1,
        restored.size(),
        'The Enquiry should be restored after undelete.'
    );
}
}