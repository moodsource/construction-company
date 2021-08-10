import { LightningElement, api, wire } from 'lwc';
import findAccountById from '@salesforce/apex/AccountController.findAccountById';
import {NavigationMixin} from 'lightning/navigation';

export default class AccountDescriptionComponent extends NavigationMixin(LightningElement) {
   @api accountId
   @wire(findAccountById,{accountId:'$accountId'})contacts;
   
   navigateToViewRecordPage(){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.accountId,
                objectApiName:"Account",
                actionName: "view"
            }
        });
    }
}