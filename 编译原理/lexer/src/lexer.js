/**
 * A very limited Lexer.
 * @param {Set<String>} keywords
 * @param {String} input
 * @author yzj
 */
function lexer(keywords, input) {
    const results = [];

    const types = ['ERROR', 'KEYWORD', 'SEPARATOR',
        'ARITHMETIC_OP', 'RELATIONAL_OP', 'NUMBER', 'ID'];
    const separators = new Set([',', ';', '(', ')', '[', ']']);
    const arithmetic_ops = new Set(['+', '-', '*', '/']);
    const relational_ops = new Set(['<', '<=', '=', '>', '>=', '<>']);
    const ids = new Set();

    const inString = input + '\0';
    let bufferPointer = 0;
    let row = 1;
    let line = 1;
    let ch = '';
    let outToken = '';

    while (true) {
        getChar();
        handleSpace();
        if (isLetter()) analyzeWord();
        else if (isDigit()) analyzeNumber();
        else if (separators.has(ch) ||
                arithmetic_ops.has(ch) ||
                relational_ops.has(ch))
            analyzePunctuation();
        else if (ch === '\0') return results;
        else {
            outToken += ch;
            log('ERROR');
        }
    }


    function getChar() {
        if (ch !== '\0') {
            ch = inString[bufferPointer ++];
            ++ line;
        }
    }

    function handleSpace() {
        while (ch === ' ' || ch === '\t' || ch === '\n' || ch === '\r') {
            if (ch === '\n') {
                ++ row;
                line = 1;
            }
            if (ch === '\r') {
                line = 1;
            }
            getChar();
        }
    }


    function analyzeWord() {
        while (isLetter() || isDigit()) {
            outToken += ch;
            getChar();
        }
        backtrack();
        if (keywords.has(outToken)) log('KEYWORD');
        else log('ID');
    }

    function analyzeNumber() {
        while (isDigit()) {
            outToken += ch;
            getChar();
        }
        if (!isLetter()) {
            backtrack();
            log('NUMBER');

            return;
        }
        while (isLetter() || isDigit()) {
            outToken += ch;
            getChar();
        }
        backtrack();
        log('ERROR');
    }

    function analyzePunctuation() {
        /* punctuation has this feature that the length is 1 or 2
        and the first letter of all the 2-length ones
        is also one of the punctuation */
        outToken += ch;
        tempPunctuation = outToken;
        getChar();
        outToken += ch;
        if (!separators.has(outToken) &&
            !arithmetic_ops.has(outToken) &&
            !relational_ops.has(outToken)
        ) {
            backtrack();
            outToken = tempPunctuation;
        }
        if (separators.has(outToken)) log('SEPARATOR');
        if (arithmetic_ops.has(outToken)) log('ARITHMETIC_OP');
        if (relational_ops.has(outToken)) log('RELATIONAL_OP');
    }

    function backtrack() {
        if (ch !== '\0') {
            -- bufferPointer;
        }
        /* Put this expression out of the above if scope
        to keep the last outToken's position correct. */
        -- line;
    }

    function isLetter() { return /[a-zA-Z]/.test(ch); }

    function isDigit() { return /[0-9]/.test(ch); }

    function log(type) {
        results.push({
            token: outToken,
            sequence: type === 'ERROR' ? 'ERROR' :
                `(` +
                `${Array.from(types).findIndex(item => item === type)}, ` +
                `${outToken}` +
                `)`,
            type,
            position: `(${row}, ${line - outToken.length})`
        });
        outToken = '';
    }
}
