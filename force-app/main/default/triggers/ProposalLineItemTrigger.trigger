trigger ProposalLineItemTrigger on Proposal_Line_Item__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createAndExecuteHandler(ProposalLineItemHandler.class);
}