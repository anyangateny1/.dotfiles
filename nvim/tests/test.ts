// Open this file and check:
// ts_ls: implicit any on `user`, type error on `x`

function greet(user) {  // ts_ls: parameter implicitly has an 'any' type
    console.log("Hello " + user.name)
}

const x: number = "not a number"  // ts_ls: type error

greet({ name: "Alice" })
