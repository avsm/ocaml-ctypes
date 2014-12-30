(*
 * Copyright (c) 2013-2014 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open OUnit2
open Ctypes


module Common_tests(S : Cstubs.FOREIGN with type 'a fn = 'a) =
struct
  module M = Functions.Stubs(S)
  open M

  (*
    Retrieve a struct exposed as a global value. 
  *)
  let test_retrieving_struct _ =
    let p = CArray.start (getf !@global_struct str) in
    let stringp = from_voidp string (to_voidp (allocate (ptr char) p)) in
    begin
      let expected = "global string" in
      assert_equal expected !@stringp;
      assert_equal
        (Unsigned.Size_t.of_int (String.length expected))
        (getf !@global_struct len)
    end


  (*
    Store a reference to an OCaml function as a global function pointer.
  *)
  let test_global_callback _ =
    begin
      assert_equal !@plus None;

      plus <-@ Some (+);

      assert_equal (sum 1 10) 55;

      plus <-@ None;
    end
end


module Foreign_tests = Common_tests(Tests_common.Foreign_binder)
module Stub_tests = Common_tests(Generated_bindings)


let suite = "Foreign value tests" >:::
  ["retrieving global struct (foreign)"
    >:: Foreign_tests.test_retrieving_struct;

   "global callback function (foreign)"
    >:: Foreign_tests.test_global_callback;

   "retrieving global struct (stubs)"
    >:: Stub_tests.test_retrieving_struct;

   "global callback function (stubs)"
    >:: Stub_tests.test_global_callback;
  ]


let _ =
  run_test_tt_main suite
