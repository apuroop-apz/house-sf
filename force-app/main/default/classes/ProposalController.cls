public with sharing class ProposalController {
    /*
     * These methods are used for proposalGreeting component.
     
    // This method saves the updated greeting text to the Proposal__c record.
    @AuraEnabled
    public static void saveGreeting(Id proposalId, String greeting) {
        // Query the Proposal record by Id
        Proposal__c proposalRec = [
            SELECT Id, Greeting_Text__c 
            FROM Proposal__c 
            WHERE Id = :proposalId 
            LIMIT 1
        ];
        proposalRec.Greeting_Text__c = greeting;
        update proposalRec;
    }
    /*
     * These methods are used for proposalItem component.
     
    @AuraEnabled(cacheable=true)
    public static List<Proposal_Item__c> getProposalItems(Id proposalId) {
        return [
            SELECT Id, Name, Description__c, Sort_Order__c, Include_in_Total__c,
                (SELECT Id, Name, Description__c, Quantity__c, Unit_Price__c, 
                        Subtotal__c, Taxable__c, Include_in_Total__c, Sort_Order__c
                 FROM Proposal_Line_Items__r
                 ORDER BY Sort_Order__c ASC)
            FROM Proposal_Item__c
            WHERE Proposal__c = :proposalId
            ORDER BY Sort_Order__c ASC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Proposal__c getProposal(Id opportunityId) {
        // Assumes there's always one Proposal__c record per Opportunity
        return [
            SELECT Id, Greeting_Text__c, Terms_and_Conditions__c 
            FROM Proposal__c
            WHERE Opportunity__c = :opportunityId
            LIMIT 1
        ];
    }*/
    // Method to get Proposal Id based on Opportunity Id
    @AuraEnabled(cacheable=true)
    public static Id getProposalId(Id opportunityId) {
        // Fetch the Proposal related to the Opportunity
        Proposal__c proposal = [SELECT Id FROM Proposal__c WHERE Opportunity__c = :opportunityId LIMIT 1];
        if (proposal != null) {
            return proposal.Id;
        }
        return null; // Return null if no proposal exists
    }

    @AuraEnabled(cacheable=true)
    public static List<Proposal_Item__c> getProposalItems(Id proposalId) {
        return [
            SELECT Id, Name, Include_in_Total__c
            FROM Proposal_Item__c
            WHERE Proposal__c = :proposalId
            ORDER BY Sort_Order__c ASC, CreatedDate ASC
        ];
    }

    @AuraEnabled
    public static void updateProposalItem(Proposal_Item__c item) {
        if (item != null) {
            update item;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Proposal_Line_Item__c> getLineItems(Id proposalItemId) {
        return [
            SELECT Id, Name, Quantity__c, Unit_Price__c, Subtotal__c, Description__c, Taxable__c
            FROM Proposal_Line_Item__c
            WHERE Proposal_Item__c = :proposalItemId
            ORDER BY Sort_Order__c ASC, CreatedDate ASC
        ];
    }

    @AuraEnabled
    public static void updateLineItem(Proposal_Line_Item__c line) {
        if (line != null) {
            update line;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Proposal__c getProposal(Id proposalId) {
        return [
            SELECT Id, Greeting_Text__c, Opportunity__c, Terms_and_Conditions__c
            FROM Proposal__c
            WHERE Id = :proposalId
            LIMIT 1
        ];
    }


    @AuraEnabled
    public static void saveGreeting(Id proposalId, String greeting) {
        if (String.isNotBlank(greeting) && proposalId != null) {
            Proposal__c proposal = [SELECT Id, Greeting_Text__c FROM Proposal__c WHERE Id = :proposalId LIMIT 1];
            proposal.Greeting_Text__c = greeting;
            update proposal;
        }
    }

}
