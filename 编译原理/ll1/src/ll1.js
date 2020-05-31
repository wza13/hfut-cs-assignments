/**
 * @param {Array<String>} rules
 * @param {String} inputString
 * @author yzj
 */
function startLL1(rules, inputString) {
    if (inputString[inputString.length - 1] !== '#')
        inputString = inputString + '#';
    if (!checkRules(rules)) {

        return ['format', []];
    }

    const [nonTerminals, terminals] = initToken(rules);
    const nullables = getNullables(rules);
    const leftString = inputString.split('');
    const stack = [rules[0][0]];
    const steps = [];

    // // test
    // console.log(nonTerminals);
    // console.log(terminals);
    // console.log(nullables);
    // return [undefined, steps];

    const first = getFirst(rules, nonTerminals, terminals, nullables);
    const follow = getFollow(rules, nonTerminals, terminals, nullables, first);
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
            getReversedRightHand(rules[usedRuleIndex]).forEach(token => {
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
                else if (nonTerminals.has(token)) {
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
                `pop; push(${getReversedRightHand(rules[usedRuleIndex]).join('')})`;
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
}
