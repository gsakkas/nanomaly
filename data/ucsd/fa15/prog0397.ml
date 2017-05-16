
let rec sepConcat sep sl =
  match sl with
  | [] -> ""
  | h::t ->
      let f a x x' = a ^ (x' ^ x) in
      let base = h in let l = sl in List.fold_left f base l;;
