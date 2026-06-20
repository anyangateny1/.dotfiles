// Open this file and check:
// gopls: unused import, error return ignored (staticcheck SA1006)

package main

import (
	"fmt"
	"os" // unused — gopls will warn
)

func divide(a, b int) (int, error) {
	if b == 0 {
		return 0, fmt.Errorf("divide by zero")
	}
	return a / b, nil
}

func main() {
	result, _ := divide(10, 0) // staticcheck: error ignored
	fmt.Println(result)
}
