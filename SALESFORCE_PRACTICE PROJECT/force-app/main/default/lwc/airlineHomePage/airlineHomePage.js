import { LightningElement } from 'lwc';
import banner from '@salesforce/resourceUrl/airlineBanner';

export default class airlineHomePage extends LightningElement {

    heroImageUrl = banner;

    isHome = true;
    isAbout = false;
    isServices = false;
    isContact = false;

    resetTabs() {
        this.isHome = false;
        this.isAbout = false;
        this.isServices = false;
        this.isContact = false;
    }

    showHome() {
        this.resetTabs();
        this.isHome = true;
    }

    showAbout() {
        this.resetTabs();
        this.isAbout = true;
    }

    showServices() {
        this.resetTabs();
        this.isServices = true;
    }

    showContact() {
        this.resetTabs();
        this.isContact = true;
    }
}