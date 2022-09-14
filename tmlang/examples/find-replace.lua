w = tape{'a', 'b', 'c'}
f = tape{'a', 'b', 'c'}
r = tape{'a', 'b', 'c'}

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
            goto final
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

-- End of match
function final() end
