public class TriggerDispatcher {

    public static void run(ITriggerHandler handler) {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert();
            } else if (Trigger.isUpdate) {
                handler.beforeUpdate();
            } else if (Trigger.isDelete) {
                handler.beforeDelete();
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                handler.afterInsert();
            } else if (Trigger.isUpdate) {
                handler.afterUpdate();
            } else if (Trigger.isDelete) {
                handler.afterDelete();
            } else if (Trigger.isUndelete) {
                handler.afterUndelete();
            }
        }
    }
}