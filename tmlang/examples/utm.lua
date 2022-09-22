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
        goto pre1
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
function pre1()
    if m == nil then
        right(m)
        goto pre2
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
function pre2()
    if w == nil then
        right(w)
        goto pre3
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
function pre3()
    if w == 'Q' then
        left(w)
        goto pre4
    else
        goto pre5
    end
end

-- Write left symbol
function pre4()
    w = 'S'
    goto pre5
end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: #(S1*)+Q1*(S1*)*
-- f: #
-- r: #
-- e: #
---------------------------------------

-- Find cursor
function pre5()
    if w == 'Q' then
        goto pre6
    else
        right(w)
    end
end

-- Check right symbol
function pre6()
    if w == 'S' then
        left(w)
        goto pre7
    elseif w == nil then
        w = 'S'
        left(w)
        goto pre7
    else
        right(w)
    end
end

-- Find cursor
function pre7()
    if w == 'Q' then
        left(w)
        goto pre8
    else
        left(w)
    end
end

-- Copy left symbol to e
function pre8()
    if w == 'S' then
        e = w
        goto pre9
    elseif w ~= 'Q' then
        e = w
        left(w)
        left(e)
    end
end

-- Find cursor
function pre9()
    if w == 'Q' then
        goto pre10
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
function pre10()
    if w == 'S' then
        f = w
        right(w)
        right(f)
        goto pre11
    else
        f = w
        right(w)
        right(f)
    end
end

-- Copy symbol to f
function pre11()
    if w == 'S' then
        left(w)
        left(f)
        goto pre12
    else
        f = w
        right(w)
        right(f)
    end
end

-- Go to start of w
function pre12()
    if w == nil then
        right(w)
        goto pre13
    else
        left(w)
    end
end

-- Go to start of f
function pre13()
    if f == nil then
        f = '<'
        goto halt
    else
        left(f)
    end
end

---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: #(S1*)+Q1*(S1*)+
-- f: #<Q1*S1*
-- r: #
-- e: #S1*
---------------------------------------


---------------------------------------
-- m: #(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+#Q1*(S1*)+
-- f: #
-- r: #
-- e: #
---------------------------------------

function halt() end
