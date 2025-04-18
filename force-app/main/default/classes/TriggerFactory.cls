//**********************************************************************************************************************
// Used to instantiate and execute Trigger Handlers associated with sObjects.
// Original author: Tony Scott
// Implemented by: Apuroop
//  
// Reference:
// https://meltedwires.com/2013/06/05/trigger-pattern-for-tidy-streamlined-bulkified-triggers-revisited/
public with sharing class TriggerFactory
{
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Type t - Type of handler to instatiate
     *
     * Throws a TriggerException if no handler has been found.
     */
    public static void createAndExecuteHandler(Type t) {
        // Make sure we have a handler registered, new handlers implement the propper interface
        Object obj = t.newInstance();
        if (obj instanceOf ITrigger) {
            execute((ITrigger)obj);
        } else if (obj instanceOf ITriggerAsync) {
            execute((ITriggerAsync)obj);
        } else{
            throw new TriggerException('No Trigger Handler found named: ' + t.getName());
        }
    }
 
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(ITrigger handler)
    {
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
 
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                for (SObject so : Trigger.old)
                {
                    handler.beforeDelete( so);
                }
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                for (sobject so : Trigger.new)
                {
                    handler.beforeInsert( so);
                }
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                for (SObject so : Trigger.old)
                {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
 
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                for (SObject so : Trigger.old)
                {
                    handler.afterDelete( so);
                }
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                for (SObject so : Trigger.new)
                {
                    handler.afterInsert( so);
                }
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                for (SObject so : Trigger.old)
                {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
 
        // Perform any post processing
        handler.andFinally();
    }

    /*
	 * Override for Async Interfacses -- Executes the handler as programmed
	 */
	private static void execute(ITriggerAsync handler) {

		// Before Triggers are not valid in asyc
		if (Trigger.isBefore) {
			throw new TriggerException('Async Trigger called in Before context; only After Insert supported.');
		}
		else {
			// Call the bulk after to handle any caching of data and enable bulkification
			handler.bulkAfter();
 
			// Iterate through the records inserted passing them to the handler.
			if (Trigger.isInsert) {
                for (SObject so : Trigger.new) {
                    handler.afterInsert(so);
				}
			}
            // Remaining contexts are not valid in async
            else if (Trigger.isDelete ) {
                throw new TriggerException('Async Trigger called in After Delete context; only After Insert supported.');
            }
			else if (Trigger.isUpdate) {
				throw new TriggerException('Async Trigger called in After Upadate context; only After Insert supported.' );
			}
			else if (Trigger.isUndelete ) {
				throw new TriggerException('Async Trigger called in After Undelete context; only After Insert supported.');
			}
		}
		/* Perform any post processing; Once following Before Trigger, once following After Trigger
		 */
		handler.andFinally();
	}
 
    public class TriggerException extends Exception {}
}