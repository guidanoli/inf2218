symbols 'a' 'b' 'c'
tapes t1 t2 t3
when s1 do pass end
when s2 do pass pass end
when s3 do pass if t1 = 'c' then pass pass else pass end end
when s3 do if t3 = 'a' then if t2 = 'b' then pass else pass end else pass end pass end
