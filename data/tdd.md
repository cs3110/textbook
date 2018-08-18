# Test-driven Development

Testing doesn't have to happen strictly after you write code. In
*test-driven development* (TDD), testing comes first! It emphasizes
*incremental* development of code: there is always something that can be
tested. Testing is not something that happens after implementation;
instead, *continuous testing* is used to catch errors early. Thus, it is
important to develop unit tests immediately when the code is written.
Automating test suites is crucial so that continuous testing requires
essentially no effort.

Here's an example of TDD.  We deliberately choose an exceedingly simple
function to implement, so that the process is clear.  Suppose we are
working with a datatype for days:

    type day = Sunday | Monday | Tuesday | Wednesday 
             | Thursday | Friday | Saturday

And we want to write a function `next_weekday : day -> day` that returns
the next weekday after a given day. We start by writing the most basic,
broken version of that function we can:

    let next_weekday d = failwith "Unimplemented"

Then we write the simplest unit test we can imagine. For example,
we know that the next weekday after Monday is Tuesday. So we add a test:

```
let tests = "test suite for next_weekday" >::: [
  "tue_after_mon"  >:: (fun _ -> assert_equal (next_weekday Monday) Tuesday);
]
```

Then we run the OUnit test suite.  It fails, as expected.  That's good!
Now we have a concrete goal, to make that unit test pass. We revise
`next_weekday` to make that happen:

    let next_weekday d = 
      match d with 
      | Monday -> Tuesday
      | _ -> failwith "Unimplemented"

We compile and run the test; it passes. Time to add some more tests.
The simplest remaining possibilities are tests involving just weekdays,
rather than weekends.  So let's add tests for weekdays.

```
let tests = "test suite for next_weekday" >::: [
  "tue_after_mon"  >:: (fun _ -> assert_equal (next_weekday Monday) Tuesday);
  "wed_after_tue"  >:: (fun _ -> assert_equal (next_weekday Tuesday) Wednesday);
  "thu_after_wed"  >:: (fun _ -> assert_equal (next_weekday Wednesday) Thursday);
  "fri_after_thu"  >:: (fun _ -> assert_equal (next_weekday Thursday) Friday);
]
```

We compile and run the tests; many fail. That's good! We add new
functionality:

    let next_weekday d = 
      match d with 
      | Monday -> Tuesday
      | Tuesday -> Wednesday
      | Wednesday -> Thursday
      | Thursday -> Friday
      | _ -> failwith "Unimplemented"

We compile and run the tests; they pass.  At this point we could move
on to handling weekends, but we should first notice something about
the tests we've written:  they involve repeating a lot of code.
In fact, we probably wrote them by copying-and-pasting the first
test, then modifying it for the next three.  That's a sign that
we should *refactor* the code.  (As we did before with the `sum`
function we were testing.)

Let's abstract a function that creates test cases for `next_weekday`:

```
let make_next_weekday_test name expected_output input= 
  name >:: (fun _ -> assert_equal expected_output (next_weekday input))
  
let tests = "test suite for next_weekday" >::: [
  make_next_weekday_test "tue_after_mon" Tuesday Monday;
  make_next_weekday_test "wed_after_tue" Wednesday Tuesday;
  make_next_weekday_test "thu_after_wed" Thursday Wednesday;
  make_next_weekday_test "fri_after_thu" Friday Thursday;
]
```

Now we finish the testing and implementation by handling weekends.
First we add some test cases:
```
  ...
  make_next_weekday_test "mon_after_fri" Monday Friday;
  make_next_weekday_test "mon_after_sat" Monday Saturday;
  make_next_weekday_test "mon_after_sun" Monday Sunday;
  ...
```

Then we finish the function:

```
let next_weekday = 
  match d with 
  | Monday -> Tuesday
  | Tuesday -> Wednesday
  | Wednesday -> Thursday
  | Thursday -> Friday
  | Friday -> Monday
  | Saturday -> Monday
  | Sunday -> Monday
```

Of course, most people could write that function without errors
even if they didn't use TDD.  But rarely do we implement functions
that are so simple.

**Process.** Let's review the process of TDD:

- Write a failing unit test case.
  Run the test suite to prove that the test case fails.
- Implement just enough functionality to make the test case pass.
  Run the test suite to prove that the test case passes.
- Improve code as needed.  In the example above we refactored
  the test suite, but often we'll need to refactor the
  functionality being implemented.
- Repeat until you are satisfied that the test suite provides
  evidence that your implementation is correct.

