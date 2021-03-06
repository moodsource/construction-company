public class TriggerFactory {
	public class TriggerException extends Exception {
	}

	private static Map<SObjectType, Boolean> disabledTriggers = new Map<SObjectType, Boolean>();

	public static void disableTrigger(SObjectType type) {
		disabledTriggers.put(type, true);
	}
	public static void enableTrigger(SObjectType type) {
		disabledTriggers.put(type, false);
	}

	public static Boolean isTriggerDisabled(SObjectType type) {
		if (!disabledTriggers.containsKey(type)) {
			return false;
		}
		return disabledTriggers.get(type);
	}

	public static void execute(SObjectType sobjectType) {
		AbstractTriggerHandler handler = createHandler(sobjectType);
		if (isTriggerDisabled(sobjectType)) {
			return;
		}

		handleOperation(handler);
	}

	private static void handleOperation(AbstractTriggerHandler handler) {
		switch on Trigger.operationType {
			when AFTER_UPDATE {
				handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
			}
			when BEFORE_UPDATE {
				handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
			}
			when BEFORE_INSERT {
				handler.beforeInsert(Trigger.new);
			}
			when AFTER_INSERT {
				handler.afterInsert(Trigger.newMap);
			}
			when BEFORE_DELETE {
				handler.beforeDelete(Trigger.oldMap);
			}
			when AFTER_DELETE {
				handler.afterDelete(Trigger.oldMap);
			}
			when AFTER_UNDELETE {
				handler.afterUndelete(Trigger.oldMap);
			}
		}
	}

	private static AbstractTriggerHandler createHandler(SObjectType sobjectType) {
		Map<SObjectType, String> typeMap = new Map<SObjectType, String>{
			Opportunity.SObjectType => 'OpportunityTriggerHandler',
			Work_Breakdown_Structure__c.SObjectType => 'WorkBreakdownStructureTriggerHandler'
		};
		Type obType = Type.forName(typeMap.get(sobjectType));
		AbstractTriggerHandler handler = (obType == null) ? null : (AbstractTriggerHandler) obType.newInstance();
		if (handler == null) {
			throw new TriggerException('No trigger handler registered for Object Type' + typeMap.get(sobjectType));
		}
		return handler;
	}
}
