function getLeftHand(rule) {
    return rule.substring(0, rule.indexOf('->'));
}

function getRightHand(rule) {
    return rule.substring(rule.indexOf('->') + 2);
}

/**
 * @returns {Array} the reversed Array of the right hand of the rule
 */
function getReversedRightHand(rule) {
    return getRightHand(rule).split('').reverse();
}

function checkRules(rules) {
    return rules.findIndex(rule => !rule.includes('->')) !== -1 ?
        false : true;
}

function getSetsTotalSize(sets) {
    return Object.values(sets)
        .map(set => set.size)
        .reduce((prev, curr) => prev + curr);
}

function appendSet(setA, setB) {
    setB.forEach(item => {setA.add(item)});
}
