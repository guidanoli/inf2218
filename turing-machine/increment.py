from tm import LEFT, RIGHT, STOP, run


def step(state, ch):
    if state == 0:
        if ch is None:
            return 1, (ch, LEFT)
        else:
            return state, (ch, RIGHT)
    elif state == 1:
        if ch == '1':
            return state, ('0', LEFT)
        else:
            return 2, ('1', STOP)


if __name__ == '__main__':
    print(run(step, 0, 2, input('Binary number: ')))
