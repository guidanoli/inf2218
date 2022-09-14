t = tape{'0', '1'}
function s0()
    if t == nil then
        goto s1
        left(t)
    else
        right(t)
    end
end
function s1()
    if t == '1' then
        t = '0'
        left(t)
    else
        t = '1'
        left(t)
        goto s2
    end
end
function s2()
    if t == nil then
        right(t)
        goto s3
    else
        left(t)
    end
end
function s3() end
