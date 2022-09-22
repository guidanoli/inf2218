-- Universal Turing Machine

w = tape{'Q', 'S', '1', 'E', 'D', '<', '>', '$'}
m = tape{'Q', 'S', '1', 'E', 'D', '<', '>', '$'}
f = tape{'Q', 'S', '1'}
r = tape{'Q', 'S', '1'}

-- w: (<Q1*S1*Q1*S1*[ED]>)*$(S1*)*
-- m:
-- f:
-- r:

-- Copy machine code from m to w
function init1()
    if w == '$' then
        w = 'Q'
        left(m)
        goto pre1
    else
        m = w
        w = nil
        right(w)
        right(m)
    end
end

-- w: (S1*)*Q1*(S1*)*  <-- pointer somewhere in the middle
-- m: (<Q1*S1*Q1*S1*[ED]>)* <-- pointer somewhere in the middle
-- f: .* <-- pointer in the last character
-- r: .* <-- pointer in the last character

-- Move cursor to beggining of w
function pre1()
    if w == nil then
        right(w)
        goto pre2
    else
        left(w)
    end
end

-- Move cursor to beggining of m
function pre2()
    if m == nil then
        right(m)
        goto pre3
    else
        left(m)
    end
end

-- Clean f and r
function pre3()
    if f == nil then
        if r == nil then
            goto pre4
        else
            r = nil
            left(w)
        end
    else
        f = nil
        left(f)
    end
end

-- Find leftmost 'Q' in w then go left
function pre4()
    if w == 'Q' then
        left(w)
        goto pre5
    else
        right(w)
    end
end

-- Write 'S' before 'Q' in w if nil
function pre5()
    if w == nil then
        w = 'S'
    end
    right(w)
    goto pre6
end

-- Find leftmost S or nil in w
function pre6()
    if w == nil then
        w = 'S'
        left(w)
        goto pre7
    elseif w == 'S' then
        left(w)
        goto pre7
    else
        right(w)
    end
end

-- Find rightmost Q in w
function pre7()
    if w == 'Q' then
        goto halt
    else
        left(w)
    end
end

-- w: (S1*)+Q1*(S1*)+
-- m: (<Q1*S1*Q1*S1*[ED]>)*
-- f:
-- r:

function halt() end
