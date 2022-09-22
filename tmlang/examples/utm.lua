-- Universal Turing Machine

m = tape{'Q', 'S', '1', 'E', 'D', '<', '>', '$'}
w = tape{'Q', 'S', '1'}
f = tape{'<', 'Q', 'S', '1'}
r = tape{'Q', 'S', '1'}
e = tape{'S', '1'}

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*$(S1*)*
-- w: #
-- f: #
-- r: #
-- e: #
---------------------------------------

-- Go to the end of m
function init1()
    if m == nil then
        left(m)
        goto init2
    else
        right(m)
    end
end

-- Move m to w until '$'
function init2()
    if m == '$' then
        m = nil
        w = 'Q'
        left(m)
        goto q1
    elseif m == 'S' or m == '1' then
        w = m
        m = nil
        left(m)
        left(w)
    end
end

---------------------------------------
-- m: m1#m2
-- w: w1#w2
-- f: #
-- r: #
-- e: #
--
-- where
-- m1 . m2 = (<Q1*S1*Q1*S1*[ED]>)*
-- w1 . w2 = (S1*)*Q1*(S1*)*
---------------------------------------

-- Go to the start of m
function q1()
    if m == nil then
        right(m)
        goto q2
    else
        left(m)
    end
end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: w1#w2
-- f: #
-- r: #
-- e: #
--
-- where
-- w1 . w2 = (S1*)*Q1*(S1*)*
---------------------------------------

-- Go to the start of w
function q2()
    if w == nil then
        right(w)
        goto q3
    else
        left(w)
    end

end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: #(S1*)*Q1*(S1*)*
-- f: #
-- r: #
-- e: #
---------------------------------------

-- Check left symbol
function q3()
    if w == 'Q' then
        left(w)
        goto q4
    else
        goto q5
    end
end

-- Write left symbol
function q4()
    w = 'S'
    goto q5
end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: #(S1*)+Q1*(S1*)*
-- f: #
-- r: #
-- e: #
---------------------------------------

-- Find cursor
function q5()
    if w == 'Q' then
        goto q6
    else
        right(w)
    end
end

-- Check right symbol
function q6()
    if w == 'S' then
        left(w)
        goto q7
    elseif w == nil then
        w = 'S'
        left(w)
        goto q7
    else
        right(w)
    end
end

-- Find cursor
function q7()
    if w == 'Q' then
        left(w)
        goto q8
    else
        left(w)
    end
end

-- Copy left symbol to e
function q8()
    if w == 'S' then
        e = w
        goto q9
    elseif w ~= 'Q' then
        e = w
        left(w)
        left(e)
    end
end

-- Find cursor
function q9()
    if w == 'Q' then
        goto q10
    else
        right(w)
    end
end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+#Q1*(S1*)+
-- f: #
-- r: #
-- e: #S1*
---------------------------------------

-- Copy state to f
function q10()
    if w == 'S' then
        f = w
        right(w)
        right(f)
        goto q11
    else
        f = w
        right(w)
        right(f)
    end
end

-- Copy symbol to f
function q11()
    if w == 'S' then
        left(w)
        left(f)
        goto q12
    else
        f = w
        right(w)
        right(f)
    end
end

-- Go to start of w
function q12()
    if w == nil then
        right(w)
        goto q13
    else
        left(w)
    end
end

-- Go to start of f
function q13()
    if f == nil then
        right(f)
        goto q14
    else
        left(f)
    end
end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: #(S1*)+Q1*(S1*)+
-- f: #Q1*S1*
-- r: #
-- e: #S1*
---------------------------------------

-- Find next transition
function q14()
    if m == '<' then
        right(m)
        goto q15
    else
        right(m)
    end
end

-- Match Q
function q15()
    if m == 'Q' and f == 'Q' then
        right(m)
        right(f)
        goto q16
    else
        goto q14
    end
end

-- Match Q number and S
function q16()
    if m == '1' and f == '1' then
        right(m)
        right(f)
    elseif m == 'S' and f == 'S' then
        right(m)
        right(f)
        goto q17
    else
        goto q14
    end
end

-- Match S number and end
function q17()
    if m == '1' and f == '1' then
        right(m)
        right(f)
    elseif m == 'Q' and f == nil then
        goto q18
    else
        goto q14
    end
end

-- Go to end of transition
function q18()
    if m == '>' then
        left(m)
        goto q19
    else
        right(m)
    end
end

-- Check movement
function q19()
    if m == 'E' then
    elseif m == 'D' then
    end
end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+#Q1*(S1*)+
-- f: #
-- r: #
-- e: #
---------------------------------------

function halt() end
