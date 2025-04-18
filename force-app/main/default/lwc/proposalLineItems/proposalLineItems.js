import { LightningElement, api, wire, track } from 'lwc';
import getProposalLineItems from '@salesforce/apex/ProposalController.getLineItems';
import updateLineItem from '@salesforce/apex/ProposalController.updateLineItem';
import { reduceErrors } from 'c/errorUtils';

export default class ProposalLineItems extends LightningElement {
    @api proposalItemId;
    @track lineItems = [];
    @track toggledLineItems = {};
    @track errors = [];

    //for debouncing
    saveTimeouts = {};
    lastSavedStates = {};
    debounceTimers = {}; // Maps line.Id => timer
    changedLines = new Set(); // Tracks which lines have pending changes

    disconnectedCallback() {
        // Save all pending changes immediately
        this.changedLines.forEach(lineId => {
            const line = this.lineItems.find(l => l.Id === lineId);
            if (line) {
                this.saveLine(line);
            }
        });
    }

    
    @wire(getProposalLineItems, { proposalItemId: '$proposalItemId' })
    wiredLines({ error, data }) {
        if (data) {
            this.lineItems = data.map(line => ({
                ...line,
                expanded: true,
                iconName: 'utility:chevrondown',
                Subtotal__c: this.calculateSubtotal(line)
            }));
        } else if (error) {
            this.errors = reduceErrors(error);
        }
    }

    toggleLine(event) {
        const lineId = event.currentTarget.dataset.id;
        this.lineItems = this.lineItems.map(line => {
            if (line.Id === lineId) {
                const expanded = !line.expanded;
                return {
                    ...line,
                    expanded,
                    iconName: expanded ? 'utility:chevrondown' : 'utility:chevronright'
                };
            }
            return line;
        });
    }

    editName(event) {
        const lineId = event.currentTarget.dataset.id;
        this.lineItems = this.lineItems.map(line => {
            return {
                ...line,
                isEditingName: line.Id === lineId
            };
        });
    }

    onBlurName(){ //clicked outside of input
        const line = this.findLine(event);
        if (line) {
            line.isEditingName = false;
        }
    }

    // START --- handle onChange fields
    handleNameChange(event) {
        const line = this.findLine(event);
        if (line) {
            line.Name = event.target.value;
            this.debounceSave(line);
        }
    }

    handleQuantityChange(event) {
        const line = this.findLine(event);
        if (line) {
            line.Quantity__c = parseFloat(event.target.value) || 0;
            line.Subtotal__c = this.calculateSubtotal(line);
            this.debounceSave(line);
        }
    }

    handlePriceChange(event) {
        const line = this.findLine(event);
        if (line) {
            line.Unit_Price__c = parseFloat(event.target.value) || 0;
            line.Subtotal__c = this.calculateSubtotal(line);
            this.debounceSave(line);
        }
    }

    handleDescriptionChange(event) {
        const line = this.findLine(event);
        if (line) {
            line.Description__c = event.target.value;
            this.debounceSave(line);
        }
    }
    // END --- handle onChange fields

    //START --- dml calls to Apex
    debounceSave(line) {
        const lineId = line.Id;
    
        // Mark this line as changed
        this.changedLines.add(lineId);
    
        // Clear any previous timer
        if (this.debounceTimers[lineId]) {
            clearTimeout(this.debounceTimers[lineId]);
        }
    
        // Set a new timer
        this.debounceTimers[lineId] = setTimeout(() => {
            this.saveLine(line);
            delete this.debounceTimers[lineId];
            this.changedLines.delete(lineId);
        }, 5000);
    }
    
    saveLine(line) {
        updateLineItem({ line })
            .then(() => console.log('Line item saved'))
            .catch(error => {
                this.errors = reduceErrors(error);
            });
    }
    //END --- dml calls to Apex

    //START --- handle lightning-button-icon actions
    handleMoveUp(event) {
        const lineId = event.currentTarget.dataset.id;
        console.log(`Move up: ${lineId}`);
        // Sorting logic to be added
    }

    handleMoveDown(event) {
        const lineId = event.currentTarget.dataset.id;
        console.log(`Move down: ${lineId}`);
        // Sorting logic to be added
    }

    handleToolsClick(event) {
        const lineId = event.currentTarget.dataset.id;
        console.log(`Tools clicked for: ${lineId}`);
        // Launch flow or modal here later
    }
    //END --- handle lightning-button-icon actions
    
    
    
    //Utility methods
    hasLineChanged(line) {
        const last = this.lastSavedStates[line.Id] || {};
        return (
            line.Name !== last.Name ||
            line.Quantity__c !== last.Quantity__c ||
            line.Unit_Price__c !== last.Unit_Price__c ||
            line.Description__c !== last.Description__c
        );
    }
    
    calculateSubtotal(line) {
        return (line.Quantity__c || 0) * (line.Unit_Price__c || 0);
    }

    findLine(event) {
        const lineId = event.target.dataset.id;
        return this.lineItems.find(l => l.Id === lineId);
    }
}
