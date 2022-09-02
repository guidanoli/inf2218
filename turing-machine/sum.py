import tm


def step(state, ch):
    if state == 0:
        if ch is None:
            return 1, (ch, tm.LEFT)
        else:
            return state, (ch, tm.RIGHT)
    elif state == 1:
        if ch == '1':
            return state, ('0', tm.LEFT)
        else:
            return 2, ('1', tm.STOP)


if __name__ == '__main__':
    print(tm.run(step, 0, 2, input('Binary number: ')))
