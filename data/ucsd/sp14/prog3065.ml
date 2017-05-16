
let rec digitsOfInt n =
  if n < 0
  then []
  else if n == 0 then [] else (digitsOfInt (n / 10)) :: (n % 10);;
