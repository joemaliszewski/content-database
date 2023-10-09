"""
Some descriptive information about the library here.
"""

from typing import List


def func(a: int, b: str) -> List[str]:
    """Function summary (single line).

    Extended Summary, perhaps with examples. We always prefer types for
    function parameters.

        Typical usage example:

        a = 1
        b = 'foo'
        c = function(a, b)

    Args:
        a: Does bar.
        b: Does bar on foo.

    Returns:
        List[String]

    Raises:
        IOError if 'a' is not equal to 1.
    """
    if a==1:
        return [b]
    else:
        raise IOError("'a' must be equal to '1'")


class Class:
    """An example class, one line summary.

    Longer more detailed information...

    Attributes:
    ---
    ham: A bool indicating whether or not we like ham.
    eggs: An integer amount of eggs.
    """

    def __init__(self, ham: bool = False):
        """Single line explaining functionality of init."""
        self.ham = ham
        self.eggs = 0

    def method(self):
        """Public class method, single line summary."""
