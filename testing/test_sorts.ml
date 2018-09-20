open OUnit2
open Sorts

let ins_sort_tests = [
  "ins empty" >:: (fun _ -> assert_equal [] (ins_sort []));
  (* add more glass box tests here *)
]

let suite = "test suite for sorts" >:::
  ins_sort_tests 
  
let _ = run_test_tt_main suite