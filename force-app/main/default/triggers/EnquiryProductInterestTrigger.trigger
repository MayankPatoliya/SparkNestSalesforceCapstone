trigger EnquiryProductInterestTrigger on Enquiry_Product__c (
    after insert,
    after update,
    after delete,
    after undelete
) {
    Set<Id> enquiryIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUndelete) {
        for (Enquiry_Product__c item : Trigger.new) {
            if (item.Enquiry__c != null) {
                enquiryIds.add(item.Enquiry__c);
            }
        }
    }

    if (Trigger.isUpdate) {
        for (Enquiry_Product__c item : Trigger.new) {
            if (item.Enquiry__c != null) {
                enquiryIds.add(item.Enquiry__c);
            }
        }

        for (Enquiry_Product__c item : Trigger.old) {
            if (item.Enquiry__c != null) {
                enquiryIds.add(item.Enquiry__c);
            }
        }
    }

    if (Trigger.isDelete) {
        for (Enquiry_Product__c item : Trigger.old) {
            if (item.Enquiry__c != null) {
                enquiryIds.add(item.Enquiry__c);
            }
        }
    }

    EnquiryProductInterestService.updateProductCount(enquiryIds);
}