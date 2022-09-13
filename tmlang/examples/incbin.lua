t = tape{'0', '1'}
function s0()
    if t == BLANK then
        goto s1
        t.left()
    else
        t.right()
    end
end
function s1()
    if t == '1' then
        t = '0'
        t.left()
    else
        t = '1'
        t.left()
        goto s2
    end
end
function s2()
    if t == BLANK then
        t.right()
        goto s3
    else
        t.left()
    end
end
function s3() end
