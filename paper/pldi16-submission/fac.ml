let rec fac n =
  if n <= 0 then
    true
  else
    n * fac (n-1)
