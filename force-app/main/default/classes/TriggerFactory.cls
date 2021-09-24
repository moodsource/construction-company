public class TriggerFactory {
	public class TriggerException extends Exception {
	}
	public static void execute(SObjectType sobjectType) {
		AbstractTriggerHandler handler = createHandler(sobjectType);
		handler.enableTrigger();
		if (!handler.isTriggerEnabled()) {
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
