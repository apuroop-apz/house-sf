public with sharing class OpportunityHandler implements ITrigger{
    private Set<Id> oppIdsForProposalCreation = new Set<Id>();

    public void bulkBefore(){}
    public void bulkAfter(){}
    public void beforeInsert(SObject so){}
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterUpdate(SObject oldSo, SObject so){}
    public void afterDelete(SObject so){}
    
    public void afterInsert(SObject so) {
        Opportunity opp = (Opportunity)so;
        oppIdsForProposalCreation.add(opp.Id);
    }

    // Final operations
    public void andFinally() {
        if ( Trigger.isAfter ) {
             // Create initial proposal if this is an insert operation
            if ( Trigger.isInsert ) {
                 // Call the helper method to create the initial proposal
                OpportunityHelper.createInitialProposal(oppIdsForProposalCreation);
            }
        }
    }
}