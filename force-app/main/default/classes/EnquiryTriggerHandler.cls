public class EnquiryTriggerHandler implements ITriggerHandler {

    public void beforeInsert() {
        EnquiryService.beforeInsert(
            (List<Enquiry__c>) Trigger.new
        );
    }

    public void beforeUpdate() {
        EnquiryService.beforeUpdate(
            (List<Enquiry__c>) Trigger.new,
            (Map<Id, Enquiry__c>) Trigger.oldMap
        );
    }

    public void beforeDelete() {}

    public void afterInsert() {
        EnquiryService.afterInsert(
            (List<Enquiry__c>) Trigger.new
        );
    }

    public void afterUpdate() {}

    public void afterDelete() {}

    public void afterUndelete() {}
}