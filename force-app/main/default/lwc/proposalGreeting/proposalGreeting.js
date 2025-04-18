import { LightningElement, api, track, wire } from 'lwc';
import { reduceErrors } from 'c/errorUtils';
import getProposal from '@salesforce/apex/ProposalController.getProposal';
import saveGreeting from '@salesforce/apex/ProposalController.saveGreeting';

export default class ProposalGreeting extends LightningElement {
    @api proposalId;
    @track greetingText = '';
    @track showSaveButton = false;
    @track errors = [];
    proposal;

    @wire(getProposal, { proposalId: '$proposalId' })
    wiredProposal({ error, data }) {
        if (data) {
            this.proposal = data;
            this.greetingText = data.Greeting_Text__c || '';
        } else if (error) {
            this.errors = reduceErrors(error);
        }
    }

    handleGreetingChange(event) {
        this.greetingText = event.target.value;
        this.showSaveButton = true;
    }

    handleSave() {
        saveGreeting({ proposalId: this.proposalId, greeting: this.greetingText })
            .then(() => {
                this.showSaveButton = false;
                console.log('Greeting saved successfully.');
            })
            .catch(error => {
                this.errors = reduceErrors(error);
            });
    }
}

