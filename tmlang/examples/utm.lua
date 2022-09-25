-------------------------------------------------------------------------------
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
function q1()
    if m == nil then
        left(m)
        goto q2
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
function q2()
    if m == '$' then
        m = nil
        w = 'Q'
        left(m)
        goto q3
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
function q3()
    if m == nil then
        right(m)
        goto q4
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
function q4()
    if w == 'Q' then
        left(w)
        goto q5
    elseif w == 'S' then
        goto q6
    end
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: { }Q1*(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Write left symbol
function q5()
    w = 'S'
    goto q6
end

--------------------------------------------------------------------------------
-- m: {<}Q1*S1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {(S1*)+Q}1*(S1*)*
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Find cursor
function q6()
    if w == 'Q' then
        right(w)
        goto q7
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
function q7()
    if w == '1' then
        right(w)
        goto q8
    elseif w == 'S' or w == nil then
        goto q9
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
function q8()
    if w == nil or w == 'S' then
        left(w)
        goto q51
    elseif w == '1' then
        right(w)
        goto q9
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
function q9()
    if w == 'S' then
        left(w)
        goto q10
    elseif w == nil then
        w = 'S'
        left(w)
        goto q10
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
function q10()
    if w == 'Q' then
        left(w)
        goto q11
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
function q11()
    if w == 'S' then
        f = w
        r = w
        goto q12
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
function q12()
    if w == 'Q' then
        goto q13
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
function q13()
    if f == nil then
        goto q14
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
function q14()
    if w == 'S' then
        f = w
        right(w)
        right(f)
        goto q15
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
function q15()
    if w == 'S' or w == nil then
        left(w)
        left(f)
        goto q16
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
function q16()
    if w == nil then
        right(w)
        goto q17
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
function q17()
    if f == nil then
        right(f)
        goto q18
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
function q18()
    if f == 'Q' then
        goto q19
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
function q19()
    if m == '<' then
        right(m)
        goto q20
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
function q20()
    if m == 'Q' and f == 'Q' then
        right(m)
        right(f)
        goto q21
    else
        goto q17
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q{1*S}1*Q1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: S1*Q{1*S}1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Match Q number and S
function q21()
    if m == '1' and f == '1' then
        right(m)
        right(f)
    elseif m == 'S' and f == 'S' then
        right(m)
        right(f)
        goto q22
    else
        goto q17
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S{1*Q}1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: S1*Q1*S{1* }
-- r: {S}1*
--------------------------------------------------------------------------------

-- Match S number and end
function q22()
    if m == '1' and f == '1' then
        right(m)
        right(f)
    elseif m == 'Q' and f == nil then
        left(f)
        goto q23
    else
        left(f)
        goto q17
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*{Q}1*S1*[ED]>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: { S1*Q1*S1*}
-- r: {S}1*
--------------------------------------------------------------------------------

-- Go to the start of f
function q23()
    if f == nil then
        right(f)
        goto q24
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
function q24()
    if m == 'D' then
        goto q25
    elseif m == 'E' then
        goto q30
    elseif m == 'S' or m == 'Q' or m == '1' then
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
function q25()
    if r == nil then
        goto q26
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
function q26()
    if m == 'S' then
        r = m
        right(r)
        right(m)
        goto q27
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
function q27()
    if m == '1' then
        r = m
        right(r)
        right(m)
    elseif m == 'D' then
        goto q28
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*{Q1*S1*D}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: S1*S1*{ }
--------------------------------------------------------------------------------

-- Go to the beggining of Q in m
function q28()
    if m == 'Q' then
        r = m
        right(r)
        right(m)
        goto q29
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
function q29()
    if m == '1' then
        r = m
        right(r)
        right(m)
    elseif m == 'S' then
        left(r)
        goto q35
    end
end

--------------------------------------------------------------------------------
-- m: (<Q1*S1*Q1*S1*[ED]>)*<Q1*S1*Q1*{S1*E}>(<Q1*S1*Q1*S1*[ED]>)*
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: {S}1*
--------------------------------------------------------------------------------

-- Find previous S in m
function q30()
    if m == 'S' then
        left(m)
        left(r)
        goto q31
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
function q31()
    if m == 'Q' then
        r = m
        right(m)
        right(r)
        goto q32
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
function q32()
    if r == nil then
        goto q33
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
function q33()
    if m == 'S' then
        r = m
        right(m)
        right(r)
        goto q34
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
function q34()
    if m == '1' then
        r = m
        right(m)
        right(r)
    elseif m == 'E' then
        left(r)
        goto q35
    end
end

--------------------------------------------------------------------------------
-- m: {(<Q1*S1*Q1*S1*[ED]>)+}
-- w: {S}1*(S1*)*Q1*(S1*)+
-- f: {S}1*Q1*S1*
-- r: { S1*S1*Q1*}
--------------------------------------------------------------------------------

-- Go to the start of r
function q35()
    if r == nil then
        right(r)
        goto q36
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
function q36()
    if f == nil then
        if w == nil then
            goto q39
        else
            if r == nil then
                left(w)
                left(r)
                goto q43
            else
                right(f)
                goto q47
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
        goto q37
    end
end

-- Undo replacement of r in w
function q37()
    if f == nil then
        right(w)
        right(f)
        right(r)
        goto q38
    else
        w = f
        left(w)
        left(f)
        left(r)
    end
end

-- Skip one letter of w
function q38()
    right(w)
    goto q36
end

-- Copy r into w
function q39()
    if r == nil then
        goto q40
    else
        w = r
        right(w)
        right(r)
    end
end

-- Find the last letter of w, f and r
function q40()
    if w == nil then
        left(w)
    else
        if f == nil then
            left(f)
        else
            if r == nil then
                left(r)
            else
                goto q41
            end
        end
    end
end

-- Find the first letter of w
function q41()
    if w == nil then
        right(w)
        goto q42
    else
        left(w)
    end
end

-- Erase f and r from right to left
function q42()
    if f == nil then
        if r == nil then
            goto q3
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
function q43()
    if w == nil then
        right(w)
        right(f)
        goto q44
    else
        goto q40
    end
end

-- Move w to f
function q44()
    if w == nil then
        left(w)
        left(f)
        goto q45
    else
        f = w
        w = nil
        right(w)
        right(f)
    end
end

-- Find first blank after w and first letter of f
function q45()
    if w == nil then
        left(w)
    else
        if f == nil then
            right(w)
            right(f)
            goto q46
        else
            left(f)
        end
    end
end

-- Move f to w
function q46()
    if f == nil then
        goto q40
    else
        w = f
        f = nil
        right(w)
        right(f)
    end
end

-- Copy w to f and r to w from left to right
function q47()
    if w == nil and r == nil then
        goto q48
    else
        f = w
        w = r
        right(w)
        right(f)
        right(r)
    end
end

-- Find first blank after w and last letter of f
function q48()
    if w == nil then
        left(w)
    else
        if f == nil then
            left(f)
        else
            right(w)
            goto q49
        end
    end
end

-- Find first letter of f
function q49()
    if f == nil then
        right(f)
        goto q50
    else
        left(f)
    end
end

-- Move f to w from left to right
function q50()
    if f == nil then
        goto q40
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
function q51()
    if m == nil then
        goto q52
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
function q52()
    if w == nil then
        right(w)
        goto q53
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
function q53()
    if w == nil then
        left(m)
        goto q55
    elseif w == 'Q' then
        w = nil
        right(w)
        goto q54
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
function q54()
    w = nil
    right(w)
    goto q53
end

--------------------------------------------------------------------------------
-- m: { (S1*)+}
-- w: { }
-- f: { }
-- r: { }
--------------------------------------------------------------------------------

-- Go to the start of m
function q55()
    if m == nil then
        right(m)
        goto q56
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

function q56() end
