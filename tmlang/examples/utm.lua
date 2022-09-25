--------------------------------------------------------------------------------
-- Universal Turing Machine
--
-- In the tape diagram, {} represents where the cursor can be
-- The space character represents the blank character in the TM.
-- Possible regexes are juxtaposed if they get too weird.
--------------------------------------------------------------------------------

m = tape{'Q', 'S', '1', 'E', 'D', '<', '>', '$'}
w = tape{'Q', 'S', '1'}
f = tape{'Q', 'S', '1'}
r = tape{'Q', 'S', '1'}

--------------------------------------------------------------------------------
-- m: {(<Q1*S1*Q1*S1*[ED]>)+$(S1*)* }
-- w: { }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Go to the end of m
function init1()
    if m == nil then
        left(m)
        goto init2
    else
        right(m)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)+$(S1*)*{S}
--    (<Q1*S1*Q1*S1*[ED]>)+$(S1*)*{1}
--    (<Q1*S1*Q1*S1*[ED]>)+{$}
-- w: { }1*(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- m: { (<Q1*S1*Q1*S1*[ED]>)+}
-- w: {S}1*(S1*)*Q1*(S1*)*
--    {Q}1*(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Go to the start of m
function q1()
    if m == nil then
        right(m)
        goto q3
    else
        left(m)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)*
--    {Q}1*(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Check left symbol
function q3()
    if w == 'Q' then
        left(w)
        goto q4
    elseif w == 'S' then
        goto q5a
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: { }Q1*(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Write left symbol
function q4()
    w = 'S'
    goto q5a
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {(S1*)+Q}1*(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Find cursor
function q5a()
    if w == 'Q' then
        right(w)
        goto q5b
    else
        right(w)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+Q{1}1*(S1*)*
--    (S1*)+Q{S}1*(S1*)*
--    (S1*)+Q{ }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Check if final state was reached (1/2)
function q5b()
    if w == '1' then
        right(w)
        goto q5c
    elseif w == 'S' or w == nil then
        goto q6
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+Q1{1}1*(S1*)*
--    (S1*)+Q1{S}1*(S1*)*
--    (S1*)+Q1{ }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Check if final state was reached (2/2)
function q5c()
    if w == nil or w == 'S' then
        left(w)
        goto f1
    elseif w == '1' then
        right(w)
        goto q6
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+Q1*{1}1*(S1*)*
--    (S1*)+Q1*{S}1*(S1*)*
--    (S1*)+Q1*{ }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Check right symbol
function q6()
    if w == 'S' then
        left(w)
        goto q7
    elseif w == nil then
        w = 'S'
        left(w)
        goto q7
    elseif w == '1' then
        right(w)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+{Q}1*(S1*)+
--    (S1*)+Q1*{1}1*(S1*)+
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Find cursor
function q7()
    if w == 'Q' then
        left(w)
        goto q8
    elseif w == '1' then
        left(w)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)*{S}1*Q1*(S1*)+
--    (S1*)+{1}1*Q1*(S1*)+
-- f: { }1*
-- r: { }1*
--------------------------------------------------------------------------------

-- Copy left symbol to r and f
function q8()
    if w == 'S' then
        f = w
        r = w
        goto q9
    elseif w == '1' then
        f = w
        r = w
        left(w)
        left(f)
        left(r)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)*{S}1*Q1*(S1*)+
--    (S1*)+{1}1*Q1*(S1*)+
--    (S1*)+{Q}1*(S1*)+
-- f: {S}1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Find cursor
function q9()
    if w == 'Q' then
        goto q9a
    else
        right(w)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+{Q}1*(S1*)+
-- f: {S}1*
--    S1*{1}1*
--    S1*{ }
-- r: {S}1*
--------------------------------------------------------------------------------

-- Go to the end of f
function q9a()
    if f == nil then
        goto q10
    else
        right(f)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+{Q}1*(S1*)+
--    (S1*)+Q1*{1}1*(S1*)+
--    (S1*)+Q1*{S}1*(S1*)*
-- f: S1*{ }
--    S1*Q1*{ }
-- r: {S}1*
--------------------------------------------------------------------------------

-- Copy state to f
function q10()
    if w == 'S' then
        f = w
        right(w)
        right(f)
        goto q11
    elseif w == 'Q' or w == '1' then
        f = w
        right(w)
        right(f)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: (S1*)+Q1*S1*{ }
--    (S1*)+Q1*S1*{S}1*(S1*)*
--    (S1*)+Q1*S1*{1}1*(S1*)*
-- f: S1*Q1*S1*{ }
-- r: {S}1*
--------------------------------------------------------------------------------

-- Copy symbol to f
function q11()
    if w == 'S' or w == nil then
        left(w)
        left(f)
        goto q12
    elseif w == '1' then
        f = w
        right(w)
        right(f)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: { (S1*)+Q1*S1*}(S1*)*
-- f: S1*Q1*S1*{1}
--    S1*Q1*{S}
-- r: {S}1*
--------------------------------------------------------------------------------

-- Go to start of w
function q12()
    if w == nil then
        right(w)
        goto q13
    else
        left(w)
    end
end

--------------------------------------------------------------------------------
-- m: {(<Q1*S1*Q1*S1*[ED]>)*}
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: { S1*Q1*S1*}
-- r: {S}1*
--------------------------------------------------------------------------------

-- Go to start of f
function q13()
    if f == nil then
        right(f)
        goto q13a
    else
        left(f)
    end
end

--------------------------------------------------------------------------------
-- m: {(<Q1*S1*Q1*S1*[ED]>)*}
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S1*Q}1*S1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Find Q in f
function q13a()
    if f == 'Q' then
        goto q14
    else
        right(f)
    end
end

--------------------------------------------------------------------------------
-- m: {(<Q1*S1*Q1*S1*[ED]>)*}
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: S1*{Q}1*S1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Find next transition
function q14()
    if m == '<' then
        right(m)
        goto q15
    else
        right(m)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<{Q}1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: S1*{Q}1*S1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Match Q
function q15()
    if m == 'Q' and f == 'Q' then
        right(m)
        right(f)
        goto q16
    else
        goto q13
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q{1*S}1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: S1*Q{1*S}1*
-- r: {S}1*
--------------------------------------------------------------------------------

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
        goto q13
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S{1*Q}1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: S1*Q1*S{1* }
-- r: {S}1*
--------------------------------------------------------------------------------

-- Match S number and end
function q17()
    if m == '1' and f == '1' then
        right(m)
        right(f)
    elseif m == 'Q' and f == nil then
        left(f)
        goto q17a
    else
        left(f)
        goto q13
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*{Q}1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: { S1*Q1*S1*}
-- r: {S}1*
--------------------------------------------------------------------------------

-- Go to the start of f
function q17a()
    if f == nil then
        right(f)
        goto q18
    else
        left(f)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*{Q1*S1*[ED]}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Find movement
function q18()
    if m == 'D' then
        goto q19
    elseif m == 'E' then
        goto q21a
    else
        right(m)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q1*S1*{D}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: {S1* }
--------------------------------------------------------------------------------

-- Go to the end of r
function q19()
    if r == nil then
        goto q20a
    else
        right(r)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q1*{S1*D}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: S1*{ }
--------------------------------------------------------------------------------

-- Go to the beggining of S in m
function q20a()
    if m == 'S' then
        r = m
        right(r)
        right(m)
        goto q20b
    elseif m == 'D' or m == '1' then
        left(m)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q1*S{1*D}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: S1*S1*{ }
--------------------------------------------------------------------------------

-- Copy 1s from m to r until D
function q20b()
    if m == '1' then
        r = m
        right(r)
        right(m)
    elseif m == 'D' then
        goto q20c
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*{Q1*S1*D}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: S1*S1*{ }
--------------------------------------------------------------------------------

-- Go to the beggining of Q in m
function q20c()
    if m == 'Q' then
        r = m
        right(r)
        right(m)
        goto q20d
    elseif m == '1' or m == 'S' or m == 'D' then
        left(m)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q{1*S}1*D>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: S1*S1*Q1*{ }
--------------------------------------------------------------------------------

-- Copy 1s from m to r until S
function q20d()
    if m == '1' then
        r = m
        right(r)
        right(m)
    elseif m == 'S' then
        left(r)
        goto q22
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q1*{S1*E}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Find previous S in m
function q21a()
    if m == 'S' then
        left(m)
        left(r)
        goto q21b
    elseif m == 'E' or m == '1' then
        left(m)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*{Q1*}S1*E>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: { }1*S1*
--------------------------------------------------------------------------------

-- Copy m to r until 'Q'
function q21b()
    if m == 'Q' then
        r = m
        right(m)
        right(r)
        goto q21c
    elseif m == '1' then
        r = m
        left(m)
        left(r)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q{1}1*S1*E>(<Q1*S1*Q1*S1*[ED]>)*
--    (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q{S}1*E>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: Q{1*S1* }
--------------------------------------------------------------------------------

-- Go to the end of r
function q21c()
    if r == nil then
        goto q21d
    elseif r == '1' or r == 'S' then
        right(r)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q{1*S}1*E>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: Q1*S1*{ }
--------------------------------------------------------------------------------

-- Find the next S in m and copy it in r
function q21d()
    if m == 'S' then
        r = m
        right(m)
        right(r)
        goto q21e
    elseif m == '1' then
        right(m)
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q1*S{1*E}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: Q1*S1*S1*{ }
--------------------------------------------------------------------------------

-- Copy 1s from m to r
function q21e()
    if m == '1' then
        r = m
        right(m)
        right(r)
    elseif m == 'E' then
        left(r)
        goto q22
    end
end

--------------------------------------------------------------------------------
-- m: {(<Q1*S1*Q1*S1*[ED]>)+}
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: { S1*S1*Q1*}
--------------------------------------------------------------------------------

-- Go to the start of r
function q22()
    if r == nil then
        right(r)
        goto m1
    else
        left(r)
    end
end

--------------------------------
-- Find and Replace algorithm --
--------------------------------

--------------------------------------------------------------------------------
-- m: {(<Q1*S1*Q1*S1*[ED]>)+}
-- w: {(S1*)+Q1*(S1*)+ }
-- f: {S1*Q1*S1* }
-- r: {S1*S1*Q1* }
--    {Q1*S1*S1* }
--------------------------------------------------------------------------------

-- Match f in w and replace it with r
function m1()
    if f == nil then
        if w == nil then
            goto m4
        else
            if r == nil then
                left(w)
                left(r)
                goto m8
            else
                right(f)
                goto m12
            end
        end
    elseif w == f then
        w = r
        right(w)
        right(f)
        right(r)
    else
        left(w)
        left(f)
        left(r)
        goto m2
    end
end

-- Undo replacement of r in w
function m2()
    if f == nil then
        right(w)
        right(f)
        right(r)
        goto m3
    else
        w = f
        left(w)
        left(f)
        left(r)
    end
end

-- Skip one letter of w
function m3()
    right(w)
    goto m1
end

-- Copy r into w
function m4()
    if r == nil then
        goto m5
    else
        w = r
        right(w)
        right(r)
    end
end

-- Find the last letter of w, f and r
function m5()
    if w == nil then
        left(w)
    else
        if f == nil then
            left(f)
        else
            if r == nil then
                left(r)
            else
                goto m6
            end
        end
    end
end

-- Find the first letter of w
function m6()
    if w == nil then
        right(w)
        goto m7
    else
        left(w)
    end
end

-- Erase f and r from right to left
function m7()
    if f == nil then
        if r == nil then
            goto q1
        else
            r = nil
            left(r)
        end
    else
        f = nil
        left(f)
    end
end

-- Check if there is a gap in w
function m8()
    if w == nil then
        right(w)
        right(f)
        goto m9
    else
        goto m5
    end
end

-- Move w to f
function m9()
    if w == nil then
        left(w)
        left(f)
        goto m10
    else
        f = w
        w = nil
        right(w)
        right(f)
    end
end

-- Find first blank after w and first letter of f
function m10()
    if w == nil then
        left(w)
    else
        if f == nil then
            right(w)
            right(f)
            goto m11
        else
            left(f)
        end
    end
end

-- Move f to w
function m11()
    if f == nil then
        goto m5
    else
        w = f
        f = nil
        right(w)
        right(f)
    end
end

-- Copy w to f and r to w from left to right
function m12()
    if w == nil and r == nil then
        goto m13
    else
        f = w
        w = r
        right(w)
        right(f)
        right(r)
    end
end

-- Find first blank after w and last letter of f
function m13()
    if w == nil then
        left(w)
    else
        if f == nil then
            left(f)
        else
            right(w)
            goto m14
        end
    end
end

-- Find first letter of f
function m14()
    if f == nil then
        right(f)
        goto m15
    else
        left(f)
    end
end

-- Move f to w from left to right
function m15()
    if f == nil then
        goto m5
    else
        w = f
        f = nil
        right(w)
        right(f)
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {Q}1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {1}1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {S}1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {1}1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {Q}1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {1}1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {S}1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {1}1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
--    {E}>(<Q1*S1*Q1*S1*[ED]>)*
--    {D}>(<Q1*S1*Q1*S1*[ED]>)*
--    {>}(<Q1*S1*Q1*S1*[ED]>)*
--    { }
-- w: (S1*)+Q{1}(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Clean m
function f1()
    if m == nil then
        goto f2
    else
        m = nil
        right(m)
    end
end

--------------------------------------------------------------------------------
-- m: { }
-- w: (S1*)+Q{1}(S1*)*
--    (S1*)+{Q}1(S1*)*
--    (S1*)+{1}(S1*)*Q1(S1*)*
--    (S1*)*{S}1*(S1*)*Q1(S1*)*
--    { }(S1*)+Q1(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Go to the start of w
function f2()
    if w == nil then
        right(w)
        goto f3
    else
        left(w)
    end
end

--------------------------------------------------------------------------------
-- m: (S1*)*{ }
-- w: {S}1*(S1*)*Q1(S1*)*
--    {1}1*(S1*)*Q1(S1*)*
--    {Q}1(S1*)*
--    {S}1*(S1*)*
--    {1}1*(S1*)*
--    { }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Move w to m, ignoring 'Q1'
function f3()
    if w == nil then
        left(m)
        goto f5
    elseif w == 'Q' then
        w = nil
        right(w)
        goto f4
    else
        m = w
        w = nil
        right(m)
        right(w)
    end
end

--------------------------------------------------------------------------------
-- m: (S1*)+{ }
-- w: {1}(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Remove 1
function f4()
    w = nil
    right(w)
    goto f3
end

--------------------------------------------------------------------------------
-- m: { (S1*)+}
-- w: { }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Go to the start of m
function f5()
    if m == nil then
        right(m)
        goto halt
    else
        left(m)
    end
end

--------------------------------------------------------------------------------
-- m: {S}1*(S1*)*
-- w: { }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

function halt() end
