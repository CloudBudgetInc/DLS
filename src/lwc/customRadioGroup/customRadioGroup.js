import { LightningElement, api, track } from 'lwc';

const VARIANT = {
    STANDARD: 'standard',
    LABEL_HIDDEN: 'label-hidden',
    LABEL_STACKED: 'label-stacked',
    LABEL_INLINE: 'label-inline'
};

const proto = {
    add(className) {
        if (typeof className === 'string') {
            this[className] = true;
        } else {
            Object.assign(this, className);
        }
        return this;
    },
    invert() {
        Object.keys(this).forEach(key => {
            this[key] = !this[key];
        });
        return this;
    },
    toString() {
        return Object.keys(this)
            .filter(key => this[key])
            .join(' ');
    }
};


export default class CustomRadioGroup extends LightningElement {
    static delegatesFocus = true;

    @api type = 'radio';

    @api label;

    @api options;

    @api messageWhenValueMissing;

    @api name;
    @api radioStyle;
    @track _required = false;
    @track _disabled = false;
    @track _value;
    
    
    connectedCallback() {
        this.classList.add('slds-form-element');  
        this.updateClassList();      
    }

    updateClassList() {
        var config = {
            'slds-form-element_stacked': this.variant === VARIANT.LABEL_STACKED,
            'slds-form-element_horizontal':
                this.variant === VARIANT.LABEL_INLINE
        };

        Object.keys(config).forEach(key => {
            if (typeof key === 'string' && key.length) {
                if (config[key]) {
                    this.classList.add(key);
                } else {
                    this.classList.remove(key);
                }
            }
        });
    }

    renderedCallback() {
        //this.synchronizeA11y();
    }

    @api get value() {
        return this._value;
    }

    set value(value) {
        this._value = value;
    }

    get radioButtonElements() {
        return this.template.querySelectorAll('input');
    }

    @api get disabled() {
        return this._disabled;
    }

    set disabled(value) {
        this._disabled = value;
    }

    @api get required() {
        return this._required;
    }
    
    @api get variant() {
        return this._variant || VARIANT.STANDARD;
    }

    set variant(value) {
        this._variant = value;
        this.updateClassList();
    }

    get transformedOptions() {
        const { options, value } = this;
        if (Array.isArray(options)) {
            return options.map((option, index) => ({
                label: option.label,
                value: option.value,
                isChecked: value === option.value,
                indexId: `radio-${index}`
            }));
        }
        return [];
    }

    handleFocus() {
        this.interactingState.enter();

        this.dispatchEvent(new CustomEvent('focus'));
    }

    handleBlur() {
        this.interactingState.leave();

        this.dispatchEvent(new CustomEvent('blur'));
    }

    handleChange(event) {
        event.stopPropagation();

        //this.interactingState.interacting();

        const value = Array.from(this.radioButtonElements)
            .filter(radioButton => radioButton.checked)
            .map(radioButton => radioButton.value)
            .toString();

        this._value = value;

        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value
                },

                //composed: true,
                //bubbles: true,
                //cancelable: true
            })
        );
    }
    
    get computedLegendClass() {
        const classnames = this.classSet(
            'slds-form-element__label'
        );

        return classnames
            .add({
                'slds-assistive-text': this.variant === VARIANT.LABEL_HIDDEN
            })
            .toString();
    }

    classSet(config) {
        if (typeof config === 'string') {
            const key = config;
            config = {};
            config[key] = true;
        }
        return Object.assign(Object.create(proto), config);
    }
}