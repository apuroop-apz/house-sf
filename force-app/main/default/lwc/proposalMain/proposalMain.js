import { LightningElement, api, wire, track } from 'lwc';
import { reduceErrors } from 'c/errorUtils';
import getProposalId from '@salesforce/apex/ProposalController.getProposalId';

export default class ProposalMain extends LightningElement {
    @api recordId; // Opportunity Id
    @track errors = [];
    proposalId;
    activeSections = ['Greeting', 'Items'];
    

    @wire(getProposalId, { opportunityId: '$recordId' })
    wiredProposal({ error, data }) {
        if (data) {
            this.proposalId = data;
            this.errors = []; // clear previous errors
        } else if (error) {
            this.errors = reduceErrors(error);
        }
    }
}