export function selectTaskAtRandom(listOfTasks) {
    // TODO Algorithm that accounts for weights
    let randomIndex = Math.floor(Math.random() * listOfTasks.length);
    return listOfTasks[randomIndex];
}