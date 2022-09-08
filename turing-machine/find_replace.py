from tm import LEFT, RIGHT, STOP, run
from enum import Enum, auto


class State(Enum):
    pass


def step(state, w, f, r):
    pass


if __name__ == '__main__':
    w = input('Word: ')
    f = input('Find: ')
    r = input('Replace: ')
    print(run(step, State.MATCHING, State.FINAL, w, f, r))
