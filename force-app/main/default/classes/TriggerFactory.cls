public class TriggerFactory {
	public class TriggerException extends Exception {
	}
	public static void execute(SObjectType sobjectType) {
		ITriggerHandler handler = createHandler(sobjectType);
		handler.disableTrigger();
		handler.enableTrigger();
		if (!handler.isTriggerEnabled()) {
			return;
		}
		handleOperation(handler);
	}

	private static void handleOperation(ITriggerHandler handler) {
		if (Trigger.isUpdate) {
			if (Trigger.isAfter) {
				handler.afterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
			} else if (Trigger.isBefore) {
				handler.beforeUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
			}
		}
	}

	private static ITriggerHandler createHandler(SObjectType sobjectType) {
		String originalTypeName = sobjectType.getDescribe().getName();
		String handlerTypeName = null;
		if (originalTypeName.toLowerCase().endsWith('__c')) {
			Integer index = originalTypeName.toLowerCase().indexOf('__c');
			handlerTypeName = originalTypeName.substring(0, index) + 'TriggerHandler';
		} else {
			handlerTypeName = originalTypeName + 'TriggerHandler';
		}
		handlerTypeName = handlerTypeName.replaceAll('_', '');
		Type obType = Type.forName(handlerTypeName);
		ITriggerHandler handler = (obType == null) ? null : (ITriggerHandler) obType.newInstance();
		if (handler == null) {
			throw new TriggerException('No trigger handler registered for Object Type' + handlerTypeName);
		}
		return handler;
	}
}
