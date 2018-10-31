open OUnit2
open Ast
open Main

(* A few test cases *)
let tests = [
  "int"  >:: (fun _ -> assert_equal (Int 22) (interp "22"));
  "add"  >:: (fun _ -> assert_equal (Int 22) (interp "11+11"));
  "adds" >:: (fun _ -> assert_equal (Int 22) (interp "(10+1)+(5+6)"));
  "let"  >:: (fun _ -> assert_equal (Int 22) (interp "let x=22 in x"));
  "lets" >:: (fun _ -> assert_equal (Int 22) (interp "let x = 0 in let x = 22 in x"));
  "mul1"  >:: (fun _ -> assert_equal (Int 22) (interp "2*11"));
  "mul2"  >:: (fun _ -> assert_equal (Int 22) (interp "2+2*10"));
  "mul3"  >:: (fun _ -> assert_equal (Int 14) (interp "2*2+10"));
  "mul4"  >:: (fun _ -> assert_equal (Int 40) (interp "2*2*10"));
  "if1"  >:: (fun _ -> assert_equal (Int 22) (interp "if true then 22 else 0"));
  "true" >:: (fun _ -> assert_equal (Bool true) (interp "true"));
  "leq" >:: (fun _ -> assert_equal (Bool true) (interp "1<=1"));
  "if2" >:: (fun _ -> assert_equal (Int 22) (interp "if 1+2 <= 3+4 then 22 else 0"));
  "if3" >:: (fun _ -> assert_equal (Int 22) (interp "if 1+2 <= 3*4 then let x = 22 in x else 0"));
  "letif" >:: (fun _ -> assert_equal (Int 22) (interp "let x = 1+2 <= 3*4 in if x then 22 else 0"));  
]

let _ = run_test_tt_main ("suite" >::: tests)
