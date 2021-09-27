public abstract class AbstractTriggerHandler {
	public virtual void beforeUpdate(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
	}

	public virtual void afterUpdate(Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
	}

	public virtual void beforeDelete(Map<Id, SObject> oldItemsMap) {
	}

	public virtual void afterInsert(Map<Id, SObject> newItemsMap) {
	}

	public virtual void afterDelete(Map<Id, SObject> oldItemsMap) {
	}

	public virtual void afterUndelete(Map<Id, SObject> oldItemsMap) {
	}

	public virtual void beforeInsert(List<SObject> newItems) {
	}
}
