function addDotToRule(rule) {
    const startIndex = rule.indexOf('->') + 2;
    return rule.substring(0, startIndex) +
        '`' + rule.substring(startIndex);
}

function getTokenAfterDot(item) {
    return item[item.indexOf('`') + 1] || '';
}
function getTokenAfterAfterDot(item) {
    return item[item.indexOf('`') + 2] || '';
}

function moveDotToNext(item) {
    const index = item.indexOf('`');
    if (index === item.length - 1) return item;
    return `${item.substring(0, index)}${item.charAt(index + 1)}` +
        `\`${item.substring(index + 2)}`;
}
