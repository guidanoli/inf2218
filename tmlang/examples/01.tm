symbols 'a' 'b' 'c'
tapes t1 t2 t3
when s1 do pass end
when s2 do pass pass end
when s3 do pass if t1 = 'c' then pass pass else pass end end
when s4 do if t3 = 'a' then if t2 = 'b' then pass else pass end else pass end pass end
when s5 do t1 <- 'a' end
when s6 do t2 <- t3 end
when s7 do goto s3 end
when s8 do goto s8 end
when s9 do left t1 end
when s10 do left t1 right t2 end -- comment
-- comment
when s11 do if 'a' = t3 then pass else pass end end
when s12 do if 'a' = 'a' then pass else pass end end
when s13 do if t2 = t1 then pass else pass end end
