import { expect } from 'chai';
import { binarySearchCDFArray } from './random.mjs';  // Adjust the import according to your file structure

describe('binarySearchCDFArray', () => {
    it('should find the task when the middle matches the exact CDF value', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0.05 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
        ];

        const task = binarySearchCDFArray(tasks, 0.1);
        expect(task.label).to.equal('Task 2');
    });

    it('should find the task when the middle value is NOT an exact match', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0.05 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
        ];

        const task = binarySearchCDFArray(tasks, 0.09); 
        expect(task.label).to.equal('Task 2'); 
    });
    
    it('should find the task to the left of the middle when the value matches the exact CDF value', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0.05 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
            { label: 'Task 5', cdfValue: 2.0 },
        ];

        const task = binarySearchCDFArray(tasks, 0.1);
        expect(task.label).to.equal('Task 2');
    });

    it('should find the task to the left of the middle with when the value is NOT an exact match', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0.05 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
            { label: 'Task 5', cdfValue: 2.0 },
        ];

        const task = binarySearchCDFArray(tasks, 0.09); 
        expect(task.label).to.equal('Task 2'); 
    });

    it('should find the first task in the array when the value is NOT an exact match', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0.05 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
            { label: 'Task 5', cdfValue: 2.0 },
        ];

        const task = binarySearchCDFArray(tasks, 0.04); 
        expect(task.label).to.equal('Task 1'); 
    });

    it('should find the first task in the array when the value is an exact match', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0.05 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
            { label: 'Task 5', cdfValue: 2.0 },
        ];

        const task = binarySearchCDFArray(tasks, 0.05); 
        expect(task.label).to.equal('Task 1'); 
    });

    it('should find the task to the right of the middle when the value matches the exact CDF value', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
        ];

        const task = binarySearchCDFArray(tasks, 0.3);
        expect(task.label).to.equal('Task 3');
    });

    it('should find the task to the right of the middle with when the value is NOT an exact match', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
        ];

        const task = binarySearchCDFArray(tasks, 0.29); 
        expect(task.label).to.equal('Task 3'); 
    });

    it('should return the last task if the random value is equal to the last task’s cdfValue', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0 },
            { label: 'Task 2', cdfValue: 0.1 },
            { label: 'Task 3', cdfValue: 0.3 },
            { label: 'Task 4', cdfValue: 1.3 },
        ];

        const task = binarySearchCDFArray(tasks, 1.3); 
        expect(task.label).to.equal('Task 4'); 
    });

    it('should find the task when the array is size 1 and there is NOT an exact CDF Value match', () => {
        const tasks = [
            { label: 'Task 1', cdfValue: 0.1 },
        ];

        const task = binarySearchCDFArray(tasks, 0.09);
        expect(task.label).to.equal('Task 1'); 
    });

    it('should handle an empty array gracefully', () => {
        const tasks = [];
        const task = binarySearchCDFArray(tasks, 1);
        expect(task).to.be.undefined; // Should return undefined for an empty array
    });
});
