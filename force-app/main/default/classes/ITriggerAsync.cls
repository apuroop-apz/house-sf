/************************************************************************************************************************
* Extension of singlton pattern for async trigger execution
* @reference https://meltedwires.com/2013/06/05/trigger-pattern-for-tidy-streamlined-bulkified-triggers-revisited/
* @implementedBy	Apuroop
************************************************************************************************************************/
public interface ITriggerAsync {

    /**
     * Async triggers only support after insert as of v52.0
     */

    /**
	 * This method is called prior to execution of an AFTER trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	void bulkAfter();
    
    /**
	 * This method is called iteratively for each record inserted during an AFTER
	 * trigger. Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The record is 'read only' by this point.
	 */
	void afterInsert(SObject so);

    /**
	 * This method is called once all records have been processed by the trigger. Use this
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	void andFinally();
}