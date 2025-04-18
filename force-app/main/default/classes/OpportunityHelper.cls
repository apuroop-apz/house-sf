public with sharing class OpportunityHelper {
    public static void createInitialProposal(Set<Id> opportunityIds) {
        List<Proposal__c> proposals = new List<Proposal__c>();
        Map<String, String> proposalTemplateMap = new Map<String, String>();
        for(Proposal_Template__c pt : [SELECT Template_Text__c, Event_Type__c FROM Proposal_Template__c WHERE Type__c = 'Greeting']){
            proposalTemplateMap.put(pt.Event_Type__c, pt.Template_Text__c);
        }
        for(Opportunity opp : [SELECT Id, Name, Account.Name, Event_Type__c FROM Opportunity WHERE Id IN :opportunityIds]) {
            Proposal__c proposal = new Proposal__c(
                Opportunity__c = opp.Id,
                Greeting_Text__c = MergeEngine.mergeOpportunityTemplate(proposalTemplateMap.get(opp.Event_Type__c), opp.Id)
            );
            proposals.add(proposal);
        }
        insert proposals;
    }
}