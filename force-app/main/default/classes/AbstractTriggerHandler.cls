public abstract class AbstractTriggerHandler {
	private Boolean triggerDisabled = false;

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

	public void disableTrigger() {
		this.triggerDisabled = true;
	}
	public void enableTrigger() {
		this.triggerDisabled = false;
	}

	public Boolean isTriggerEnabled() {
		return !triggerDisabled;
	}
}
