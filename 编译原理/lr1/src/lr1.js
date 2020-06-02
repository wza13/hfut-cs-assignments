
/**
 * @param {Array<String>} rules
 * @param {String} inputString
 * @author yzj
 */
function startLR1(rules, inputString) {
    if (inputString[inputString.length - 1] !== '#')
        inputString = inputString + '#';
    if (!checkRules(rules)) {

        return ['format', [], []];
    }

    const originStart = rules[0][0];
    rules.unshift(`${originStart}'->${originStart}`);

    const [nonTerminals, terminals] = initToken(rules);
    const nullables = getNullables(rules);
    const leftString = inputString.split('');
    const statusStack = ['0'];
    const tokenStack = ['#'];
    const steps = [];

    // // test
    // console.log(nonTerminals);
    // console.log(terminals);
    // console.log(nullables);
    // return [undefined, steps, []];

    const first = getFirst(rules, nonTerminals, terminals, nullables);
    const follow = getFollow(rules, nonTerminals, terminals, nullables, first);

    // // test
    // console.dir(first);
    // console.dir(follow);
    // return [undefined, steps, []];

    const [actionTable, gotoTable, itemSets, hasConflicts] = getTable();
    if (hasConflicts)
        return ['notLR1', steps, []];

    // // test
    // console.log('项目集族')
    // console.dir(itemSets);
    // console.log('action表')
    // console.dir(actionTable);
    // console.log('goto表')
    // console.dir(gotoTable);
    // console.log('是否有冲突', hasConflicts);
    // return [undefined, steps, []];

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
            return ['fail', steps, [nonTerminals, terminals, actionTable, gotoTable, itemSets.size]];
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
                return ['fail', steps, [nonTerminals, terminals, actionTable, gotoTable, itemSets.length]];
            }
            statusStack.push(pushingStatus);
            steps[steps.length - 1].action = `规约，状态${pushingStatus}入栈`;
        }
        else /* if (actionTable[status][token].toLowerCase() === 'accept') */ {
            steps[steps.length - 1].action = '分析成功';
            return [undefined, steps, [nonTerminals, terminals, actionTable, gotoTable, itemSets.length]];
        }
    }


    function getTable() {
        /* Use this char ` to represent the DOT MARK. */
        /* itemSet format:
            {
                id: '0',
                items (Set): {
                    {
                        string: 'A->B`C',
                        followed: Set{'#'}
                    },
                    {
                        string: 'C->`a',
                        followed: Set{'#', 'b'}
                    },
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
            items: closure(new Set([{
                string: addDotToRule(rules[0]),
                followed: new Set(['#']),
            }])),
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
                if (item.string[item.string.length - 1] === '`') {
                    const reductionRule = rules.findIndex(rule =>
                        rule === item.string.substring(0, item.string.length - 1));
                    /* reduce */
                    if (reductionRule !== 0) {
                        for (const followed of item.followed) {
                            if (actionTable[currItemSet.id][followed])
                                hasConflicts = true;
                            else actionTable[currItemSet.id][followed] =
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
                if (getTokenAfterDot(item.string) === token)
                    tempSet.add({
                        string: moveDotToNext(item.string),
                        followed: item.followed,
                    });
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
         * @param {Set} items Set of the defined format items.
         * @returns {Set}
         */
        function closure(items) {
            let size = 0;
            let newSize = 0;
            do {
                size = items.size;
                const _items = new Set(items);
                for (const item of items) {
                    const tokenAfterDot = getTokenAfterDot(item.string);
                    const tokenAfterAfterDot = getTokenAfterAfterDot(item.string);
                    if (nonTerminals.has(tokenAfterDot)) {
                        for (const rule of rules) {
                            if (rule[0] === tokenAfterDot)
                                addNewItem(
                                    addDotToRule(rule),
                                    getFollowed(tokenAfterAfterDot, item.followed),
                                    _items
                                );
                        }
                    }
                }
                items = _items;
                newSize = items.size;
            } while (size !== newSize)

            return items;
        }

        function getFollowed(tokenAfterAfterDot, originFollowed) {
            if (tokenAfterAfterDot === '') return new Set(originFollowed);
            if (terminals.has(tokenAfterAfterDot))
                return new Set([tokenAfterAfterDot]);
            const temp = new Set(first[tokenAfterAfterDot]);
            if (nullables.has(tokenAfterAfterDot)) appendSet(temp, originFollowed);
            return temp;
        }

        /**
         * @param {String} string
         * @param {Set} followed
         * @param {Set} items
         */
        function addNewItem(string, followed, items) {
            for (const item of items) {
                if (item.string === string) {
                    appendSet(item.followed, followed);
                    return;
                }
            }
            items.add({ string, followed });
        }


        /**
         * @param {Set} items
         * @returns {number} itemSet id
         */
        function findSameSet(items) {
            const _items = mergeStringAndFollowed(items);
            for (const itemSet of itemSets) {
                const _difference = mergeStringAndFollowed(itemSet.items);
                for (const elem of _items) {
                    if (_difference.has(elem)) {
                        _difference.delete(elem)
                    } else {
                        _difference.add(elem)
                    }
                }
                if (_difference.size === 0) return itemSet.id;
            }
            return -1;

            function mergeStringAndFollowed(items) {
                const temp = new Set();
                items.forEach(item => temp.add(
                    `${item.string}${Array.from(item.followed).sort().join('')}`
                ));
                return temp;
            }
        }
    }
}

// const rules =
// `S->BB
// B->aB
// B->b`;

// const input = 'aabb';

// startLR1(rules.split('\n'), input);
