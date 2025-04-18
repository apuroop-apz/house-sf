import { LightningElement, api } from 'lwc';

export default class ErrorPanel extends LightningElement {
    @api location;
    @api errors = [];

    get hasErrors() {
        return this.errors && this.errors.length > 0;
    }
}
