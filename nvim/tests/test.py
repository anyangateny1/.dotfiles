# Open this file and check:
# pyright: return type mismatch, wrong arg type on greet()
# ruff (nvim-lint): unused import (F401), bare except (E722)

import os  # unused

def divide(a: int, b: int) -> int:
    try:
        return a / b  # pyright: float not assignable to int
    except:           # ruff E722: bare except
        return 0

def greet(name: str) -> None:
    print("Hello " + name)

greet(123)  # pyright: int not assignable to str
