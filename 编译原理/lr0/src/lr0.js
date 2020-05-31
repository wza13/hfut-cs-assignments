/**
 * @param {Array<String>} rules
 * @param {String} inputString
 * @author yzj
 */
function startLR0(rules, inputString) {
    if (inputString[inputString.length - 1] !== '#')
        inputString = inputString + '#';
    if (!checkRules(rules)) {

        return ['format', []];
    }

    const originStart = rules[0][0];
    rules.unshift(`${originStart}'->${originStart}`);

    const [nonTerminals, terminals] = initToken(rules);
    const nullables = getNullables(rules);
    const leftString = inputString.split('');
    const statusStack = ['0'];
    const tokenStack = ['#'];
    const steps = [];

    const [actionTable, gotoTable, itemSets, hasConflicts] = getTable();
    if (hasConflicts)
        return ['notLR0', steps];

    // // test
    // console.log('项目集族')
    // console.dir(itemSets);
    // console.log('action表')
    // console.dir(actionTable);
    // console.log('goto表')
    // console.dir(gotoTable);
    // console.log('是否有冲突', hasConflicts);
    // return;

    while (true) {
        steps.push({
            statusStack: statusStack.join(' '),
            tokenStack: tokenStack.join(''),
            leftString: leftString.join(''),
        });

        const token = leftString[0];
        const status = statusStack[statusStack.length - 1];
        if (actionTable[status][token] === undefined) {
            steps[steps.length - 1].action = '分析失败';
            return ['fail', steps];
        }
        else if (actionTable[status][token][0] === 's') {
            leftString.shift();
            tokenStack.push(token);
            const pushingStatus = actionTable[status][token].substring(1);
            statusStack.push(pushingStatus);
            steps[steps.length - 1].action = `移进，状态${pushingStatus}入栈`;
        }
        else if (actionTable[status][token][0] === 'r') {
            const reduceRuleIndex =
                Number(actionTable[status][token].substring(1));
            const reduction = getLeftHand(rules[reduceRuleIndex]);
            const popLength = getRightHand(rules[reduceRuleIndex]).length;
            for (let i = 0; i < popLength; ++ i) {
                statusStack.pop();
                tokenStack.pop();
            }
            tokenStack.push(reduction);
            const currStatus = statusStack[statusStack.length - 1];
            const pushingStatus = gotoTable[currStatus][reduction];
            if (pushingStatus === undefined) {
                steps[steps.length - 1].action = '分析失败';
                return ['fail', steps];
            }
            statusStack.push(pushingStatus);
            steps[steps.length - 1].action = `规约，状态${pushingStatus}入栈`;
        }
        else /* if (actionTable[status][token].toLowerCase() === 'accept') */ {
            steps[steps.length - 1].action = '分析成功';
            return [undefined, steps];
        }
    }


    function getTable() {
        /* Use this char ` to represent the DOT MARK. */
        /* itemSet format:
            {
                id: '0',
                items (Set): {
                    'A->B`C',
                    'C->`a',
                    ...
                }
            }
        */
        let hasConflicts = false;
        const originNonTerminals = new Set(nonTerminals);
        originNonTerminals.delete(`${originStart}'`);

        const actionTable = {};
        const gotoTable = {};
        const itemSets = [];
        const itemSetQueue = [];

        const firstItemSet = {
            id: '0',
            items: closure(addDotToRule(rules[0]))
        };
        itemSets.push(firstItemSet);
        itemSetQueue.push(firstItemSet);

        while (itemSetQueue.length) {
            const currItemSet = itemSetQueue.shift();
            if (actionTable[currItemSet.id] === undefined)
                actionTable[currItemSet.id] = {};
            if (gotoTable[currItemSet.id] === undefined)
                gotoTable[currItemSet.id] = {};

            let pointingItemSet = null;
            for (const terminal of terminals) {
                pointingItemSet = go(currItemSet, terminal);
                /* shift */
                if (pointingItemSet)
                    actionTable[currItemSet.id][terminal] =
                        `s${pointingItemSet.id}`;
            }

            for (const nonTerminal of originNonTerminals) {
                pointingItemSet = go(currItemSet, nonTerminal);
                /* goto */
                if (pointingItemSet)
                    gotoTable[currItemSet.id][nonTerminal] =
                        pointingItemSet.id;
            }
            for (item of currItemSet.items) {
                if (item[item.length - 1] === '`') {
                    const reductionRule = rules.findIndex(rule =>
                        rule === item.substring(0, item.length - 1));
                    /* reduce */
                    if (reductionRule !== 0) {
                        for (const terminal of terminals) {
                            if (actionTable[currItemSet.id][terminal])
                                hasConflicts = true;
                            else actionTable[currItemSet.id][terminal] =
                                `r${reductionRule}`;
                        }
                    }
                    /* accept */
                    else actionTable[currItemSet.id]['#'] = 'accept';
                }
            }
        }

        return [actionTable, gotoTable, itemSets, hasConflicts];


        function go(itemSet, token) {
            let tempSet = new Set();
            for (const item of itemSet.items) {
                if (getTokenAfterDot(item) === token)
                    tempSet.add(moveDotToNext(item));
            }

            if (!tempSet.size) return null;
            tempSet = closure(tempSet);
            const existedSetId = findSameSet(tempSet);
            if (existedSetId === -1) {
                const newItemSet = {
                    id: String(itemSets.length),
                    items: tempSet,
                };
                itemSets.push(newItemSet);
                itemSetQueue.push(newItemSet);

                return newItemSet;
            }
            else return itemSets.find(itemSet => itemSet.id === existedSetId);
        }

        /**
         * @param {String | Set<String>} item
         * @returns {Set<String>}
         */
        function closure(item) {
            let _item = item;
            if (typeof(item) === 'string') {
                _item = new Set([item]);
            }
            let size = 0;
            let newSize = 0;
            do {
                size = _item.size;
                const __item = new Set(_item);
                for (const item of _item) {
                    const tokenAfterDot = getTokenAfterDot(item);
                    if (nonTerminals.has(tokenAfterDot)) {
                        for (const rule of rules) {
                            if (rule[0] === tokenAfterDot)
                                __item.add(addDotToRule(rule))
                        }
                    }
                }
                _item = __item;
                newSize = _item.size;
            } while (size !== newSize)

            return _item;
        }

        /**
         * @param {Set<String>} items
         * @returns {number} itemSet id
         */
        function findSameSet(items) {
            for (const itemSet of itemSets) {
                const _difference = new Set(itemSet.items);
                for (const elem of items) {
                    if (_difference.has(elem)) {
                        _difference.delete(elem)
                    } else {
                        _difference.add(elem)
                    }
                }
                if (_difference.size === 0) return itemSet.id;
            }
            return -1;
        }
    }
}
