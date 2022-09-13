t
=
{
    '0'
    ,
    '1'
}
while s0 do
    if t == blank then
        goto s1
        left(t)
    else
        right(t)
    end
end
while s1 do
    if t == '1' then
        t = '0'
        left(t)
    else
        t = '1'
        goto s2
    end
end
while s2 do end
