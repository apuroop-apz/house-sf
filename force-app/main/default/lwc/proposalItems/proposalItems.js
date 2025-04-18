import { LightningElement, api, wire, track } from 'lwc';
import { reduceErrors } from 'c/errorUtils';
import getProposalItems from '@salesforce/apex/ProposalController.getProposalItems';
import updateProposalItem from '@salesforce/apex/ProposalController.updateProposalItem';

export default class ProposalItems extends LightningElement {
    @api proposalId;
    @track proposalItems = [];
    @track errors = [];

    @wire(getProposalItems, { proposalId: '$proposalId' })
    wiredItems({ error, data }) {
        if (data) {
            this.proposalItems = data.map(item => ({ ...item, isEditing: false }));
        } else if (error) {
            this.errors = reduceErrors(error);
            this.proposalItems = undefined;
        }
    }

    handleItemNameChange(event) {
        const itemId = event.target.dataset.id;
        const item = this.proposalItems.find(i => i.Id === itemId);
        if (item) {
            item.Name = event.target.value;
        }
    }

    saveItemName(event) {
        const itemId = event.target.dataset.id;
        const item = this.proposalItems.find(i => i.Id === itemId);
        if (item) {
            // Save the updated item name
            updateProposalItem({ item })
                .then(() => {
                    item.isEditing = false;  // Switch back to display mode after saving
                })
                .catch(error => {
                    this.errors = reduceErrors(error);
                });
        }
    }

    enableEditing(event) {
        const itemId = event.target.dataset.id;
        const item = this.proposalItems.find(i => i.Id === itemId);
        if (item) {
            item.isEditing = true;  // Enable editing for this item
        }
    }

    preventEditUnlessDoubleClick(event) {
        const itemId = event.target.dataset.id;
        const item = this.proposalItems.find(i => i.Id === itemId);
        if (item) {
            // Prevent editing unless double-clicked
            if (item && !item.isEditing) {
                event.preventDefault();
            }
        }
    }
}