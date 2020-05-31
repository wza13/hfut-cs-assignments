/**
 * @param {Array<String>} rules
 * @returns {[Array, Array]} [nonTerminals, terminals]
 */
function initToken(rules) {
    let nonTerminals = new Set();
    let terminals = new Set();
    terminals.add('#');
    for (const rule of rules) {
        nonTerminals.add(getLeftHand(rule));
    }
    for (const rule of rules) {
        getRightHand(rule).split('').forEach(token => {
            if (!nonTerminals.has(token))
                terminals.add(token);
        })
    }

    return [nonTerminals, terminals]
}


function getNullables(rules) {
    let nullables = new Set();
    let size = 0;
    let newSize = 0;
    do {
        size = nullables.size;
        for (const rule of rules) {
            const nonTerminal = getLeftHand(rule);
            const rightHand = getRightHand(rule)
            if (rightHand === '') nullables.add(nonTerminal);
            else {
                let nullable = true;
                for (const token of rightHand.split('')) {
                    if (!nullables.has(token)) {
                        nullable = false;
                        break;
                    }
                }
                if (nullable) nullables.add(nonTerminal);
            }
        }
        newSize = nullables.size;
    } while (newSize !== size)

    return nullables;
}


function getFirst(rules, nonTerminals, terminals, nullables) {
    const first = {};
    for (const nonTerminal of nonTerminals) {
        first[nonTerminal] = new Set();
    }
    let size = 0;
    let newSize = 0;
    do {
        size = getSetsTotalSize(first);
        for (const rule of rules) {
            const nonTerminal = getLeftHand(rule);
            for (const token of getRightHand(rule).split('')) {
                if (terminals.has(token)) {
                    first[nonTerminal].add(token);
                    break;
                }
                else {
                    appendSet(first[nonTerminal], first[token])
                    if (!nullables.has(token)) break;
                }
            }
        }
        newSize = getSetsTotalSize(first);
    } while (newSize !== size)

    return first;
}


function getFollow(rules, nonTerminals, terminals, nullables, first) {
    const follow = {};
    for (const nonTerminal of nonTerminals) {
        follow[nonTerminal] = new Set();
    }
    follow[rules[0][0]].add('#');
    let size = 0;
    let newSize = 0;
    do {
        size = getSetsTotalSize(follow);
        for (const rule of rules) {
            const nonTerminal = getLeftHand(rule);
            let temp = new Set(follow[nonTerminal]);
            for (const token of getRightHand(rule).split('').reverse()) {
                if (terminals.has(token)) {
                    temp = new Set([token]);
                }
                else {
                    appendSet(follow[token], temp);
                    if (nullables.has(token)) appendSet(temp, first[token]);
                    else temp = new Set(first[token]);
                }
            }
        }
        newSize = getSetsTotalSize(follow);
    } while (newSize !== size)

    return follow;
}
