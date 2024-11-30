export function selectTaskAtRandom(listOfTasks) {
    const cdfArray = [];
    let cdfCumulativeValue = 0.0;

    for (const task of listOfTasks) {
        var taskWeight;
        if (task.weight != null) {
            taskWeight = task.weight;
        } else {
            taskWeight = 1.0;
        }
        cdfCumulativeValue += taskWeight;
        // Creates a new "task" object with cdfValue (because you can't modify the original)
        cdfArray.push({ ...task, cdfValue: cdfCumulativeValue });
    }

    const randomValue = Math.random() * cdfCumulativeValue;

    var randomTask = binarySearchCDFArray(cdfArray, randomValue);
    delete randomTask.cdfValue; // strip out our custom cdfValue attribute
    return randomTask;
}

export function binarySearchCDFArray(cdfArray, value) {
    // DEBUG
    // console.log(cdfArray);
    // console.log(value);

    if (cdfArray == []) {
        return undefined;
    }

    let leftIndex = 0;
    let rightIndex = cdfArray.length - 1;

    // If the right index is the same as (or <) the left index, we know there's only 1 task in the array
    while (leftIndex < rightIndex) {
        const midIndex = Math.floor((leftIndex + rightIndex) / 2);

        const midTask = cdfArray[midIndex];

        if (value === midTask.cdfValue) {
            return midTask;
        }
        if (value < midTask.cdfValue) {
            rightIndex = midIndex;
        }
        if (value > midTask.cdfValue) {
            leftIndex = midIndex + 1;
        }
    }

    return cdfArray[rightIndex]; // At this point, rightIndex <= leftIndex, meaning, there is only one entry in the array
}
  
