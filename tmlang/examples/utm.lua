-- Universal Turing Machine

w = tape{'<', 'Q', 'S', '>', 'D', 'E', '1', '$'}
m = tape{'<', 'Q', 'S', '>', 'D', 'E', '1'}
f = tape{'S', '1'}
r = tape{'S', '1'}

-- Move machine code from w to m
function s1()
    if w == '$' then
        w = 'Q' -- initial state
        left(m)
        goto s2
    else
        m = w
        w = nil
        right(w)
        right(m)
    end
end

-- Go to the beggining of m
function s2()
    if m == nil then
        right(m)
        goto halt
    else
        left(m)
    end
end

function halt() end
