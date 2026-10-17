public class CloseStaleEnquiriesBatch
    implements Database.Batchable<SObject> {

    private Datetime staleBefore;
    private Date activitySince;

    public CloseStaleEnquiriesBatch() {
        this(
            System.now().addDays(-30),
            Date.today().addDays(-30)
        );
    }

    @TestVisible
    public CloseStaleEnquiriesBatch(
        Datetime staleBefore,
        Date activitySince
    ) {
        this.staleBefore = staleBefore;
        this.activitySince = activitySince;
    }

    public Database.QueryLocator start(
        Database.BatchableContext bc
    ) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, LastModifiedDate, LastActivityDate
            FROM Enquiry__c
            WHERE Status__c = 'In Progress'
            AND LastModifiedDate < :staleBefore
            AND (
                LastActivityDate = NULL
                OR LastActivityDate < :activitySince
            )
        ]);
    }

    public void execute(
        Database.BatchableContext bc,
        List<SObject> scope
    ) {
        for (SObject record : scope) {
            Enquiry__c enquiry = (Enquiry__c) record;
            enquiry.Status__c = 'Closed';
        }

        if (!scope.isEmpty()) {
            update scope;
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Batch processing completed.
    }
}