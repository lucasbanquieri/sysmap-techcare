import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import SLA_DEADLINE_FIELD from '@salesforce/schema/Case_Request__c.SLA_Deadline__c';
import STATUS_FIELD from '@salesforce/schema/Case_Request__c.Status__c';

import reopenCaseRequest from '@salesforce/apex/CaseRequestReopen.reopenCaseRequest';

export default class CaseDetail extends LightningElement {

    static ALLOWED_PROFILES = ['Support Premium', 'System Administrator'];

    @api recordId;
    @track isCaseClosed;
    @track profileName;
    @track SLADeadline;
    @track SLAExpired = false;
    @track caseStatus;
    @track dataReady = false;
    intervalId;
    @track SLARemaining = 0;

    @wire(getRecord, { recordId: USER_ID, fields: PROFILE_NAME_FIELD })
    getUserProfile({ data, error }) {
        if (data) {
            this.profileName = data.fields.Profile.displayValue;
        } else if (error) {
            console.error('Error fetching user profile:', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [SLA_DEADLINE_FIELD, STATUS_FIELD] })
    getCaseRequestSLADeadline({ error, data }) {
        if (data) {
            this.SLADeadline = new Date(data.fields.SLA_Deadline__c.value);
            this.caseStatus = data.fields.Status__c.value;

            if (this.caseStatus === 'Closed')
                this.isCaseClosed = true;

            this.dataReady = true;
            this.startCountdown();
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }

    get showSLARemaining() {
        if (!this.dataReady)
            return false;

        return this?.caseStatus !== 'Closed' && this?.SLARemaining?.hours > 0;
    }

    get showSLAExpired() {
        if (!this.dataReady)
            return false;

        return this?.caseStatus !== 'Closed' && this?.SLARemaining <= 0;
    }

    get showReopenButton() {
        if (!this.dataReady)
            return false;

        return this?.caseStatus === 'Closed' && ALLOWED_PROFILES.includes(this?.profileName);
    }

    startCountdown() {
        this.updateCountdown();
        this.intervalId = setInterval(() => {
            this.updateCountdown();
        }, 1000);
    }

    updateCountdown() {
        const now = new Date();
        const difference = this.SLADeadline - now;

        if (difference <= 0) {
            clearInterval(this.intervalId);
            this.SLARemaining = 0;
            return;
        }

        const totalSeconds = Math.floor(difference / 1000);
        const days = Math.floor(totalSeconds / (3600 * 24));
        const hours = Math.floor((totalSeconds % (3600 * 24)) / 3600);

        this.SLARemaining = { days, hours, minutes };
    }

    handleReopenClick() {
        reopenCaseRequest({ caseRequestId: this.recordId })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Case Request reopened successfully.',
                    variant: 'success'
                }));
                this.isCaseClosed = false;
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }))
            });
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }
    
}