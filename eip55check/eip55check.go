package main

import (
	"fmt"
	"os"
	"github.com/ethereum/go-ethereum/common"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: eip55check <address>")
		os.Exit(2)
	}

	input := os.Args[1]
	if !common.IsHexAddress(input) {
		fmt.Fprintf(os.Stderr, "❌ Invalid Ethereum address format: %s\n", input)
		os.Exit(1)
	}

	// Compute correct checksummed address
	correct := common.HexToAddress(input).Hex()
	if input != correct {
		fmt.Fprintf(os.Stderr, "❌ Not EIP-55 checksummed: %s (expected: %s)\n", input, correct)
		os.Exit(1)
	}

	fmt.Println("✅ Valid EIP-55 checksummed address")
}
