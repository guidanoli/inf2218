w = tape{'a', 'b', 'c'}
f = tape{'a', 'b', 'c'}
r = tape{'a', 'b', 'c'}

function matching()
    if f == BLANK then
        if w == BLANK then
            goto copy_r
        else
            if r == BLANK then
                left(w)
                left(r)
                goto check_w_blank
            else
                right(f)
                goto w2f_and_r2w
                -- insert rest of r in the middle of w
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
        goto undo
    end
end

function undo()
    if f == BLANK then
        right(w)
        right(f)
        right(r)
        goto skip_w
    else
        left(w)
        left(f)
        left(r)
    end
end

function skip_w()
    right(w)
    goto matching
end

function copy_r()
    if r == BLANK then
        goto find_ends
    else
        w = r
        right(w)
        right(r)
    end
end

function find_ends()
    if w == BLANK then
        left(w)
    else
        if f == BLANK then
            left(f)
        else
            if r == BLANK then
                left(r)
            else
                goto find_wstart
            end
        end
    end
end

function find_wstart()
    if w == BLANK then
        right(w)
        goto erase_fr
    else
        left(w)
    end
end

function erase_fr()
    if f == BLANK then
        if r == BLANK then
            goto final
        else
            r = BLANK
            left(r)
        end
    else
        f = BLANK
        left(f)
    end
end

function check_w_blank()
    if w == BLANK then
        right(w)
        right(f)
        goto move_w_to_f
    else
        goto find_ends
    end
end

function move_w_to_f()
    if w == BLANK then
        left(w)
        left(f)
        goto wend_and_fstart
    else
        f = w
        w = BLANK
        right(w)
        right(f)
    end
end

function wend_and_fstart()
    if w == BLANK then
        left(w)
    else
        if f == BLANK then
            right(w)
            right(f)
            goto move_f_to_w
        else
            left(f)
        end
    end
end

function move_f_to_w()
    if f == BLANK then
        goto find_ends
    else
        w = f
        f = BLANK
        right(w)
        right(f)
    end
end

function w2f_and_r2w()
    if w == BLANK and r == BLANK then
        goto find_wend_and_fend
    else
        f = w
        w = r
        right(w)
        right(f)
        right(r)
    end
end

function find_wend_and_fend()
    if w == BLANK then
        left(w)
    else
        if f == BLANK then
            left(f)
        else
            right(w)
            goto find_fstart
        end
    end
end

function find_fstart()
    if f == BLANK then
        right(f)
        goto move_f2w
    else
        left(f)
    end
end

function move_f2w()
    if f == BLANK then
        goto find_ends
    else
        w = f
        f = BLANK
        right(w)
        right(f)
    end
end

function final()
end
