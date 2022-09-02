LEFT = -1
STOP = 0
RIGHT = 1


def to_dict(container):
    return {i: v for i, v in enumerate(container)}


def from_dict(dictionary):
    sorted_keys = sorted(dictionary.keys())
    first_key = sorted_keys[0]
    last_key = sorted_keys[-1]
    return [dictionary.get(key) for key in range(first_key, last_key+1)]


def run(step, initial_state, final_state, *tapes):
    state = initial_state
    tapes = [to_dict(tape) for tape in tapes]
    tape_heads = [0 for tape in tapes]
    while state != final_state:
        read_chars = [tape.get(tape_head)
                      for tape, tape_head in zip(tapes, tape_heads)]
        state, *tape_actions = step(state, *read_chars)
        for tape_index, (written_char, movement) in enumerate(tape_actions):
            tape = tapes[tape_index]
            tape_head = tape_heads[tape_index]
            if written_char is None:
                if tape_head in tape:
                    del tape[tape_head]
            else:
                tape[tape_head] = written_char
            assert movement in (LEFT, STOP, RIGHT)
            tape_heads[tape_index] += movement
    return tuple(from_dict(tape) for tape in tapes)
