import {api, LightningElement, track} from 'lwc';

export default class CbValueBar extends LightningElement {
	@api value = 0.25;

	@track styleWidth;
	@track styleFill;
	@track showWarning;

	connectedCallback () {
		let width = this.value * 100;
		this.styleFill = width >= 0 ? 'blueBarFill' : 'redBarFill';
		this.showWarning = width > 100 || width < -100;
		if(width < 0) width *= -1;
		if(width > 100) width = 100;
		this.styleWidth = `width: ${width}%`;
	}
}