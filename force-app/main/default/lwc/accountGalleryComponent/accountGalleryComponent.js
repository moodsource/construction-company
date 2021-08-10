import { LightningElement, wire } from 'lwc';  

import fetchAllAccounts from '@salesforce/apex/IterationInLwcController.fetchAllAccounts'; 


export default class IterationInLwc extends LightningElement { 
    accData
    accountBudget = 0
    value = 'All Types'
    accountidFromParent

    @wire(fetchAllAccounts,{actName:'$value'}) accounts(data){
        this.accData = data
        this.accountBudget = 0
        for (var key in data.data) {
            this.accountBudget += parseFloat(data.data[key].Budget__c)
        }
    };
    
    get options() {
        return [
            { label: 'All Types', value: 'All types' },
            { label: 'Channel', value: 'Customer - Channel' },
            { label: 'Direct', value: 'Customer - Direct' },
        ];
    }
    
    handleChange(event) {
        this.value = event.detail.value;
    }  
    handleClick(event){
        event.preventDefault();
        this.accountidFromParent = event.target.dataset.accountid
    }
 }