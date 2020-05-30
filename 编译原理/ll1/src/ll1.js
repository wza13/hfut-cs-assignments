/**
 * @param {Array<String>} rules
 * @param {String} inputString
 * @author yzj
 */
function startLL1(rules, inputString) {
    if (inputString[inputString.length - 1] !== '#')
        inputString = inputString + '#';
    if (!checkRules()) {

        return ['format', []];
    }

    const [nonTerminals, terminals] = initToken();
    const nullables = getNullables();
    const leftString = inputString.split('');
    const stack = [rules[0][0]];
    const steps = [];

    // // test
    // console.log(nonTerminals);
    // console.log(terminals);
    // console.log(nullables);
    // return [undefined, steps];

    const first = getFirst();
    const follow = getFollow();
    const firstS = getFirstS();
    const table = getTable();

    // // test
    // console.dir(first);
    // console.dir(follow);
    // console.dir(firstS);
    // console.dir(table);
    // return [undefined, steps];

    if (!checkTable()) {

        return ['notLL1', []];
    }

    pushStep(stack, leftString, -1, 'initialize');
    while (stack.length) {
        const t = stack.pop();
        if (nonTerminals.has(t)) {
            const usedRuleIndex = table[t][leftString[0]];
            if (usedRuleIndex === null || usedRuleIndex === undefined)
                return ['fail', steps];
            getReversedRightHand(usedRuleIndex).forEach(token => {
                stack.push(token);
            });
            pushStep(stack, leftString, usedRuleIndex);
        }
        else {
            const s = leftString.shift();
            if (t !== s) return ['fail', steps];
            pushStep(stack, leftString, -1, 'get next');
        }
    }

    return [undefined, steps];


    /**
     * @returns {[Array, Array]} [nonTerminals, terminals]
     */
    function initToken() {
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


    function getNullables() {
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


    function getFirst() {
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


    function getFollow() {
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


    function getFirstS() {
        const firstS = {};
        rules.forEach((rule, index) => {
            firstS[index] = new Set();
            let allRightHandTokenIsNullable = true;
            for (const token of getRightHand(rule).split('')) {
                if (terminals.has(token)) {
                    firstS[index].add(token);
                    allRightHandTokenIsNullable = false;
                    break;
                }
                else {
                    appendSet(firstS[index], first[token]);
                    if (!nullables.has(token)) {
                        allRightHandTokenIsNullable = false;
                        break;
                    }
                }
            }
            if (allRightHandTokenIsNullable)
                appendSet(firstS[index], follow[getLeftHand(rule)]);
        });

        return firstS;
    }


    function getTable() {
        const table = {};
        nonTerminals.forEach(nonTerminal => {
            table[nonTerminal] = {};
            terminals.forEach(terminal => {
                table[nonTerminal][terminal] = [];
            });
        });
        rules.forEach((rule, index) => {
            const nonTerminal = getLeftHand(rule);
            firstS[index].forEach(token => {
                table[nonTerminal][token].push(index);
            });
        });

        return table;
    }


    function checkTable() {
        for (const nonTerminal in table) {
            for (const terminal in table[nonTerminal]) {
                if (table[nonTerminal][terminal].length > 1)

                    return false;
            }
        }
        for (const nonTerminal in table) {
            for (const terminal in table[nonTerminal]) {
                table[nonTerminal][terminal] = table[nonTerminal][terminal][0];
            }
        }

        return true;
    }


    /**
     * @param {Array} stack
     * @param {Array} leftString
     * @param {number} usedRuleIndex -1 ~ rules.length - 1
     * -1 means no rule is used
     * @param {String} action if usedRuleIndex !== -1,
     * action should be 'pop, push(reverse of the right hand)'
     * @returns {Object} return an Object that contain 4 strings
     */
    function pushStep(stack, leftString, usedRuleIndex, action) {
        const stackString = stack.join('');
        const leftStringString = leftString.join('');
        let actionString = action || '';
        if (usedRuleIndex !== -1) {
            actionString =
                `pop; push(${getReversedRightHand(usedRuleIndex).join('')})`;
        }
        steps.push({
            stack: stackString,
            leftString: leftStringString,
            usedRule: usedRuleIndex === -1 ? '' : rules[usedRuleIndex],
            action: actionString,
        });
        // console.log(stackString, leftStringString, usedRuleIndex,
        //     usedRuleIndex === -1 ? '' : rules[usedRuleIndex], actionString);
    }


    /**
     * @returns {Array} the reversed Array of the right hand of the rule
     */
    function getReversedRightHand(ruleIndex) {
        return getRightHand(rules[ruleIndex]).split('').reverse();
    }

    function getLeftHand(rule) {
        return rule.substring(0, rule.indexOf('->'));
    }
    function getRightHand(rule) {
        return rule.substring(rule.indexOf('->') + 2);
    }

    function checkRules() {
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
}
