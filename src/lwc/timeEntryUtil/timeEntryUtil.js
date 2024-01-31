export default class timeEntryUtil {
    static validateTimeValue(value) {
        const validValues = [0.00, 0.25, 0.50, 0.75]; 
        if (!value == NaN || value ) {
            const result = parseFloat(value) - parseInt(value); 
            return validValues.includes(result);       
        }    
        return true; 
    }
}