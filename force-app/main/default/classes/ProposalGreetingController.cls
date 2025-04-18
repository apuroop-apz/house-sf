public with sharing class ProposalGreetingController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTemplateAndOpportunity(Id opportunityId) {
        Opportunity opp = [
            SELECT Id, Name, Event_Type__c, Account.Name
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        Proposal_Template__c template = [
            SELECT Template_Text__c
            FROM Proposal_Template__c
            WHERE Event_Type__c = :opp.Event_Type__c
            AND Type__c = 'Greeting'
            LIMIT 1
        ];

        return new Map<String, Object>{
            'opportunity' => opp,
            'templateBody' => template.Template_Text__c
        };
    }

    @AuraEnabled
    public static void saveGreeting(Id opportunityId, String greeting) {
        Proposal__c proposal = [SELECT Id, Greeting_Text__c FROM Proposal__c WHERE Opportunity__c = :opportunityId LIMIT 1];
        proposal.Greeting_Text__c = greeting;
        update proposal;
    }

}
