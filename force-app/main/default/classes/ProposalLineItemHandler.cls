public with sharing class ProposalLineItemHandler implements ITrigger {
    private Set<Id> proposalItemIds = new Set<Id>();
    private List<Proposal_Line_Item__c> plisForDefaultSortBeforeInsert = new List<Proposal_Line_Item__c>();
    private List<Proposal_Line_Item__c> plisForDefaultSortBeforeUpdate = new List<Proposal_Line_Item__c>();
    private List<Proposal_Line_Item__c> oldPliRecords = new List<Proposal_Line_Item__c>();
    private List<Proposal_Line_Item__c> newPliRecords = new List<Proposal_Line_Item__c>();

    public void bulkBefore() {}
    public void bulkAfter() {}

    public void beforeInsert(SObject so) {
        Proposal_Line_Item__c newLine = (Proposal_Line_Item__c)so;
        if (newLine.Sort_Order__c == null) {
            plisForDefaultSortBeforeInsert.add(newLine);
            proposalItemIds.add(newLine.Proposal_Item__c);
        }
    }

    public void afterInsert(SObject so) {
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        Proposal_Line_Item__c newLine = (Proposal_Line_Item__c)so;
        Proposal_Line_Item__c oldLine = (Proposal_Line_Item__c)oldSo;
        if (oldLine.Sort_Order__c != newLine.Sort_Order__c) { // Only swap order if it has changed
            oldPliRecords.add(oldLine);
            newPliRecords.add(newLine);
        }
        if (newLine.Sort_Order__c == null && newLine.Proposal_Item__c != null) {
            plisForDefaultSortBeforeUpdate.add(newLine);
            proposalItemIds.add(newLine.Proposal_Item__c);
        }
    }

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void beforeDelete(SObject so) {
    }

    public void afterDelete(SObject so) {
    }

    // Final operations
    public void andFinally() {
        if ( Trigger.isBefore ) {
            if ( Trigger.isInsert ) {
                if (!plisForDefaultSortBeforeInsert.isEmpty()) {
                    ProposalLineItemHelper.assignDefaultSortOrder(plisForDefaultSortBeforeInsert, proposalItemIds);
                }
            }
            if ( Trigger.isUpdate ) {
                if (!plisForDefaultSortBeforeUpdate.isEmpty()) {
                    ProposalLineItemHelper.assignDefaultSortOrder(plisForDefaultSortBeforeUpdate, proposalItemIds);
                }
                if (!oldPliRecords.isEmpty()) {
                    ProposalLineItemHelper.swapSortOrder(oldPliRecords, newPliRecords);
                }
            }
        }
    }
}
