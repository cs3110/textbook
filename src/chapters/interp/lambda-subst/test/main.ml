open OUnit2
open Interp
open Main

(** [make n s1 s2] makes an OUnit test named [n] that expects
    [s2] to evalute to [s1]. *)
let make n s1 s2 =
  n >:: (fun _ -> assert_equal (parse s1) (interp s2))

(** [make_unbound_err n s] makes an OUnit test named [n] that
    expects [s] to produce an unbound variable error. *)
let make_unbound_err n s =
  n >:: (fun _ -> assert_raises (Failure unbound_var_err) (fun () -> interp s))

let tests = [
  make "reduce correct"
    "fun y -> y"
    "(fun x -> x) (fun y -> y)";
  make "shadowing correct"
    "fun a -> fun b -> b"
    "(fun x -> fun x -> x) (fun a -> fun b -> a) (fun a -> fun b -> b)";
  make_unbound_err "capture avoiding correct"
    "((fun x -> (fun z -> x)) z) (fun x -> x)";
]

let _ = run_test_tt_main ("suite" >::: tests)
