// Open this file and check:
// clangd: unused variable, implicit conversion warning
// clang-tidy: modernize-use-nullptr, readability-braces-around-statements

#include <iostream>
#include <string>

void greet(const std::string& name) { // clang-tidy: pass by const ref
    std::string shadow = "shadow";
    std::cout << "Hello " << name << '\n';
    int unused = 0; // clang-tidy: unused variable
}

auto main() -> int {
    int* p = nullptr;   // clang-tidy: modernize-use-nullptr
    if (p == nullptr) { // clang-tidy: braces-around-statements
        std::cout << "null" << std::endl;
    }
    greet("world");
    return 0;
}
