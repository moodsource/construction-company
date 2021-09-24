public interface ITriggerHandler {
	void beforeUpdate(
		Map<Id, SObject> newItemsMap,
		Map<Id, SObject> oldItemsMap,
		List<SObject> newItems,
		List<SObject> oldItems
	);

	void beforeInsert(List<SObject> newItems);

	void beforeDelete(Map<Id, SObject> oldItemsMap);

	void afterUpdate(
		Map<Id, SObject> newItemsMap,
		Map<Id, SObject> oldItemsMap,
		List<SObject> newItems,
		List<SObject> oldItems
	);

	void afterDelete(Map<Id, SObject> oldItemsMap);

	void afterUndelete(Map<Id, SObject> oldItemsMap);

	void afterInsert(Map<Id, SObject> newItemsMap);

	Boolean isTriggerEnabled();

	void disableTrigger();
	
	void enableTrigger();
}
