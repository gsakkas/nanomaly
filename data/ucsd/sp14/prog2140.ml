
type expr =
  | VarX
  | VarY
  | Sine of expr
  | Cosine of expr
  | Average of expr* expr
  | Times of expr* expr
  | Thresh of expr* expr* expr* expr;;

let pi = 4.0 *. (atan 1.0);;

let rec eval (e,x,y) =
  match e with
  | VarX  -> x
  | VarY  -> y
  | Sine e -> sin (pi *. (eval (e, x, y)))
  | Cosine e -> cos (pi *. (eval (e, x, y)))
  | Average (e1,e2) -> ((eval (e1, x, y)) +. (eval (e2, x, y))) /. 2.0
  | Times (e1,e2) -> (eval (e1, x, y)) *. (eval (e2, x, y))
  | Thresh (e1,e2,e3,e4) ->
      if (eval (e1, x, y)) < (eval (e2, x, y))
      then eval (e3, x, y)
      else eval (e4, x, y);;

let rec ffor (low,high,f) =
  if low > high then () else (let _ = f low in ffor ((low + 1), high, f));;

let toIntensity z = int_of_float (127.5 +. (127.5 *. z));;

let toReal (i,n) = (float_of_int i) /. (float_of_int n);;

type expr =
  | VarX
  | VarY
  | Sine of expr
  | Cosine of expr
  | Average of expr* expr
  | Times of expr* expr
  | Thresh of expr* expr* expr* expr
  | MyExpr1 of expr* expr* expr
  | MyExpr2 of expr;;

let buildAverage (e1,e2) = Average (e1, e2);;

let buildCosine e = Cosine e;;

let buildMyExpr1 (a,b,c) = MyExpr1 (a, b, c);;

let buildMyExpr2 e = MyExpr2 e;;

let buildSine e = Sine e;;

let buildThresh (a,b,a_less,b_less) = Thresh (a, b, a_less, b_less);;

let buildTimes (e1,e2) = Times (e1, e2);;

let buildX () = VarX;;

let buildY () = VarY;;

let rec build (rand,depth) =
  if depth = 0
  then buildX ()
  else
    (let randNum = rand (0, 8) in
     let depth = depth - 1 in
     match randNum with
     | 0 -> buildSine (build (rand, depth))
     | 1 -> buildCosine (build (rand, depth))
     | 2 -> buildTimes ((build (rand, depth)), (build (rand, depth)))
     | 3 -> buildAverage ((build (rand, depth)), (build (rand, depth)))
     | 4 -> buildY ()
     | 5 ->
         buildThresh
           ((build (rand, depth)), (build (rand, depth)),
             (build (rand, depth)), (build (rand, depth)))
     | 6 ->
         buildMyExpr1
           ((build (rand, depth)), (build (rand, depth)),
             (build (rand, depth)))
     | _ -> buildMyExpr2 (build (rand, depth)));;

let emitGrayscale (f,n,name) =
  let fname = "art_g_" ^ name in
  let chan = open_out (fname ^ ".pgm") in
  let n2p1 = (n * 2) + 1 in
  let _ = output_string chan (Format.sprintf "P5 %d %d 255\n" n2p1 n2p1) in
  let _ =
    ffor
      ((- n), n,
        (fun ix  ->
           ffor
             ((- n), n,
               (fun iy  ->
                  let x = toReal (ix, n) in
                  let y = toReal (iy, n) in
                  let z = f (x, y) in
                  let iz = toIntensity z in output_char chan (char_of_int iz))))) in
  close_out chan;
  ignore (Sys.command ("convert " ^ (fname ^ (".pgm " ^ (fname ^ ".jpg")))));
  ignore (Sys.command ("rm " ^ (fname ^ ".pgm")));;

let eval_fn e (x,y) =
  let rv = eval (e, x, y) in assert (((-1.0) <= rv) && (rv <= 1.0)); rv;;

let rec exprToString ex =
  match ex with
  | VarX  -> "x"
  | VarY  -> "y"
  | Sine e -> "sin(pi*" ^ ((exprToString e) ^ ")")
  | Cosine e -> "cos(pi*" ^ ((exprToString e) ^ ")")
  | Average (e1,e2) ->
      "((" ^ ((exprToString e1) ^ (" + " ^ ((exprToString e2) ^ ")/2)")))
  | Times (e1,e2) -> (exprToString e1) ^ ("*" ^ (exprToString e2))
  | Thresh (e1,e2,e3,e4) ->
      "(" ^
        ((exprToString e1) ^
           ("<" ^
              ((exprToString e2) ^
                 ("?" ^
                    ((exprToString e3) ^ (":" ^ ((exprToString e4) ^ ")")))))))
  | MyExpr1 (e1,e2,e3) ->
      "(sqrt(" ^
        ((exprToString e1) ^
           (")*sqrt(" ^
              ((exprToString e2) ^ (")*" ^ ((exprToString e3) ^ ")")))))
  | MyExpr2 e -> "halve(" ^ ((exprToString e) ^ ")");;

let makeRand (seed1,seed2) =
  let seed = Array.of_list [seed1; seed2] in
  let s = Random.State.make seed in
  fun (x,y)  -> x + (Random.State.int s (y - x));;

let doRandomGray (depth,seed1,seed2) =
  let g = makeRand (seed1, seed2) in
  let e = build (g, depth) in
  let _ = print_string (exprToString e) in
  let f = eval_fn e in
  let n = 150 in
  let name = Format.sprintf "%d_%d_%d" depth seed1 seed2 in
  emitGrayscale (f, n, name);;