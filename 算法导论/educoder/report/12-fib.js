function fib1(n) {
    return n < 2 ? n : fib1(n - 1) + fib1(n - 2)
}


function fib2(n, h = Array(n)) {
    return n < 2 ? n : h[n] ? h[n] : h[n] = fib2(n - 1, h) + fib2(n - 2, h)
}


function fib3(n) {
    let dp = [0, 1], i = 1
    while (i++ < n)
        dp[i] = dp[i - 1] + dp[i - 2]
    return n > 0 ? dp[n] : 0
}


function fib4(n) {
    let a = 0, b = 1, i = 0
    while (i++ < n)
        b = a + (a = b)
    return n > 0 ? a : 0
}


function fib5(n) {
    function matrixPow(a, n) {
        ret = [[1, 0], [0, 1]]
        while (n-- > 0)
            ret = matrixMultiply(ret, a)
        return ret
    }

    if (n <= 1)
        return n
    m = [[1, 1], [1, 0]]
    res = matrixPow(m, n - 1)
    return res[0][0]
}


function fib6(n) {
    function matrixPowFast(a, n) {
        ret = [[1, 0], [0, 1]]
        while (n > 0) {
            if (n & 1) 
                ret = matrixMultiply(ret, a)
            n >>= 1
            a = matrixMultiply(a, a)
        }
        return ret
    }

    if (n <= 1)
        return n
    m = [[1, 1], [1, 0]]
    res = matrixPowFast(m, n - 1)
    return res[0][0]
}


function fib7(n) {
    sqrt5 = Math.sqrt(5)
    fibN = Math.pow((1 + sqrt5) / 2, n) - Math.pow((1 - sqrt5) / 2, n)
    return Math.round(fibN / sqrt5)
}


function fib8(n) {
    function quickMul(a, n) {
        ret = 1
        while (n > 0) {
            if (n & 1) 
                ret *= a
            n >>= 1
            a *= a
        }
        return ret
    }

    sqrt5 = Math.sqrt(5)
    fibN = quickMul((1 + sqrt5) / 2, n) - quickMul((1 - sqrt5) / 2, n)
    return Math.round(fibN / sqrt5)
}


function fib9(n) {
    function triangle(numRows) {
        return Array(numRows).fill().map((_, i, r) => r[i] = Array(i + 1).fill(1).map((v, j) => j > 0 && j < i ? r[i - 1][j - 1] + r[i - 1][j] : v))
    }

    let T = triangle(n)
    let res = 0, i = n, j = -1
    while (i-- && ++j < T[i].length)
        res += T[i][j]
    return res
}


function fib10(n) {
    function triangle(numRows) {
        const arr = Array(numRows)
        for(let i = 0; i < numRows; ++i) {
            arr[i] = Array(i + 1).fill(1)
            for (let j = 1; j <= i >> 1; ++j) 
                arr[i][j] = arr[i][i - j] = arr[i - 1][j - 1] + arr[i - 1][j]
        }
        return arr
    }

    let T = triangle(n)
    let res = 0, i = n, j = -1
    while (i-- && ++j < T[i].length)
        res += T[i][j]
    return res
}


function fib11(n) {
    return n < 2 ? n : Math.round(0.4472135955 * Math.pow(1.618033988745, n))
}


function matrixMultiply(a, b) {
    c = [[], []]
    for (let i = 0; i < 2; ++i)
        for (let j = 0; j < 2; ++j)
            c[i][j] = a[i][0] * b[0][j] + a[i][1] * b[1][j]
    return c
}


function test() {
    arr = [fib1, fib2, fib3, fib4, fib5, fib6, fib7, fib8, fib9, fib10, fib11]
    arr.forEach(fib => {
        for (let i = 1; i <= 15; ++i)
            process.stdout.write(fib(i) + ' ')
        process.stdout.write('\n')
    });
}

function compare() {
    arr = [fib1, fib2, fib3, fib4, fib5, fib6, fib7, fib8, fib9, fib10, fib11]
    arr.forEach((fib, index) => {
        console.time(`fib${index + 1}`)
        for (let k = 0; k < 20; ++k)
            for (let i = 1; i <= 40; ++i)
                fib(i)
        console.timeEnd(`fib${index + 1}`)
    });
}

function requestedOut() {
    [5, 10, 20, 50].forEach(n => {
        console.log(`fib(${n}) = ${fib3(n)}`)
    });
}

function main() {
    test() 
    compare()
    requestedOut()
}

main()
